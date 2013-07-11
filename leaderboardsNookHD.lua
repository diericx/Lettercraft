local scoredojo = require "scoredojo"

local M = {}

function M.new()
	local group = display.newGroup()

	--check for ser info, if there create header
	local userInfo = Load("userInfo", userInfo)
	local userInfoTemp = {email = nil, password = nil, username = nil}

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

	
	scoredojo.start(baseLink, token, "10")

	return group
end

return M