local M = {}
function M.new()
	local group = display.newGroup()

	display.setStatusBar( display.HiddenStatusBar )

	local bg = displayBackground(group)

	local btnYOffset = -10

	local function setRush()
		gameMode="Rush"
		token = "0295e83b1031e2412ef0cc26045b2366"
	end

	local function setInfini()
		gameMode="InfiniFall"
	end

	local function setWallTWall()
		gameMode="WallToWall"
		token = "3d59539700c3cdc77c43d3b3e415891d"
	end

	local backBtn = displayNewButton(group, "scoredojo/buttonUpSmall.png", "scoredojo/buttonDownSmall.png", 20, 10, false, 1, nil, "menu", "Back", 25, 25, 25, "Hiruko", 40, removeFields, nil)

	--local testBtn = display.newImage(group, "Images/clearBtn.png", 0, 230)

	local rushBtn = displayNewButton(group, "Images/clearBtn.png", "Images/clearBtnDwn.png", cw/2 - 350, ch/2 - 300 + btnYOffset, false, 1, 0, "gameNew", "Rush", 255, 255, 255, "Hiruko", 80, setRush, nil)
	--rushBtn.alpha = 0.8
	local infiniBtn = displayNewButton(group, "Images/clearBtn.png", "Images/clearBtnDwn.png", cw/2 - 350, ch/2 - 150 + btnYOffset, false, 1, 0, "gameNew", "Infini-Fall", 255, 255, 255, "Hiruko", 80, setInfini, nil)
	local wallToWallBtn = displayNewButton(group, "Images/clearBtn.png", "Images/clearBtnDwn.png", cw/2 - 350, ch/2 + btnYOffset , false, 1, 0, "gameNew", "Wall To Wall", 255, 255, 255, "Hiruko", 68, setWallTWall, nil)
	
	local modelName = findModel()
	if modelName == "Nook" or modelName == "NookHD" or modelName == "Macbook" then
		btnYOffset = 30
		rushBtn.y = rushBtn.y -10
		infiniBtn.y = ch/2 - 173 + btnYOffset
		wallToWallBtn.y = ch/2 - 0 + btnYOffset
	end

	return group
end

return M