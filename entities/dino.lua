local Class  = require("libs.hump.class")
local Entity = require("entities.Entity")

local Dino = Class{
  __includes = Entity -- Player class inherits our Entity class
}

function Dino:init(world, x, y, w, h)
  Entity.init(self, world, x, y, w, h)
  self.color = {255,0,0}

  self.world:add(self, self:getRect())
end

function Dino:update(dt)
  -- if love.keyboard.isDown("up", "w") then
  -- end
end

function Dino:draw()
  love.graphics.setColor(unpack(self.color))
  love.graphics.rectangle("fill", self:getRect())
end

return Dino
