Gamestate = require("libs.hump.gamestate")
DinoGame  = require("gamestates.DinoGame")

-- Menu Gamestate
local Menu = {}

function Menu:init()
  love.graphics.setFont(love.graphics.newFont(22))
end

function Menu:draw()
  love.graphics.printf("Press Enter to continue", 0,
                       love.graphics.getHeight() / 2,
                       love.graphics.getWidth(), "center")
end

function Menu:keyreleased(key, code)
  if key == "return" then
    Gamestate.switch(DinoGame)
  end
end

return Menu
