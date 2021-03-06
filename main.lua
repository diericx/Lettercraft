local mime = require "mime"
json = require "json"
--widget = require "widget"
scoredojo = require "scoredojo"
gameNetwork = require "gameNetwork"
require "multiline_text"
local onEnterFrame = false
local lastTime = system.getTimer()

token = "0295e83b1031e2412ef0cc26045b2366"
baseLink = "https://scoredojo.com/api/v1/"

--Acheivments

--for GameCenter, default to the achievement name from iTunes Connect
myAchievement = "com.lettercraft.achivementname"
--leaderboards
myCategory = "com.yourname.yourgame.highscores"

sentEmail = false
rated = false

display.setStatusBar( display.HiddenStatusBar )


--system.setIdleTimer( false ) -- change for nook
--set game mode
gameMode = "Rush"

--other stuff
cw = display.contentWidth
ch = display.contentHeight


device = {

	name = system.getInfo("name"),
	model = system.getInfo("model"),

}

alphabet = {
	{letter="A", value=1}, {letter="B", value=3}, {letter="C", value=3}, {letter="D", value=2}, {letter="E", value=1}, 
	{letter="F", value=4}, {letter="G", value=2}, {letter="H", value=4}, {letter="I", value=1}, {letter="J", value=8}, 
	{letter="K", value=5}, {letter="L", value=1}, {letter="M", value=3}, {letter="N", value=1}, {letter="O", value=1}, 
	{letter="P", value=3}, {letter="Q", value=10}, {letter="R", value=1}, {letter="S", value=1}, {letter="T", value=1}, 
	{letter="U", value=1}, {letter="V", value=4}, {letter="W", value=4}, {letter="X", value=8}, {letter="Y", value=4}, 
	{letter="Z", value=10}, 
	--MORE VOWELS!
	{letter="A", value=1},
	{letter="E", value=1},
	{letter="I", value=1},
	{letter="O", value=1},
	{letter="U", value=1},
	--AND SOMETIMES Y!
	{letter="Y", value=4},
}
print(alphabet[1].letter)

-- alphabet = {
-- 	{letter="R", value = 1}, {letter="O", value=1}
-- }

function setEnterFrame( listener )   
	onEnterFrame = listener
end

function enterFrame(event)	
	if onEnterFrame then
		onEnterFrame(event.time - lastTime)
	end
	lastTime = event.time
end
Runtime:addEventListener("enterFrame", enterFrame)

function findModel ()

	device = {

		name = system.getInfo("name"),
		model = system.getInfo("model"),

	}

	deviceModelName = ""

	if device.model == "BNTV200a" or device.model == "BNTV200" or device.model == "BNTV250" or device.model == "BNTV250a" then 
		deviceModelName = "Nook"
	elseif device.model == "BNTV400" or device.model == "BNTV600" then
		deviceModelName = "NookHD"
	elseif device.model == "A1428" or device.model == "A1429" or device.model == "A1442" then
		deviceModelName = "iPhone5"
	elseif device.model == "A1387" or device.model == "A1431" or device.model == "A1349" or device.model == "A1332" or device.model == "A1325" or device.model == "A1303" or device.model == "A1324" or device.model == "A1241" or device.model == "A1203" or device.model == "iPhone" then
		deviceModelName = "iPhoneBelow5"
	elseif device.model == "BNRV200" then
		deviceModelName = "Macbook"
	else 
		deviceModelName = "Android"
	end
	return deviceModelName
end

print("deviceModel: ", device.model, "findModel: ", findModel())

function displayBackground(group)
	local deviceModel = findModel()
	local bg
	if deviceModel == "Nook" or deviceModel == "Macbook" then
		bg = display.newImage(group, "Images/bg2.png", 10, 0)
		bg:scale(1.2, 1.2)
	elseif deviceModel == "iPhone5" then
		bg = display.newImage(group, "Images/bg2.png", 10, 0)
		bg:scale(1.2, 1.2)
	elseif deviceModel == "iPhoneBelow5" then
		bg = display.newImage(group, "Images/bg2.png", 10, 0)
		bg:scale(1.2, 1)
	else
		bg = display.newImage(group, "Images/bg2.png", 10, 0)
		bg:scale(1.2, 1)
	end
	return bg
end

function randomLetter()
	local randomNumber = math.random(1, 32) -- 32
	local letter
	for i = 1, 32 do 
		if randomNumber == i then
			letter = { text = alphabet[i].letter, value = alphabet[i].value }
		end
	end
	return letter
