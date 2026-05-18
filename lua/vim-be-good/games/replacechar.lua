local GameUtils = require("vim-be-good.game-utils")

-- The character we substitute into the sentence to create the typo.
-- Chosen to be visually obvious and never appear in game-utils sentences.
local WRONG_CHAR = "?"

local ReplaceChar = {}

function ReplaceChar:new(difficulty, window)
    local round = {
        window = window,
        difficulty = difficulty,
        config = {},
    }
    self.__index = self
    return setmetatable(round, self)
end

-- Static 3-line placeholder; real instructions are injected by render() so
-- they can show the specific character to type.
function ReplaceChar:getInstructions()
    return {"", "", ""}
end

function ReplaceChar:getConfig()
    return { roundTime = GameUtils.difficultyToTime[self.difficulty] }
end

function ReplaceChar:render()
    local sentence = GameUtils.getRandomSentence()

    -- Collect all non-space positions
    local positions = {}
    for i = 1, #sentence do
        if sentence:sub(i, i) ~= ' ' then
            table.insert(positions, i)
        end
    end

    local wrongPos = positions[math.random(#positions)]  -- 1-indexed
    local correctChar = sentence:sub(wrongPos, wrongPos)

    -- Avoid substituting a char with itself
    local wrongChar = WRONG_CHAR
    if correctChar == WRONG_CHAR then
        wrongChar = "X"
    end

    local corruptedLine = sentence:sub(1, wrongPos - 1) .. wrongChar .. sentence:sub(wrongPos + 1)

    local instructions = {
        string.format("Replace '%s' with '%s' using:  r%s", wrongChar, correctChar, correctChar),
        "r<char> replaces the character under the cursor without entering Insert mode",
        "",
    }
    self.window.buffer:setInstructions(instructions)

    self.config = { expectedLine = sentence }

    local lines = GameUtils.createEmpty(3)
    lines[2] = corruptedLine

    local col = wrongPos - 1  -- 0-indexed column for nvim_win_set_cursor
    return lines, 2, col
end

function ReplaceChar:checkForWin()
    local lines = self.window.buffer:getGameLines()
    return (lines[2] or "") == self.config.expectedLine
end

function ReplaceChar:name()
    return "replace-char"
end

return ReplaceChar
