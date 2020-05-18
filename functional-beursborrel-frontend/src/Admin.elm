module Admin exposing (Model, Msg)

import Drink exposing (DrinkList)

type alias AdminSession =
    { apiKey : String
    , drinks : DrinkList
    }

type Model
    = Unauthenticated
    | Failure
    | Loading
    | Success ()

type Msg
    = None
    | Update