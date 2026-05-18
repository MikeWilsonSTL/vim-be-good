local GameUtils = require("vim-be-good.game-utils")

-- ── motion definitions ─────────────────────────────────────────────────────
--
-- Each entry has:
--   instructions  — exactly 3 lines (matches placeholder length in getInstructions)
--   build()       — returns lines, cursorLine, cursorCol, winFn

local motions = {}

-- Vd: visual-line select then delete
motions[1] = {
    instructions = {
        "Delete the current line using visual line mode: Vd",
        "V selects the entire line;  d deletes the selection",
        "",
    },
    build = function()
        local lines = {
            GameUtils.getRandomSentence(),
            "VISUAL_DELETE_ME",
            GameUtils.getRandomSentence(),
        }
        return lines, 2, 0, function(gameLines)
            for _, l in ipairs(gameLines) do
                if l == "VISUAL_DELETE_ME" then return false end
            end
            return true
        end
    end,
}

-- viwd: visual inner-word select then delete (cursor inside word)
motions[2] = {
    instructions = {
        "Delete the inner word using: viwd",
        "v enters visual mode, iw selects the word, d deletes — cursor can be anywhere in the word",
        "",
    },
    build = function()
        local marker = "SELECTME"
        local prefix = "apple "
        local line = prefix .. marker .. " banana"
        local midOffset = math.floor(#marker / 2)
        local col = #prefix + midOffset
        return {"", line, ""}, 2, col, function(gameLines)
            return not (gameLines[2] or ""):find(marker, 1, true)
        end
    end,
}

-- VGd: visual line to end-of-file then delete
motions[3] = {
    instructions = {
        "Delete from the cursor to the last line using: VGd",
        "V enters visual line mode, G extends to end of file, d deletes",
        "",
    },
    build = function()
        local keepLine = GameUtils.getRandomSentence()
        local lines = {keepLine, "DELETEFROM", "also delete this", "and this too"}
        return lines, 2, 0, function(gameLines)
            for _, l in ipairs(gameLines) do
                if l == "DELETEFROM" then return false end
            end
            return true
        end
    end,
}

-- ── Visual class ───────────────────────────────────────────────────────────

local Visual = {}

function Visual:new(difficulty, window)
    local round = {
        window = window,
        difficulty = difficulty,
        winFn = nil,
    }
    self.__index = self
    return setmetatable(round, self)
end

-- Static 3-line placeholder; actual instructions are injected in render().
function Visual:getInstructions()
    return {"", "", ""}
end

function Visual:getConfig()
    return { roundTime = GameUtils.difficultyToTime[self.difficulty] }
end

function Visual:render()
    local motion = motions[math.random(#motions)]
    local lines, cursorLine, cursorCol, winFn = motion.build()

    self.winFn = winFn
    self.window.buffer:setInstructions(motion.instructions)

    return lines, cursorLine, cursorCol
end

function Visual:checkForWin()
    if not self.winFn then return false end
    return self.winFn(self.window.buffer:getGameLines())
end

function Visual:name()
    return "visual"
end

return Visual
