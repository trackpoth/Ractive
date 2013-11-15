mouse = {}

function mouse:new()
	local object = {
		mouseposx = 0,
		mouseposy = 0,
		crosshairx = 0,
		crosshairy = 0,
		mouseimg = love.graphics.newImage("player/crosshair.png")
	}
	return setmetatable(object, { __index = self })
end

function mouse:update(playerX, playerY)
	self.mouseposx, self.mouseposy = love.mouse.getPosition()
end