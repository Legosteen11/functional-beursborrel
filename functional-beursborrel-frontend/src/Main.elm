module Main exposing (main)

import Msg exposing (..)
import Home exposing (Model)
import Admin
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
    | AdminLogin Admin.Model
    | AdminOrder Admin.Model
    | AdminListDrinks Admin.Model
    | AdminModifyDrink Admin.Model
    | NotFound Session.Data


init : Flags -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ _ key =
    let
        initSession =
            Session.new
        
        mdl =
            { key = key
            , page = Home (Home.Loading initSession)
            }
    in
    (mdl, Cmd.none)


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
        
        toMsg msg _ =
            msg
    in
    case model.page of
        Home home ->
            Base.view session (toMsg Msg.HomeMsg) (Home.view home)

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

        AdminLogin m ->
            (Admin.exit m).session

        AdminOrder m ->
            (Admin.exit m).session

        AdminListDrinks m ->
            (Admin.exit m).session

        AdminModifyDrink m ->
            (Admin.exit m).session


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    -- case Debug.log "msg" msg of
    case msg of
        _ ->
            ( model, Cmd.none )