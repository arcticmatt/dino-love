local Class  = require("libs.hump.class")
local Entity = require("entities.Entity")
local Types  = require("entities.Types")
local Colors = require("utils.Colors")

local Dino = Class{
  __includes = Entity -- Player class inherits our Entity class
}

local Directions = { up = "up", down = "down", duck = "duck", still = "still" }

function Dino:init(world, x, y, w, h)
  Entity.init(self, world, x, y, w, h)
  self.standHeight = h
  self.duckHeight  = h / 2
  self.standY      = y
  self.duckY       = y + self.duckHeight
  self.color = Colors.white
  self.direction = Directions.still

  -- Movement (only y-direction)
  self.yVelocity = 0
  self.yAcc      = 600
  self.yMaxSpeed = 20
  self.gravity   = 70
  self.atMaxHeight = false
  self.friction  = 5 -- air friction???

  -- Set type
  self.type = Types.dino

  self.gameover = false

  self.world:add(self, self:getRect())
end

function Dino:standOrDuck()
  if self:isDir(Directions.duck) then
    self.h = self.duckHeight
    self.y = self.duckY
    -- IMPORTANT! need to update the world
    self.world:update(self, self:getRect())
  else
    self.h = self.standHeight
    -- Note: don't need to update self.y, bump will do that for us
    -- IMPORTANT! need to update the world
    self.world:update(self, self:getRect())
  end
end

function Dino:update(dt)
  -- Handle key DOWNS
  if love.keyboard.isDown("up") then self:setDirection(Directions.up) end
  if love.keyboard.isDown("down") then self:setDirection(Directions.duck) end

  -- Handle going UP
  if self:isDir(Directions.up) then
    if -self.yVelocity < self.yMaxSpeed and not self.hasReachedMax then
      self.yVelocity = self.yVelocity - self.yAcc * dt
    elseif math.abs(self.yVelocity) > self.yMaxSpeed then
      self.hasReachedMax = true
      self.direction = Directions.down
    end
  end

  -- Apply FRICTION
  self.yVelocity = self.yVelocity * (1 - math.min(dt * self.friction, 1))

  -- Apply GRAVITY
  if self:isDir(Directions.still) or self:isDir(Directions.duck) then
    self.yVelocity = 0
  else
    self.yVelocity = self.yVelocity + self.gravity * dt
  end


  -- Handle ducking/not ducking
  -- Need to do this after moving, otherwise stuff gets messed up
  self:standOrDuck()

  -- MOVE dino, taking into account COLLISIONS
  local goalY = self.y + self.yVelocity
  self.x, self.y, collisions, len = self.world:move(self, self.x, goalY)

  for i, c in ipairs(collisions) do
    if c.other:getType() == Types.barrier then
      self.gameover = true
    elseif c.other:getType() == Types.ground and c.normal.y == -1 then -- dino hit the ground
      self.hasReachedMax = false
      if self:isDir(Directions.down) then
        self.direction = Directions.still
      end
    end
  end
end

function Dino:isDir(dir)
  return self.direction == dir
end

-- Used for handling key presses/downs
function Dino:setDirection(newDir)
  if newDir == Directions.up and self:isDir(Directions.still) then
    self.direction = newDir
  elseif newDir == Directions.duck and self:isDir(Directions.still) then
    self.direction = newDir
  elseif newDir == Directions.down or newDir == Directions.still then
    self.direction = newDir
  end
end

function Dino:draw()
  love.graphics.setColor(unpack(self.color))
  love.graphics.rectangle("fill", self:getRect())
end

function Dino:keyToDir(key)
  if key == "up" then
    return Directions.up
  elseif key == "down" then
    return Directions.down
  elseif key == "duck" then -- note: technically "duck" is not a key
    return Directions.duck
  else
    return Directions.still
  end
end

return Dino
