local M = {}

function M.new()
	physics = require "physics"
	physics.start()
	physics.setGravity(0,0)
	sqlite3 = require "sqlite3"

	local currentSlide = 1

	local group = display.newGroup()
	local letterGroup = display.newGroup()
	group:insert(letterGroup)

	local bg = displayBackground(group)

	local modelName = findModel()
	if modelName == "Nook" or modelName == "iPhone5" or modelName == "Macbook" or modelName == "NookHD" then
		local yDif = 87
		local extraYDif = 22
		bg.y = bg.y - yDif
	end

	local getStartedBtn = display.newImage(group, "Images/tutGetStarted.png", 0, 0)
	getStartedBtn.x, getStartedBtn.y = cw/2, ch - 100

	local getStartedBtnD = display.newImage(group, "Images/tutGetStartedD.png", 0, 0)
	getStartedBtnD.x, getStartedBtnD.y = cw/2 + 1000, ch - 100

	getStartedBtnOverlay = display.newRect(group, cw/2, ch - 100, 564, 108)
	getStartedBtnOverlay.x, getStartedBtnOverlay.y = cw/2, ch-100
	getStartedBtnOverlay.alpha = 0.01

	local leftBtn = display.newRect(group, 50, ch/2 + 141, 140, 115)
	leftBtn:setFillColor(100, 100, 100)
	leftBtn.alpha = 0.01

	local rightBtn = display.newRect(group, cw/2 + 140, ch/2 + 141, 140, 115)
	rightBtn:setFillColor(100, 100, 100)
	rightBtn.alpha = 0.01
	--rightBtn.x, rightBtn.y = 80, ch/2 + 171

	local slides = {}

	for i = 1, 6 do
		local slide = display.newImage(group, "Images/tutPage"..i..".png", 0, 0)
		slide.x, slide.y = cw/2 + 1000, ch/2 - 75
		local tablePos = #slides + 1
		slides[tablePos] = slide

		rightBtn:toFront()
		leftBtn:toFront()
	end

	local function getStarted (event)
		if event.phase == "began" then
			getStartedBtn.x = cw/2 + 1000
			getStartedBtnD.x = cw/2
		elseif event.phase == "ended" then
			getStartedBtn.x = cw/2
			getStartedBtnD.x = cw/2 + 1000
			setEnterFrame(nil)
			director:changeScene("gameNew")
		end
	end
	getStartedBtnOverlay:addEventListener("touch", getStarted)

	local function previousSlide (event)
		if event.phase == "began" then
			leftBtn.alpha = 0.3
		elseif event.phase == "ended" then
			leftBtn.alpha = 0.01
			print(currentSlide)
			if currentSlide > 1 then
				currentSlide = currentSlide - 1
			end
		end
	end
	leftBtn:addEventListener("touch", previousSlide)

	local function nextSlide (event)
		if event.phase == "began" then
			rightBtn.alpha = 0.3
		elseif event.phase == "ended" then
			rightBtn.alpha = 0.01
			print(currentSlide)
			if currentSlide < #slides then
				currentSlide = currentSlide + 1
			end
		end
	end
	rightBtn:addEventListener("touch", nextSlide)

	local function enterFrame ()
		for i = 1, #slides do
			if currentSlide == i then
				slides[i].x = cw/2
			else
				slides[i].x = cw/2 + 1000
			end
		end
	end
	setEnterFrame(enterFrame)


	return group
end

return M