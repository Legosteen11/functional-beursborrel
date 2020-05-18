module Main exposing (main)

import Browser
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


initialModel : Model
initialModel =
    Model 


type Msg
    = NoOp


init : Flags -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ _ _ =
    ( initialModel, Cmd.none )


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = \_ -> NoOp
        , onUrlRequest = \_ -> NoOp
        }


view : Model -> Browser.Document Msg
view model =
    let
        session =
            exit model
    in
    case model.page of
        Home home ->

        AdminLogin admin ->

        AdminOrder admin ->

        AdminListDrinks admin ->
        
        AdminModifyDrink admin ->

        NotFound _ -> 
            { title = "Not found"
            , body = 
                [ Element.layout [] <| Element.text "Page not found"
                ]
            }
    { title = "Example"
    , body =
        [ layout
            []
            (text "Hello World!")
        ]
    }


exit : Model -> Session.Data
exit model =
    case model.page of
        NotFound session ->
            session
        
        Home m ->
            m.session

        AdminLogin m ->
            m.session

        AdminOrder m ->
            m.session

        AdminListDrinks m ->
            m.session

        AdminModifyDrink m ->
            m.session


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    -- case Debug.log "msg" msg of
    case msg of
        NoOp ->
            ( model, Cmd.none )