local log = require("vim-be-good.log")
local GameUtils = require("vim-be-good.game-utils")
local SnakeGame = require("vim-be-good.games.snakelib.snakegame")
local T = require("vim-be-good.types")

local Snake = {}

function Snake:new(difficulty, window)
    local getDifficultyLevel = function(d)
        for i, val in ipairs(T.difficulty) do
            if d == val then
                return i
            end
        end
        return 0
    end
    local round = {
        window = window,
        difficulty = difficulty,
        difficultyLevel = getDifficultyLevel(difficulty),
        endRoundCallback = nil,
    }
    self.__index = self
    return setmetatable(round, self)
end

function Snake:getInstructions()
    return {
        '',
        'Classic game of Snake.  Use hjkl to steer.',
        '  h = left   j = down   k = up   l = right',
        'Eat food (O) to grow your snake.',
        "Don't run into your own body!",
        'On higher difficulties walls kill you.',
        '',
    }
end

function Snake:getConfig()
    log.info("getConfig", self.difficulty, GameUtils.difficultyToTime[self.difficulty])
    return {
        roundTime = 1000000,
        noCursor = true,
        canEndRound = true,
    }
end

function Snake:checkForWin()
    return false
end

function Snake:name()
    return 'snake'
end

-- Called by game-runner so the snake game can signal when a round is over.
function Snake:setEndRoundCallback(cb)
    self.endRoundCallback = cb
end

-- Bugfix (upstream afd8b21): return directly rather than via local variables.
function Snake:render()
    if self.snakeGame then
        self.snakeGame:shutdown(nil)
    end
    self.snakeGame = SnakeGame:new(35, 15, self.difficultyLevel, self.endRoundCallback)
    self.snakeGame:start()
    return {''}, 1
end

return Snake
