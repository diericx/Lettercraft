local scoredojo = require "scoredojo"

local M = {}

function M.new()
	local group = display.newGroup()

	--check for ser info, if there create header
	local userInfo = Load("userInfo", userInfo)
	local userInfoTemp = {email = nil, password = nil, username = nil}
	local token = "eac5a095cbe1936c64079d0a5a6dc268"
	local baseLink = "https://scoredojo.com/api/v1/"

	--server stuff
	headers = {}
	headers["Accept"] = "application/json"

	if userInfo ~= nil and userInfo.authKey ~= nil then
		headers["Authorization"] = "Token token="..tostring(userInfo.authKey)
	end
	-- local bg = display.newImage(group, "Images/bg.png", 0, 0)
	-- bg:rotate(0)
	-- bg.x = cw/2
	-- bg.y = ch/2
	-- local bg = display.newRect(0, 0, cw, ch)
	-- bg:setFillColor(240,240,240)

	
	scoredojo.start("https://scoredojo.com/api/v1/", "eac5a095cbe1936c64079d0a5a6dc268", "10")

	return group
end

return M