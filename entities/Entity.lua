local Class = require("libs.hump.class")
local Types = require("entities.Types")

local Entity = Class{}

-- Superclass of all entities
function Entity:init(world, x, y, w, h)
  self.world = world
  self.x = x
  self.y = y
  self.w = w
  self.h = h
  self.type = Types.entity -- default type
end

function Entity:getRect()
  return self.x, self.y, self.w, self.h
end

function Entity:draw()
  -- Do nothing by default, but we still have something to call
end

function Entity:update(dt)
  -- Do nothing by default, but we still have something to call
end

function Entity:getType()
  return self.type
end

return Entity
