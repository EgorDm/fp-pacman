module Game.Level.Level (
    Powerup(..),
    Tile(..),
    Table(..),
    Marker(..),
    Level(..),
    (!),
    set,
    setl,
    tileToCoordinate,
    coordToTile,
    markerCoordinate,
    markerCoordinates,
    markerCageCorner,
    markerRevivalPoint,
    markerDoor,
    isWall
) where
    
import Prelude hiding (length)
import qualified Data.Vector as Vec
import Engine.Graphics.Base
import Engine.Core.Base
import Resources
import Constants
    
{- Data structures -}
data Table a = Table (Vec.Vector (Vec.Vector a)) Int Int deriving (Show, Eq)

data Powerup = PacDot | PowerPill | Cherry deriving (Show, Eq)

data Marker = Marker Char deriving (Show, Eq, Ord)

data Tile = TileEmpty | TilePowerup Powerup | TileWall Sprite | TileDoor | TileMarker Marker deriving (Show, Eq)

data Level = Level {tiles :: Table Tile, markers :: [(Marker, Coordinate)], dotCount :: Int} deriving (Show, Eq)

{- Classes -}

{- Instances -}
instance Functor Table where
    fmap f (Table vec w h) = Table vecn w h where vecn = Vec.map (Vec.map f) vec

-- | Creates draw instructions for each tile
instance Drawable Level where
    draw l@(Level{tiles=t@(Table _ w h)}) = [drawTile (Pos x y) | x <- [0.. w-1], y <- [0.. h-1]]
                                             where drawTile p = DrawInstruction (tileToCoordinate t p) (tileToSprite (t ! p))
{- Functions -}
-- | Gets tile at given position
(!) :: Table Tile -> Pos -> Tile
(!) (Table vec w h) (Pos x y) | x < 0 || x >= w || y < 0 || y >= h = TileEmpty
                              | otherwise = vec Vec.! y Vec.! x

-- | Replaces tile at position within table by specified one
set :: Table a -> Pos -> a -> Table a
set t@(Table vec w h) (Pos x y) v 
    | x < 0 || x >= w || y < 0 || y >= h = t
    | otherwise = Table nvec w h
    where 
        nvec = vec Vec.// [(y, nrow)]
        nrow = (vec Vec.! y) Vec.// [(x, v)]

-- | Replaces tile at position within level by specified one
setl :: Level -> Pos -> Tile -> Level
setl l@Level{tiles=t} p tile = l{tiles=set t p tile}

-- | Converts a tile type to a sprite
tileToSprite :: Tile -> Sprite
tileToSprite tile = case tile of TileEmpty                 -> createEmptySprite
                                 (TilePowerup PacDot)      -> spritePowerupPacDot
                                 (TilePowerup PowerPill)   -> spritePowerupPowerPellet
                                 (TilePowerup Cherry)      -> spritePowerupCherry
                                 (TileWall sprite)         -> sprite
                                 TileDoor                  -> createEmptySprite
                                 (TileMarker (Marker '_')) -> spriteTileDoor
                                 (TileMarker _)            -> createEmptySprite

-- | Converts given tile position to a coordinate
tileToCoordinate :: Table Tile -> Pos -> Coordinate
tileToCoordinate (Table _ w h) (Pos x y) = (coord x y - coord (w-1) (h-1) / 2) * fromInteger tileSize

-- | Get tile for given coordinate withing given table
coordToTile :: Table Tile -> Coordinate -> Pos
coordToTile (Table _ w h) c = coordToPos (c / fromInteger tileSize + coord (w-1) (h-1) / 2)

-- | Get coordinate for given marker
markerCoordinate :: Marker -> Level -> Coordinate
markerCoordinate m Level{markers} = case lookup m markers of Just c -> c; Nothing -> coordZ

-- | Get all coordinates for given markers. Multiple possible. Just use supported markers
markerCoordinates :: Marker -> [(Marker, Coordinate)] -> [Coordinate]
markerCoordinates _ [] = []
markerCoordinates m ((mo, c):ms) | mo == m   = c:(markerCoordinates m ms)
                                 | otherwise = markerCoordinates m ms

-- | Checks if a tile is wall
isWall :: Tile -> Bool
isWall (TileWall _) = True
isWall _ = False

-- | Some special marker definitions
markerCageCorner, markerRevivalPoint :: Marker
markerCageCorner = Marker '6'
markerRevivalPoint = Marker 'R'
markerDoor = Marker '_'