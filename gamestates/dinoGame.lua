bump      = require("libs.bump.bump")
Gamestate = require("libs.hump.gamestate")
local Entities = require("entities.Entities")
local Entity   = require("entities.Entity")
local Colors   = require("utils.Colors")

-- Create our Gamestate
local DinoGame = {}

-- Import needed entities
local Dino    = require("entities.dino")
local Ground  = require("entities.ground")
local Barrier = require("entities.barrier")

-- Global vars
dino = nil
ground = nil

function DinoGame:enter()
  -- Clear entities (need for restarting, but good practice anyways)
  Entities:clear()
  -- Font size is different than menu and gameover screens
  love.graphics.setFont(love.graphics.newFont(14))

  -- We need collisions
  self.world = bump.newWorld(16)

  -- Initialize our Entity System
  Entities:enter(world)
  local gWidth, gHeight = love.graphics.getWidth(), 30
  local gX, gY          = 0, love.graphics.getHeight() - gHeight
  ground = Ground(self.world, gX, gY, gWidth, gHeight)
  local dWidth, dHeight = 30, 60
  local dX, dY          = 20, gY - dHeight
  dino = Dino(self.world, dX, dY, dWidth, dHeight)

  -- Initialize some useful vars
  self.groundY = gY
  self.paused = false
  self.score = 0

  -- Add dino and ground
  Entities:addMany({dino, ground})

  self:addBarrier()

  Entities:getFirstBarrier()
end

function DinoGame:update(dt)
  if not Entities:gameover() and not self.paused then
    -- self:shouldAddBarrier()
    Entities:update(dt)
    self:updateScore()
  end
end

function DinoGame:updateScore()
  -- Note: we only display the integer part of the score
  self.score = self.score + 0.2
end

-- This function adds a barrier (if we should)
function DinoGame:shouldAddBarrier()
  lastBarrier = Entities:getLastBarrier()

  -- Add barrier if last barrier is a certain distance from right edge, or
  -- if there are no current barriers.
  if lastBarrier then
    fromEdgeDist = love.graphics.getWidth() - lastBarrier:rightPos()
    if fromEdgeDist > 100 then -- TODO: constant
      self:addBarrier()
    end
  else
    self:addBarrier()
  end
end

-- This function adds a new barrier
function DinoGame:addBarrier()
  local bWidth, bHeight = 30, 60
  newBarrier = Barrier(self.world, love.graphics.getWidth(), self.groundY - bHeight, bWidth, bHeight)
  Entities:add(newBarrier)
end

function DinoGame:draw()
  Entities:draw()
  love.graphics.setColor(Colors.white)
  love.graphics.print(string.format("score: %d", math.floor(self.score)), 10, 10)
  if Entities:gameover() then
    love.graphics.setColor(Colors.red)
    love.graphics.print("gameover",10,20)
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

return DinoGame
