local GameUtils = require("vim-be-good.game-utils")

-- ── motion definitions ─────────────────────────────────────────────────────
--
-- Each motion table has:
--   instructions  — 3-line array shown to the player
--   build()       — returns lines, cursorLine, cursorCol, winFn
--
-- winFn(gameLines) returns true when the player completed the motion.
-- All motions use exactly 3 game lines and 3 instruction lines so that the
-- cursor offset calculation in game-runner stays consistent.

local motions = {}

-- dd: delete the current line
motions[1] = {
    instructions = {
        "Delete the current line using: dd",
        "dd removes the entire line; the lines below shift up",
        "",
    },
    build = function()
        local a = GameUtils.getRandomSentence()
        local b = GameUtils.getRandomSentence()
        local lines = {a, "DELETE_ME", b}
        return lines, 2, 0, function(gameLines)
            for _, l in ipairs(gameLines) do
                if l == "DELETE_ME" then return false end
            end
            return true
        end
    end,
}

-- D: delete from cursor to end of line (same as d$)
motions[2] = {
    instructions = {
        "Delete from the cursor to the end of the line using: D  (or d$)",
        "The cursor is already placed at the start of the text to remove",
        "",
    },
    build = function()
        local prefix = "keep: "
        local line = prefix .. "CUTHERE remove this part from the line"
        local col = #prefix  -- 0-indexed; cursor lands on "C"
        return {"", line, ""}, 2, col, function(gameLines)
            return not (gameLines[2] or ""):find("CUTHERE", 1, true)
        end
    end,
}

-- dw: delete word forward from cursor (cursor at word start)
motions[3] = {
    instructions = {
        "Delete the word at the cursor using: dw",
        "dw deletes forward from the cursor to the start of the next word",
        "",
    },
    build = function()
        local prefix = "apple banana "
        local marker = "REMOVE"
        local line = prefix .. marker .. " cherry grape"
        local col = #prefix  -- 0-indexed; cursor on first char of REMOVE
        return {"", line, ""}, 2, col, function(gameLines)
            return not (gameLines[2] or ""):find(marker, 1, true)
        end
    end,
}

-- diw: delete inner word with cursor anywhere inside the word
motions[4] = {
    instructions = {
        "Delete the inner word using: diw",
        "diw works even when the cursor is in the middle of the word",
        "",
    },
    build = function()
        local prefix = "left side "
        local marker = "DELWORD"
        local line = prefix .. marker .. " right side"
        -- place cursor in the middle of the marker word
        local midOffset = math.floor(#marker / 2)
        local col = #prefix + midOffset  -- 0-indexed
        return {"", line, ""}, 2, col, function(gameLines)
            return not (gameLines[2] or ""):find(marker, 1, true)
        end
    end,
}

-- ── DMotion class ──────────────────────────────────────────────────────────

local DMotion = {}

function DMotion:new(difficulty, window)
    local round = {
        window = window,
        difficulty = difficulty,
        winFn = nil,
    }
    self.__index = self
    return setmetatable(round, self)
end

-- Returns a static 3-line placeholder so game-runner has a stable length for
-- cursor offset math.  The real instructions are injected in render().
function DMotion:getInstructions()
    return {"", "", ""}
end

function DMotion:getConfig()
    return { roundTime = GameUtils.difficultyToTime[self.difficulty] }
end

function DMotion:render()
    local motion = motions[math.random(#motions)]
    local lines, cursorLine, cursorCol, winFn = motion.build()

    self.winFn = winFn

    -- Override the placeholder instructions with motion-specific ones.
    -- buffer:render() is called by game-runner after this returns, so the
    -- updated instructions are picked up correctly.
    self.window.buffer:setInstructions(motion.instructions)

    return lines, cursorLine, cursorCol
end

function DMotion:checkForWin()
    if not self.winFn then return false end
    return self.winFn(self.window.buffer:getGameLines())
end

function DMotion:name()
    return "dmotion"
end

return DMotion
