module NotFound exposing (view)

import Html exposing (..)
import Routes


view : Html msg
view =
    div []
        [ h1 [] [ text "Not Found" ]
        , a [ Routes.href Routes.Home ] [ text "Return to home" ]
        ]
