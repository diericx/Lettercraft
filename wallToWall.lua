local M = {}

function M.new()
	local group = display.newGroup()
	local guiGroup = display.newGroup()
	local letterSpawnTime = 70
	local score = 0
	local currentScore = score
	local currentTime = 140
	local timeSubtractor = 0.1
	local letterSpeed = 115
	local timeCapacity = currentTime
	local letterSpawnCooldown = letterSpawnTime
	local swipeStartX
	local swipeStartY
	local swipeEndX
	local swipeEndY
	local word
	local enterFrame
	physics = require("physics")
	sqlite3 = require ("sqlite3")
	--Sqlite setup
	local path = system.pathForFile("dictionary.sqlite")
	local db = sqlite3.open( path ) --remember to close
	--physics setup
	physics.start()
	physics.setGravity(0,0) 

	local function untouchable ()
		print("Aint nobody gon touch mah chillen")
		return true
	end

	local function isWordValid(word)
		local cmd = "SELECT * FROM words WHERE word LIKE '" .. word .. "'"
		--local cmd = "SELECT * FROM words WHERE word LIKE '[A]%'"
		--local wordsFound = db:nrows(cmd)
		local validity = false
		for row in db:nrows(cmd) do
			print("Valid")
			validity = true
			print(row)
		end
		return validity
	end

	local letters = {}

	local chosenLetters = {}

	-- local bg = display.newRect(group, 0, 0, cw, ch)
	-- bg:setFillColor(250, 250, 250)

	local bg = display.newImage(group, "Images/bg2.png", 10, 0)
	bg:scale(1.2, 1)

	-- local botBar = display.newRect(guiGroup, 0, ch-150, cw, 150)
	-- botBar:setFillColor(150,150,150)
	-- botBar.alpha = 0.8
	local botBar = display.newImage(guiGroup, "Images/bar.png", 0, ch - 123)
	botBar:setFillColor(200, 200, 200)
	botBar:scale(1, 1.5)
	botBar.alpha = 0.8

	local topBar = display.newRect(guiGroup, 0, 0, cw, 50)
	topBar:setFillColor(0, 0, 0)
	topBar.alpha = 0.6
	topBar:addEventListener("touch", untouchable)

	local scoreTxt = display.newText(guiGroup, currentScore, 0, 0, "Hiruko", 50)
	scoreTxt.x = cw/2 + 2
	scoreTxt.y = 30
	scoreTxt:setTextColor(255, 215, 0)

	local menuButton = display.newText(guiGroup, "Menu", 0, 0, "Hiruko", 40)
	menuButton.x = 100
	menuButton.y = 30

	-- local timeBarGradient = graphics.newGradient(
	--   { 255, 0, 0 },
	--   { 255, 255, 0 },
	--   "right" )

	local timeBar = display.newRect(guiGroup, 0, 50, cw, 10)
	--timeBar:setFillColor(52, 152, 219)
	timeBar:setFillColor(243, 156, 18)
	timeBar.alpha = topBar.alpha
	-- local timeCapacityUI = display.newRect(0, 50, cw, 10)
	-- timeCapacityUI:setFillColor(fartbarGradient)

	local function pause(option)
		local pausedText
		local divider
		local resumeButton
		local quitButton
		local fade = display.newRect(guiGroup, 0,0, cw,ch)
		fade:addEventListener("touch", untouchable)
		fade:addEventListener("tap", untouchable)
		fade:setFillColor(0,0,0)
		fade.alpha = 0.6
		setEnterFrame(nil)
		physics.pause()
		if option == "menu" then
			--resume game
			local function resume()
				display.remove(pausedText)
				display.remove(fade)
				display.remove(divider)
				display.remove(resumeButton)
				display.remove(quitButton)
				setEnterFrame(enterFrame)
				physics.start()
			end
			local function quit()
				display.remove(pausedText)
				display.remove(fade)
				display.remove(divider)
				display.remove(resumeButton)
				display.remove(quitButton)
				director:changeScene("menu", "crossfade")
			end
			--create buttons and text
			pausedText = display.newText(guiGroup, "Paused", 0, 0, "Hiruko", 60)
			pausedText.x, pausedText.y = cw/2, ch/2-300
			divider = display.newRect(guiGroup, 0, 0, cw-250, 5)
			divider.x, divider.y = cw/2, pausedText.y + 30
			--Resume Button
			resumeButton = displayNewButton(guiGroup, "Images/buttonResume.png", "Images/buttonResumeTapped.png", cw/2 - 258, divider.y + 20, false, 1, 0, nil, "Resume", 255, 255, 255, "Hiruko", 50, resume, 1)
			--Quit Button
			quitButton = displayNewButton(guiGroup, "Images/buttonExit.png", "Images/buttonExitTapped.png", cw/2 - 258, divider.y + 120, false, 1, 0, nil, "Quit", 255, 255, 255, "Hiruko", 50, quit, 1)
		end
	end
	menuButton.tap = function() pause("menu") end
	menuButton:addEventListener("tap", menuButton)
	--clear only one letter
	local function clearChosenLetter(i)
		if i then
			if chosenLetters[i] then
				display.remove(chosenLetters[i])
			end
		end
	end
	--update size of time bar
	local function updateTimeBar () 
		--change size of time bar
		if currentTime > timeCapacity then
			currentTime = timeCapacity
		elseif currentTime < 0 then
			currentTime = timeSubtractor
		end
		timeBar.xScale = currentTime / timeCapacity
		timeBar.x = timeBar.width/2--timeCapacity*timeBar.xScale
	end
	--clear the whole table or submit word
	local function clearChosenLetterTable (event)
		local swipe = false
		if event.phase == "began" then
			--log the start touch position
			swipeStartX = event.x
			swipeStartY = event.y
		elseif event.phase == "ended" then
			--create end x and y
			swipeEndX = event.x
			swipeEndY = event.y 
			local xDif = swipeEndX - swipeStartX
			--find end x and end y and see if it was a swipe
			if swipeStartX < swipeEndX and xDif > 125 then -- check X for swipe
				--if startY == (endY+20) or startY == (endY-20) then
					swipe = true
					print("WAS A SWIPE!!!")
				--end
			end
			if swipe then --if it was a swipe then check if it is valid
				--if there is no word highlight the box
				if word == nil then 
					print("Make a word first!")
				else -- if there is a word, check its validity
					print(word)
					local isWordValid = isWordValid(word)
					print(isWordValid)
					if isWordValid == true then
						print("YOU WIN YOU WINNER!")
						scoreToAdd = 0
						for i = 1, #chosenLetters do
							scoreToAdd = scoreToAdd + chosenLetters[i].value
							scoreTxt.text = score
							transition.to(chosenLetters[i], {x = 1000, onComplete = function() clearChosenLetter(i) end})
							transition.to(chosenLetters[i].letterTxt, {x = 1000, onComplete = function() end})
						end
						--add to the score
						score = score + (scoreToAdd * #chosenLetters)
						--scoreTxt.text = currentScore
						--add to the time
						currentTime = currentTime + (scoreToAdd * #chosenLetters)
						word = ""
						chosenLetters = {}
					elseif isWordValid ~= true then 
						for i = 1, #chosenLetters do 
							chosenLetters[i]:setFillColor(255, 0, 0)
						end
					end
				end
			else -- if it wasn't a swipe
				for i = 1, #chosenLetters do 
					if chosenLetters[i] then
						local function dealWithLetters()
							--remove the current selected words
							local letterId = chosenLetters[i].id
							display.remove(chosenLetters[i])
							letters[letterId] = {"nil"}
							letters[letterId].letterTxt = {"nil"}
							--clear the table and word at end of for loop
							if i == #chosenLetters then
								chosenLetters = {}
								word = ""
							end
						end
						transition.to(chosenLetters[i].letterTxt, {xScale = 0.01, yScale = 0.01, time = 150})
						transition.to(chosenLetters[i], {xScale = 0.01, yScale = 0.01, time = 150,  onComplete = dealWithLetters})
					end	
				end
			end
		elseif event.phase == "canceled" then
		end
		return true
	end
	botBar:addEventListener("touch", clearChosenLetterTable)

	local function selectLetter(self, event)
		if event.phase == "ended" then
			local xPos = cw/5
			local tablePos = #chosenLetters + 1
			print(tablePos)
			chosenLetters[tablePos] = self -- add the letter to one of the chosen letters
			self:setLinearVelocity(0, 0, self.x, self.y) -- remove any velocity
			self.touch = nil
			--check to see if it is a correct answer AFTER it transitions
			local function checkWordValidity()
				word = ""
				for i = 1, #chosenLetters do
					word = word..tostring(chosenLetters[i].letter)
				end
				print(word, "WORD CREATED")
			end
			local scaleTime = 150
			local function moveToPosition()
				guiGroup:insert(self) -- put rect in the top most group
				guiGroup:insert(letters[self.id].letterTxt) -- put text in top most group
				self.x = (tablePos-1) * xPos + ((self.width)/2) + 5 
				self.y = botBar.y 
				transition.to( self, { time=scaleTime, xScale = 1, yScale = 1, onComplete = function() self.tap = nil end}) 
				self.letterTxt.x = (tablePos-1) * xPos + ((self.width)/2) + 5 
				self.letterTxt.y = botBar.y 
				transition.to( self.letterTxt, { time=scaleTime, xScale = 1, yScale = 1, onComplete = checkWordValidity}) 

			end
			transition.to( self, { time=scaleTime, xScale = 0.01, yScale = 0.01 } )
			transition.to( self.letterTxt, { time=scaleTime, xScale = 0.01, yScale = 0.01, onComplete=moveToPosition } )
		end
	end

	--spawn letters that fall
	local function spawnLetter()
		for i = 0, 4 do
			print("spawn letter")
			local letter = math.random(1, 3)
			local xPos = cw/5
			local lettersTablePos = #letters + 1
			local randomLetter = randomLetter()
			--create letter outline
			local letterBox = display.newRect(group, 0, 0, cw/5 - 10, cw/5)
			letters[lettersTablePos] = letterBox
			letterBox:setFillColor(220, 220, 220)
			letterBox.strokeWidth = 4
			letterBox.x = i*xPos + ((letterBox.width)/2) + 5
			letterBox.y = -100
			letterBox.id = lettersTablePos
			letterBox.value = randomLetter.value
			letterBox.letter = randomLetter.text
			physics.addBody(letterBox, {isSensor = true})
			letterBox:setLinearVelocity(0, letterSpeed, letterBox.x, letterBox.y)
			--create letter
			local letter = display.newText(group, "A", 0, 0, "Hiruko", 80)
			letter.text = randomLetter.text
			letter.id = lettersTablePos
			letters[lettersTablePos].letterTxt = letter
			letter:setTextColor(64, 64, 64)
			--add listener for tap on letter
			letterBox.touch = selectLetter
			letterBox:addEventListener("touch", letterBox)

			guiGroup:toFront()
		end
	end

	enterFrame = function ()
		if letterSpawnCooldown > 0 then
			letterSpawnCooldown = letterSpawnCooldown - 1
		elseif letterSpawnCooldown <= 0.1 then
			spawnLetter()
			letterSpawnCooldown = letterSpawnTime
		end
		if currentScore < score then
			currentScore = currentScore + 1
			scoreTxt.text = currentScore
		end
		for i = 1, #letters do 
			if letters[i] ~= nil then
				if letters[i].x ~= nil then
					if letters[i].letterTxt.x ~= nil then
						letters[i].letterTxt.x = letters[i].x
						letters[i].letterTxt.y = letters[i].y
					end
				end
			end
		end
		currentTime = currentTime - timeSubtractor
		updateTimeBar()
	end

	setEnterFrame(enterFrame)

	return group
end

return M