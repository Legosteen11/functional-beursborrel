module Order exposing (Data, OrderList, new)

import List exposing (map)

type alias Data =
    { id : Int
    , amount : Int
    }


type alias OrderList =
    { drinks : List Data
    }


new : List (Int, Int) -> OrderList
new order =
    { drinks = map (\(id, amount) -> { id = id, amount = amount }) order
    }