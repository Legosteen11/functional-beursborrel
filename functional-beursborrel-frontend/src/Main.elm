module Main exposing (main)

import Msg exposing (..)
import Home
import Base
import Browser
import Session
import Browser.Navigation as Nav
import Element exposing (..)
import Url


type alias Flags =
    {}


type alias Model =
    { key : Nav.Key
    , page : Page
    }


type Page
    = Home Home.Model
    | NotFound Session.Data


init : Flags -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ _ key =
    let
        initSession =
            Session.new
        
        mdl =
            { key = key
            , page = Home (Home.Loading initSession Nothing)
            }
    in
    stepHome mdl (Home.init initSession)


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = \_ -> None
        , onUrlRequest = \_ -> None
        }


view : Model -> Browser.Document Msg
view model =
    let
        session =
            exit model
    in
    case model.page of
        Home home ->
            Base.view session (Msg.HomeMsg) (Home.view home)

        -- AdminLogin admin ->
        --     Base view session AdminMsg (Admin.view admin)

        -- AdminOrder admin ->
        --     Base.view session AdminMsg (Admin.view admin)

        -- AdminListDrinks admin ->
        --     Base.view session AdminMsg (Admin.view admin)
        
        -- AdminModifyDrink admin ->
        --     Base.view session AdminMsg (Admin.view admin)

        _ ->
            { title = "Not found"
            , body = 
                [ Element.layout [] <| Element.text "Page not found"
                ]
            }


exit : Model -> Session.Data
exit model =
    case model.page of
        NotFound session ->
            session
        
        Home m ->
            Home.exit m

        -- AdminLogin m ->
        --     (Admin.exit m).session

        -- AdminOrder m ->
        --     (Admin.exit m).session

        -- AdminListDrinks m ->
        --     (Admin.exit m).session

        -- AdminModifyDrink m ->
        --     (Admin.exit m).session


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.page of
            Home home ->
                Sub.map Msg.HomeMsg (Home.subscriptions home)

            _ ->
                Sub.none


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of 
        HomeMsg msg ->
            case model.page of
                Home home ->
                    stepHome model (Home.update msg home)
                
                _ ->
                    (model, Cmd.none)
        
        _ ->
            (model, Cmd.none)


stepHome : Model -> (Home.Model, Cmd Home.Msg) -> (Model, Cmd Msg)
stepHome model (home, cmd) =
    ( { model | page = Home home }
    , Cmd.map HomeMsg cmd)