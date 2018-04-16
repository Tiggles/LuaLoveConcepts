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
    movingDown = false
    movingUp = false
    movingLeft = false
    movingRight = false
    horisontalStalling = false
    verticalStalling = false
    for i = 1, #targets do
        local target = targets[i]
        local entity = entities[i]
        local distance = math.sqrt(target.x * entity.x + target.y * entity.y)
        if entity.x < target.x then
            entity:moveHorisontally(dt, false);
            movingRight = true
        elseif entity.x > target.x then
            entity:moveHorisontally(-dt, false);
            movingLeft = true
        else
            entity:moveHorisontally(dt, true)
            horisontalStalling = true
        end
        if entity.y < target.y then
            entity:moveVertically(dt, false);
            movingDown = true
        elseif entity.y > target.y then
            entity:moveVertically(-dt, false);
            movingUp = true
        else
            entity:moveVertically(dt, true)
            verticalStalling = true
        end
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
    end
    love.graphics.print( "Moving right: " .. tostring(movingRight), 20, 20)
    love.graphics.print( "Moving left: " .. tostring(movingLeft), 20, 30)
    love.graphics.print( "Moving up: " .. tostring(movingUp), 20, 40)
    love.graphics.print( "Moving down: " .. tostring(movingDown), 20, 50)
    love.graphics.print( "Stalling h: " .. tostring(horisontalStalling), 20, 60)
    love.graphics.print( "Stalling v: " .. tostring(verticalStalling), 20, 70)
    love.graphics.print( "Vel x: " .. tostring(entities[1].velocity.speedX) , 20, 80)
    love.graphics.print( "Vel y: " .. tostring(entities[1].velocity.speedY) , 20, 90)
end

function love.resize(width, height)
	horisontal_draw_scale = width / gameboard.width
	vertical_draw_scale = height / gameboard.height
end