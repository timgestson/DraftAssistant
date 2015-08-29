module Players where

type alias Player =
    { name : String
    , position : String
    , positionalRank : Int
    , positionalTier : Int
    , adp : Float
    , drafted : Bool
    , onMyTeam : Bool
    }


filterByPosition : String -> Player -> Bool
filterByPosition position player =
    player.position == position 

filterByMyTeam : Player -> Bool
filterByMyTeam  player = 
    player.onMyTeam

filterOutDrafted : Player -> Bool
filterOutDrafted player = player.drafted


adpAvailableView : List Player -> List Player
adpAvailableView players =
    List.filter (filterOutDrafted) players
    |> List.sortBy .adp

positionAvailableView : String -> List Player -> List Player
positionAvailableView position players = 
    List.filter (filterOutDrafted) players
