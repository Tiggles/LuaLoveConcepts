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
        velocity = velocity
    }
    self.__index = self
    return setmetatable(entity, self)
end

function Entity:moveHorisontally(dt, stall)
    if stall then
        if self.velocity.speedX >= 0 then
            self.velocity.speedX = math.max(self.velocity.speedX - self.velocity.delta * dt, 0) 
        else
            self.velocity.speedX = math.min(self.velocity.speedX + self.velocity.delta * dt, 0) 
        end
        return
    end
    self.velocity.speedX = math.max(math.min(self.velocity.speedX + self.velocity.delta * dt, self.velocity.max), self.velocity.min);
    self.x = self.x + self.velocity.speedX
end

function Entity:moveVertically(dt, stall)
    if stall then
        self.velocity.speedY = math.max(self.velocity.speedY + self.velocity.delta * dt, 0) 
        return
    end
    self.velocity.speedY = math.max(math.min(self.velocity.speedY + self.velocity.delta * dt, self.velocity.max), self.velocity.min);
    self.y = self.y + self.velocity.speedY
end