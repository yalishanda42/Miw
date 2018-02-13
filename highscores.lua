
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- Initialize variables
local json = require("json")

local scoresTable = {}

local filePath = system.pathForFile("scores.json", system.DocumentsDirectory)

local function loadScores()

	local file = io.open(filePath, "r")

	if file then
		local contents = file:read("*a")
		io.close(file)
		scoresTable = json.decode(contents)
	end

	if (scoresTable == nil or #scoresTable == 0) then
		scoresTable = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
	end
end

local function saveScores()
	for i = #scoresTable, 11, -1 do
		table.remove(scoresTable, i)
	end

	local file = io.open(filePath, "w")

	if file then
		file:write(json.encode(scoresTable))
		io.close(file)
	end
end

local function gotoMenu()
	composer.gotoScene("menu", {time=800, effect="crossFade"})
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view

	loadScores() -- load the previous scores

	-- Insert the saved score from the last game to the table, then reset it
	table.insert(scoresTable, composer.getVariable("finalScore"))
	composer.setVariable("finalScore", 0)

	-- Sort the table entries from highest to lowest
	local function compare(a, b)
		return a > b
	end
	table.sort(scoresTable, compare)

	-- Saves the scores
	saveScores()

	-- display a background image
	local background = display.newImageRect( sceneGroup, "background.jpg", display.actualContentWidth, display.actualContentHeight )
	background.anchorX = 0
	background.anchorY = 0
	background.x = 0 + display.screenOriginX 
	background.y = 0 + display.screenOriginY
	
	-- create a smaller title image on upper-half of the screen
	titleLogo = display.newImageRect( sceneGroup, "miw.png", 60, 30 )
	titleLogo.x = display.contentCenterX
	titleLogo.y = 25

	logoHeart = display.newImageRect( sceneGroup, "undertale_heart.png", 8, 8)
	logoHeart.x = display.contentCenterX
    logoHeart.y = titleLogo.y - 20

    -- create back button
	backBtn = display.newText(sceneGroup, "Back", display.contentCenterX, display.contentHeight - 20, "Funny & Cute.ttf", 22)
    backBtn:setFillColor(1, 0.69, 0.78)
    backBtn:addEventListener("tap", gotoMenu)
    
    local font = "emulogic.ttf"

	local highScoresHeader = display.newText(sceneGroup, "High Scores", display.contentCenterX, 70, font, 22)

	for i = 1, 10 do
		if(scoresTable[i]) then
			local yPos = highScoresHeader.y + (i * 35)
			local hasFoundSans = composer.getVariable("hasFoundSans")


			local rankNum = display.newText(sceneGroup, i..")", display.contentCenterX-50, yPos, font, 16)
			rankNum:setFillColor(0.8)
			rankNum.anchorX = 1

			local thisScore = display.newText(sceneGroup, scoresTable[i], display.contentCenterX-30, yPos, font, 16)
			thisScore.anchorX = 0

			if i==1 and hasFoundSans and scoresTable[i] < 20000 then
				-- if the user has not yet accomplished Sans' challenge
				thisScore.text = "NOT 20000"
				thisScore:setFillColor(1,0,0)
			end
		end
	end
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		composer.removeScene("highscores")
		

	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
