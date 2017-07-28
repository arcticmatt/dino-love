local Class  = require("libs.hump.class")
local Entity = require("entities.Entity")
local Types  = require("entities.Types")
local Colors = require("utils.Colors")

local time

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
  time = 0
  self.myShader = love.graphics.newShader[[
  extern number time;
  #define TWO_PI 6.28318530718
  vec3 hsb2rgb( in vec3 c ){
      vec3 rgb = clamp(abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),
                               6.0)-3.0)-1.0,
                       0.0,
                       1.0 );
      rgb = rgb*rgb*(3.0-2.0*rgb);
      return c.z * mix( vec3(1.0), rgb, c.y);
  }
  vec4 effect( vec4 color, Image texture,
  	vec2 texture_coords, vec2 screen_coords ){
  	vec2 st = gl_FragCoord.xy/love_ScreenSize.xy;
      vec3 color2 = vec3(0.0);
      // Use polar coordinates instead of cartesian
      vec2 toCenter = vec2(0.5)-st;
      float angle = atan(toCenter.y,toCenter.x);
      float radius = length(toCenter)*2.0;

      // Map the angle (-PI to PI) to the Hue (from 0 to 1)
      // and the Saturation to the radius
      color2 = hsb2rgb(vec3(sin(time) * (angle/TWO_PI)+0.5,radius,1.0));
      return vec4(color2,1.0);
  }

  ]]
end

function Dino:collisionFilter(other)
  if other:getType() == Types.ground then return "slide"
  elseif other:getType() == Types.barrier then return "touch"
  else return nil
  end
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
  self:standOrDuck()

  -- MOVE dino, taking into account COLLISIONS
  local goalY = self.y + self.yVelocity
  self.x, self.y, collisions, len = self.world:move(self, self.x, goalY, self.collisionFilter)

  -- Handle COLLISIONS
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

  time = time + dt
  self.myShader:send("time",time)
end

-- Helper function
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
  -- love.graphics.setColor(unpack(self.color))
  love.graphics.setShader(self.myShader)
  love.graphics.rectangle("fill", self:getRect())
  love.graphics.setShader()
end

-- Used by DinoGame Gamestate
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
