mouse = {}

function mouse:new()
	local object = {
		mousePosX = love.graphics.getWidth() / 2,
		mousePosY = love.graphics.getHeight() / 2,
		mouseimg = love.graphics.newImage("player/crosshair.png")
	}
	return setmetatable(object, { __index = self })
end

function mouse:update(mouseX, mouseY, dt)
	self.mousePosX = self.mousePosX + (mouseX - (width / 2))
	self.mousePosY = self.mousePosY + (mouseY - (height / 2))
end