module Home exposing (Model (..), Msg (..), init, subscriptions, update, view, exit)

import Element exposing (Element, text, column, table, fill)
import Element.Input as Input
import Drink exposing (DrinkList, drinkListDecoder)
import Session
import Http
import Urls
import Time
import String exposing (fromFloat)


type Msg
    = None
    | GotDrinks (Result Http.Error (DrinkList))
    | Update


type Model
    = Failure Session.Data (Maybe DrinkList)
    | Loading Session.Data (Maybe DrinkList)
    | Success Session.Data DrinkList


init : Session.Data -> (Model, Cmd Msg)
init data =
    ( Loading data Nothing
    , getDrinks
    )


exit : Model -> Session.Data
exit model =
    case model of
        Failure data _ ->
            data
    
        Loading data _ ->
            data

        Success data _ ->
            data


exitDrinks : Model -> Maybe DrinkList
exitDrinks model =
    case model of
        Success _ drinks ->
            Just drinks
        
        Loading _ maybeDrinks ->
            maybeDrinks

        Failure _ maybeDrinks ->
            maybeDrinks


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        None ->
            (model, Cmd.none)
            
        Update ->
            (Loading (exit model) (exitDrinks model), getDrinks)

        GotDrinks result ->
            case result of
                Ok drinks ->
                    (Success (exit model) drinks, Cmd.none)
                
                Err _ ->
                    (Failure (exit model) (exitDrinks model), Cmd.none)


view : Model -> (String, List (Element Msg))
view model =
    ( "Beursborrel"
    , [ case model of
            Success _ drinks ->
                renderDrinks drinks
            
            Loading _ Nothing ->
                text "Loading drinks"

            Loading _ (Just drinks) ->
                column []
                [ renderDrinks drinks
                , text "Updating prices..."
                ]

            Failure _ (Just drinks) ->
                column []
                [ renderDrinks drinks
                , text "Could not update prices; they may be outdated."
                ]

            Failure _ Nothing ->
                text "Failed to load drinks"
      , Input.button [] { onPress = Just Update, label = text "Update prices" }
      ]
    )


renderDrinks : DrinkList -> Element Msg
renderDrinks drinks =
    table [] 
    { data = drinks
    , columns =
        [ { header = text "Item"
            , width = fill
            , view =
                \drink ->
                    text drink.name
            }
        , { header = text "Price"
            , width = fill
            , view =
                \drink ->
                    text (fromFloat drink.price)
            }
        ]                
    }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Time.every (10 * 1000) <| always Update


getDrinks : Cmd Msg
getDrinks =
    Http.get
        { url = Urls.drinkUrl
        , expect = Http.expectJson GotDrinks drinkListDecoder
        }