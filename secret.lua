-----------------------------------------------------------------------------------------
--
-- game_over.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

local sheetInfo = require "sheet"
local imageSheet = graphics.newImageSheet("sheet.png", sheetInfo:getSheet())


local background
local backgroundMusic, sansSpeech, battleSfx
local frame
local sans, heart
local sansTextObj, helperText
local speechTimer, speech_t
local textPosBegin = 1
local textPosEnd = 1

local heartPosY = display.contentHeight - 100 -- the ending Y coord of the heaart



local function addPhysics()
	physics.start()
	-- rectangular chain shape
	local frameW, frameH = 200, 150

	local frameChain = {-(frameW/2),-(frameH/2), (frameW/2),-(frameW/2), (frameW/2),(frameH/2)}

	physics.addBody(frame, "static", {chain = frameChain, connectFirstAndLastChainVertex = true})
	physics.addBody(heart, "dynamic", {bounce = 0.8})

	audio.play(battleSfx)
	sans.alpha = 1
end

local function beginning()
	audio.play(battleSfx)

	-- move the heart to the bottom
	
	transition.to(heart, {delay = 500, time = 500, y = heartPosY, width = 35, height = 35, onComplete = addPhysics})


	backgroundMusic = audio.loadStream("audio/Undertale mus_battle2.mp3")

	audio.play(backgroundMusic, {channel = composer.getVariable("audioChannel"), loops=-1})

	frame.alpha = 1 -- make the frame finally visible
end

local function endScene()
	transition.to(sans, {time=1000, x=display.actualContentWidth + 300})
	composer.setVariable("hasFoundSans", true)
	composer.gotoScene("menu", {effect="crossFade", time=800})
end


local function changeVisibleText()
	local SPEECH_CHANNEL = composer.getVariable("speechChannel")

	

	-- the actual animation
	sansTextObj.text = sansText:sub(textPosBegin, textPosEnd)


	if sansText:sub(textPosEnd, textPosEnd) == '\n' or
		textPosEnd == sansText:len()
	then
		audio.pause(SPEECH_CHANNEL)
		timer.pause(speechTimer)

		local function onTapText()
			helperText.alpha = 0

			if textPosEnd == sansText:len() + 1 then
				endScene()
			else
				timer.resume(speechTimer)
				audio.resume(SPEECH_CHANNEL)
			end

			sansTextObj:removeEventListener("tap", onTapText)
		end

		sansTextObj:addEventListener("tap", onTapText)
		helperText.alpha = 1

		textPosBegin = textPosEnd + 1
	end

	textPosEnd = textPosEnd + 1
end

local function speech()
	sansText = "* Heheheh.\n* I am everywhere, aren't I ;]\n* just realized there are no suitable Undertale characters here for you to fight with\n* because fighting Omega Flowey is cancer and fighting me...\n* nevermind. Here is a little challenge: try scoring over 20000 points.\n* it will be harder than it seems, I promise ;]\n* See ya in Jigoku ;]"
	if composer.getVariable("hasFoundSans") then
		sansText = "* Setting a highscore above 20000 is... something I am actually afraid of.\n* You gotta be damn skilled...and...evil...\n* so if you complete my little challenge I guess that \n* you are gonna hate me next time you play Undertale #;]"
	end

	audio.play(sansSpeech, {channel = composer.getVariable("speechChannel"), loops=-1})

	speechTimer = timer.performWithDelay(100, changeVisibleText, sansText:len())


end



-- create()
function scene:create( event )
	local sceneGroup = self.view

	-- background
	background = display.newRect(sceneGroup, display.contentCenterX, display.contentCenterY, display.actualContentWidth, display.actualContentHeight)
	background:setFillColor(0) -- black

	-- add a nice little undertale-ish frame with a
	-- rectangular chain shape
	local frameW, frameH = 200, 150

	local frameChain = {-(frameW/2),-(frameH/2), (frameW/2),-(frameW/2), (frameW/2),(frameH/2)}

	frame = display.newRect(sceneGroup, display.contentCenterX, heartPosY, frameW, frameH)
	frame.alpha = 0
	frame:setFillColor(0)
	frame.strokeWidth = 4
	frame:setStrokeColor(1,1,1)

	-- heart
	heart = display.newImageRect(sceneGroup, imageSheet, sheetInfo:getFrameIndex("undertale_heart"), 40, 40)
	heart.x = display.contentCenterX
	heart.y = 150

	-- Sans
	sans = display.newImageRect(sceneGroup, imageSheet, sheetInfo:getFrameIndex("sans"), 90, 90)
	sans.x = display.contentCenterX
	sans.y = 55
	sans.alpha = 0



	-- Sans text
	sansTextObj = display.newText({
		parent = sceneGroup, 
		text = "",
		x = 45,
		y = 125,
		width = display.actualContentWidth - 80,
		height = 0,
		font = "LDFComicSans.ttf",
		fontSize = 24,
		align = "left"
	})
	sansTextObj.anchorX = 0
	sansTextObj.anchorY = 0

	-- little helper
	helperText = display.newText(sceneGroup, "(tap the text above to continue...)", display.contentCenterX, display.contentHeight-8, "Comic Sans MS", 12)
	helperText.alpha = 0
	helperText:setFillColor(0.8)

	-- load the background music
	backgroundMusic = audio.loadStream("audio/Undertale mus_battle2.mp3")

	-- load the Sans speech
	sansSpeech = audio.loadStream("audio/Just Sans Talking.mp3")

	-- load SFX
	battleSfx = audio.loadSound("audio/battle encounter.mp3")
    
end

--show()
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

		
		beginning()

		speech_t = timer.performWithDelay(2000, speech, 1)

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
		timer.cancel(speech_t)
		timer.cancel(speechTimer)
	elseif phase == "did" then
		-- Called when the scene is now off screen

		audio.stop()
		physics.pause()

		composer.removeScene("secret")
	end	
end

function scene:destroy( event )
	local sceneGroup = self.view
	
	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	
	audio.dispose(battleSfx)
	audio.dispose(backgroundMusic)
	audio.dispose(sansSpeech)
	
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene