local M = {}
function M.new()
	local group = display.newGroup()

	--check for ser info, if there create header
	local userInfo = Load("userInfo", userInfo)
	--server stuff
	headers = {}
	headers["Accept"] = "application/json"

	if userInfo ~= nil and userInfo.authKey ~= nil then
		headers["Authorization"] = "Token token="..tostring(userInfo.authKey)
	end

	-- local bg = display.newRect(group, 0, 0, cw, ch)
	-- bg:setFillColor(250, 250, 250)
	displayBackground(group)

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

	-- local sheetData = { width=256, height=256, numFrames=2, sheetContentWidth=512, sheetContentHeight=256 }
	 
	-- local mySheet = graphics.newImageSheet( "Images/audio.png", sheetData )
	 
	-- local sequenceData = {
	--    { name = "toggle", start=1, count=2 },
	-- }

	-- local audioAnimation = display.newSprite( mySheet, sequenceData )
	-- group:insert(audioAnimation)
	-- audioAnimation:scale(0.5, 0.5)
	-- audioAnimation.x = display.contentWidth/2 - 230  --center the sprite horizontally
	-- audioAnimation.y = 80  --center the sprite vertically
	-- audioAnimation:setFrame(1)
	--tut button
	local tutorialBtn = display.newImage(group, "Images/tutorialBtn.png", cw - 140, 20, 100, 100)
	tutorialBtn.x, tutorialBtn.y = cw - 80, 78
	local tutorialBtnD = display.newImage(group, "Images/tutorialBtnD.png", cw - 140, 20, 100, 100)
	tutorialBtnD.x, tutorialBtnD.y = cw - 8000, 78
	local tutorialBtnOverlay = display.newRect(group, 0, 0, 110, 110)
	tutorialBtnOverlay.alpha = 0.01
	tutorialBtnOverlay.x, tutorialBtnOverlay.y = tutorialBtn.x, tutorialBtn.y
	---------
	local soundOverlay = display.newRect(group, 0, 0, 110, 110)
	soundOverlay.alpha = 0.01
	soundOverlay.x, soundOverlay.y = 80, 78
	--outline
	local soundBtnOutline = display.newImage(group, "Images/soundOutline.png", 140, 20, 100, 100)
	soundBtnOutline.x, soundBtnOutline.y = 80, 78
	local soundBtnOutlineD = display.newImage(group, "Images/soundOutlineD.png", 140, 20, 100, 100)
	soundBtnOutlineD.x, soundBtnOutlineD.y = 8000, 78
	--audio button
	local soundBtn = display.newImage(group, "Images/soundOn.png", 140, 20, 100, 100)
	soundBtn.x, soundBtn.y = 80, 78
	local soundBtnD = display.newImage(group, "Images/soundOff.png", 140, 20, 100, 100)
	soundBtnD.x, soundBtnD.y = 8000, 78


	local function goTutorial(event)
		if event.phase == "began" then
			tutorialBtn.x =  cw - 80000
			tutorialBtnD.x = cw - 80
		elseif event.phase == "ended" then
			tutorialBtnD.x = cw - 80000
			tutorialBtn.x = cw - 80
			director:changeScene("tutorial", "crossfade")
		end
	end
	tutorialBtnOverlay:addEventListener("touch", goTutorial)

	local function updateAudioToggle(event)
		local audioData = Load("audioData")
		print("Audio is...", audioData.toggle)
		if audioData.toggle == "on" then
			soundBtn.x = 80
			soundBtnD.x = 80000
		elseif audioData.toggle == "off" then
			soundBtn.x = 80000
			soundBtnD.x = 80
		end
	end
	updateAudioToggle()
	-- local function updateAudioToggle()
	-- 	local audioData = Load("audioData")
	-- 	print("Audio is...", audioData.toggle)
	-- 	if audioData.toggle == "on" then
	-- 		audioAnimation:setFrame(1)
	-- 	elseif audioData.toggle == "off" then
	-- 		audioAnimation:setFrame(2)
	-- 	end
	-- end
	-- updateAudioToggle()

	local function toggleAudio(event)
		if event.phase == "began" then
			soundBtnOutline.x = 80000
			soundBtnOutlineD.x = 80
			soundBtn:scale(0.9,0.9)
			soundBtnD:scale(0.9,0.9)
		elseif event.phase == "ended" then
			soundBtnOutline.x = 80
			soundBtnOutlineD.x = 80000
			soundBtn:scale(1.1,1.1)
			soundBtnD:scale(1.1,1.1)

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
	end
	soundOverlay:addEventListener("touch", toggleAudio)
	 	
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

	local rushBtn = displayNewButton(group, "Images/button.png", nil, cw/2 - 175, ch/2 - 300, false, 1, 0, "gameNew", "Rush", 150, 150, 150, "Hiruko", 80, nil, nil)
	local infiniBtn = displayNewButton(group, "Images/button.png", nil, cw/2 - 175, ch/2 - 150, false, 1, 0, "gameNew", "Infini-Fall", 150, 150, 150, "Hiruko", 80, setInfini, nil)
	local wallToWallBtn = displayNewButton(group, "Images/button.png", nil, cw/2 - 175, ch/2 , false, 1, 0, "gameNew", "Wall To Wall", 150, 150, 150, "Hiruko", 68, setWallTWall, nil)

	-- move things according to device
	local modelName = findModel()
	if modelName == "Nook" or modelName == "iPhone5" or modelName == "Macbook" then

		print("DIF MODEL!")
		local yDif = 50
		rushBtn.y = rushBtn.y - yDif
		infiniBtn.y = infiniBtn.y - yDif
		wallToWallBtn.y = wallToWallBtn.y - yDif
		-- tut and sound btns
		tutorialBtn.y = tutorialBtn.y - yDif
		tutorialBtnD.y = tutorialBtnD.y - yDif
		tutorialBtnOverlay.y = tutorialBtnOverlay.y - yDif
		soundBtn.y = soundBtn.y - yDif
		soundBtnD.y = soundBtnD.y - yDif
		soundBtnOutline.y = soundBtnOutline.y - yDif
		soundBtnOutlineD.y = soundBtnOutlineD.y - yDif
		soundOverlay.y = soundOverlay.y - yDif

		-- more specifics
		if modelName == "Nook" or modelName == "Macbook" then
			-- create the leaderboard btn
			local leaderboardsBtn = displayNewButton(group, "Images/button.png", nil, cw/2 - 175, ch/2 + 100, false, 1, 0, "leaderboards", "Leaderboards", 150, 150, 150, "Hiruko", 55, nil, nil)

		elseif modelName == "iPhone5" then
			-- move mail down a bit more
			mail.y = mail.y + yDif
			multiLineText.y = multiLineText.y + yDif
			-- move the sound up a bit more
			local soundExtraDif = -25
			soundBtn.y = soundBtn.y + soundExtraDif 
			soundBtnD.y = soundBtnD.y   + soundExtraDif
			soundBtnOutline.y = soundBtnOutline.y   + soundExtraDif
			soundBtnOutlineD.y = soundBtnOutlineD.y   + soundExtraDif
			soundOverlay.y = soundOverlay.y  + soundExtraDif
			-- move the tut btns up a bit more
			tutorialBtn.y = tutorialBtn.y + soundExtraDif
			tutorialBtnD.y = tutorialBtnD.y + soundExtraDif
			tutorialBtnOverlay.y = tutorialBtnOverlay.y + soundExtraDif
		end
	end
	--group:insert(leaderboardsBtnH)
	--director:changeScene("game")

	return group
end

return M