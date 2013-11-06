Player = {}

function Player:new()
    local object = {
    x = 0,
    y = 0,
    width = 0,
    height = 0,
    xSpeed = 0,
    ySpeed = 0,
    xSpeedMax = 800,
    ySpeedMax = 800,
    state = "",
    jumpSpeed = 0,
    runSpeed = 0,
    onFloor = false
    }
    setmetatable(object, { __index = Player })
    return object
end
 
function Player:jump()
    if self.onFloor then
        self.ySpeed = self.jumpSpeed
        self.onFloor = false
    end
end
 
function Player:moveRight()
    self.xSpeed = self.runSpeed
end
 
function Player:moveLeft()
    self.xSpeed = -self.runSpeed
end
 
function Player:stop()
    self.xSpeed = 0
end
 
function Player:collide(event)
    if event == "floor" then
        self.ySpeed = 0
        self.onFloor = true
    end
    if event == "ceiling" then
        self.ySpeed = 0
    end
end
 
function Player:update(dt, gravity, map)
    local halfX = self.width / 2
    local halfY = self.height / 2
   
    self.ySpeed = self.ySpeed + (gravity * dt)
   
    self.ySpeed = math.clamp(self.ySpeed, -self.ySpeedMax, self.ySpeedMax)
	
    local nextY = math.floor(self.y + (self.ySpeed * dt))
    if self.ySpeed < 0 then
        if not(self:isColliding(map, self.x - halfX + 1, nextY - halfY))
            and not(self:isColliding(map, self.x + halfX - 1, nextY - halfY)) then
            self.y = nextY
            self.onFloor = false
        else
            self.y = nextY + map.tileHeight - ((nextY - halfY) % map.tileHeight)
            self:collide("ceiling")
        end
    elseif self.ySpeed > 0 then
        if not(self:isColliding(map, self.x - halfX + 1, nextY + halfY))
            and not(self:isColliding(map, self.x + halfX - 1, nextY + halfY)) then
            self.y = nextY
            self.onFloor = false
        else
            self.y = nextY - ((nextY + halfY) % map.tileHeight)
            self:collide("floor")
        end
    end
	
    local nextX = self.x + (self.xSpeed * dt)
    if self.xSpeed > 0 then
        if not(self:isColliding(map, nextX + halfX, self.y - halfY))
            and not(self:isColliding(map, nextX + halfX, self.y + halfY - 1)) then
            self.x = nextX
        else
            self.x = nextX - ((nextX + halfX) % map.tileWidth)
        end
    elseif self.xSpeed < 0 then
        if not(self:isColliding(map, nextX - halfX, self.y - halfY))
            and not(self:isColliding(map, nextX - halfX, self.y + halfY - 1)) then
            self.x = nextX
        else
            self.x = nextX + map.tileWidth - ((nextX - halfX) % map.tileWidth)
        end
    end
	
	self.state = self:getState()
	
end

function Player:isColliding(map, x, y)
    local layer = map.tl["Walls"]
    local tileX, tileY = math.floor(x / map.tileWidth), math.floor(y / map.tileHeight)
    
    local tile = layer.tileData(tileX, tileY)
    
    return not(tile == nil)
end

function Player:getState()
    local myState = ""
    if self.onFloor then
        if self.xSpeed > 0 then
            myState = "moveRight"
        elseif self.xSpeed < 0 then
            myState = "moveLeft"
        else
            myState = "stand"
        end
    end
    if self.ySpeed < 0 then
        myState = "jump"
    elseif self.ySpeed > 0 then
        myState = "fall"
    end
    return myState
end