end

function Load( pathname )
	local data = nil
	local path = system.pathForFile( pathname..".dat", system.DocumentsDirectory  ) 
	local fileHandle = io.open( path, "r" )
	if fileHandle then
		data = json.decode( mime.unb64( fileHandle:read( "*a" ) ) or "" )
		io.close( fileHandle ) 
	end 
	return data 
end

function Save( data, pathname ) 
	local success = false 
	local path = system.pathForFile( pathname..".dat", system.DocumentsDirectory  ) 
	local fileHandle = io.open( path, "w" ) 
	if fileHandle and data then 
		local encodedData = mime.b64( json.encode(data) ) 
		fileHandle:write( encodedData ) 
		io.close( fileHandle ) 
		success = true
	end
	return success 
end

local audioData = Load("audioData")
if audioData then
else 
	local audioData = {toggle = "on"}
	Save(audioData, "audioData")
end

local menuCount = Load("menuCount")
-- if its not there, create one
if menuCount == nil then
	menuCount = {count = 0, top = 5, shouldDisplayPopup = true, shouldDisplayEmail = true, shouldDisplayRated = true, rush = false, wtw = false, infini = false, shouldDisplyILove = true, shouldDisplayTheresMore = true}
	Save(menuCount, "menuCount")
end


--check for ser info, if there create header
local userInfo = Load("userInfo", userInfo)
--server stuff
headers = {}
headers["Accept"] = "application/json"

if userInfo ~= nil and userInfo.authKey ~= nil then
	print("Asdf")
	headers["Authorization"] = "Token token="..tostring(userInfo.authKey)
	print(userInfo.authKey, userInfo.username, userInfo.password)
end
director = require("director")


--------
--------ANDROID LEADERBOARDS
--------
local playerName

function loadLocalPlayerCallback( event )
	print(event.isError)
   playerName = event.data.alias
   saveSettings()  --save player data locally using your own "saveSettings()" function
end

function gameNetworkLoginCallback ( event )
	print(event.isError)
	print("LOGINCALLBACK")
   gameNetwork.request( "loadLocalPlayer", { listener=loadLocalPlayerCallback } )
   return true
end

function gpgsInitCallback ( event )
	print(event.isError)
	print("INITCALLBACK")
    gameNetwork.request( "login", { userInitiated=true, listener=gameNetworkLoginCallback } )
end

function gameNetworkSetup ()
   if ( system.getInfo("platformName") == "Android" ) then
   	   print("GAMENETWORKSETUP")
      gameNetwork.init( "google", gpgsInitCallback )
   else
      gameNetwork.init( "gamecenter", gameNetworkLoginCallback )
   end
end
local modelName = findModel()
if modelName == "Android" or modelName == "iPhone5" or modelName == "iPhoneBelow5" then
	gameNetworkSetup()
end

------HANDLE SYSTEM EVENTS------
local function systemEvents( event )
	print(sentEmail, rated)
   print("systemEvent " .. event.type)
   if ( event.type == "applicationSuspend" ) then
      print( "suspending..........................." )
   elseif ( event.type == "applicationResume" ) then
   		--gameNetworkSetup()
      	print( "resuming............................." )
      	local modelName = findModel()
     	menuCount = Load("menuCount")
     	if modelName == "Android" then
		    if sentEmail == true and menuCount.shouldDisplayEmail == true then
		    	local modelName = findModel()
		    	menuCount.shouldDisplayEmail = false
		      	Save(menuCount, "menuCount")
				--acheivment for android/ios
				timer.performWithDelay(1000, function() 
					print("ACHEIVMENT SENT EMAIL")
					if modelName == "Android" then
						myAchievement = "CgkIsPr-4KgFEAIQBA"

						gameNetwork.request( "unlockAchievement",
						{
						   achievement = { identifier="CgkIsPr-4KgFEAIQBA", percentComplete=100, showsCompletionBanner=true },
						   listener = achievementRequestCallback
						} )
					end
				end, 1)
		    elseif rated == true and menuCount.shouldDisplayRated == true then
		    	local modelName = findModel()
		    	menuCount.shouldDisplayEmail = false
		      	Save(menuCount, "menuCount")
				--acheivment for android/ios
				timer.performWithDelay(1000, function() 
					print("ACHEIVMENT rated")
					if modelName == "Android" then
						myAchievement = "CgkIsPr-4KgFEAIQBQ"

						gameNetwork.request( "unlockAchievement",
						{
						   achievement = { identifier="CgkIsPr-4KgFEAIQBQ", percentComplete=100, showsCompletionBanner=true },
						   listener = achievementRequestCallback
						} )
					end
				end, 1)
			end
		end
   elseif ( event.type == "applicationExit" ) then
      print( "exiting.............................." )
   elseif ( event.type == "applicationStart" ) then
		if modelName == "Android" or modelName == "iPhone5" or modelName == "iPhoneBelow5" then
        	gameNetworkSetup()  --login to the network here
        end
   end
   return true
