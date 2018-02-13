-----------------------------------------------------------------------------------------
--
-- game_over.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()


local background, textLabel

local sound1, sound2

local function endScene()
    composer.gotoScene("highscores")
end

local function playLandcoreLaughter()
	audio.play(sound2)
end

-- create()
function scene:create( event )
	local sceneGroup = self.view

    background = display.newImageRect(sceneGroup, "autistic-screeching-bat.jpg", 5, 8)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    textLabel = display.newText(sceneGroup, "GAME OVER.", display.contentCenterX, display.contentCenterY - (30 + display.contentCenterY/2), "emulogic.ttf", 26)
	textLabel.alpha = 0
	textLabel:setFillColor(1,0,0)

	scoreLabel = display.newText(sceneGroup, composer.getVariable("finalScore").." points", display.contentCenterX, display.contentCenterY + (30 +display.contentCenterY/2), "emulogic.ttf", 16)
	scoreLabel.alpha = 0
	scoreLabel:setFillColor(0.88)

	sound1 = audio.loadSound("audio/zashiki-warashi.wav")
	sound2 = audio.loadSound("audio/landcore-notification.mp3")
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

		audio.play(sound1) -- zashiki warashi's laughter

		transition.to(background, {time=3000, 
			-- widen the bat
            width=display.contentWidth, 
			height = display.contentWidth * 541 / 800,

			onComplete = function()
				transition.fadeIn(textLabel, {
					-- game over label
					time=1000,
					onComplete = playLandcoreLaughter
				})
				transition.fadeIn(scoreLabel, {
					-- highscores label
					delay = 1000,
					time= 2500, 
					onComplete = endScene
				})
			end
			}
		)



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

		composer.removeScene("game_over")
	end	
end

function scene:destroy( event )
	local sceneGroup = self.view
	
	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	
	audio.dispose(sound1)
	audio.dispose(sound2)
	
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene