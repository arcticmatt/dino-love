local Class  = require("libs.hump.class")
local Entity = require("entities.Entity")

local Ground = Class{
  __includes = Entity -- Ground class inherits our Entity class
}

function Ground:init(world, x, y, w, h)
  Entity.init(self, world, x, y, w, h)
  self.color = {0,0,255}

  self.world:add(self, self:getRect())
end

function Ground:draw()
  love.graphics.setColor(unpack(self.color))
  love.graphics.rectangle("fill", self:getRect())
end

return Ground
