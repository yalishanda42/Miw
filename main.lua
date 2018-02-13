-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- hide the status bar
display.setStatusBar( display.HiddenStatusBar )

-- seed the random number generator
math.randomseed(os.time())


-- reserve audio channel for background music and Sans' speech
AUDIO_CHANNEL_BACKGROUND = 1
AUDIO_CHANNEL_SPEECH = 2

audio.reserveChannels(2)


audio.setVolume(1)

local composer = require "composer"

-- pass the channel to composer so we can use it
composer.setVariable("audioChannel", AUDIO_CHANNEL_BACKGROUND)
composer.setVariable("speechChannel", AUDIO_CHANNEL_SPEECH)

-- the variable determining whether the player has found the secret level
composer.setVariable("hasFoundSans", false)

-- load menu screen
composer.gotoScene( "menu" )