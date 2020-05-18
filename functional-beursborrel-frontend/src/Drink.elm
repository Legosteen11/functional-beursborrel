module Drink exposing (Data, DrinkList)

type alias Data =
    { id: Int
    , name : String
    , minPrice : Float
    , startPrice : Float
    , price : Float
    }

type alias DrinkList =
    List Data
