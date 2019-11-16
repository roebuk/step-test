module Routes exposing (Route(..), href, match)

import Html
import Html.Attributes
import Url exposing (Url)
import Url.Parser as Parser exposing (Parser)


type Route
    = Home
    | Results


href : Route -> Html.Attribute msg
href route =
    Html.Attributes.href (routeToString route)


routeToString : Route -> String
routeToString route =
    case route of
        Home ->
            "/"

        Results ->
            "/results"


routeParser : Parser (Route -> a) a
routeParser =
    Parser.oneOf
        [ Parser.map Home Parser.top
        ]


match : Url -> Maybe Route
match url =
    Parser.parse routeParser url
