module Admin exposing (Model (..), Msg (..), init, subscriptions, update, view, exit)

import Drink exposing (DrinkList, drinkListDecoder, drinkDecoder)
import Order exposing (OrderList)
import Session
import Element exposing (Element, text)
import Element.Input as Input
import Urls
import Maybe exposing (Maybe, withDefault)
import Http

type Msg
    = None
    | GotDrinks (Result Http.Error (DrinkList))
    | Update


type Model
    = Failure Session.Data (Maybe DrinkList) (Maybe OrderList)
    | Loading Session.Data (Maybe DrinkList) (Maybe OrderList)
    | Login Session.Data
    | Order Session.Data DrinkList OrderList


init : Session.Data -> Maybe DrinkList -> (Model, Cmd Msg)
init data maybeDrinks =
    ( Loading data maybeDrinks Nothing
    , getDrinks
    )


exit : Model -> Session.Data
exit model =
    case model of
        Failure data _ _ ->
            data
            
        Loading data _ _ ->
            data
            
        Login data ->
            data
            
        Order data _ _ ->
            data


exitDrinks : Model -> Maybe DrinkList
exitDrinks model = 
    case model of
        Failure _ maybeDrinks _ ->
            maybeDrinks
        
        Loading _ maybeDrinks _ ->
            maybeDrinks

        Order _ drinks _ ->
            Just drinks

        _ ->
            Nothing


exitOrders : Model -> Maybe OrderList
exitOrders model =
    case model of
        Failure _ _ maybeOrders ->
            maybeOrders

        Loading _ _ maybeOrders ->
            maybeOrders

        Order _ _ orders ->
            Just orders

        _ ->
            Nothing


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


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        GotDrinks result ->
            case result of
                Ok drinks ->
                    let
                        orders =
                            withDefault (Order.new []) (exitOrders model)
                    in
                    (Order (exit model) drinks orders, Cmd.none)
                
                Err _ ->
                    (Failure (exit model) (exitDrinks model) (exitOrders model), Cmd.none)

        Update ->
            (model, getDrinks)

        _ ->
            (model, Cmd.none)
