module Home exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class, href)
import Routes


view : Html msg
view =
    div []
        [ a [ Routes.href Routes.FitnessTest, class "button" ] [ text "Let's Do This!" ]
        ]
