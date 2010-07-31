-----------------------------------------------------------------------------
--
-- Module      :  SlagGun
-- Copyright   :
-- License     :  AllRightsReserved
--
-- Maintainer  :  Oleksiy Dyagilev aka.fe2s@gmail.com
-- Stability   :
-- Portability :
--
-- |
--
-----------------------------------------------------------------------------

module SlagGun
    where

import Prelude

data World = World [Actor]

bigBangBoom :: World
bigBangBoom = World [createPlayer]

updateWorld :: PlayerAction -> World -> World
updateWorld action (World actors) = World $ map (updateActor action) actors

-----------------------------------------------------------------------------

data Actor = Player { position :: Point }
           | Shell  { position :: Point , vectorSpeed :: Point}
                deriving (Show)

createPlayer :: Actor
createPlayer = Player (0.2, 0.2)

updateActor :: PlayerAction -> Actor -> Actor
updateActor action p@(Player (x,y)) = case action of
                                        SlagGun.Right   -> Player (x+step, y)
                                        SlagGun.Left    -> Player (x-step, y)
                                        SlagGun.Up      -> Player (x, y+step)
                                        SlagGun.Down    -> Player (x, y-step)
                                        _               -> p
                                    where step = 0.01


updateActor _ (Shell _ _) = undefined

-----------------------------------------------------------------------------

data PlayerAction = Down | Up | Left | Right | Fire deriving (Show, Eq)

-----------------------------------------------------------------------------


type Point = (Float, Float)

xPoint = fst
yPoint = snd
