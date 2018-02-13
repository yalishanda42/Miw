-----------------------------------------------------------------------------------------
--
-- game.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

local physics = require "physics"

-- the spritesheet
local sheetInfo = require("sheet")
local imageSheet = graphics.newImageSheet("sheet.png", sheetInfo:getSheet())

--------------------------------------------

-- forward declarations and other locals
local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX
local upperUi_Y = display.screenOriginY + 30
local life, score = 9, 1000
local STARTING_GRAVITY = 6
local harderDifficulty = false
local timeBetweenSpawns = 1000

local backgroundGroup, mainGroup, uiGroup
local lifeTxtObj, scoreTxtObj
local box, flames
local lifeChangeTxt, scoreChangeTxt

local musicTrack


-- jigoku objects table and methods
local JIGOKU_OBJ = {
	-- holds the indexes of the images that shall fall into hell for bonus points
	9, 14, 16, 17, 21, 22, 23, 27, 37
}

function JIGOKU_OBJ:isJigokuObj(sheetIndex)
	for i=1, #self, 1 do
		if self[i] == sheetIndex then
			return true
		end
	end

	return false
end

-- defining functions

local function getKeyByValueInTable(value, table)
	for key, val in pairs(table) do
		if val == value then
			return key
		end
	end

	return nil
end

local function endGame()
	composer.setVariable("finalScore", score)
	composer.gotoScene("game_over")
end


local function updateScore()
	lifeTxtObj.text = life
	scoreTxtObj.text = "Score:"..score

	if life <= 0 then
		endGame()
	elseif life <=3 then
		lifeTxtObj:setFillColor(1, 0.1, 0.1)
	elseif life > 3 then
		lifeTxtObj:setFillColor(1)
	end

	if score <= 0 then
		endGame()
	end
end

local function fadeChangeStatsLabel (label, amount)

	if amount > 0 then
		label.text = "+"..amount
		label:setFillColor(0,1,0)
	elseif amount < 0 then
		label.text = amount
		label:setFillColor(1,0,0)
	end

	label.alpha = 1

	transition.to(label, {time=1000, alpha=0})

	updateScore()
end

local function addScore(amount)
	score = score + amount
	fadeChangeStatsLabel(scoreChangeTxt, amount)
end

local function addLife(amount)
	if not harderDifficulty then
		life = life + amount
		fadeChangeStatsLabel(lifeChangeTxt, amount)
	else
		lifeTxtObj.text = "?"
	end
end



