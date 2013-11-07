require "player/player"
require "SpriteAnimation"
require "camera"

function love.load()	
    g = love.graphics
    width = g.getWidth()
    height = g.getHeight()
    g.setBackgroundColor(0, 137, 255)
	
	loader = require("AdvTiledLoader.Loader")
    loader.path = "maps/"
    map = loader.load("map01.tmx")
    map:setDrawRange(0, 0, map.width * map.tileWidth, map.height * map.tileHeight)
	camera:setBounds(0, 0, map.width * map.tileWidth - width, map.height * map.tileHeight - height)
	
	animation = SpriteAnimation:new("player/playersprites.png", 24, 32, 4, 4)
    animation:load(delay)
    
	
    p = Player:new()
    
    p.x = 300
    p.y = 300
    p.width = 24
    p.height = 32
    p.jumpSpeed = -420
    p.runSpeed = 180
    
    gravity = 1000
    delay = 120
    hasJumped = false
end
 
function love.update(dt)
	if (dt > 1/60) then 
		dt = 1/60 
	end
	
    if love.keyboard.isDown("left") then
        p:moveLeft()
		animation:flip(true, false)
    end
    if love.keyboard.isDown("right") then
        p:moveRight()
		animation:flip(false, false)
    end
    if love.keyboard.isDown("x") then
        p:jump()
    end

    p:update(dt, gravity, map)
	
    if (p.state == "stand") then
        animation:switch(1, 2, 1000)
    end
    if (p.state == "moveRight") or (p.state == "moveLeft") then
        animation:switch(2, 2, 120)
    end
    if (p.state == "jump") then
        animation:switch(3, 1, 300)
    end
    if (p.state == "fall") then
        animation:switch(4, 1, 300)
    end
    animation:update(dt)
	camera:setPosition(math.floor(p.x - width / 2), math.floor(p.y - height / 2))
end
 
function love.draw()
    local x = math.floor(p.x)
    local y = math.floor(p.y)
	local camX, camY = camera._x, camera._y
    local tileX = math.floor(p.x / map.tileWidth)
    local tileY = math.floor(p.y / map.tileHeight)
    
	camera:set()
	
	map:draw()
	
    animation:draw(x - p.width / 2, y - p.height / 2)
	
    camera:unset()
	
	g.setColor(255, 255, 255)
    g.print("Player coordinates: ("..x..","..y..")", 5, 5)
    g.print("Current state: "..p.state, 5, 20)
	love.graphics.print("Current tile: ("..tileX..", "..tileY..")", 5, 35)
end
 
function love.keyreleased(key)
    if key == "escape" then
        love.event.push("quit")
    end
    if (key == "right") or (key == "left") then
        p:stop()
    end
end

function math.clamp(x, min, max)
    return x < min and min or (x > max and max or x)
end
