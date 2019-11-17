module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Browser.Navigation as Nav
import FitnessTest
import Home
import Html exposing (..)
import Html.Attributes exposing (class, href)
import Html.Lazy exposing (lazy)
import NotFound
import Results
import Routes
import Url exposing (Url)



---- MODEL ----


type alias Flags =
    { hasBluetooth : Bool
    }


type alias Model =
    { hasBluetooth : Bool
    , navKey : Nav.Key
    , page : Page
    }


type Page
    = Home
    | FitnessTest FitnessTest.Model
    | Results Results.Model
    | NotFound


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    setNewPage (Routes.match url) (initialModel key flags)


initialModel : Nav.Key -> Flags -> Model
initialModel key flags =
    { page = NotFound
    , hasBluetooth = flags.hasBluetooth
    , navKey = key
    }



---- UPDATE ----


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged (Maybe Routes.Route)
    | GotFitnessMsg FitnessTest.Msg
    | GotResultsMsg Results.Msg


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

        GotResultsMsg resultMsg ->
            case model.page of
                Results result ->
                    toResult model (Results.update resultMsg result)

                _ ->
                    ( model, Cmd.none )


toFitness : Model -> ( FitnessTest.Model, Cmd FitnessTest.Msg ) -> ( Model, Cmd Msg )
toFitness model ( fitness, cmd ) =
    ( { model | page = FitnessTest fitness }
    , Cmd.map GotFitnessMsg cmd
    )


toResult : Model -> ( Results.Model, Cmd Results.Msg ) -> ( Model, Cmd Msg )
toResult model ( result, cmd ) =
    ( { model | page = Results result }
    , Cmd.map GotResultsMsg cmd
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
            let
                ( resultsModel, resultsCmds ) =
                    Results.init
            in
            ( { model | page = Results resultsModel }, Cmd.map GotResultsMsg resultsCmds )

        Nothing ->
            ( { model | page = NotFound }, Cmd.none )



---- VIEW ----


viewHeader : () -> Html msg
viewHeader _ =
    Html.header [ class "header" ]
        [ div [ class "header-inner" ]
            [ Html.h1 [] [ a [ Routes.href Routes.Home, class "header-title" ] [ text "Step Test" ] ]
            , div []
                [ a [ Routes.href Routes.Results, class "nav-link" ] [ text "Results" ] ]
            ]
        ]


viewFooter : () -> Html msg
viewFooter _ =
    Html.footer [ class "footer" ]
        [ div [] [ span [ class "footer-text" ] [ text "Kristian Roebuck" ] ]
        , div [ class "footer-right" ]
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
        ]


viewNoBTWarning : Bool -> Html msg
viewNoBTWarning hasBT =
    if hasBT == True then
        text ""

    else
        div [ class "warning" ] [ text "Your browser doesn't have Bluetooth support" ]


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

        Results model ->
            ( "Results"
            , Results.view model
                |> Html.map GotResultsMsg
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
        [ lazy viewHeader ()
        , viewNoBTWarning model.hasBluetooth
        , main_ [ class "main" ]
            [ content ]
        , lazy viewFooter ()
        ]
    }



---- PROGRAM ----


main : Program Flags Model Msg
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
