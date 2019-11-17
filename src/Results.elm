module Results exposing (Model, Msg(..), StepResult, init, stepResultDecoder, stepResultsDecoder, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Json.Decode as Decode exposing (Decoder, decodeString, field, float, int, nullable, string)
import Routes



-- TYPES


type Msg
    = GotStepResults (Result Http.Error (List StepResult))


type alias Model =
    { results : Maybe (List StepResult) }


type alias StepResult =
    { id : Int
    , name : String
    , age : Int
    , heartBeat : Int
    }



-- DECODER


stepResultsDecoder : Decoder (List StepResult)
stepResultsDecoder =
    Decode.list stepResultDecoder


stepResultDecoder : Decoder StepResult
stepResultDecoder =
    Decode.map4 StepResult
        (field "result_id" int)
        (field "name" string)
        (field "age" int)
        (field "heart_beat" int)



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotStepResults result ->
            case result of
                Ok results ->
                    ( { model | results = Just results }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )



-- VIEW


viewResult : StepResult -> Html msg
viewResult result =
    tr []
        [ td [ class "table-cell" ]
            [ text result.name ]
        , td [ class "table-cell" ]
            [ text (String.fromInt result.age) ]
        , td [ class "table-cell" ]
            [ text (String.fromInt result.heartBeat) ]
        , td [ class "table-cell" ]
            [ text (String.fromInt result.heartBeat) ]
        ]


viewResults : List StepResult -> Html msg
viewResults results =
    table [ class "table" ]
        [ tr [ class "table-heading-row" ]
            [ th [ class "table-heading" ]
                [ text "Name" ]
            , th [ class "table-heading" ]
                [ text "Age" ]
            , th [ class "table-heading" ]
                [ text "HeartBeat" ]
            , th
                [ class "table-heading" ]
                [ text "Result" ]
            ]
        , tbody [] <| List.map viewResult results
        ]


view : Model -> Html msg
view model =
    div []
        [ h1 [] [ text "Results" ]
        , case model.results of
            Just res ->
                viewResults res

            Nothing ->
                div [] [ text "No results" ]
        ]


init : ( Model, Cmd Msg )
init =
    ( { results = Nothing }
    , Http.get
        { url = "https://step.roeb.uk/api"
        , expect = Http.expectJson GotStepResults stepResultsDecoder
        }
    )
