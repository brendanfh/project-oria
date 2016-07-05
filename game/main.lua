require "lib/mod"

import {
    Game = "src.game:";
}

local game = nil
function love.load()
    math.randomseed(love.timer.getTime())
    game = Game()
end

function love.update(dt)
    if love.keyboard.isDown "escape" then
        love.event.quit()
    end
    game:update(dt)
end

function love.draw()
    game:draw()
end
