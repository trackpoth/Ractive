local Player = require "player/player"
local Coin = require "player/coin"
local SpriteAnimation = require "SpriteAnimation"
local Camera = require "camera"
local Mouse = require "mouse/mouse"

local g, loader, map, camera, animation, coinSprites, score, coins, numCoins, i, p, gravity, delay, hasJumped, coinsound

function love.load()
	g = love.graphics
	g.setMode(1024, 768)
	g.setCaption("Ractive PreAlpha 0.1.1")
	width = g.getWidth()
	height = g.getHeight()
	g.setBackgroundColor(0, 137, 255)

	loader = require("AdvTiledLoader.Loader")
	loader.path = "maps/"

	map = loader.load("map01.tmx")
	map:setDrawRange(0, 0, map.width * map.tileWidth, map.height * map.tileHeight)

	camera = Camera:new()
	camera:setBounds(0, 0, map.width * map.tileWidth - width, map.height * map.tileHeight - height)

	animation = SpriteAnimation:new("player/playersprites.png", 24, 32, 4, 4)
	animation:load(delay)

	coinSprites = SpriteAnimation:new("player/coin.png", 32, 32, 20, 1)
	coinSprites:load(delay)
   
	score = 0

	p = Player:new()
	m = mouse:new()

	p.x = 300
	p.y = 300
	p.width = 24
	p.height = 32
	p.jumpSpeed = -420
	p.runSpeed = 180

	gravity = 1000
	delay = 120
	hasJumped = false

	math.randomseed(os.time())
	numCoins = math.random(40,60)
	coins = {}
	for i = 1, numCoins do
		local coinCollides = true
		while coinCollides do
			local coinX = math.random(1, map.width - 1) * map.tileWidth + map.tileWidth / 2
			local coinY = math.random(1, map.height - 1) * map.tileHeight + map.tileHeight / 2
			coins[i] = coin:new(coinX, coinY)
			
			coinCollides = coins[i]:isColliding(map)
		end
	end

	coinsound = love.audio.newSource("sound/coin.mp3")
	coinsound:setVolume(2.0)

	love.mouse.setVisible(false)

	font = g.newImageFont("font.png",
    " abcdefghijklmnopqrstuvwxyz" ..
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
    "123456789.,!?-+/():;%&`'*#=[]\"")

    g.setFont(font)
end

function love.update(dt)
	if dt > 1/60 then
		dt = 1/60
	end

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
			love.audio.play(coinsound)
			table.remove(coins, i)
		end
	end

	m:update(p.x, p.y)

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

	for i in ipairs(coins) do
		coinSprites:start(coins[i].frame)
		coinSprites:draw(coins[i].x - coins[i].width / 2, coins[i].y - coins[i].height / 2)
	end

	animation:draw(x - p.width / 2, y - p.height / 2)

	camera:unset()

	g.draw(m.mouseimg, m.mouseposx, m.mouseposy)

	g.setColor(0, 255, 255)
	g.print("Player coordinates: ("..x..","..y..")", 5, 5)
	g.print("Current state: "..p.state, 5, 20)
	g.print("Current tile: ("..tileX..", "..tileY..")", 5, 35)
	g.print("Mouse position: ("..m.mouseposx..","..m.mouseposy..")",5, 50)
	g.print("WASD to move, Space or W to jump, Esc to quit", 5, 65)
	g.print("Score: "..score, 900, 5)
	g.setColor(255, 255, 255)
end

function love.keyreleased(key)
	if key == "escape" then
		love.event.push("quit")
	end
	if key == "d" or key == "a" then
		p:stop()
	end
end

function math.clamp(x, min, max)
	return x < min and min or (x > max and max or x)
end