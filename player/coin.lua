coin = {}

function coin:new(coinX, coinY)
	local object = {
		x = coinX,
		y = coinY,
		width = 32,
		height = 32,
		frame = 1,
		delay = 200,
		delta = 0,
		maxDelta = 10
	}
	setmetatable(object, { __index = coin } )
	return object
end

function coin:update(dt)
	self.delta = self.delta + self.delay * dt
	
	if self.delta >= self.maxDelta then
		self.frame = self.frame % 20 + 1
		self.delta = 0
	end
end

function coin:isColliding(map)
	local tileX, tileY = math.floor(self.x / map.tileWidth), math.floor(self.y / map.tileHeight)
	local layer = map.tl["Coins"]
	
	local tile = layer.tileData(tileX, tileY)
	
	return tile == nil
end

function coin:touchesObject(object)
	local cx1, cx2 = self.x - self.width / 2, self.x + self.width / 2 - 1
	local cy1, cy2 = self.y - self.height / 2, self.y + self.height / 2 - 1
	local px1, px2 = object.x - object.width / 2, object.x + object.width / 2 - 1
	local py1, py2 = object.y - object.height / 2, object.y + object.height / 2 - 1
	
	return ((cx2 >= px1) and (cx1 <= px2) and (cy2 >= py1) and (cy1 <= py2))
end