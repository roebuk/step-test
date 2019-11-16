module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Browser.Navigation as Nav
import Html exposing (main_, text)
import Routes
import Url exposing (Url)



---- MODEL ----


type alias Model =
    { navKey : Nav.Key
    , page : Page
    }


type Page
    = Home
    | NotFound


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    ( initialModel key, Cmd.none )


initialModel : Nav.Key -> Model
initialModel key =
    { page = Home
    , navKey = key
    }



---- UPDATE ----


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged (Maybe Routes.Route)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlChanged maybeRoute ->
            setNewPage maybeRoute model

        LinkClicked (Browser.Internal url) ->
            ( model, Nav.pushUrl model.navKey (Url.toString url) )

        LinkClicked (Browser.External href) ->
            ( model, Nav.load href )


setNewPage : Maybe Routes.Route -> Model -> ( Model, Cmd Msg )
setNewPage maybeRoute model =
    case maybeRoute of
        Just Routes.Home ->
            ( { model | page = Home }, Cmd.none )

        Nothing ->
            ( { model | page = NotFound }, Cmd.none )



---- VIEW ----


view : Model -> Browser.Document Msg
view model =
    { title = "Hello"
    , body =
        [ main_ [] [ text "Hello World" ]
        ]
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = Routes.match >> UrlChanged
        , onUrlRequest = LinkClicked
        }
