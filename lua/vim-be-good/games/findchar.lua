local GameUtils = require("vim-be-good.game-utils")

local TARGET = "@"

local wordList = {
    "the", "quick", "brown", "fox", "jumps", "over", "lazy", "dog",
    "vim", "and", "not", "with", "for", "are", "key", "each",
    "big", "old", "new", "one", "two", "hot", "fast", "good",
    "run", "set", "get", "put", "cut", "hit", "bit", "fit",
    "map", "let", "var", "far", "bar", "hat", "sat", "pat",
}

local distanceRanges = {
    noob      = {min = 3,  max = 7},
    easy      = {min = 7,  max = 14},
    medium    = {min = 12, max = 22},
    hard      = {min = 18, max = 30},
    nightmare = {min = 25, max = 40},
    tpope     = {min = 35, max = 55},
}

local instructions = {
    "Use f@ to jump forward to the @ character, then press x to delete it",
    "Tip: F@ searches backward. Press ; to repeat the last f/F/t/T motion.",
    "",
}

local FindChar = {}

function FindChar:new(difficulty, window)
    local round = {
        window = window,
        difficulty = difficulty,
        config = {},
    }
    self.__index = self
    return setmetatable(round, self)
end

function FindChar:getInstructions()
    return instructions
end

function FindChar:getConfig()
    return { roundTime = GameUtils.difficultyToTime[self.difficulty] }
end

local function buildLine(targetPos)
    local line = ""
    while #line < targetPos - 1 do
        local space = #line > 0 and " " or ""
        local word = wordList[math.random(#wordList)]
        if #line + #space + #word >= targetPos then
            -- pad remainder with spaces so target lands at targetPos
            line = line .. string.rep(" ", targetPos - 1 - #line)
            break
        end
        line = line .. space .. word
    end
    line = line .. TARGET
    for _ = 1, math.random(3, 6) do
        line = line .. " " .. wordList[math.random(#wordList)]
    end
    return line
end

function FindChar:render()
    local range = distanceRanges[self.difficulty] or distanceRanges.medium
    local targetPos = math.random(range.min, range.max)
    local line = buildLine(targetPos)

    self.config = { hasTarget = true }

    local lines = GameUtils.createEmpty(3)
    lines[2] = line
    return lines, 2, 0
end

function FindChar:checkForWin()
    local lines = self.window.buffer:getGameLines()
    local line = lines[2] or ""
    return not line:find(TARGET, 1, true)
end

function FindChar:name()
    return "find-char"
end

return FindChar
