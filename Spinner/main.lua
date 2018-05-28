local Vertex = {}

function Vertex:new(x, y, z)
    local v = {
        x = x,
        y = y,
        z = z
    }
    self.__index = self
	return setmetatable(v, self)
end

function Vertex:toCenter(width, height)
    self.x = self.x + width / 2.0 
    self.y = self.y + height / 2.0
    return self
end

local Triangle = {}

function Triangle:new(v1, v2, v3, color)
    local t = {
        v1 = v1,
        v2 = v2,
        v3 = v3,
        color = color
    }
    self.__index = self
    return setmetatable(t, self)
end

local Matrix3 = {
    __mul = function(m1, m2) 
        local result = {0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0}
        for row = 0, 2 do
            for col = 0, 2 do
                for i = 0, 2 do
                    result[row * 3 + col + 1] = result[row * 3 + col + 1] + m1.values[row * 3 + i + 1] * m2.values[i * 3 + col + 1];
                end
            end
        end
        return result
    end
}

function Matrix3:new(array)
    local m3 = {
        values = array
    }
    self.__index = self
    return setmetatable(m3, self)
end

function Matrix3:transform(v)
    return Vertex:new(
        v.x * self.values[1] + v.y * self.values[4] + v.z * self.values[7],
        v.x * self.values[2] + v.y * self.values[5] + v.z * self.values[8],
        v.x * self.values[3] + v.y * self.values[6] + v.z * self.values[9]
    )
end

function newSquare()
    square = {}
    table.insert(square, Triangle:new(
        Vertex:new(100.0, 100.0, 100.0),
        Vertex:new(-100.0, -100.0, 100.0),
        Vertex:new(-100.0, 100.0, -100.0), { r = 1, g = 1, b = 1}))
    table.insert(square, Triangle:new(
        Vertex:new(100.0, 100.0, 100.0),
        Vertex:new(-100.0, -100.0, 100.0),
        Vertex:new(100.0, -100.0, -100.0), { r = 1, g = 0, b = 0}))
    table.insert(square, Triangle:new(
        Vertex:new(-100.0, 100.0, -100.0),
        Vertex:new(100.0, -100.0, -100.0),
        Vertex:new(100.0, 100.0, 100.0), { r = 0, g = 1, b = 0}))
    table.insert(square, Triangle:new(
        Vertex:new(-100.0, 100.0, -100.0),
        Vertex:new(100.0, -100.0, -100.0),
        Vertex:new(-100.0, -100.0, 100.0), { r = 0, g = 0, b = 1}))
    return square
end

function love.load()
    width = 800
    height = 800
    love.window.setMode(width, height)
    verticalAngle = 0
    horizontalAngle = 0
    tetrahedron = newSquare()
end

function love.update(dt)
    if love.keyboard.isDown("escape") then
        love.event.quit()
    end

    horizontalAngle = (horizontalAngle + dt * 20) % 360
    verticalAngle = (verticalAngle + dt * 20) % 360

    local heading = math.rad(horizontalAngle)
    headingTransform = Matrix3:new({
        math.cos(heading), 0.0, -math.sin(heading),
        0.0, 1.0, 0.0,
        math.sin(heading), 0.0, math.cos(heading)
    });

    local pitch = math.rad(verticalAngle)
    pitchTransform = Matrix3:new({
        1.0, 0.0, 0.0,
        0.0, math.cos(pitch), math.sin(pitch),
        0.0, -math.sin(pitch), math.cos(pitch)
    })

    transformation = Matrix3:new(headingTransform * pitchTransform)
end

function drawWireFrame(v1, v2, v3)
    love.graphics.line(v1.x, v1.y, v2.x, v2.y)
    love.graphics.line(v2.x, v2.y, v3.x, v3.y)
    love.graphics.line(v3.x, v3.y, v1.x, v1.y)
end

function love.draw()
    love.graphics.setBackgroundColor(0, 0,0, 0)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(love.timer.getFPS(), 10, 10)
    for i = 1, #square do
        local triangle = square[i]
        local v1 = transformation:transform(triangle.v1):toCenter(width, height)
        local v2 = transformation:transform(triangle.v2):toCenter(width, height)
        local v3 = transformation:transform(triangle.v3):toCenter(width, height)
        drawWireFrame(v1, v2, v3)
    end
end