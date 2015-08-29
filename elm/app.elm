module App where 

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Players exposing (..)
import Json.Encode exposing (string)
import Util exposing (..)
import Task exposing (..)

type alias Model = 
    { screen: String 
    , players: List Player
    }

main : Signal Html
main = Signal.map (view actions.address) model


actions : Signal.Mailbox Action
actions = Signal.mailbox NoOp

model : Signal Model
model = Signal.foldp update initialModel (Signal.merge actions.signal (Signal.map swipeToAction swipe))

initialModel = Maybe.withDefault emptyModel getState

port getState : Maybe Model

port setState : Signal Model
port setState = model

port gestureListener : Signal Model
port gestureListener = Signal.merge
        (Signal.sampleOn startAppMailbox.signal model)
                model

port swipe : Signal (Maybe Command)

--port swiper = Signal.send action.address ()

type alias Command = 
    { action : String
    , direction : String
    , player : String
    }


swipeToAction maybe =  
    case maybe of
        Nothing -> NoOp
        Just command  -> 
            case command.action of
                "draft"-> Draft command.player (command.direction == "right")
                "undraft" -> Undraft command.player
                _-> NoOp 


startAppMailbox = Signal.mailbox ()

port startApp : Signal (Task error ())
port startApp = 
        Signal.constant (Signal.send startAppMailbox.address ())


emptyModel = 
    { screen = "home"
    , players = []
    }

type Action 
    = ChangeScreen String
    | Draft String Bool
    | Undraft String
    | NoOp


update action model = 
    case action of
        ChangeScreen screen -> { model | screen <- screen }
        Draft player mine -> { model | players <- (draftPlayer model.players player mine) }
        Undraft player -> { model | players <- (undraftPlayer model.players player) }
        _ -> model

draftPlayer players name mine = 
    List.map (\player-> 
        case player.name == name of 
            True -> { player | drafted <- True
                     , onMyTeam <- mine
                    }
            False -> player
        ) players

undraftPlayer players name = 
    List.map (\player ->
        case player.name == name of
            True -> { player | drafted <- False
                    , onMyTeam <- False
                    }
            False -> player
        ) players

view address model = 
    div [] 
        [ nav [ class "navbar navbar-default navbar-fixed-top"]
            [ div [ class "navbar-header"] 
                [ button 
                    [class "navbar-toggle collapsed"
                    , attribute "data-toggle" "collapse"
                    , attribute "data-target" "#navbar-list"
                    , attribute "aria-expanded" "false"
                    ]
                    [ span [class "sr-only"] [ text "Toggle Navigation"] 
                    , span [ class "icon-bar" ] []
                    , span [ class "icon-bar" ] []
                    , span [ class "icon-bar" ] []
                    ]
                , a [ class "navbar-brand" ] [ text "Draftinator" ]
                ]  
            , div   [ class "navbar-collapse collapse" 
                    , id "navbar-list"
                    , attribute "aria-expanded" "false"
                    ]
                    [ ul [ class "nav navbar-nav" ]
                         [ li (isActive model "Home") 
                            [ a [ href "#" 
                                , onClick address (ChangeScreen "Home") 
                                ] [ text "Home" ] 
                            ]
                         , li (isActive model "My Team")
                            [ a [ href "#" 
                                , onClick address (ChangeScreen "My Team")
                                ] [ text "My Team"] 
                            ]
                        , li (isActive model "Drafted")
                            [ a [ href "#" 
                                , onClick address (ChangeScreen "Drafted")
                                ] [ text "Drafted"] 
                            ]
                         , li (isActive model "QB")
                            [ a [ href "#" 
                                , onClick address (ChangeScreen "QB")
                                ] [ text "QB"] 
                            ]
                         , li (isActive model "RB")
                            [ a [ href "#" 
                                , onClick address (ChangeScreen "RB")
                                ] [ text "RB"] 
                            ]
                         , li (isActive model "WR")
                            [ a [ href "#" 
                                , onClick address (ChangeScreen "WR")
                                ] [ text "WR"] 
                            ]
                         , li (isActive model "TE")
                            [ a [ href "#" 
                                , onClick address (ChangeScreen "TE")
                                ] [ text "TE"] 
                            ]
                         , li (isActive model "Def")
                            [ a [ href "#" 
                                , onClick address (ChangeScreen "Def")
                                ] [ text "Def"] 
                            ]
                        ]
                    ]
            ]
        , table [ class "table", style [("margin-top","50px")] ] 
            [ tbody []
                (getList model)
            ]        
        ]

isActive model screen = 
    case model.screen == screen of
        True -> [ class "active" ]
        _-> []

getList : Model -> List Html
getList model =
    case model.screen of
        "QB" -> positionalChart "QB" model.players
        "RB" -> positionalChart "RB" model.players
        "TE" -> positionalChart "TE" model.players
        "WR" -> positionalChart "WR" model.players
        "Def" -> positionalChart "DEF" model.players
        "Drafted" -> draftedChart model.players
        "My Team" -> teamChart model.players
        _ -> adpChart model.players

adpChart : List Player -> List Html
adpChart players =
    List.filter (\player->player.drafted == False) players
    |> List.sortBy .adp 
    |> List.map adpToTableItem
    |> List.map tableItemToHtml

adpToTableItem player = 
    let 
        color = case player.position of
            "QB" -> Red
            "RB" -> Blue
            "WR" -> Green
            "TE" -> Yellow
            "DEF" -> White
            _-> Grey
    in
       { color = color
       , text = player.name
       , disabled = False
       , id = player.name
       , number = player.adp
       }

positionalTableItem player = 
    let 
        color = case player.positionalTier % 4 of
            0 -> Blue
            1 -> Green
            2 -> Red
            3 -> Yellow
    in 
        { color = color
       , text = player.name
       , disabled = False
       , id = player.name
       , number = player.adp
       }

positionalChart position players =
    List.filter (\player->player.drafted == False) players
    |> List.filter (\player->player.position == position)
    |> List.sortBy .positionalRank 
    |> List.map positionalTableItem
    |> List.map tableItemToHtml


draftedChart players = 
    List.filter .drafted players
    |> List.sortBy .adp
    |> List.map adpToTableItem
    |> List.map tableItemToHtml

teamChart players =
    List.filter .onMyTeam players
    |> List.sortBy .adp
    |> List.map adpToTableItem
    |> List.map tableItemToHtml
