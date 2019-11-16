port module FitnessTest exposing (Model, Msg, init, subscriptions, update, view)

import Html as Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Events exposing (on)
import Json.Decode as Decode
import Random
import Time


port requestBT : () -> Cmd msg


port receiveHeartBeat : (Int -> msg) -> Sub msg


stepDuration =
    180


sitDuration =
    60


type GameState
    = RequestingInfo
    | Stepping
    | Sitting
    | Results


type HeartBeat
    = NotRequested
    | Requested
    | Beating Int
    | Errored String


type Sex
    = Male
    | Female


type alias Model =
    { name : String
    , age : String
    , sex : Sex
    , heartBeat : HeartBeat
    , gameState : GameState
    , gameTime : Int
    , number : Int
    }


type Msg
    = GotFormSubmission
    | SetName String
    | SetSex Sex
    | SetAge String
    | RequestBlueTooth
    | GotHeartBeat Int
    | Tick Time.Posix


init : ( Model, Cmd Msg )
init =
    ( { name = ""
      , age = ""
      , sex = Female
      , heartBeat = NotRequested
      , gameState = RequestingInfo
      , gameTime = 180
      , number = 0
      }
    , Cmd.none
    )


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
            ( { model | gameState = Stepping }, Cmd.none )

        RequestBlueTooth ->
            ( { model | heartBeat = Requested }, requestBT () )

        Tick _ ->
            let
                newGameTime =
                    model.gameTime - 1
            in
            ( { model | gameTime = model.gameTime - 1 }, Cmd.none )


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
                button [ Events.onClick RequestBlueTooth, class "button  mod-small" ] [ text "Request Bluetooth" ]

            Requested ->
                button [ class "button  mod-small", disabled True ] [ text "Awaiting Beats" ]

            Beating beats ->
                div []
                    [ div [ class "heart" ] []
                    , span [] [ text (String.fromInt beats) ]
                    ]

            Errored _ ->
                div [] [ text "Errored" ]
        ]


view : Model -> Html Msg
view model =
    div [] <|
        case model.gameState of
            RequestingInfo ->
                [ viewForm model ]

            Stepping ->
                [ text "stepping" ]

            Sitting ->
                [ text "sitting" ]

            Results ->
                [ text "results" ]


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


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ receiveHeartBeat GotHeartBeat

        -- Time.every 1000 Tick
        ]
