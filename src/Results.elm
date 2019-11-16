module Results exposing (view)

import Html exposing (..)
import Routes


view : Html msg
view =
    div []
        [ h1 [] [ text "Results" ]
        , a [ Routes.href Routes.Home ] [ text "Home" ]
        ]
