port module FitnessTest exposing (Model, Msg, init, subscriptions, update, view)

import Html as Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Events exposing (on)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Time
import Types exposing (Sex(..))


port requestBT : () -> Cmd msg


port receiveHeartBeat : (Int -> msg) -> Sub msg


port metronome : () -> Cmd msg


gameTime =
    240


type GameState
    = RequestingInfo
    | TestActive
    | Results


type HeartBeat
    = NotRequested
    | Requested
    | Beating Int
    | Errored String


type alias Model =
    { name : String
    , age : String
    , sex : Sex
    , heartBeat : HeartBeat
    , gameState : GameState
    , gameTime : Int
    }


type Msg
    = GotFormSubmission
    | SetName String
    | SetSex Sex
    | SetAge String
    | RequestBlueTooth
    | GotHeartBeat Int
    | Tick Time.Posix
    | MetroTick Time.Posix
    | GotResultResponse (Result Http.Error String)


init : ( Model, Cmd Msg )
init =
    ( { name = ""
      , age = ""
      , sex = Female
      , heartBeat = NotRequested
      , gameState = RequestingInfo
      , gameTime = gameTime
      }
    , Cmd.none
    )


encodeResult : String -> Int -> Int -> Encode.Value
encodeResult name age heartBeat =
    Encode.object
        [ ( "name", Encode.string name )
        , ( "age", Encode.int age )
        , ( "heartBeat", Encode.int heartBeat )
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetName name ->
            ( { model | name = name }, Cmd.none )

        SetSex sex ->
            ( { model | sex = sex }, Cmd.none )

        SetAge age ->
            ( { model | age = age }, Cmd.none )

        GotHeartBeat beats ->
            ( { model | heartBeat = Beating beats }, Cmd.none )

        GotFormSubmission ->
            ( { model | gameState = TestActive }, Cmd.none )

        RequestBlueTooth ->
            ( { model | heartBeat = Requested }, requestBT () )

        Tick _ ->
            let
                newGameTime =
                    clamp 0 gameTime (model.gameTime - 1)

                isFinished =
                    if newGameTime == 0 then
                        Results

                    else
                        TestActive

                beats =
                    case model.heartBeat of
                        Beating heartRate ->
                            heartRate

                        _ ->
                            0

                fireCmd =
                    if isFinished == Results then
                        Http.post
                            { url = "https://step.roeb.uk/api"
                            , body = Http.jsonBody (encodeResult model.name (model.age |> String.toInt |> Maybe.withDefault 18) beats)
                            , expect = Http.expectString GotResultResponse
                            }

                    else
                        Cmd.none
            in
            ( { model | gameTime = newGameTime, gameState = isFinished }, fireCmd )

        MetroTick _ ->
            let
                cmdToFire =
                    if model.gameTime < 60 then
                        Cmd.none

                    else
                        metronome ()
            in
            ( model, cmdToFire )

        GotResultResponse result ->
            case result of
                Ok _ ->
                    ( model, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )


generateInputID : String -> String
generateInputID =
    String.toLower >> String.replace " " "-"


viewTextInput : String -> String -> (String -> msg) -> Html msg
viewTextInput inputLabel inputValue tagger =
    let
        inputID =
            generateInputID inputLabel
    in
    div [ class "form-element" ]
        [ label [ for inputID, class "form-element-label" ]
            [ span [ class "form-element-label-text" ] [ text inputLabel ]
            , input
                [ id inputID
                , type_ "text"
                , class "form-element-input"
                , Events.onInput tagger
                , value inputValue
                ]
                []
            ]
        ]


viewAudio : Html msg
viewAudio =
    audio [ class "audio" ]
        [ source [ src "/metro.mp3", type_ "audio/mp3" ] []
        ]


viewRadio : String -> Sex -> Sex -> (Sex -> Msg) -> Html Msg
viewRadio radioLabel value selectedValue tagger =
    let
        inputID =
            generateInputID radioLabel
    in
    div [ class "form-element-radio" ]
        [ input
            [ id inputID
            , type_ "radio"
            , onChange (tagger value)
            , checked (value == selectedValue)
            ]
            []
        , label [ for inputID ] [ text radioLabel ]
        ]


onChange : msg -> Attribute msg
onChange msg =
    on "click" (Decode.succeed msg)


viewHeart : HeartBeat -> Html Msg
viewHeart heartbeat =
    div [ class "bluetooth-button-container" ]
        [ case heartbeat of
            NotRequested ->
                button
                    [ Events.onClick RequestBlueTooth
                    , class "button  mod-small"
                    , type_ "button"
                    ]
                    [ text "Request Bluetooth" ]

            Requested ->
                button [ class "button  mod-small", disabled True ] [ text "Awaiting Beats" ]

            Beating beats ->
                div []
                    [ div [ class "heart" ]
                        [ div [ class "heart-image" ] []
                        , span [ class "heart-text" ] [ text (String.fromInt beats) ]
                        ]
                    ]

            Errored _ ->
                div [] [ text "Errored" ]
        ]


view : Model -> Html Msg
view model =
    div []
        [ viewAudio
        , div
            []
          <|
            case model.gameState of
                RequestingInfo ->
                    [ viewForm model ]

                TestActive ->
                    if model.gameTime < 60 then
                        [ viewSittingActive model ]

                    else
                        [ viewTestActive model ]

                Results ->
                    [ text "results" ]
        ]


viewSittingActive : Model -> Html Msg
viewSittingActive model =
    div []
        [ h1 [ class "page-heading" ] [ text "Get Sit And Wait…" ]
        , div [ class "page-image mod-sitting" ] []
        , div [ class "trem" ] [ text "Keep Sitting…" ]
        , span [ class "time-remaining" ] [ text (model.gameTime |> String.fromInt) ]
        , case model.heartBeat of
            Beating beats ->
                div []
                    [ div [ class "heart" ]
                        [ div [ class "heart-image" ] []
                        , span [ class "heart-text" ] [ text (String.fromInt beats) ]
                        ]
                    ]

            _ ->
                text ""
        ]


viewTestActive : Model -> Html Msg
viewTestActive model =
    let
        timeRemaining =
            model.gameTime - 60 |> String.fromInt

        stepStage =
            modBy 4 (model.gameTime - 60)

        dots =
            List.range 0 (stepStage + 1)
    in
    div []
        [ h1 [ class "page-heading" ] [ text "Get Stepping…" ]
        , div [ class "page-image mod-stepping" ]
            []
        , div
            [ class "trem" ]
            [ text "Time Remaining..." ]
        , span [ class "time-remaining" ] [ text timeRemaining ]
        , case model.heartBeat of
            Beating beats ->
                div []
                    [ div [ class "heart" ]
                        [ div [ class "heart-image" ] []
                        , span [ class "heart-text" ] [ text (String.fromInt beats) ]
                        ]
                    ]

            _ ->
                text ""
        ]


viewForm : Model -> Html Msg
viewForm model =
    Html.form [ Events.onSubmit GotFormSubmission ]
        [ viewTextInput "Name" model.name SetName
        , viewTextInput "Age" model.age SetAge
        , fieldset [ class "form-element" ]
            [ legend [ class "form-element-label-text" ] [ text "Sex" ]
            , viewRadio "Female" Female model.sex SetSex
            , viewRadio "Male" Male model.sex SetSex
            ]
        , viewHeart model.heartBeat
        , button [ type_ "submit", class "button mod-full" ] [ text "Start" ]
        ]


beatsToMilli =
    60000 / 96


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ receiveHeartBeat GotHeartBeat
        , if model.gameState == TestActive then
            Time.every 1000 Tick

          else
            Sub.none
        , case model.gameState of
            TestActive ->
                Time.every beatsToMilli MetroTick

            _ ->
                Sub.none
        ]
