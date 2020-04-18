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

-- Logging
import Control.Monad.IO.Class (MonadIO)
import Control.Monad.Logger

-- Models
share
    [mkPersist sqlSettings, mkMigrate "migrateAll"]
    [persistLowerCase|
Drink json
    name Text
    description Text
    minPrice Double Maybe
    deriving Show
BoughtDrink json
    drinkId DrinkId
    deriving Show
|]

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
    -- drinks
    get "drink" $ do
        -- Return all drinks
        allDrinks <- runSQL $ selectList [] [Asc DrinkId]
        json allDrinks
    post "drink" $ do
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
    get ("drink" <//> var) $ \drinkId -> do
        -- Return specific drink
        maybeDrink <- runSQL $ P.get drinkId :: ApiAction (Maybe Drink)
        case maybeDrink of
            Nothing -> do
                setStatus notFound404
                errorJson 2 "Could not find a drink with matching id"
            Just theDrink -> json theDrink

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
