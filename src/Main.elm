module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Routes
import Url exposing (Url)



---- MODEL ----


type alias Model =
    { navKey : Nav.Key
    , page : Page
    }


type Page
    = Home
    | Results
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

        Just Routes.Results ->
            ( { model | page = Results }, Cmd.none )

        Nothing ->
            ( { model | page = NotFound }, Cmd.none )



---- VIEW ----


viewHeader : Html msg
viewHeader =
    Html.header [ class "header" ]
        [ div [ class "header-inner" ]
            [ Html.h1 [] [ a [ Routes.href Routes.Home, class "header-title" ] [ text "STEP TEST" ] ]
            , div []
                [ a [ Routes.href Routes.Results, class "nav-link" ] [ text "Results" ]
                , a [ Routes.href Routes.Results, class "nav-link" ] [ text "About" ]
                ]
            ]
        ]


viewFooter : Html msg
viewFooter =
    Html.footer [ class "footer" ]
        [ a
            [ class "footer-logo mod-twitter"
            , href "https://twitter.com/roebuk"
            ]
            [ span [ class "visually-hidden" ] [ text "Twitter" ] ]
        , a
            [ class "footer-logo mod-github"
            , href "https://github.com/roebuk/step-test"
            ]
            [ span [ class "visually-hidden" ] [ text "Github" ] ]
        ]


view : Model -> Browser.Document Msg
view model =
    { title = "Hello"
    , body =
        [ viewHeader
        , main_ [ class "main" ] [ text "Hello World" ]
        , viewFooter
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
