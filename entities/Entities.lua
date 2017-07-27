local Types = require("entities.Types")

local Entities = {
  active = true,
  world  = nil,
  entityList = {}
}

function Entities:enter(world)
  self:clear()

  self.world = world
end

-- entityList is an array. This is important; we have order.
function Entities:add(entity)
  table.insert(self.entityList, entity)
  -- IMPORTANT! Entities deals with adding/removing Entity objects from the world!
  self.world:add(entity, entity:getRect())
end

function Entities:addMany(entities)
  for k, entity in pairs(entities) do
    self:add(entity)
  end
end

-- Not currently used
function Entities:remove(entity)
  for i, e in ipairs(self.entityList) do
    if e == entity then
      table.remove(self.entityList, i)
      self.world:remove(e)
      return
    end
  end
end

-- Not currently used
function Entities:removeAt(index)
  e = table.remove(self.entityList, index)
  self.world:remove(e)
end

-- Get rightmost barrier
-- We assume barriers are added at the end of the list (true b/c of Entities:add)
function Entities:getFirstBarrier()
  for i, e in ipairs(self.entityList) do
    if e:getType() == Types.barrier then
      return i, e
    end
  end
end

-- Get leftmost barrier.
function Entities:getLastBarrier()
  local lastEntity = self.entityList[#self.entityList]
  if lastEntity and lastEntity:getType() == Types.barrier then
    return lastEntity
  else
    return nil
  end
end

-- Remove rightmost barrier, if off-screen
function Entities:removeFirstBarrier()
  local i, e = self:getFirstBarrier()
  assert(e:getType() == Types.barrier)
  if e:offRight() then
    table.remove(self.entityList, i)
    -- IMPORTANT! remove from world too
    self.world:remove(e)
  end
end

-- Check if any of the entities indicates gameover
function Entities:gameover()
  for i, e in ipairs(self.entityList) do
    if e.gameover == true then return e.gameover end
  end
  return false
end

function Entities:clear()
  self.world = nil
  self.entityList = {}
end

function Entities:draw()
  for i, e in ipairs(self.entityList) do
    e:draw(i)
  end
end

function Entities:update(dt)
  for i, e in ipairs(self.entityList) do
    e:update(dt, i)
  end
end

return Entities
