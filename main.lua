local Player = require "player/player"
local Coin = require "player/coin"
local Camera = require "camera"
local SpriteAnimation = require "libraries/SpriteAnimation"

require "libraries/TEsound"

local g, loader, map, camera, animation, coinSprites, score, coins, numCoins, i, p, m, gravity, delay, hasJumped, coinsound, debugmode, togglemusic, gamestate

function love.load()
	g = love.graphics

	width = g.getWidth()
	height = g.getHeight()
	g.setBackgroundColor(14, 182, 255)

	loader = require("libraries/AdvTiledLoader.Loader")
	loader.path = "maps/"

	map = loader.load("map01.tmx")
	map:setDrawRange(0, 0, map.width * map.tileWidth, map.height * map.tileHeight)

	cam = Camera:new()
	cam:setBounds(0, 0, map.width * map.tileWidth - width, map.height * map.tileHeight - height)

	animation = SpriteAnimation:new("player/playersprites.png", 24, 32, 4, 4)
	animation:load(delay)

	coinSprites = SpriteAnimation:new("player/coin.png", 32, 32, 20, 1)
	coinSprites:load(delay)
   
	score = 0

	p = Player:new()
	p.x = 300
	p.y = 300
	p.width = 24
	p.height = 32

	gravity = 1000
	delay = 120
	hasJumped = false

	math.randomseed(os.time())
	numCoins = math.random(40,60)
	coins = {}
	for i = 1, numCoins do
		local coinCollides = true
		while coinCollides do
			local coinOverlaps = true
			while coinOverlaps do
				coinX = math.random(1, map.width - 1) * map.tileWidth + map.tileWidth / 2
				coinY = math.random(1, map.height - 1) * map.tileHeight + map.tileHeight / 2

				coinOverlaps = checkXYOverlapping(coins, coinX, coinY)
			end
			coins[i] = coin:new(coinX, coinY)

			coinCollides = coins[i]:isColliding(map)
		end
	end

	font = g.newImageFont("font.png",
	" abcdefghijklmnopqrstuvwxyz" ..
	"ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
	"123456789.,!?-+/():;%&`'*#=[]\"")

	g.setFont(font)

	mousePosX = g.getWidth() / 2
	mousePosY = g.getHeight() / 2
	mouseimg = g.newImage("player/crosshair.png")

	gamestate = "ingame"
end

function love.update(dt)
	if dt > 1/60 then
		dt = 1/60
	end

	if p.life < 1 then
		gamestate = "gameover"
	end

	if gamestate == "ingame" then
		if love.keyboard.isDown("a") and not(love.keyboard.isDown("d")) then
			p:moveLeft()
			animation:flip(true, false)
		end
		if love.keyboard.isDown("d") and not(love.keyboard.isDown("a")) then
			p:moveRight()
			animation:flip(false, false)
		end
		if love.keyboard.isDown(" ") or love.keyboard.isDown("w") then
			p:jump()
		end

		p:update(dt, gravity, map)

		if p.state == "stand" then
			animation:switch(1, 2, 1000)
		end
		if p.state == "moveRight" or p.state == "moveLeft" then
			animation:switch(2, 2, 120)
		end
		if p.state == "jump" then
			animation:switch(3, 1, 300)
		end
		if p.state == "fall" then
			animation:switch(4, 1, 300)
		end
		animation:update(dt)

		for i in ipairs(coins) do
			coins[i]:update(dt)
			if coins[i]:touchesObject(p) then
				score = score + 1
				TEsound.play("sound/coin.ogg")
				table.remove(coins, i)
			end
		end

		for i,v in ipairs(p.bullets) do
			v.x = v.x + (v.dx * dt)
			if v.x < 0 or v.x > map.width * map.tileWidth then
				table.remove(p.bullets, i)
			end
			v.y = v.y + (v.dy * dt)
			if v.y < 0 or v.y > map.height * map.tileHeight then
				table.remove(p.bullets, i)
			end
			if CheckCollision(p.x - halfX + 1, p.y - halfY, p.width, p.height, v.x, v.y, 1, 1) then
				table.remove(p.bullets, i)
				p.life = p.life - 1
			end
			if p:isColliding(map, v.x, v.y) then
				table.remove(p.bullets, i)
			end
		end

		cam:setPosition(math.floor(p.x - width / 2), math.floor(p.y - height / 2))
		mousePosX, mousePosY = cam:mousePosition()
	end

	local angle = math.atan2(p.y - mousePosY, p.x - mousePosX) + math.rad(180)
	local crosshairDistance = 100
	crosshairX, crosshairY = math.floor(crosshairDistance * math.cos(angle) + p.x), math.floor(crosshairDistance * math.sin(angle) + p.y)

	TEsound.cleanup()
