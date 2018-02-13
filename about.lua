-----------------------------------------------------------------------------------------
--
-- about.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()


-- forward declarations and other locals
local backBtn
local lovelyMusicTrack

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

	-- stops any previously playing audio
	audio.stop(composer.getVariable("audioChannel"))

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
	backBtn = display.newText(sceneGroup, "Back", display.contentCenterX, display.contentHeight - 10, "Funny & Cute.ttf", 20)
	backBtn:setFillColor(1, 0.69, 0.78)

    backBtn:addEventListener("tap", onBackBtnRelease)
    
    
    -- the About text
    local aboutText = "This little game was intended to serve as a present for my lovely girlfriend. I hope that whenever she feels lonely, sad, anxious, desperate or simply bored - playing this special game will cheer her up and remind her that I will be with her should times of hardship arise."
	local authorText = "With Love,\n\nYour boifrendo,\nYalishanda.\n14.02.2018."

	if composer.getVariable("hasFoundSans") then
		authorText = "With Love,\n\nYour boifrendo,\nSANS.\n01.04.2014."
	end

	local lowerY = display.contentHeight - 104	

    local aboutTxtObj = display.newText({
        parent = sceneGroup,
        text = aboutText,
        x = display.contentCenterX,
        y = titleLogo.y + 40,
        width = display.actualContentWidth - 100,
        height = display.contentHeight - (titleLogo.y + 65),
        font = "Anjelika Rose.ttf",
        fontSize = 20,
        align = "left"
    })
	aboutTxtObj.anchorY = 0

	local authorTxtObj = display.newText({
		parent = sceneGroup,
		text = authorText,
		x = display.contentCenterX-20,
		y = lowerY,
		width = display.contentCenterX - 50,
		height = 0,
		font = "Anjelika Rose.ttf",
		fontSize = 20,
		align = "right"
	})
	authorTxtObj.anchorX = 1
	
	-- pusheen couple (or sans troll image if secret level is found)
	local imgFile = "pusheen-couple.gif"
	if composer.getVariable("hasFoundSans") then imgFile = "ba_dum_tss.jpg" end

	local pusheenCouple = display.newImageRect(sceneGroup, imgFile,  140, 128)
	pusheenCouple.anchorX = 0
	pusheenCouple.x = display.contentCenterX
	pusheenCouple.y = lowerY

	-- background track
	lovelyMusicTrack = audio.loadStream("audio/Undertale OST 092 - Reunited.mp3")

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

		audio.play(lovelyMusicTrack, {channel=composer.getVariable("audioChannel"), loops=-1})
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

		composer.removeScene("about")
		
	end	
end

function scene:destroy( event )
	local sceneGroup = self.view
	
	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	
	audio.dispose(lovelyMusicTrack)
	
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene