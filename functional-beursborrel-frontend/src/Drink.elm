module Drink exposing (Data, DrinkList, drinkListDecoder, drinkDecoder)

import Json.Decode exposing (Decoder, list, string, float, int, succeed)
import Json.Decode.Pipeline exposing (required)

type alias Data =
    { id: Int
    , name : String
    , minPrice : Float
    , startPrice : Float
    , price : Float
    }

type alias DrinkList =
    List Data

drinkListDecoder : Decoder DrinkList
drinkListDecoder =
    list drinkDecoder


drinkDecoder : Decoder Data
drinkDecoder =
    succeed Data
        |> required "id" int
        |> required "name" string
        |> required "minPrice" float
        |> required "startPrice" float
        |> required "startPrice" float
