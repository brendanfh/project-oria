import {
}

Vector2 = class {
    init = function(self, x, y)
        self.x = x
        self.y = y
    end;

    __add = function(self, other)
        return Vector2(self.x + other.x, self.y + other.y)
    end;

    __sub = function(self, other)
        return Vector2(self.x - other.x, self.y - other.y)
    end;

    __mul = function(self, other)
        if type(other) == "number" then
            return Vector2(self.x * other, self.y * other)
        else
            return Vector2(self.x * other.x, self.y * other.y)
        end;
    end;

    __div = function(self, other)
        if type(other) == "number" then
            return Vector2(self.x / other, self.y / other)
        else
            return Vector2(self.x / other.x, self.y / other.y)
        end;
    end;

    dot = function(self, other)
        return self.x * other.x + self.y + other.y
    end;

    len = function(self)
        return math.sqrt(self:dot(self))
    end;

    normalized = function(self)
        return self / self:len()
    end;

    rotate = function(self, angle, point)
        local sangle = math.atan2(point.y - self.y, point.x - self.x)
        local a = angle + sangle
        local d = (self - point):len()
        return Vector2(d * math.cos(a), d * math.sin(a))
    end;

    pointTo = function(self, p)
        local a = math.atan2(p.y, p.x)
        return Vector2(math.cos(a), math.sin(a))
    end;
}
