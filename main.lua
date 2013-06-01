local mime = require "mime"
json = require "json"
--widget = require "widget"
scoredojo = require "scoredojo"
local onEnterFrame = false
local lastTime = system.getTimer()

display.setStatusBar( display.HiddenStatusBar )


--system.setIdleTimer( false ) -- change for nook

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

-- gameNetwork = require( "gameNetwork" )

-- CC_Access_Key = "874d15b4684aae2811308c25cf18c4c556ad5755"
-- CC_Secret_Key = "6109e4882fe07cb0abb510b6dd6a25653fa52eb6"

-- coronaCloud = require ( "corona-cloud-core" )
-- coronaCloud.init( CC_Access_Key, CC_Secret_Key )

-- local params = { accessKey = CC_Access_Key, secretKey = CC_Secret_Key, }
-- gameNetwork.init( "corona", params )

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

function randomLetter()
	local randomNumber = math.random(1, 32)
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

function displayNewButton(group, image, imageDown, x, y, shouldScale, scaleX, timeToScale, sceneToGoTo, text, tr, tg, tb, font, textSize, customFunction, id)
	local btnGroup = display.newGroup()
	group:insert(btnGroup)
	local newBtn = display.newImage(image, 0, 0 )
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

	
	--newBtn.touch = onNewBtnTouch
	--newBtn:addEventListener("touch", newBtn)
	newBtn:addEventListener("touch", onNewBtnTouch)
	btnGroup.x = x
	btnGroup.y = y
	return btnGroup
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

