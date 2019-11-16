module Routes exposing (Route(..), match)

import Html
import Html.Attributes
import Url exposing (Url)
import Url.Parser as Parser exposing (Parser)


type Route
    = Home


routeParser : Parser (Route -> a) a
routeParser =
    Parser.oneOf
        [ Parser.map Home Parser.top
        ]


match : Url -> Maybe Route
match url =
    Parser.parse routeParser url
