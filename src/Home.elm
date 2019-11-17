module Home exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class, href)
import Routes


view : Html msg
view =
    div [ class "home-container" ]
        [ h1 [ class "page-heading" ] [ text "Cardiovascular fitness test" ]
        , ul []
            [ li [] [ text "Step for 3 minutes" ]
            , li [] [ text "Sit for 1 minute" ]
            , li [] [ text "Get Results" ]
            ]
        , div [ class "workout" ] []
        , a [ Routes.href Routes.FitnessTest, class "button mod-full" ] [ text "Let's Do This!" ]
        ]
