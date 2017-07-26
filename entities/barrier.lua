local Class  = require("libs.hump.class")
local Entity = require("entities.Entity")
local Types = require("entities.Types")

local Barrier = Class{
  __includes = Entity -- Ground class inherits our Entity class
}

function Barrier:init(world, x, y, w, h)
  Entity.init(self, world, x, y, w, h)
  self.color = {0,255,0}
  self.speed = 500

  -- Set type
  self.type = Types.barrier

  self.gameover = false

  self.world:add(self, self:getRect())
end

function Barrier:rightPos()
  return self.x + self.w
end

-- function Barrier:leftPos()
--   return self.x
-- end

function Barrier:offRight()
  return self:rightPos() < 0
end

function Barrier:update(dt)
  -- For now, just move it to the left
  self.x, self.y, collisions = self.world:move(self, self.x - self.speed * dt, self.y)

  for i, c in pairs(collisions) do
    if c.other:getType() == Types.dino then
      self.gameover = true
    end
  end
end

function Barrier:draw()
  love.graphics.setColor(unpack(self.color))
  love.graphics.rectangle("fill", self:getRect())
end

return Barrier
