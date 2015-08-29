module Util where

import Html exposing (..)
import Html.Attributes exposing (..)


type Color 
    = Blue
    | Yellow
    | Green
    | Red
    | Grey
    | White

type alias TableItem = 
   { color : Color
   , text : String
   , disabled : Bool
   , id : String
   , number : Float
   }

tableItemToHtml : TableItem -> Html
tableItemToHtml item = 
    tr (tableAttributes item) 
        [ th [attribute "scope" "row"] [ text (toString item.number) ]
        , td [] [ text item.text ]
        , td [] 
            [ span 
                [class "draftStamp"
                 , style [("opacity", "0"), ("font-weight", "bold"), ("color", "red")]
                 ] 
                 [ text "DRAFT" ]
            ]
        ]

tableAttributes item =
    let color = 
        case item.color of
            Blue -> "info"
            Yellow -> "warning"
            Green -> "success"
            Red -> "danger"
            Grey -> "active"
            White -> ""
    in
       [ class (color ++ " swipable")
       , id item.id
       ] 
