module Game.Structure.Internal (
    World(..),
    Agent(..),
    AgentBehaviour(..),
) where

import System.Random
import Engine.Core.Base
import Engine.Graphics.Base
import Game.Agents.AgentTypes
import Game.Input.Base
import Game.Level.Base

{- Data structures -}
data World = World {
                 level :: Level,
                 agents :: [Agent],
                 rng :: StdGen
             } deriving (Show)

-- | Behaviour by which an agent moves
data AgentBehaviour = AIBehaviour (Float -> Agent -> World -> Direction) | InputBehaviour InputData

data Agent = Agent {
                 agentType :: AgentType,
                 position :: Coordinate,
                 direction :: Direction,
                 speed :: Float,
                 sprite :: Sprite,
                 behaviour :: AgentBehaviour,
                 lastTurn :: Pos
             } deriving (Show)

{- Classes -}


{- Instances -}
instance Show AgentBehaviour where
    show (AIBehaviour _) = "AI"
    show (InputBehaviour inputData) = show inputData

{- Functions -}
