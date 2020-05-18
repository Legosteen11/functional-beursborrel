module Fetch exposing (getDrinks)

import Http
import Msg exposing (Msg)
import Json.Decode exposing (Decoder, list, string, float, int, succeed)
import Json.Decode.Pipeline exposing (required)
import Drink exposing (DrinkList)

getDrinks : Cmd Msg
getDrinks =
    Http.get
        { url = "/drink"
        , expect = Http.expectJson Msg.GotDrinks drinkListDecoder
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
