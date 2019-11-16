module Results exposing (view)

import Html exposing (..)
import Json.Decode as Decode exposing (Decoder, decodeString, float, int, nullable, string)
import Json.Decode.Pipeline exposing (required)
import Routes



-- TYPES


type alias Result =
    { id : Int
    , name : String
    , age : Int
    , heartBeat : Int
    }



-- DECODER


resultDecoder : Decoder Result
resultDecoder =
    Decode.succeed Result
        |> required "id" int
        |> required "name" string
        |> required "age" int
        |> required "heartbeat" int



-- VIEW


view : Html msg
view =
    div []
        [ h1 [] [ text "Results" ]
        , a [ Routes.href Routes.Home ] [ text "Home" ]
        ]
