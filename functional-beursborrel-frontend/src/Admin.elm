module Admin exposing (Model, Msg, AdminSession, exit)

import Drink exposing (DrinkList)
import Session

type alias AdminSession =
    { session : Session.Data
    , apiKey : String
    , drinks : DrinkList
    }

type Model
    = Unauthenticated AdminSession
    | Failure AdminSession
    | Loading AdminSession
    | Success AdminSession

exit : Model -> AdminSession
exit model =
    case model of
        Unauthenticated sess ->
            sess

        Failure sess ->
            sess

        Loading sess ->
            sess

        Success sess ->
            sess

type Msg
    = None
    | Update