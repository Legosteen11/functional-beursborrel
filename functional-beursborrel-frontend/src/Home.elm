module Home exposing (Model, Msg, init, subscriptions, update, view)

import Element exposing (Element, text, column, row)
import Element.Input as Input
import Drink
import Http
import List exposing (map)
import String exposing (fromFloat)
import Json.Decode exposing (Decoder, list, string, float, int, succeed)
import Json.Decode.Pipeline exposing (required)

type alias DrinkList =
    List Drink.Data


type Model
    = Failure
    | Loading
    | Success (DrinkList)

type Msg
    = None
    | GotDrinks (Result Http.Error DrinkList)
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

getDrinks : Cmd Msg
getDrinks =
    Http.get
        { url = "/drink"
        , expect = Http.expectJson GotDrinks drinkListDecoder
        }


drinkListDecoder : Decoder DrinkList
drinkListDecoder =
    list drinkDecoder


drinkDecoder : Decoder Drink.Data
drinkDecoder =
    succeed Drink.Data
        |> required "id" int
        |> required "name" string
        |> required "minPrice" float
        |> required "startPrice" float
        |> required "startPrice" float


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


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
