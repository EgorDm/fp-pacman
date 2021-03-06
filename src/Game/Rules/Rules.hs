module Game.Rules.Rules (
    GameRule, GameInputRule, MenuInputRule,
    applyGameRules, applyGameInputRules, applyMenuInputRules
) where

import Control.Arrow
import Game.Structure.GameState
import Game.Structure.MenuState
import Graphics.Gloss.Game(Event(..))

{- Data structures -}
type GameRule = (GameState -> GameState)
type GameInputRule = (Event -> GameState -> GameState)
type MenuInputRule = (Event -> MenuState -> MenuState)
{- Classes -}


{- Instances -}


{- Functions -}
-- | Applies all the rules to the GameState
applyGameRules :: [GameRule] -> GameState -> GameState
applyGameRules rls st = (foldl (>>>) id rls) st

-- | Applies menu input rules to the GameState
applyMenuInputRules :: Event -> [MenuInputRule] -> MenuState -> MenuState
--applyMenuInputRules e rls st = (foldl (\a b -> a e >>> b) id rls) st
applyMenuInputRules e rls st = (applyMenuInputRules_ e rls) st
applyMenuInputRules_ e [] = id
applyMenuInputRules_ e (r:rls) = r e >>> applyMenuInputRules_ e rls

-- | Applies game input rules to the GameState
applyGameInputRules :: Event -> [GameInputRule] -> GameState -> GameState
applyGameInputRules e rls st = (applyGameInputRules_ e rls) st
applyGameInputRules_ e [] = id
applyGameInputRules_ e (r:rls) = r e >>> applyGameInputRules_ e rls
