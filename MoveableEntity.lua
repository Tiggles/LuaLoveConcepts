Velocity = {}
	
function Velocity:new(delta, max_min)
	newVelocity = {
		speedX = 0,
		speedY = 0,
		delta = delta,
		min = -max_min,
		max = max_min
	}
	self.__index = self
	return setmetatable(newVelocity, self)
end

Entity = {}

function Entity:new(x, y, velocity)
    entity = {
        x = x,
        y = y,
        weight = 1,
        velocity = velocity
    }
    self.__index = self
    return setmetatable(entity, self)
end

function Entity:move(deltaTime, target, gameSpeed)
    local distance = math.sqrt(math.pow(target.x - entity.x, 2) + math.pow(target.y - entity.y, 2))
    if distance > 20 then 
        if target.x < self.x then
            self.velocity.speedX = self.velocity.speedX - self.velocity.delta * deltaTime * gameSpeed
        elseif target.x > self.x then
            self.velocity.speedX = self.velocity.speedX + self.velocity.delta * deltaTime * gameSpeed
        end
        if target.y > self.y then
            self.velocity.speedY = self.velocity.speedY + self.velocity.delta * deltaTime * gameSpeed
        elseif target.y < self.y then
            self.velocity.speedY = self.velocity.speedY - self.velocity.delta * deltaTime * gameSpeed
        end
    elseif distance < 0.1 then
        if self.velocity.speedX > 0 then
            self.velocity.speedX = math.max(self.velocity.speedX - (2 * self.velocity.delta * deltaTime * gameSpeed), 0)
        else 
            self.velocity.speedX = math.min(self.velocity.speedX + (2 *self.velocity.delta * deltaTime * gameSpeed), 0)
        end
        if self.velocity.speedY > 0 then
            self.velocity.speedY = math.max(self.velocity.speedY - (2 * self.velocity.delta * deltaTime * gameSpeed), 0)
        else 
            self.velocity.speedY = math.min(self.velocity.speedY + (2 * self.velocity.delta * deltaTime * gameSpeed), 0)
        end
    else
        if self.velocity.speedX > 0 then
            self.velocity.speedX = math.max(self.velocity.speedX - (self.velocity.delta * deltaTime * gameSpeed), 0)
        else 
            self.velocity.speedX = math.min(self.velocity.speedX + (self.velocity.delta * deltaTime * gameSpeed), 0)
        end
        if self.velocity.speedY > 0 then
            self.velocity.speedY = math.max(self.velocity.speedY - self.velocity.delta * deltaTime * gameSpeed, 0)
        else 
            self.velocity.speedY = math.min(self.velocity.speedY + self.velocity.delta * deltaTime * gameSpeed, 0)
        end
    end

	self.velocity.speedX = math.max(math.min(self.velocity.speedX, self.velocity.max), self.velocity.min)
	self.velocity.speedY = math.max(math.min(self.velocity.speedY, self.velocity.max), self.velocity.min)
	self.x = self.x + (self.velocity.speedX * self.weight * gameSpeed)
	self.y = self.y + (self.velocity.speedY * self.weight * gameSpeed)
end