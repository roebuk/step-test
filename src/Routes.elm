module Routes exposing (Route(..), href, match)

import Html
import Html.Attributes
import Url exposing (Url)
import Url.Parser as Parser exposing (Parser)


type Route
    = Home
    | FitnessTest
    | Results


href : Route -> Html.Attribute msg
href route =
    Html.Attributes.href (routeToString route)


routeToString : Route -> String
routeToString route =
    case route of
        Home ->
            "/"

        FitnessTest ->
            "/fitness"

        Results ->
            "/results"


routeParser : Parser (Route -> a) a
routeParser =
    Parser.oneOf
        [ Parser.map Home Parser.top
        , Parser.map FitnessTest (Parser.s "fitness")
        , Parser.map Results (Parser.s "results")
        ]


match : Url -> Maybe Route
match url =
    Parser.parse routeParser url
