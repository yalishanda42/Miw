-----------------------------------------------------------------------------------------
--
-- about.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

local widget = require "widget"


-- forward declarations and other locals
local backBtn

-- event listener functions
local function onBackBtnRelease()
	composer.gotoScene( "menu", "fade", 500 )
	return true	-- indicates successful touch
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
	
	-- create a smaller title image on upper-half of the screen
	titleLogo = display.newImageRect( sceneGroup, "miw.png", 60, 30 )
	titleLogo.x = display.contentCenterX
	titleLogo.y = 50

	logoHeart = display.newImageRect( sceneGroup, "undertale_heart.png", 8, 8)
	logoHeart.x = display.contentCenterX
    logoHeart.y = titleLogo.y - 20

    -- create back button
	backBtn = display.newText(sceneGroup, "Back", display.contentCenterX, display.contentHeight - 10, native.systemFont, 20)
    backBtn:setFillColor(1, 0.69, 0.78)
    

    -- create switch for the audio


    -- event listeners
    backBtn:addEventListener("tap", onBackBtnRelease)
    
    
    
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

		audio.stop(composer.getVariable("audioChannel"))
	elseif phase == "did" then
		-- Called when the scene is now off screen

		composer.removeScene("options")
		
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