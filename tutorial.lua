local M = {}

function M.new()
	physics = require "physics"
	physics.start()
	physics.setGravity(0,0)
	sqlite3 = require "sqlite3"

	local group = display.newGroup()
	local letterGroup = display.newGroup()
	group:insert(letterGroup)


	return group
end

return M