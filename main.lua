Gamestate      = require("libs.hump.gamestate")
local Menu     = require("gamestates.Menu")

function love.load()
  Gamestate.registerEvents()
  Gamestate.switch(Menu)
end

function love.keypressed(key)
  if key == "escape" or key == "q" then
    love.event.push("quit")
  end
end
