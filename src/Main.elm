module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Browser.Navigation as Nav
import FitnessTest
import Home
import Html exposing (..)
import Html.Attributes as Attrs exposing (href, src)
import Html.Lazy exposing (lazy)
import NotFound
import Results
import Routes
import Url exposing (Url)



---- MODEL ----


type alias Model =
    { navKey : Nav.Key
    , page : Page
    }


type Page
    = Home
    | FitnessTest FitnessTest.Model
    | Results
    | NotFound


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    setNewPage (Routes.match url) (initialModel key)


initialModel : Nav.Key -> Model
initialModel key =
    { page = NotFound
    , navKey = key
    }



---- UPDATE ----


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged (Maybe Routes.Route)
    | GotFitnessMsg FitnessTest.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlChanged maybeRoute ->
            setNewPage maybeRoute model

        LinkClicked (Browser.Internal url) ->
            ( model, Nav.pushUrl model.navKey (Url.toString url) )

        LinkClicked (Browser.External href) ->
            ( model, Nav.load href )

        GotFitnessMsg fitnessMsg ->
            case model.page of
                FitnessTest fitness ->
                    toFitness model (FitnessTest.update fitnessMsg fitness)

                _ ->
                    ( model, Cmd.none )


toFitness : Model -> ( FitnessTest.Model, Cmd FitnessTest.Msg ) -> ( Model, Cmd Msg )
toFitness model ( fitness, cmd ) =
    ( { model | page = FitnessTest fitness }
    , Cmd.map GotFitnessMsg cmd
    )


setNewPage : Maybe Routes.Route -> Model -> ( Model, Cmd Msg )
setNewPage maybeRoute model =
    case maybeRoute of
        Just Routes.Home ->
            ( { model | page = Home }, Cmd.none )

        Just Routes.FitnessTest ->
            let
                ( fitnessModel, fitnessCmds ) =
                    FitnessTest.init
            in
            ( { model | page = FitnessTest fitnessModel }, Cmd.map GotFitnessMsg fitnessCmds )

        Just Routes.Results ->
            ( { model | page = Results }, Cmd.none )

        Nothing ->
            ( { model | page = NotFound }, Cmd.none )



---- VIEW ----


viewHeader : Page -> Html msg
viewHeader page =
    Html.header [ Attrs.class "header" ]
        [ div [ Attrs.class "header-inner" ]
            [ Html.h1 [] [ a [ Routes.href Routes.Home, Attrs.class "header-title" ] [ text "HEADER" ] ]
            , div []
                [ a [ Routes.href Routes.Results, Attrs.class "nav-link" ] [ text "Results" ]
                , a [ Routes.href Routes.Results, Attrs.class "nav-link" ] [ text "About" ]
                ]
            ]
        ]


viewFooter : () -> Html msg
viewFooter _ =
    Html.footer [ Attrs.class "footer" ]
        [ a [ href "https://twitter.com/roebuk" ] [ text "Twitter" ]
        , a [ href "https://github.com/roebuk" ] [ text "Github" ]
        ]


viewContent : Page -> ( String, Html Msg )
viewContent page =
    case page of
        Home ->
            ( "Home"
            , Home.view
            )

        FitnessTest model ->
            ( "Test"
            , FitnessTest.view model
                |> Html.map GotFitnessMsg
            )

        Results ->
            ( "Results"
            , Results.view
            )

        NotFound ->
            ( "404 - Not Found"
            , NotFound.view
            )


view : Model -> Browser.Document Msg
view model =
    let
        ( title, content ) =
            viewContent model.page
    in
    { title = title
    , body =
        [ lazy viewHeader model.page
        , main_ [ Attrs.class "main" ] [ content ]
        , lazy viewFooter ()
        ]
    }



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


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.page of
        FitnessTest fitnessTest ->
            FitnessTest.subscriptions fitnessTest
                |> Sub.map GotFitnessMsg

        _ ->
            Sub.none