end

function love.draw()
	local x = math.floor(p.x)
	local y = math.floor(p.y)
	local camX, camY = cam._x, cam._y
	local tileX = math.floor(p.x / map.tileWidth)
	local tileY = math.floor(p.y / map.tileHeight)

	if gamestate == "ingame" then
		cam:set()

		map:draw()

		for i in ipairs(coins) do
			coinSprites:start(coins[i].frame)
			coinSprites:draw(coins[i].x - coins[i].width / 2, coins[i].y - coins[i].height / 2)
		end

		for i,v in ipairs(p.bullets) do
			g.rectangle("fill", v.x, v.y, 4, 4)
		end

		animation:draw(x - p.width / 2, y - p.height / 2)
		g.draw(mouseimg, crosshairX - 16, crosshairY - 16)

		cam:unset()

		g.setColor(255, 255, 255)
		g.print("WASD to move, Space or W to jump, Esc to quit, T to toggle debug info, M to toggle music", 5, 5)

		if debuginfo then
			g.print("Player coordinates: ("..x..","..y..")", 5, 20)
			g.print("Current state: "..p.state, 5, 35)
			g.print("Current tile: ("..tileX..", "..tileY..")", 5, 50)
			g.print("Mouse position: ("..mousePosX..","..mousePosY..")", 5, 65)
			g.print("Map Width: "..map.width * map.tileWidth..", Height: "..map.height * map.tileHeight, 5, 80)
		end
		
		g.print("Score: "..score, 5, height - 35)

		if p.life < p.maxLife / 3 then
			g.setColor(255, 0, 0)
		else
			g.setColor(255, 255, 255)
		end
		g.print("Life: "..p.life.."/"..p.maxLife, 5, height - 20)
		g.setColor(255, 255, 255)
	end

	if gamestate == "gameover" then
		TEsound.stop("all")
		love.mouse.setVisible(true)
		g.setBackgroundColor(0, 0, 0)
		g.setColor(255, 255, 255)
		g.print("Game over. Press ESC to quit", 5, 5)
		g.print("Score: "..score, 5, 20)
	end
end

function love.keypressed(key)
	if key == "t" then
		if debuginfo == true then
			debuginfo = false
		else
			debuginfo = true
		end
	end

	if key == "m" and gamestate == "ingame" then
		if togglemusic == true then
			togglemusic = false
			TEsound.stop("bgm")
		else
			togglemusic = true
			TEsound.playLooping("sound/bgm.ogg", "bgm")
		end
	end
end

function love.keyreleased(key)
	if key == "escape" then
		love.event.push("quit")
	end
	if key == "d" or key == "a" then
		p:stop()
	end
end

function love.mousepressed(x, y, button)
	if button == "l" then
		local angle = math.atan2((p.y - crosshairY), (p.x - crosshairX))
		
		local bulletDx = p.bulletSpeed * math.cos(angle)
		local bulletDy = p.bulletSpeed * math.sin(angle)
		
		table.insert(p.bullets, {x = crosshairX, y = crosshairY, dx = bulletDx, dy = bulletDy})
	end
end

function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
	return x1 < x2 + w2 and
		x2 < x1 + w1 and
		y1 < y2 + h2 and
		y2 < y1 + h1
end

function math.clamp(x, min, max)
	return x < min and min or (x > max and max or x)
end

function checkXYOverlapping(table, Xvalue, Yvalue)
	for i,v in ipairs(table) do
		if math.floor(v.x / map.tileWidth) == math.floor(Xvalue / map.tileWidth) and math.floor(v.y / map.tileHeight) == math.floor(Yvalue / map.tileHeight) then
			return true
		end
	end
	return false
end