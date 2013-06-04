local M = {}
function M.new()
	require "multiline_text"
	local group = display.newGroup()

	--check for ser info, if there create header
	local userInfo = Load("userInfo", userInfo)
	gameMode = "Rush"
	--server stuff
	headers = {}
	headers["Accept"] = "application/json"

	if userInfo ~= nil and userInfo.authKey ~= nil then
		headers["Authorization"] = "Token token="..tostring(userInfo.authKey)
	end

	-- local bg = display.newRect(group, 0, 0, cw, ch)
	-- bg:setFillColor(250, 250, 250)
	local bg = display.newImage(group, "Images/bg2.png", 10, 0)
	bg:scale(1.2, 1)

	local multiLineText = display.newMultiLineText  
        {
        text = "Report missing words or give feedback.",
        width = cw,                  --OPTIONAL        Defailt : nil 
        left = 0,top = cw+270,             --OPTIONAL        Default : left = 0,top=0
        font = "Hiruko",     --OPTIONAL        Default : native.systemFont
        fontSize = 35,                --OPTIONAL        Default : 14
        color = {237,67,55},              --OPTIONAL        Default : {0,0,0}
        align = "center"              --OPTIONAL   Possible : "left"/"right"/"center"
        }
        multiLineText.x = cw/2

	local mail = display.newImage(group, "Images/mail.png", -100, 0)
	mail:setReferencePoint( display.CenterReferencePoint )
	mail.x = cw/2 + 10
	mail.y = ch - 135
	mail:scale(0.8,0.8)

	local sheetData = { width=256, height=256, numFrames=2, sheetContentWidth=512, sheetContentHeight=256 }
	 
	local mySheet = graphics.newImageSheet( "Images/audio.png", sheetData )
	 
	local sequenceData = {
	   { name = "toggle", start=1, count=2 },
	}

	local audioAnimation = display.newSprite( mySheet, sequenceData )
	group:insert(audioAnimation)
	audioAnimation:scale(0.5, 0.5)
	audioAnimation.x = display.contentWidth/2 - 230  --center the sprite horizontally
	audioAnimation.y = 80  --center the sprite vertically
	audioAnimation:setFrame(1)

	local function updateAudioToggle()
		local audioData = Load("audioData")
		print("Audio is...", audioData.toggle)
		if audioData.toggle == "on" then
			audioAnimation:setFrame(1)
		elseif audioData.toggle == "off" then
			audioAnimation:setFrame(2)
		end
	end
	updateAudioToggle()

	local function toggleAudio()
		local audioData = Load("audioData")
		if audioData.toggle == "on" then
			audioData.toggle = "off"
			Save(audioData, "audioData")
			updateAudioToggle()
		elseif audioData.toggle == "off" then
			audioData.toggle = "on"
			Save(audioData, "audioData")
			updateAudioToggle()
		end
	end
	audioAnimation:addEventListener("tap", toggleAudio)
	 	
	local function newMail(event)
		-- system.openURL( "mailto:appdojostudios@gmail.com?subject=Llama Or Duck Game&body=")
		--ios
		print("New MAil")
		local options =
		{
		   to = "appdojostudios@gmail.com",
		   subject = "I Found a Missing Word!",
		   body = ""
		}
		native.showPopup("mail", options)
	end
	mail:addEventListener("tap", newMail)

	local function setInfini()
		gameMode="InfiniFall"
	end

	local function setWallTWall()
		gameMode="WallToWall"
	end

	local rushBtn = displayNewButton(group, "Images/button.png", nil, cw/2 - 175, ch/2-300, false, 1, 0, "gameNew", "Rush", 150, 150, 150, "Hiruko", 80, nil, nil)
	local infiniBtn = displayNewButton(group, "Images/button.png", nil, cw/2 - 175, cw/2 + 20, false, 1, 0, "gameNew", "Infini-Fall", 150, 150, 150, "Hiruko", 80, setInfini, nil)
	local wallToWallBtn = displayNewButton(group, "Images/button.png", nil, cw/2 - 175, cw/2 + 180, false, 1, 0, "gameNew", "Wall To Wall", 150, 150, 150, "Hiruko", 68, setWallTWall, nil)

	--group:insert(leaderboardsBtnH)
	--director:changeScene("game")

	return group
end

return M