{-# LANGUAGE DeriveGeneric              #-}
{-# LANGUAGE EmptyDataDecls             #-}
{-# LANGUAGE FlexibleContexts           #-}
{-# LANGUAGE FlexibleInstances          #-}
{-# LANGUAGE GADTs                      #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses      #-}
{-# LANGUAGE OverloadedStrings          #-}
{-# LANGUAGE QuasiQuotes                #-}
{-# LANGUAGE TemplateHaskell            #-}
{-# LANGUAGE TypeFamilies               #-}
{-# LANGUAGE DerivingStrategies         #-}
{-# LANGUAGE StandaloneDeriving         #-}
{-# LANGUAGE UndecidableInstances       #-}

-- Spock
import Web.Spock
import Web.Spock.Config
import Network.HTTP.Types.Status
import Network.Wai                       (Middleware)
import Network.Wai.Middleware.AddHeaders (addHeaders)
import Network.Wai.Middleware.Cors       (CorsResourcePolicy(..), cors)

-- Text and JSON data
import Data.Aeson hiding (json)
import Data.Monoid hiding ((<>))
import Data.Text (Text, pack)
import Data.Text.Encoding (decodeUtf8)
import GHC.Generics

-- Persistance
import Database.Persist hiding (delete, get)
import qualified Database.Persist as P
import Database.Persist.Sqlite hiding (delete, get)
import Database.Persist.TH
import Network.HTTP.Types.Status

-- Time
import Data.Time.Clock
import Data.Fixed

-- Logging
import Control.Monad.IO.Class (MonadIO, liftIO)
import Control.Monad.Logger

-- List
import Data.List (nub)
import Data.List.Extra (groupSort, nubOrdOn)

-- Models
share
    [mkPersist sqlSettings, mkMigrate "migrateAll"]
    [persistLowerCase|
Drink json
    name Text
    description Text
    startPrice Double
    minPrice Double Maybe
    deriving Show
BoughtDrink json
    drinkId DrinkId
    price Double
    amount Int
    time UTCTime
    deriving Show
|]

-- JSON
data Item = Item
    {   id :: Int
    ,   amount :: Int
    } deriving (Generic, Show)

instance ToJSON Item

instance FromJSON Item

data Order = Order
    {   drinks :: [Item]
    } deriving (Generic, Show)

instance ToJSON Order

instance FromJSON Order

type Api = SpockM SqlBackend () () ()

type ApiAction a = SpockAction SqlBackend () () a

main :: IO ()
main = do
    pool <- runStdoutLoggingT $ createSqlitePool "api.db" 5
    spockCfg' <- defaultSpockCfg () (PCPool pool) ()
    let spockCfg = spockCfg' {spc_errorHandler = jsonErrorHandler}
    runStdoutLoggingT $ runSqlPool (do runMigration migrateAll) pool
    runSpock 8080 (spock spockCfg app)

app :: SpockM SqlBackend () () ()
app = do
    middleware allowCsrf
    middleware corsified
    -- drinks
    get "drink" $ do
        -- Return all drinks
        allDrinks <- runSQL $ selectList [] [Asc DrinkId]
        json allDrinks
    get ("drink" <//> var) $ \drinkId -> do
        -- Return specific drink
        maybeDrink <- runSQL $ P.get drinkId :: ApiAction (Maybe Drink)
        case maybeDrink of
            Nothing -> do
                setStatus notFound404
                errorJson 2 "Could not find a drink with matching id"
            Just theDrink -> json theDrink
    get "price" $ do
        -- Return prices for drinks
        boughtDrinks <- runSQL $ selectList [] [Desc BoughtDrinkTime, LimitTo 2]
        currTime <- liftIO getCurrentTime
        -- TODO Fetch default and minprice
        let price = calculatePrice TimeDiffBasedPrice 0.50 0.50 boughtDrinks currTime
        json $ object ["price" .= price]
    post "admin/order" $ do
        -- Place an order for drinks
        maybeOrder <- jsonBody :: ApiAction (Maybe Order)
        case maybeOrder of
            Nothing -> do
                setStatus badRequest400
                errorJson 1 "Invalid JSON"
            Just theOrder -> do
                boughtDrinkList <- runSQL $ selectList [] [Desc BoughtDrinkTime]
                let prices = nubOrdOn (\(identifier, _) -> identifier) $ groupSort $ map (\(Entity _ e) -> (boughtDrinkDrinkId e, e)) boughtDrinkList
                json $ object ["price" .= (0.5 :: Double)]
    post "admin/drink" $ do
        -- Insert new drink
        maybeDrink <- jsonBody :: ApiAction (Maybe Drink)
        case maybeDrink of
            Nothing -> do
                setStatus badRequest400
                errorJson 1 "Invalid JSON"
            Just theDrink -> do
                newId <- runSQL $ insert theDrink
                setStatus created201
                json $ object ["result" .= String "success", "id" .= newId]

data PriceAlgorithm = ConstantPrice | TimeDiffBasedPrice

calculatePrice :: PriceAlgorithm -> Double -> Double -> [Entity BoughtDrink] -> UTCTime-> Double

calculatePrice ConstantPrice defaultPrice _ _ _ = defaultPrice

calculutePrice TimeDiffBasedPrice startPrice minPrice boughtDrinks currTime
    | (length boughtDrinks) >= 2 = max minPrice (calcP (boughtDrinks !! 0) (boughtDrinks !! 1) currTime)
    | otherwise = startPrice

timeDiffRatio :: UTCTime -> UTCTime -> UTCTime -> Double
timeDiffRatio a b curr = fromRational $ abDiff / aCurrTimeDiff
    where   abDiff = toRational $ diffUTCTime a b
            aCurrTimeDiff = toRational $ diffUTCTime a curr

calcP :: Entity BoughtDrink -> Entity BoughtDrink -> UTCTime -> Double
calcP (Entity _ a) (Entity _ b) currTime = timeDiffRatio (boughtDrinkTime a) (boughtDrinkTime b) currTime

runSQL :: (HasSpock m, SpockConn m ~ SqlBackend)
    =>  SqlPersistT (LoggingT IO) a -> m a
runSQL action = runQuery $ \conn -> runStdoutLoggingT $ runSqlConn action conn

errorJson :: MonadIO m => Int -> Text -> ActionCtxT ctx m ()
errorJson code message =
    json $
    object
        [   "result" .= String "Failure"
        ,   "error" .= object ["code" .= code, "message" .= message]
        ]

jsonErrorHandler :: Status -> ActionCtxT ctx IO ()
jsonErrorHandler (Status code message) = errorJson code (decodeUtf8 message)


-- Copied from https://stackoverflow.com/questions/41399055/haskell-yesod-cors-problems-with-browsers-options-requests-when-doing-post-req
-- | @x-csrf-token@ allowance.
-- The following header will be set: @Access-Control-Allow-Headers: x-csrf-token@.
allowCsrf :: Middleware
allowCsrf = addHeaders [("Access-Control-Allow-Headers", "x-csrf-token,authorization")]

-- | CORS middleware configured with 'appCorsResourcePolicy'.
corsified :: Middleware
corsified = cors (const $ Just appCorsResourcePolicy)

-- | Cors resource policy to be used with 'corsified' middleware.
--
-- This policy will set the following:
--
-- * RequestHeaders: @Content-Type@
-- * MethodsAllowed: @OPTIONS, GET, PUT, POST@
appCorsResourcePolicy :: CorsResourcePolicy
appCorsResourcePolicy = CorsResourcePolicy {
    corsOrigins        = Nothing
  , corsMethods        = ["OPTIONS", "GET", "PUT", "POST"]
  , corsRequestHeaders = ["Authorization", "Content-Type"]
  , corsExposedHeaders = Nothing
  , corsMaxAge         = Nothing
  , corsVaryOrigin     = False
  , corsRequireOrigin  = False
  , corsIgnoreFailures = False
}
