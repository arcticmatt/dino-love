Gamestate      = require("libs.hump.gamestate")
local dinoGame = require("gamestates.dinoGame")

function love.load()
  Gamestate.registerEvents()
  Gamestate.switch(dinoGame)
end

function love.keypressed(key)
  if key == "escape" or key == "q" then
    love.event.push("quit")
  end
end
