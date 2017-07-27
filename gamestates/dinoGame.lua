local bump      = require("libs.bump.bump")
local Gamestate = require("libs.hump.gamestate")
local serpent   = require("libs.serpent.src.serpent")
local Entities  = require("entities.Entities")
local Entity    = require("entities.Entity")
local Colors    = require("utils.Colors")
local Levels    = require("utils.Levels")

-- Create our Gamestate
local DinoGame = {}

-- Import needed entities
local Dino    = require("entities.dino")
local Ground  = require("entities.ground")
local Barrier = require("entities.barrier")

-- Filesystem stuff
local FNAME = "dinoscores"
local MAX_ENTRIES = 5

-- Level stuff
local levelDiff = 150
local baseSpeed = 350

-- Global vars
dino = nil
ground = nil

function DinoGame:enter()
  -- Restart stuff
  -- Clear entities (need for restarting, but good practice anyways)
  Entities:clear()
  self:saveScore()

  -- Font size is different than menu and gameover screens
  love.graphics.setFont(love.graphics.newFont(14))

  -- Seed random!
  math.randomseed(os.time())

  -- We need collisions
  self.world = bump.newWorld(16)

  -- Initialize our Entity System
  Entities:enter(self.world)
  local gWidth, gHeight = love.graphics.getWidth(), 30
  local gX, gY          = 0, love.graphics.getHeight() - gHeight
  ground = Ground(self.world, gX, gY, gWidth, gHeight)
  local dWidth, dHeight = 30, 60
  local dX, dY          = 40, gY - dHeight
  dino = Dino(self.world, dX, dY, dWidth, dHeight)

  -- Initialize some useful vars
  self.groundY = gY
  self.paused = false
  self.score = 0
  self.scoreTable = {}
  self.level = 1 -- one-indexing!!!
  self.speed = baseSpeed -- increases with score

  -- Add dino and ground
  Entities:addMany({dino, ground})
end

function DinoGame:update(dt)
  if not Entities:gameover() and not self.paused then
    self:shouldAddBarrier()
    Entities:update(dt)
    self:updateScore()
    self:updateLevel()
    self:updateSpeed()
    Entities:removeFirstBarrier()
  end
end

function DinoGame:updateScore()
  -- Note: we only display the integer part of the score
  self.score = self.score + 0.2
end

function DinoGame:updateLevel()
  -- use math.ceil cause 1-indexing
  local level = math.ceil(self.score / levelDiff)
  if level > #Levels then level = #Levels end
  self.level = level
end

function DinoGame:updateSpeed()
  -- Increase speed by 100 every time the score goes up by 500
  -- i.e. increase = (score / 300) * 100
  local increase = (self.score / 5) * 1
  -- Cap speed at 600
  self.speed = math.min(baseSpeed + increase, 600)
end

-- This function adds a barrier (if we should)
function DinoGame:shouldAddBarrier()
  lastBarrier = Entities:getLastBarrier()
  local level = Levels[self.level]
  local dist = math.random(unpack(level.dists))

  -- Add barrier if last barrier is a certain distance from right edge, or
  -- if there are no current barriers.
  if lastBarrier then
    fromEdgeDist = love.graphics.getWidth() - lastBarrier:rightPos()
    if fromEdgeDist > dist then
      self:addBarrier()
    end
  else
    self:addBarrier()
  end
end

-- This function adds a new barrier
function DinoGame:addBarrier()
  local level = Levels[self.level]
  local width = math.random(unpack(level.widths))
  local height = math.random(unpack(level.heights))
  local y = self.groundY - height
  if math.random() < .25 then y = y - 50 end

  newBarrier = Barrier(self.world, love.graphics.getWidth(), y, width, height)
  newBarrier:setSpeed(self.speed)
  Entities:add(newBarrier)
end

function DinoGame:draw()
  Entities:draw()
  love.graphics.setColor(Colors.white)
  love.graphics.print(string.format("score: %d", math.floor(self.score)), 10, 10)
  -- love.graphics.print(math.floor(self.speed), 10, 25)
  if Entities:gameover() then
    love.graphics.setColor(Colors.red)
    local y = 125
    local inc = 25
    love.graphics.printf("gameover",0,y, love.graphics.getWidth(), "center")
    -- Save and display high scores
    local highscores = self:getHighscores()
    love.graphics.setColor(Colors.green)
    if #highscores < MAX_ENTRIES or self.score > highscores[#highscores] then
      love.graphics.printf(string.format("New highscore! %d", self.score),
                           0,y + inc, love.graphics.getWidth(), "center")
    end
    for k,v in ipairs(highscores) do
      local scoreStr = string.format("%d) %d", k, v)
      love.graphics.printf(scoreStr,0,y + inc + inc * k, love.graphics.getWidth(), "center")
    end
  end
end

function DinoGame:keypressed(key)
  if key == "up" then
    dino:setDirection(dino:keyToDir(key))
  elseif key == "down" then
    dino:setDirection(dino:keyToDir("duck"))
  end
end

function DinoGame:keyreleased(key)
  if key == "up" then
    dino:setDirection(dino:keyToDir("down"))
  elseif key == "down" then
    dino:setDirection(dino:keyToDir("still"))
  elseif key == "p" then
    self.paused = not self.paused
  elseif key == "r" then
    Gamestate.enter(DinoGame) -- restart
  end
end

function DinoGame:quit()
  self:saveScore()
end

-- Call when we quit or restart
function DinoGame:saveScore()
  if self.score then
    local savedTable = self:getHighscores()
    -- Add new score to table, preserving sortedness
    -- Add if we haven't reached MAX_ENTRIES, or if the current score is
    -- greater than the least entry.
    if #savedTable < MAX_ENTRIES or savedTable[MAX_ENTRIES] < self.score then
      if #savedTable >= MAX_ENTRIES then table.remove(savedTable) end
      table.insert(savedTable, self.score)
      table.sort(savedTable, function(a, b) return a > b end) -- descending
    end

    -- Save table, overwriting old one
    love.filesystem.write(FNAME, serpent.dump(savedTable))
  end
end

function DinoGame:getHighscores()
  -- Retrieve serialized table
  local savedText = love.filesystem.read(FNAME)
  -- Deserialize it (use empty table if savedText is nil)
  local savedTable = {}
  if savedText then _, savedTable = serpent.load(savedText) end
  -- Return it
  return savedTable
end

return DinoGame
