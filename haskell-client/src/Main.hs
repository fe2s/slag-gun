-----------------------------------------------------------------------------
--
-- Module      :  Main
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

module Main
    where

import Prelude
import Data.IORef
import Data.Map as Map
import Graphics.Rendering.OpenGL
import Graphics.UI.GLUT
import Network.Socket hiding (recv)
import Network.Socket.ByteString
import System.IO
import qualified Data.ByteString.Char8 as C

import SlagGun as S

-----------------------------------------------------------------------------

class Displayable a where
        display :: a -> IO()

instance Displayable World where
    display (World actors) = mapM_ display actors

instance Displayable Actor where
    display (Player pos) = displayPoint pos
    display (Shell _ _ ) = undefined

-----------------------------------------------------------------------------

displayPoint point = vertex $ Vertex2 (fst point) (snd point)

-----------------------------------------------------------------------------

-- keyboard preferences
keyPrefs :: Map Key PlayerAction
keyPrefs = fromList [((Char 'w'), S.Up),
                     ((Char 's'), S.Down),
                     ((Char 'a'), S.Left),
                     ((Char 'd'), S.Right)]

-----------------------------------------------------------------------------

main :: IO ()
main = do
    (progname, _) <- getArgsAndInitialize
    testConnection
    -- initialDisplayMode $= [DoubleBuffered]
    createWindow progname
    world <- newIORef bigBangBoom
    keyboardMouseCallback $= Just (keyboardMouse world)
    displayCallback $= (displayFrame world)
    -- idleCallback $= Just idle
    mainLoop

-----------------------------------------------------------------------------

displayFrame :: IORef World -> DisplayCallback
displayFrame world = do
    clear [ColorBuffer]
    renderPrimitive Points $ do
                             world' <- get world
                             display world'
                             print "displayFrame"
    flush

-----------------------------------------------------------------------------

keyboardMouse :: IORef World -> Key -> KeyState -> Modifiers -> Position -> IO ()
keyboardMouse world key keyState modifiers position = do
    world' <- get world
    print "keyboardMouse"
    world $= processKey key world'
    postRedisplay Nothing

-----------------------------------------------------------------------------

processKey :: Key -> World -> World
processKey key world =
    case Map.lookup key keyPrefs of
        Just playerAction -> updateWorld playerAction world
        Nothing           -> world

-----------------------------------------------------------------------------

testConnection :: IO ()
testConnection = withSocketsDo $ do
    print $ "opening connection " ++ hostName ++ ":" ++ port
    addrinfos <- getAddrInfo Nothing (Just hostName) (Just port)
    let addr = head addrinfos
    sock <- socket (addrFamily addr) Stream defaultProtocol
    connect sock (addrAddress addr)
    sendAll sock $ C.pack "Greetings from Haskell\n"
    msg <- recv sock readBuff
    C.putStrLn msg
    sClose sock
        where hostName = "localhost"
              port     = "5555"
              readBuff = 1024

-----------------------------------------------------------------------------






