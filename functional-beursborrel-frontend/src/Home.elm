module Home exposing (Model, Msg, init, subscriptions, update, view)

import Element exposing (Element, text, column)
import Element.Input as Input
import Drink exposing (DrinkList)
import Fetch exposing (getDrinks)
import List exposing (map)
import String exposing (fromFloat)


type Model
    = Failure
    | Loading
    | Success (DrinkList)


type Msg
    = None
    | Update


init : () -> (Model, Cmd Msg)
init _ =
    ( Loading
    , getDrinks
    )


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        None ->
            (model, Cmd.none)
            
        Update ->
            (Loading, getDrinks)

        GotDrinks result ->
            case result of
                Ok drinks ->
                    (Success drinks, Cmd.none)
                
                Err _ ->
                    (Failure, Cmd.none)


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
        Failure ->
            text "Could not load drinks"
        
        Loading ->
            text "Loading drinks..."

        Success drinks ->
            column [] (map renderDrink drinks)


renderDrink : Drink.Data -> Element Msg
renderDrink drink =
    text (drink.name ++ " costs " ++ fromFloat drink.price)


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
