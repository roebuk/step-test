module Results exposing (Model, Msg(..), StepResult, init, stepResultDecoder, stepResultsDecoder, update, view)

import Html exposing (..)
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
    , age : String
    , heartBeat : Int
    }



-- DECODER


stepResultsDecoder : Decoder (List StepResult)
stepResultsDecoder =
    Decode.list stepResultDecoder


stepResultDecoder : Decoder StepResult
stepResultDecoder =
    Decode.map4 StepResult
        (field "id" int)
        (field "name" string)
        (field "age" string)
        (field "hearbeat" int)



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotStepResults result ->
            case result of
                Ok _ ->
                    ( model, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )



-- VIEW


view : Model -> Html msg
view model =
    div []
        [ h1 [] [ text "Results" ]
        , a [ Routes.href Routes.Home ] [ text "Home" ]
        ]


init : ( Model, Cmd Msg )
init =
    ( { results = Nothing }
    , Http.get
        { url = "https://step.roeb.uk/api"
        , expect = Http.expectJson GotStepResults stepResultsDecoder
        }
    )
