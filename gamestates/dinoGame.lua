bump      = require("libs.bump.bump")
Gamestate = require("libs.hump.gamestate")
local Entities = require("entities.Entities")
local Entity   = require("entities.Entity")

-- Create our Gamestate
local dinoGame = {}

-- Import needed entities
local Dino   = require("entities.dino")
local Ground = require("entities.ground")

function dinoGame:enter()
  -- We need collisions
  world = bump.newWorld(16)

  -- Initialize our Entity System
  Entities:enter(world)
  local gWidth, gHeight = love.graphics.getWidth(), 30
  local gX, gY          = 0, love.graphics.getHeight() - gHeight
  ground = Ground(world, gX, gY, gWidth, gHeight)
  local dWidth, dHeight = 30, 60
  local dX, dY          = 20, gY - dHeight
  dino = Dino(world, dX, dY, dWidth, dHeight)

  -- Add instances of our entities to the Entity List
  Entities:addMany({dino, ground})
end

function dinoGame:update(dt)
  Entities:update(dt)
end

function dinoGame:draw()
  Entities:draw()
end

return dinoGame
