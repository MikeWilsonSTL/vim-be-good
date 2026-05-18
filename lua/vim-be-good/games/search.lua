local GameUtils = require("vim-be-good.game-utils")

local TARGET = "FINDME"

local instructions = {
    "Search for FINDME using /FINDME<Enter>, then delete it with dw",
    "Tip: n jumps to the next match, N goes backward",
    "",
}

local SearchGame = {}

function SearchGame:new(difficulty, window)
    local round = {
        window = window,
        difficulty = difficulty,
        config = {},
    }
    self.__index = self
    return setmetatable(round, self)
end

function SearchGame:getInstructions()
    return instructions
end

function SearchGame:getConfig()
    return { roundTime = GameUtils.difficultyToTime[self.difficulty] }
end

function SearchGame:render()
    local lineCount = 7
    local lines = {}
    for _ = 1, lineCount do
        table.insert(lines, GameUtils.getRandomSentence())
    end

    -- Insert TARGET into a random interior line at a word boundary
    local targetLineIdx = math.random(2, lineCount - 1)
    local words = {}
    for w in lines[targetLineIdx]:gmatch("%S+") do
        table.insert(words, w)
    end
    local insertPos = math.random(1, #words + 1)
    table.insert(words, insertPos, TARGET)
    lines[targetLineIdx] = table.concat(words, " ")

    self.config = { lineCount = lineCount }

    return lines, 1, 0
end

function SearchGame:checkForWin()
    local lines = self.window.buffer:getGameLines()
    for _, line in ipairs(lines) do
        if line:find(TARGET, 1, true) then
            return false
        end
    end
    return true
end

function SearchGame:name()
    return "search"
end

return SearchGame
