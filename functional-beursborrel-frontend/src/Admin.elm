module Admin exposing (Model (..), Msg (..), init, subscriptions, view, exit)

import Drink exposing (DrinkList, drinkListDecoder, drinkDecoder)
import Order exposing (OrderList)
import Session
import Element exposing (Element, text)
import Element.Input as Input
import Urls
import Http

type Msg
    = None
    | GotDrinks (Result Http.Error (DrinkList))
    | Update


type Model
    = Failure Session.Data
    | Loading Session.Data
    | Login Session.Data
    | Order Session.Data DrinkList OrderList


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
            
        Login data ->
            data
            
        Order data _ _ ->
            data


view : Model -> (String, List (Element Msg))
view model =
    case model of
        Order _ drinks order ->
            ( "Admin - Order"
            , [ renderOrder drinks order
            , Input.button [] { onPress = Just Update, label = text "Update prices" } 
            ]
            )

        _ ->
            ( "Admin - Error"
            , [ text "Something went wrong!"
              ] 
            )


renderOrder : DrinkList -> OrderList -> Element Msg
renderOrder drinks order =
    text "test"



subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


getDrinks : Cmd Msg
getDrinks =
    Http.get
        { url = Urls.drinkUrl
        , expect = Http.expectJson GotDrinks drinkListDecoder 
        }