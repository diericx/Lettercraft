local M = {}
function M.new()
	local group = display.newGroup()

	display.setStatusBar( display.HiddenStatusBar )

	local bg = displayBackground(group)

	local function setInfini()
		gameMode="InfiniFall"
	end

	local function setWallTWall()
		gameMode="WallToWall"
		token = "3d59539700c3cdc77c43d3b3e415891d"
	end

	--local testBtn = display.newImage(group, "Images/clearBtn.png", 0, 230)

	local rushBtn = displayNewButton(group, "Images/clearBtn.png", "Images/clearBtnDwn.png", cw/2 - 350, ch/2 - 300, false, 1, 0, "gameNew", "Rush", 255, 255, 255, "Hiruko", 80, nil, nil)
	--rushBtn.alpha = 0.8
	local infiniBtn = displayNewButton(group, "Images/clearBtn.png", "Images/clearBtnDwn.png", cw/2 - 350, ch/2 - 150, false, 1, 0, "gameNew", "Infini-Fall", 255, 255, 255, "Hiruko", 80, setInfini, nil)
	local wallToWallBtn = displayNewButton(group, "Images/clearBtn.png", "Images/clearBtnDwn.png", cw/2 - 350, ch/2 , false, 1, 0, "gameNew", "Wall To Wall", 255, 255, 255, "Hiruko", 68, setWallTWall, nil)
	return group
end

return M