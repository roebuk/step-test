module Home exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class, href)
import Routes


view : Html msg
view =
    div [ class "home-container" ]
        [ div [ class "workout" ] []
        , a [ Routes.href Routes.FitnessTest, class "button mod-full" ] [ text "Let's Do This!" ]
        ]
