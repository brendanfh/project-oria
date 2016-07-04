import {
}

width, height = love.window.getMode()
Particle = class {
    init = function(self, x, y)
        self.x = x
        self.y = y
        self.vx = 0
        self.vy = 0
        self.color = { math.random(0, 255), math.random(0, 255), math.random(0, 255) }
    end;

    update = function(self)
        if love.mouse.isDown(1) then
            self.x = love.mouse.getX()
            self.y = love.mouse.getY()
        end

        self.x = self.x + self.vx
        self.y = self.y + self.vy
        self.vx = self.vx * .97
        self.vy = self.vy * .97

        if math.random() > .97 then
            self.vx = math.random() * 4 - 2
            self.vy = math.random() * 4 - 2
        end

        if self.x < 0 then self.x = self.x + width end
        if self.x >= width then self.x = self.x - width end
        if self.y < 0 then self.y = self.y + height end
        if self.y >= height then self.y = self.y - height end
    end;

    draw = function(self)
        love.graphics.setColor(self.color)
        love.graphics.rectangle("fill", self.x, self.y, 32, 32)
    end;
}

Game = class {
    init = function(self)
        self.particles = {}
        for i=0,1000 do
            table.insert(self.particles, Particle(400, 300))
        end
    end;

    update = function(self)
        for k, v in ipairs(self.particles) do
            self.particles[k]:update()
        end
    end;

    draw = function(self)
        love.graphics.clear(0, 0, 0)

        for k, v in ipairs(self.particles) do
            self.particles[k]:draw()
        end
    end;
}

return module { Game }
