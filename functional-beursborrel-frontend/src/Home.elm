module Home exposing (Model (..), Msg (..), init, subscriptions, update, view, exit)

import Element exposing (Element, text, column)
import Element.Input as Input
import Drink exposing (DrinkList, drinkListDecoder)
import List exposing (map)
import Session
import Http
import String exposing (fromFloat)


type Msg
    = None
    | GotDrinks (Result Http.Error (DrinkList))
    | Update


type Model
    = Failure Session.Data
    | Loading Session.Data
    | Success Session.Data (DrinkList)


init : Session.Data -> (Model, Cmd Msg)
init data =
    ( Loading data
    , getDrinks
    )


exit : Model -> Session.Data
exit model =
    case model of
        Failure data ->
            data
    
        Loading data ->
            data

        Success data _ ->
            data


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        None ->
            (model, Cmd.none)
            
        Update ->
            (Loading (exit model), getDrinks)

        GotDrinks result ->
            case result of
                Ok drinks ->
                    (Success (exit model) drinks, Cmd.none)
                
                Err _ ->
                    (Failure (exit model), Cmd.none)


view : Model -> (String, List (Element Msg))
view model =
    ( "Beursborrel"
    , [ renderDrinks model
      , Input.button [] { onPress = Just Update, label = text "Update prices" }
      ]
    )


renderDrinks : Model -> Element Msg
renderDrinks model =
    case model of
        Failure _ ->
            text "Could not load drinks"
        
        Loading _ ->
            text "Loading drinks..."

        Success _ drinks ->
            column [] (map renderDrink drinks)


renderDrink : Drink.Data -> Element Msg
renderDrink drink =
    text (drink.name ++ " costs " ++ fromFloat drink.price)


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


getDrinks : Cmd Msg
getDrinks =
    Http.get
        { url = "http://localhost:8080/drink"
        , expect = Http.expectJson GotDrinks drinkListDecoder
        }