local function spawnObject(index)
	local w, h = 80, 80
	if index==40 then
		-- the heart is oversized otherwize :/
		w = 35
		h = 35
	else
		w = sheetInfo.sheet.frames[index].width
		h = sheetInfo.sheet.frames[index].height
	end

	local newObj = display.newImageRect(mainGroup, imageSheet, index, w, h)
	newObj.x = math.random(display.screenOriginX + 10, display.actualContentWidth)
	newObj.y = -10 - (score/100)

	if index==4 or index==8 or index==39 or index==10 then
		-- broken outlines ;( dunno why
		physics.addBody(newObj, {radius=38})
	else
		local objOutline = graphics.newOutline(1, imageSheet, index)
		physics.addBody(newObj, {outline = objOutline})
	end
	newObj.rotation = math.random(math.floor(score/1000), math.floor(score/1000))
	if score > 9000 then newObj:applyTorque(math.random(-3,3)) end -- it's over 9000!

	newObj.myName = "fallingObject"
	newObj.spriteName = getKeyByValueInTable(index, sheetInfo.frameIndex)
	newObj.isJigokuObject = JIGOKU_OBJ:isJigokuObj(index)

	return newObj
end

-- event listeners
local function onDragBox(event)
	local box = event.target
	local phase = event.phase

	if phase == "began" then
		display.currentStage:setFocus(box)

		box.touchOffsetX = event.x - box.x
	elseif phase == "moved" then
		box.x = event.x - box.touchOffsetX
	elseif phase == "ended" or phase == "cancelled" then
		display.currentStage:setFocus(nil)
	end

	return true
end

local function onCollision(event)
	local obj1 = event.object1
	local obj2 = event.object2

	if ((obj1.myName == "flames" and obj2.myName == "fallingObject") or
		(obj1.myName == "fallingObject" and obj2.myName == "flames"))
	then -- If an object has fallen into the JIGOKU
		local obj, flames

		-- determining which object is which
		if obj1.myName == "fallingObject" then
			obj = obj1
			flames = obj2
		elseif obj2.myName == "fallingObject" then
			obj = obj2
			flames = obj1
		end

		display.remove(obj)


		-- JIGOKU COLLISION RULES --
		if obj.isJigokuObject then
			if composer.getVariable( "hasFoundSans" ) then
				if harderDifficulty then
					addScore(-2000) -- #;]
				else
					addLife(-1) -- Genocide mode
				end
			else
				addScore(250) -- normal mode
			end

		else

			if composer.getVariable("hasFoundSans") then
				if obj.spriteName == "sans" then
					addLife(-2) 
				else
					addScore(50) -- Genocide mode
				end
			else
				if obj.spriteName == "undertale_heart" then
					addLife(-2)
				else
					addLife(-1) -- normal mode
				end
			end
		end
		----------------------------

	elseif ((obj1.myName == "box" and obj2.myName == "fallingObject") or
			(obj1.myName == "fallingObject" and obj2.myName == "box"))
	then
		-- determining which object is which
		if obj1.myName == "fallingObject" then
			obj = obj1
			box = obj2
		elseif obj2.myName == "fallingObject" then
			obj = obj2
			box = obj1
		end

		display.remove(obj)


		-- BOX COLLISION RULES --
		if obj.isJigokuObject then

			if composer.getVariable("hasFoundSans") then
				addScore(250) -- Genocide mode
			else
				addLife(-1) -- normal mode
			end
			 
		else

			if composer.getVariable("hasFoundSans") then
				if obj.spriteName == "sans" then
					addLife(1) -- in Genocide mode Sans becomes the life adder
				else
					if harderDifficulty then
						addScore(-1000) -- after Sans and 20k
					else
						addLife(-1) -- normal Genocide mode
					end
				end
			else
				if obj.spriteName == "undertale_heart" then
					addLife(1) -- normal life adding
				else
					addScore(50) -- normal mode
				end
			end
		end
		-------------------------
	end
end

local function gameLoop()
	-- creates a new object to fall
	spawnObject(math.random(43))

	-- if the player has seen Sans' challenge
	if score >= 20000 and composer.getVariable("hasFoundSans") then
		-- make the difficulty harder #;]
		harderDifficulty = true
		timeBetweenSpawns = 500

		gameLoopTimer._delay = timeBetweenSpawns --huehue

		lifeTxtObj.text = "?"
	end


	-- adjusts gravity according to the score
	physics.setGravity(0, STARTING_GRAVITY + math.floor(score/1000))
end

--create()
function scene:create( event )

	local sceneGroup = self.view

	-- We need physics started to add bodies, but we don't want the simulaton
	-- running until the scene is on the screen.
	physics.start()
	physics.setGravity(0, STARTING_GRAVITY)
	physics.pause()

	-- stops previously running background music
	audio.stop(composer.getVariable("audioChannel"))

	-- create 3 display groups
	backgroundGroup = display.newGroup() -- for the background
	sceneGroup:insert(backgroundGroup) -- insert into scene's view group

	mainGroup = display.newGroup() -- for the game objects
	sceneGroup:insert(mainGroup)

	uiGroup = display.newGroup() -- for the ui objects like the score
	sceneGroup:insert(uiGroup)


	-- create the background
	local background = display.newImageRect(backgroundGroup, "gridvapor2.jpg", display.actualContentWidth, display.actualContentHeight)
	background.x = display.contentCenterX
	background.y = display.contentCenterY


	-- create the bottom flames
	flames = display.newImageRect( backgroundGroup, "flames.png", screenW, 200)
	flames.anchorX = 0
	flames.anchorY = 1
	flames.x, flames.y = display.screenOriginX, display.actualContentHeight + display.screenOriginY

	local physWidth = halfW
	local flamesShape = {-physWidth,15, physWidth,15, physWidth,100, -physWidth,100}
	physics.addBody( flames, "static", {shape = flamesShape} )
	flames.myName = "flames"

	-- create text over the flames
	local flamesText = display.newText(uiGroup, "J I G O K U", display.screenOriginX + 50, flames.y - 15, "Funny & Cute.ttf", 42)
	flamesText.anchorX = 0
	flamesText.anchorY = 1
	flamesText:setFillColor(0,0,0)

	-- create the box
	local boxFileName = "boxu2.png"

	box = display.newImageRect(mainGroup, boxFileName, 100, 100)
	box.x = display.contentCenterX
	box.y = display.actualContentHeight - 175

	local boxShape = {-39,17, 18,17, 18,-9, -39,-9}
	physics.addBody(box, "static", {shape = boxShape})
	box.myName  = "box"

	box:addEventListener("touch", onDragBox)

	-- create life ands score labels
	local font = "emulogic.ttf"
	local lifeImgFile = "undertale_heart.png"
	if composer.getVariable("hasFoundSans") then lifeImgFile = "sans-trans.png" end

	local lifeImg = display.newImageRect(uiGroup, lifeImgFile, 25, 25)
	lifeImg.x, lifeImg.y = 30, upperUi_Y

	lifeTxtObj = display.newText(uiGroup, life, lifeImg.x + 18, upperUi_Y, font, 22)
	lifeTxtObj.anchorX = 0

	scoreTxtObj = display.newText(uiGroup, "Score:"..score, screenW - 120, upperUi_Y, font, 20)

	-- creating hidden dynamic labels for the changes in the score and life count
	lifeChangeTxt = display.newText(uiGroup, "", 55, upperUi_Y + 20, font, 16)
	lifeChangeTxt.alpha = 0

	scoreChangeTxt = display.newText(uiGroup, "", screenW - 85, upperUi_Y + 20, font, 16)
	scoreChangeTxt.alpha = 0



	-- insert image groups intro the scene group
	sceneGroup:insert( backgroundGroup )
	sceneGroup:insert( mainGroup )
	sceneGroup:insert( uiGroup )

	-- add collision listener
	Runtime:addEventListener("collision", onCollision)

	-- add background music
	local musicFile = "audio/Girlfriend.mp3"
	if composer.getVariable("hasFoundSans") then
		musicFile = "audio/Undertale mus_battle2.mp3"
	end

	musicTrack = audio.loadStream(musicFile)
end


function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase

	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		--
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.

		audio.play(musicTrack, {channel = composer.getVariable("audioChannel"), loops=-1})

		physics.start()

		gameLoopTimer = timer.performWithDelay(timeBetweenSpawns, gameLoop, -1)
	end
end

function scene:hide( event )
	local sceneGroup = self.view

	local phase = event.phase

	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)

		timer.cancel(gameLoopTimer)

		audio.stop(composer.getVariable("audioChannel"))

	elseif phase == "did" then
		-- Called when the scene is now off screen

		physics.pause()

		composer.removeScene("game") -- will it support pausing?
	end

end

function scene:destroy( event )

	-- Called prior to the removal of scene's "view" (sceneGroup)
	--
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	local sceneGroup = self.view

	box:removeEventListener("touch", onDragBox)
	Runtime:removeEventListener("collision", onCollision)

	package.loaded[physics] = nil
	physics = nil

	audio.dispose(musicTrack)
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