end

--Runtime:addEventListener( "system", systemEvents )

-- director = {
--     scene = 'main',
--     changeScene = function (self, moduleName)
--         if type(moduleName) == 'nil' or self.scene == moduleName then return end
--         if self.clean and type(self.clean) == 'function' then self.clean() end
--         if self.view then self.view:removeSelf() end
--         if self.scene ~= 'main' and type(package.loaded[self.scene]) == 'table' then
--             package.loaded[self.scene], self.view = nil
--             collectgarbage('collect')
--         end
--         self.scene, self.view, self.clean = moduleName, require(moduleName).new()
--     end
-- }

function displayNewButton(group, image, imageDown, x, y, shouldScale, scaleX, timeToScale, sceneToGoTo, text, tr, tg, tb, font, textSize, customFunction, id, textX, textY)
	local btnGroup = display.newGroup()
	group:insert(btnGroup)
	local newBtn = display.newImage(image, 0, 0 )
	if newBtn then
		newBtn.id = id
		btnGroup:insert(newBtn)
		--newBtn.x = x
		local overlayBtn
		local btnText
		newBtn.alpha = 1

		local btnText
		if text ~= nil then
			newBtn.text = btnText
			btnText = display.newText( text, newBtn.x, newBtn.y, font, textSize )
			btnText:setTextColor(tr,tg,tb)
			btnText.x, btnText.y = newBtn.x, newBtn.y + 7
			if textX then
				btnText.x = btnText.x + textX
			end
			if textY then
				btnText.y = btnText.y + textY
			end
			btnGroup:insert(btnText)
		end

		local function onNewBtnTouch (event)
			if event.phase == "began" then
				currentButtonDown = newBtn
				if shouldScale == true then
					transition.to(newBtn, {time=timeToScale, xScale = scaleX, yScale = scaleX})
					transition.to(btnText, {time=timeToScale, xScale = scaleX, yScale = scaleX})
				end
				if imageDown ~= nil then
					overlayBtn = display.newImage(btnGroup, imageDown, 0, 0)
					btnGroup:insert(overlayBtn)
					btnText:toFront()
					btnText.alpha = 0.5
				end
			elseif event.phase == "ended" then
				btnText.alpha = 1
				display.remove(overlayBtn)
				if customFunction then
					customFunction(btnGroup)
				end
				currentButtonDown = nil
				--if customFunction == nil then
					if shouldScale == true then
						transition.to(newBtn, {time=timeToScale, xScale = 1, yScale = 1, onComplete=function()transition.cancel(newBtn) if sceneToGoTo ~= nil then end end})
						transition.to(btnText, {time=timeToScale, xScale = 1, yScale = 1, onComplete=function()transition.cancel(newBtn) if sceneToGoTo ~= nil then end end})			
					elseif shouldScale == false then
						if sceneToGoTo ~= nil then 
							if overlayBtn then
								--btnGroup:removeSelf()
							end
							director:changeScene(sceneToGoTo, "crossfade")
						end
					end
				--end
			end
			return true
		end

		newBtn.cancel = function ()
			if overlayBtn then
				btnText.alpha = 1
				display.remove(overlayBtn)
				overlayBtn = nil
			end
			if shouldScale == true then
				transition.to(newBtn, {time=timeToScale, xScale = 1, yScale = 1})
				transition.to(btnText, {time=timeToScale, xScale = 1, yScale = 1})
			end
		end

		newBtn:addEventListener("touch", onNewBtnTouch)
		btnGroup.x = x
		btnGroup.y = y
		return btnGroup
	end
end

local function runtimeTouch (event)

		if event.phase == "moved" then
			if currentButtonDown then
				--- this is the 'onMouseOut' event
				currentButtonDown.cancel()
			end
		elseif event.phase == "ended" then
            --- all buttons should be 'up' becuse there are no touches
            if currentButtonDown then
           		currentButtonDown.cancel()
           	end
		end

end

Runtime:addEventListener("touch", runtimeTouch)


director:changeScene("menu") 

