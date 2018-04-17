require "../MoveableEntity"

function love.load()
    gameboard = {
        width = 720,
        height = 480
    }
    horisontal_draw_scale = 1
	vertical_draw_scale = 1
    love.window.setMode( gameboard.width, gameboard.height, { resizable = true, fullscreen = false } )
    vel = Velocity:new(5, 20)
    entities = {}; targets = {};
    --for i = 0, 20 do
        --table.insert(targets, { x = i * 10, y = i * 10})
        --table.insert(entities, Entity:new(1 * i, 1 * i, vel))
    --end
    table.insert(targets, {x = 360, y = 240})
    table.insert(entities, Entity:new(340, 50, vel))
end

function love.update(dt)
    for i = 1, #targets do
        local target = targets[i]
        local entity = entities[i]
        entity:move(dt, target, 1)
    end
end

function love.draw()
    for i = 1, #entities do
        local entity = entities[i]
        local target = targets[i]
        love.graphics.setColor(0,0,1)
        love.graphics.rectangle( "fill", target.x, target.y, 1, 1 )
        love.graphics.setColor(1,1,1)
        love.graphics.rectangle( "fill", entity.x, entity.y, 1, 1 )
        love.graphics.print( "Dist: " .. tostring(math.sqrt(math.pow(target.x - entity.x, 2) + math.pow(target.y - entity.y, 2))) , 20, 50)
    end
    love.graphics.print( "Vel x: " .. tostring(entities[1].velocity.speedX) , 20, 80)
    love.graphics.print( "Vel y: " .. tostring(entities[1].velocity.speedY) , 20, 90)
end

function love.resize(width, height)
	horisontal_draw_scale = width / gameboard.width
	vertical_draw_scale = height / gameboard.height
end