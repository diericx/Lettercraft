local M = {}
function M.new()
	local group = display.newGroup()

	display.setStatusBar( display.HiddenStatusBar )

	--check for ser info, if there create header
	local userInfo = Load("userInfo", userInfo)
	--server stuff
	headers = {}
	headers["Accept"] = "application/json"

	if userInfo ~= nil and userInfo.authKey ~= nil then
		headers["Authorization"] = "Token token="..tostring(userInfo.authKey)
	end

	token = "0295e83b1031e2412ef0cc26045b2366"

	-- local bg = display.newRect(group, 0, 0, cw, ch)
	-- bg:setFillColor(250, 250, 250)
	local bg = displayBackground(group)

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

	-- local mail = display.newImage(group, "Images/mail.png", -100, 0)
	-- mail:setReferencePoint( display.CenterReferencePoint )
	-- mail.x = cw/2 + 10
	-- mail.y = ch - 135
	-- mail:scale(0.8,0.8)

	local mail = displayNewButton(group, "Images/mail.png", nil, cw/2 - 100, ch - 335, true, 0.8, 0, "gameNew", "", 150, 150, 150, "Hiruko", 80, nil, nil)
	mail.x, mail.y = cw/2 - 100, ch - 240
	local function thanksPopListener( event )
	        if "clicked" == event.action then
	                local i = event.index
	                if 1 == i then -- No
	                	print("rate")
						local options =
						{
						   iOSAppId = "670830956",
						   nookAppEAN = "2940147138588",
						   supportedAndroidStores = { "nook" },
						}
						native.showPopup("rateApp", options)
	                elseif 2 == i then -- Yes
	                	print("Remind me")
	                elseif 3 == i then -- Yes
	                	print("no thanks")
	                	local menuCount = Load("menuCount")
	                	menuCount.shouldDisplayPopup = false
	                	Save(menuCount, "menuCount")
	                end
	        end
	end

	-- ask for feedback every once in a while
	-- feedback popup listener
	-- Handler that gets notified when the alert closes
	local doYouLoveAlert
	local thanksAlert
	local function popupListener( event )
	        if "clicked" == event.action then
	                local i = event.index
	                if 1 == i then -- No
	                	local options =
						{
						   to = "appdojostudios@gmail.com",
						   subject = "Give Feedback",
						   body = ""
						}
						native.showPopup("mail", options)
						local menuCount  = Load("menuCount")
						menuCount.shouldDisplayPopup = false
						Save(menuCount, "menuCount")
	                        --system.openURL( "http://developer.anscamobile.com" )	                		
	                        -- Do nothing; dialog will simply dismiss
	                elseif 2 == i then -- Yes
	                	print("Rate")
	                	-- native.cancelAlert(doYouLoveAlert)
	                	local thanksTxt = "We are so happy to hear that you love Lettercraft! It'd be really helpful if you rated us in the App Store."
	                	thanksAlert = native.showAlert( "Thank you!", thanksTxt, { "Rate Lettercraft", "Remind Me Later", "No Thanks" }, thanksPopListener )
	                	--thanksAlert = native.showAlert( "Thank you!", thanksTxt, { "Maybe later" }, thanksPopListener )
	                        -- Open URL if "Learn More" (the 2nd button) was clicked
	                end
	        end
	end

	local menuCount = Load("menuCount")
	-- if its not there, create one
	if menuCount == nil then
		menuCount = {count = 0, top = 5, shouldDisplayPopup = true}
		Save(menuCount, "menuCount")
	-- if it is there, add to it
	elseif menuCount.shouldDisplayPopup == true then
		if menuCount.count < menuCount.top then
			menuCount.count = menuCount.count + 1
			Save(menuCount, "menuCount")
		-- if it equals the top then display popup
		elseif menuCount.count == menuCount.top then
			menuCount.count = 0
			Save(menuCount, "menuCount")
			--display a popup
			-- Show alert with five buttons
			doYouLoveAlert = native.showAlert( "Do you love Lettercraft?", "", { "No", "Yes" }, popupListener )
		end
	end

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
		token = "3d59539700c3cdc77c43d3b3e415891d"
	end

	local rushBtn = displayNewButton(group, "Images/button.png", nil, cw/2 - 175, ch/2 - 300, false, 1, 0, "gameNew", "Rush", 150, 150, 150, "Hiruko", 80, nil, nil)
	local infiniBtn = displayNewButton(group, "Images/button.png", nil, cw/2 - 175, ch/2 - 150, false, 1, 0, "gameNew", "Infini-Fall", 150, 150, 150, "Hiruko", 80, setInfini, nil)
	local wallToWallBtn = displayNewButton(group, "Images/button.png", nil, cw/2 - 175, ch/2 , false, 1, 0, "gameNew", "Wall To Wall", 150, 150, 150, "Hiruko", 68, setWallTWall, nil)

	-- move things according to device
	local modelName = findModel()
	if modelName == "Nook" or modelName == "NookHD" or modelName == "iPhone5" or modelName == "iPhoneBelow5" or modelName == "Macbook" then

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
		if modelName == "Nook" or modelName == "NookHD" or modelName == "Macbook" then
			-- create the leaderboard btn
			--local infiniFallLeaderboards = displayNewButton(group, "Images/button.png", nil, cw/2 - 175, ch/2 + 100, false, 1, 0, "leaderboards", "infinifall Lb", 150, 150, 150, "Hiruko", 55, nil, nil)
			--local wallToWallLeaderboards = displayNewButton(group, "Images/button.png", nil, cw/2 - 175, ch/2 + 100, false, 1, 0, "leaderboards", "WallToWall LB", 150, 150, 150, "Hiruko", 55, nil, nil)
			local function goRushLB(self, event)
				if event.phase == "began" then
					self:setFillColor(210, 210, 255)
				elseif event.phase == "ended" then
					self:setFillColor(235, 235, 255)
					token = "0295e83b1031e2412ef0cc26045b2366"
					if modelName == "NookHD" then
						director:changeScene("leaderboardsNookHD", "moveFromLeft")
					else
						director:changeScene("leaderboards", "moveFromLeft")
					end
				end
			end

			local function goWTWLB(self, event)
				if event.phase == "began" then
					self:setFillColor(210, 210, 255)
				elseif event.phase == "ended" then
					self:setFillColor(235, 235, 255)
					token = "3d59539700c3cdc77c43d3b3e415891d"
					if modelName == "NookHD" then
						director:changeScene("leaderboardsNookHD", "moveFromRight")
					else 
						director:changeScene("leaderboards", "moveFromRight")
					end
				end
			end

			local rushLB = display.newImage (group, "Images/button.png", 0, 0)
			rushLB:setFillColor(235, 235, 255) --220
			rushLB:scale(0.9, 0.9)
			rushLB.x, rushLB.y = cw/2 - 150, ch/2 + 170
			rushLB.touch = goRushLB
			rushLB:addEventListener("touch", rushLB)

			local wallToWallLB = display.newImage (group, "Images/button.png", 0, 0)
			wallToWallLB:setFillColor(235, 235, 255)
			wallToWallLB:scale(0.9, 0.9)
			wallToWallLB.x, wallToWallLB.y = cw/2 + 150, ch/2 + 170
			wallToWallLB.touch = goWTWLB
			wallToWallLB:addEventListener("touch", wallToWallLB)

			local rushLBtxt = display.newMultiLineText  
		        {
		        text = "Rush Leaderboards",
		        width = 250,                  --OPTIONAL        Defailt : nil 
		        left = cw/2 - 150,top = ch/2 + 170,             --OPTIONAL        Default : left = 0,top=0
		        font = "Hiruko",     --OPTIONAL        Default : native.systemFont
		        fontSize = 40,                --OPTIONAL        Default : 14
		        color = {90,90,90},              --OPTIONAL        Default : {0,0,0}
		        align = "center"              --OPTIONAL   Possible : "left"/"right"/"center"
		        }
		    rushLBtxt.x = cw/2 - 150
		    rushLBtxt.y = ch/2 + 170

		    group:insert(rushLBtxt)

			local wtwLBText = display.newMultiLineText  
		        {
		        text = "Wall To Wall Leaderboards",
		        width = 250,                  --OPTIONAL        Defailt : nil 
		        left = cw/2 - 150,top = ch/2 + 170,             --OPTIONAL        Default : left = 0,top=0
		        font = "Hiruko",     --OPTIONAL        Default : native.systemFont
		        fontSize = 40,                --OPTIONAL        Default : 14
		        color = {90,90,90},              --OPTIONAL        Default : {0,0,0}
		        align = "center"              --OPTIONAL   Possible : "left"/"right"/"center"
		        }
		    wtwLBText.x = cw/2 + 150
		    wtwLBText.y = ch/2 + 170

		    group:insert(wtwLBText)
		    if modelName == "NookHD" then
		    	local yDif = 48
				tutorialBtn.y = tutorialBtn.y + yDif
				tutorialBtnD.y = tutorialBtnD.y + yDif
				tutorialBtnOverlay.y = tutorialBtnOverlay.y + yDif
				soundBtn.y = soundBtn.y + yDif 
				soundBtnD.y = soundBtnD.y   + yDif
				soundBtnOutline.y = soundBtnOutline.y   + yDif
				soundBtnOutlineD.y = soundBtnOutlineD.y   + yDif
				soundOverlay.y = soundOverlay.y  + yDif
			end

		elseif modelName == "iPhone5" then
			-- move bg
			bg:scale(1, 1.1)
			bg.y = bg.y - 100
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
		elseif modelName == "iPhoneBelow5" then
			local bellow5Dif = 35
			soundBtn.y = soundBtn.y + bellow5Dif 
			soundBtnD.y = soundBtnD.y   + bellow5Dif
			soundBtnOutline.y = soundBtnOutline.y   + bellow5Dif
			soundBtnOutlineD.y = soundBtnOutlineD.y   + bellow5Dif
			soundOverlay.y = soundOverlay.y  + bellow5Dif
			-- move the tut btns up a bit more
			tutorialBtn.y = tutorialBtn.y + bellow5Dif
			tutorialBtnD.y = tutorialBtnD.y + bellow5Dif
			tutorialBtnOverlay.y = tutorialBtnOverlay.y + bellow5Dif
		end
	end
	--group:insert(leaderboardsBtnH)
	--director:changeScene("game")

	return group
end

return M