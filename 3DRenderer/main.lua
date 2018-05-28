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

function newTetrahedron()
    tetrahedron = {}
    table.insert(tetrahedron, Triangle:new(
        Vertex:new(100.0, 100.0, 100.0),
        Vertex:new(-100.0, -100.0, 100.0),
        Vertex:new(-100.0, 100.0, -100.0), { r = 1, g = 1, b = 1}))
    table.insert(tetrahedron, Triangle:new(
        Vertex:new(100.0, 100.0, 100.0),
        Vertex:new(-100.0, -100.0, 100.0),
        Vertex:new(100.0, -100.0, -100.0), { r = 1, g = 0, b = 0}))
    table.insert(tetrahedron, Triangle:new(
        Vertex:new(-100.0, 100.0, -100.0),
        Vertex:new(100.0, -100.0, -100.0),
        Vertex:new(100.0, 100.0, 100.0), { r = 0, g = 1, b = 0}))
    table.insert(tetrahedron, Triangle:new(
        Vertex:new(-100.0, 100.0, -100.0),
        Vertex:new(100.0, -100.0, -100.0),
        Vertex:new(-100.0, -100.0, 100.0), { r = 0, g = 0, b = 1}))
    return tetrahedron
end


local camera = {
    250, 250, 250
}

function love.load()
    width = 800
    height = 800
    love.window.setMode(width, height)
    horizontalAngle = 0
    verticalAngle = 0
    tetrahedron = newTetrahedron()
    asWireFrame = false
    nextWireframetransition = love.timer.getTime()
end

function love.update(dt)
    if love.keyboard.isDown("escape") then
        love.event.quit()
    end
    local left = love.keyboard.isDown("a")
    local right = love.keyboard.isDown("d")
    local inwards = love.keyboard.isDown("q")
    local outwards = love.keyboard.isDown("e")
    local up = love.keyboard.isDown("w")
    local down = love.keyboard.isDown("s")
    local reset = love.keyboard.isDown("r")
    local wireframe = love.keyboard.isDown("space")
    if wireframe and love.timer.getTime() > nextWireframetransition then
        asWireFrame = not asWireFrame
        nextWireframetransition = love.timer.getTime() + 0.5
    end
    if reset then tetrahedron = newTetrahedron() end
    -- following controls are currently worthless
    if inwards or outwards then
        local sign = 0;
        if inwards then sign = sign + 1 end
        if outwards then sign = sign - 1 end
        for i = 1, #tetrahedron do
            tetrahedron[i].v1.z = tetrahedron[i].v1.z + sign * dt * 100
            tetrahedron[i].v2.z = tetrahedron[i].v2.z + sign * dt * 100
            tetrahedron[i].v3.z = tetrahedron[i].v3.z + sign * dt * 100
        end
    end
    if left or right then
        local sign = 0;
        if left then sign = sign + 1 end
        if right then sign = sign - 1 end
        for i = 1, #tetrahedron do
            tetrahedron[i].v1.x = tetrahedron[i].v1.x + sign * dt * 100
            tetrahedron[i].v2.x = tetrahedron[i].v2.x + sign * dt * 100
            tetrahedron[i].v3.x = tetrahedron[i].v3.x + sign * dt * 100
        end
    end
    if up or down then
        local sign = 0;
        if up then sign = sign + 1 end
        if down then sign = sign - 1 end
        for i = 1, #tetrahedron do
            tetrahedron[i].v1.y = tetrahedron[i].v1.y + sign * dt * 100
            tetrahedron[i].v2.y = tetrahedron[i].v2.y + sign * dt * 100
            tetrahedron[i].v3.y = tetrahedron[i].v3.y + sign * dt * 100
        end
    end
    horizontalAngle = (horizontalAngle + dt * 40) % 360
    verticalAngle = (verticalAngle + dt * 20) % 360
    local heading = math.rad(horizontalAngle);
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
    zBuffer = {}
    for i = 1, width * height do
        zBuffer[i] = -math.huge
    end
end

function drawWireFrame(v1, v2, v3)
    love.graphics.line(v1.x, v1.y, v2.x, v2.y)
    love.graphics.line(v2.x, v2.y, v3.x, v3.y)
    love.graphics.line(v3.x, v3.y, v1.x, v1.y)
end

function scaleBy(scale, v)
    v.x = v.x * scale
    v.y = v.y * scale
    v.z = v.z * scale
end

function drawWithDepthBuffer(v1, v2, v3, color)
    local ab = Vertex:new(v2.x - v1.x, v2.y - v1.y, v2.z - v1.z)
    local ac = Vertex:new(v3.x - v1.x, v3.y - v1.y, v3.z - v1.z)
    local normal = Vertex:new(
        ab.y * ac.z - ab.z * ac.y,
        ab.z * ac.x - ab.x * ac.z,
        ab.x * ac.y - ab.y * ac.x
    )
    local normalLength = math.sqrt(normal.x * normal.x + normal.y * normal.y + normal.z * normal.z)
    normal.x = normal.x / normalLength
    normal.y = normal.y / normalLength
    normal.z = normal.z / normalLength
    local angleCos = math.abs(normal.z)
    local minX = math.floor(math.max(0.0, math.ceil(math.min(v1.x, math.min(v2.x, v3.x)))))
    local maxX = math.floor(math.min((width - 1), math.floor(math.max(v1.x, math.max(v2.x, v3.x)))))
    local minY = math.floor(math.max(0.0, math.ceil(math.min(v1.y, math.min(v2.y, v3.y)))))
    local maxY = math.floor(math.min((height - 1), math.floor(math.max(v1.y, math.max(v2.y, v3.y)))))
    local triangleArea = (v1.y - v3.y) * (v2.x - v3.x) + (v2.y - v3.y) * (v3.x - v1.x)
    for y = minY, maxY do
        for x = minX, maxX do
            local b1 = ((y - v3.y) * (v2.x - v3.x) + (v2.y - v3.y) * (v3.x - x)) / triangleArea
            local b2 = ((y - v1.y) * (v3.x - v1.x) + (v3.y - v1.y) * (v1.x - x)) / triangleArea
            local b3 = ((y - v2.y) * (v1.x - v2.x) + (v1.y - v2.y) * (v2.x - x)) / triangleArea
            if b1 >= 0.0 and b1 <= 1.0 and b2 >= 0.0 and b2 <= 1.0 and b3 >= 0.0 and b3 <= 1.0 then
                local depth = b1 * v1.z + b2 * v2.z + b3 * v3.z
                local zIndex = y * width + x
                if (zBuffer[zIndex] < depth) then
                    love.graphics.setColor(getShade(color, angleCos))
                    love.graphics.points(x, y)
                    zBuffer[zIndex] = depth
                end
            end
        end
    end
end

function love.draw()
    love.graphics.setBackgroundColor(0, 0,0, 0)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(love.timer.getFPS(), 10, 10)
    for i = 1, #tetrahedron do
        local triangle = tetrahedron[i]
        local v1 = transformation:transform(triangle.v1):toCenter(width, height)
        local v2 = transformation:transform(triangle.v2):toCenter(width, height)
        local v3 = transformation:transform(triangle.v3):toCenter(width, height)

        if asWireFrame then
            drawWireFrame(v1, v2, v3)
        else
            drawWithDepthBuffer(v1, v2, v3, triangle.color)
        end
    end
end

function getShade(color, shade)
    local redLinear = math.pow(color.r, 2.4) * shade
    local greenLinear = math.pow(color.g, 2.4) * shade
    local blueLinear = math.pow(color.b, 2.4) * shade
    local red = math.pow(redLinear, 1 / 2.4)
    local green = math.pow(greenLinear, 1 / 2.4)
    local blue = math.pow(blueLinear, 1 / 2.4)
    return red, green, blue
end

function inflate() end