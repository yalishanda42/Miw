-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

-- include Corona's "widget" library
local widget = require "widget"

--------------------------------------------

-- forward declarations and other locals
-- buttons
local playBtn, highScoresBtn, aboutBtn, muteSwitch
local titleLogo, logoHeart
local musicTrack
local whiteFaderImg

-- event listener functions
local function onPlayBtnRelease()
	composer.gotoScene( "game", "fade", 500 )
	return true	-- indicates successful touch
end

local function onHighScoresBtnRelease()
	composer.gotoScene("highscores", "fade", 500)
	return true
end

local function onAboutBtnRelease()
	composer.gotoScene("about", "fade", 500)
	return true
end

local function onMuteSwitchRelease()
	local isMuted = muteSwitch.isOn
	local newVolume = 0

	if not isMuted then
		newVolume = 1
	end

	audio.setVolume(newVolume)
end


local function onTapHeart()
	logoHeart:removeEventListener("tap", onTapHeart) -- the heart will still be partly visible though
	playBtn:removeEventListener("tap", onPlayBtnRelease)
	highScoresBtn:removeEventListener("tap", onHighScoresBtnRelease)
	aboutBtn:removeEventListener("tap", onAboutBtnRelease)

	-- stop current sound
	audio.stop()

	if composer.getVariable("hasFoundSans") then
		-- go directly to Sans
		composer.gotoScene("secret")
	else
		-- load and playthe new music
		local incubusSong = audio.loadStream("audio/Wish You Were Here.mp3")
		audio.play(incubusSong, {channel = composer.getVariable("audioChannel")})

		-- we should stop it exactly before the main riff begins [huehue]
		local stopTime = 11250 -- milliseconds
		audio.stopWithDelay(stopTime)

		-- fade the image in in the meantime
		transition.fadeIn(whiteFaderImg, {
			time = 6000
		})

		-- after the music was stopped, proceed to the secret level
		local endSceneTimer = timer.performWithDelay(
			stopTime, -- delay
			function() -- listener
				composer.gotoScene("secret") -- without any transition, immediately
			end,
			1 -- iterations (only once)
		)

	end


	return true
end

-- create()
function scene:create( event )
	local sceneGroup = self.view

	-- Called when the scene's view does not exist.
	--
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	-- display a background image
	local background = display.newImageRect( sceneGroup, "background.jpg", display.actualContentWidth, display.actualContentHeight )
	background.anchorX = 0
	background.anchorY = 0
	background.x = 0 + display.screenOriginX
	background.y = 0 + display.screenOriginY

	-- create/position logo/title image on upper-half of the screen
	titleLogo = display.newImageRect( sceneGroup, "miw.png", 303, 152 )
	titleLogo.x = display.contentCenterX
	titleLogo.y = 118

	logoHeart = display.newImageRect( sceneGroup, "undertale_heart.png", 42, 42)
	logoHeart.x = display.contentCenterX - 5
	logoHeart.y = titleLogo.y - 42
	logoHeart.alpha = 0


	-- create buttons
	local buttonsFont = "Funny & Cute.ttf"

	aboutBtn = display.newText(sceneGroup, "About this little game...", display.contentCenterX, display.contentHeight - 80, buttonsFont, 20)
	aboutBtn:setFillColor(1, 0.88, 0.88)

	highScoresBtn = display.newText(sceneGroup, "High Scores", display.contentCenterX, aboutBtn.y - 74, buttonsFont, 24)
	highScoresBtn:setFillColor(1, 0.88, 0.88)

	playBtn = display.newText(sceneGroup, "Play game :3", display.contentCenterX, highScoresBtn.y - 80, buttonsFont, 32)
	playBtn:setFillColor(1, 0.69, 0.78)

	-- create mute switch
	local currentMasterVolume = audio.getVolume()
	local switchState = false
	if currentMasterVolume==0 then switchState = true end

	muteSwitch = widget.newSwitch({
		x = display.contentCenterX,
		y = display.contentHeight - 20,
		style = "checkbox",
		initialSwitchState = switchState,
		onRelease = onMuteSwitchRelease
	})
	sceneGroup:insert(muteSwitch)
	muteSwitch.anchorX = 0

	local muteLabel = display.newText(sceneGroup, "Mute", muteSwitch.x, muteSwitch.y, buttonsFont, 14)
	muteLabel.anchorX = 1

	-- create the lovely image on top of everything else
	-- should be secret
	whiteFaderImg = display.newImageRect(sceneGroup, "TxP.jpg", display.contentWidth, display.contentHeight)
	whiteFaderImg.anchorX, whiteFaderImg.anchorY = 0, 0
	whiteFaderImg.alpha = 0 -- make it transparent
	whiteFaderImg.x, whiteFaderImg.y = 0, 0


	-- add event listeners to the buttons
	playBtn:addEventListener("tap", onPlayBtnRelease)
	highScoresBtn:addEventListener("tap", onHighScoresBtnRelease)
	aboutBtn:addEventListener("tap", onAboutBtnRelease)

	logoHeart:addEventListener("tap", onTapHeart)

	-- load the background music
	musicTrack = audio.loadStream("audio/Closer To The Heart.mp3")

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

		audio.play(musicTrack, {channel=composer.getVariable("audioChannel"), loops=-1})

		transition.to(logoHeart, {time=1000, y = titleLogo.y - 88, alpha=1, delay=1500})
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

	elseif phase == "did" then
		-- Called when the scene is now off screen

		composer.removeScene("menu")
	end
end

function scene:destroy( event )
	local sceneGroup = self.view

	-- Called prior to the removal of scene's "view" (sceneGroup)
	--
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.

end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
