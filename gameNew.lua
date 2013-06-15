local M = {}

function M.new()
	physics = require "physics"
	physics.start()
	physics.setGravity(0,0)
	sqlite3 = require "sqlite3"

	local group = display.newGroup()
	local letterGroup = display.newGroup()
	group:insert(letterGroup)
	--tables
	local chosenLetters = {}
	--variables
	local score = 0
	local currentScore = score 
	local letterSpawnY = -100
	local letterSpeed = 115
	local letterSpawnTime = 70
	local letterSpawnCooldown = letterSpawnTime
	local currentTime = 150 -- 150
	local timeCapacity = currentTime
	local timeSubtractor = 0.05
	local difficultyTimer = 240
	local difficultyCooldown = difficultyTimer
	local doubleChance = 90
	local canDisplayGameOver = true
	local swipeStartX
	local swipeStartY
	local swipeEndX
	local swipeEndY
	local enterFrame
	--audio load
	local buttonSound1 = audio.loadSound( "button.mp3" )
	local buttonSound2 = audio.loadSound( "button2.mp3" )
	local correctSound = audio.loadSound( "correct.wav" )
	local clearSound = audio.loadSound( "clearSound.wav" )
	--Sqlite setup
	local path = system.pathForFile("dictionary.sqlite")
	local db = sqlite3.open( path ) --remember to close

	--change difficulty for game modes
	if gameMode == "WallToWall" then
		currentTime = 35 --35
		timeCapacity = currentTime
	end

	local function untouchable ()
		print("Aint nobody gon touch mah chillen")
		return true
	end

	local bg = displayBackground(group)

	local botBar = display.newImage(group, "Images/bar.png", 0, ch - 123)
	botBar:setFillColor(200, 200, 200)
	botBar:scale(1, 1.5)
	botBar.alpha = 0.8

	local topBar = display.newRect(group, 0, 0, cw, 50)
	topBar:setFillColor(0, 0, 0)
	topBar.alpha = 0.6
	topBar:addEventListener("touch", untouchable)

	local deleteBar = display.newRect(group, 0, ch + 150, cw, 10)
	physics.addBody(deleteBar, "static")

	local scoreTxt = display.newText(group, currentScore, 0, 0, "Hiruko", 50)
	scoreTxt.x = cw/2 + 2
	scoreTxt.y = 30
	scoreTxt:setTextColor(255, 215, 0)

	local menuButton = display.newText(group, "Menu", 0, 0, "Hiruko", 40)
	menuButton.x = 100
	menuButton.y = 30

	local timeBar = display.newRect(group, 0, 50, cw, 10)
	--timeBar:setFillColor(52, 152, 219)
	timeBar:setFillColor(243, 156, 18)
	timeBar.alpha = topBar.alpha

	-- move stuff according to device
	local modelName = findModel()
	if modelName == "Nook" or modelName == "iPhone5" or modelName == "Macbook" then
		local yDif = 66
		letterSpawnY = letterSpawnY - 50
		topBar.y = topBar.y - yDif
		deleteBar.y = deleteBar.y + 60
		menuButton.y = menuButton.y - yDif
		timeBar.y = timeBar.y - yDif
		scoreTxt.y = scoreTxt.y - yDif
		botBar.y = botBar.y + yDif
	end

	local function playAudio(audioVar)
		local audioData = Load("audioData")
		if audioData.toggle == "on" then
			audio.play(audioVar)
		elseif audioData.toggle == "off" then
		end
	end

	local function tweet ()
		print("TWEET!")
		local function tweetCallback( event )
		   if ( event.action == "cancelled" ) then
		      print( "User cancelled" )
		   else
		      print( "Thanks for the tweet!" )
		   end
		end

		local options = {
		   message = "I got a sweet score of "..score.."in WordForge #wordforge",
		   listener = tweetCallback,
		}
		native.showPopup( "twitter", options )
	end

	--update size of time bar
	local function updateTimeBar () 
		--change size of time bar
		if currentTime > timeCapacity then
			currentTime = timeCapacity
		elseif currentTime < 0 then
			currentTime = timeSubtractor
		end
		barXScale = currentTime / timeCapacity
		if barXScale <= 0 then
			timeBar.xScale = 0.01
		else
			timeBar.xScale = barXScale
		end
		timeBar.x = timeBar.width/2--timeCapacity*timeBar.xScale
	end

	local function removeLetter(event)
		display.remove(event.other)
	end
	deleteBar:addEventListener("collision", removeLetter)

	local function menu(option)
		local pausedText
		local divider
		local resumeButton
		local quitButton
		local fade = display.newRect(group, 0,0, cw,ch)
		fade:addEventListener("touch", untouchable)
		fade:addEventListener("tap", untouchable)
		fade:setFillColor(0,0,0)
		fade.alpha = 0.6
		if option == "menu" then
			setEnterFrame(nil)
			physics.pause()
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
			pausedText = display.newText(group, "Paused", 0, 0, "Hiruko", 60)
			pausedText.x, pausedText.y = cw/2, ch/2-300
			divider = display.newRect(group, 0, 0, cw-250, 5)
			divider.x, divider.y = cw/2, pausedText.y + 30
			--Resume Button
			resumeButton = displayNewButton(group, "Images/buttonResume.png", "Images/buttonResumeTapped.png", cw/2 - 258, divider.y + 20, false, 1, 0, nil, "Resume", 255, 255, 255, "Hiruko", 50, resume, 1)
			--Quit Button
			quitButton = displayNewButton(group, "Images/buttonExit.png", "Images/buttonExitTapped.png", cw/2 - 258, divider.y + 120, false, 1, 0, nil, "Quit", 255, 255, 255, "Hiruko", 50, quit, 1)
		elseif option == "end" then
			--resume game
			local function resume()
				display.remove(pausedText)
				display.remove(fade)
				display.remove(divider)
				display.remove(resumeButton)
				display.remove(quitButton)
				physics.stop()
				setEnterFrame(nil)
				director:changeScene("gameNew")
			end
			local function quit()
				display.remove(pausedText)
				display.remove(fade)
				display.remove(divider)
				display.remove(resumeButton)
				display.remove(quitButton)
				physics.stop()
				setEnterFrame(nil)
				director:changeScene("menu", "crossfade")
			end
			--create buttons and text
			--social media
			-- local twitter = display.newImage(group, "Images/tweet.png", cw/2, ch/2)
			-- twitter.x, twitter.y = cw/2, ch/2 - 120
			-- twitter:addEventListener("tap", tweet)
			--pause - quit buttons
			pausedText = display.newText(group, "Game Over!", 0, 0, "Hiruko", 60)
			pausedText.x, pausedText.y = cw/2, ch/2-300
			endScoreTxt = display.newText(group, "Your Score: "..score, 0, 0, "Hiruko", 60)
			endScoreTxt:setTextColor(255, 215, 0)
			endScoreTxt.x, endScoreTxt.y = cw/2, ch/2-200
			divider = display.newRect(group, 0, 0, cw-250, 5)
			divider.x, divider.y = cw/2, pausedText.y + 30
			--Resume Button
			resumeButton = displayNewButton(group, "Images/buttonResume.png", "Images/buttonResumeTapped.png", cw/2 - 258, divider.y + 205, false, 1, 0, nil, "Replay", 255, 255, 255, "Hiruko", 50, resume, 1)
			--Quit Button
			quitButton = displayNewButton(group, "Images/buttonExit.png", "Images/buttonExitTapped.png", cw/2 - 258, divider.y + 305, false, 1, 0, nil, "Quit", 255, 255, 255, "Hiruko", 50, quit, 1)
			-- Tweet button
			tweetBtn = displayNewButton(group, "Images/tweet.png", "Images/tweet.png", cw/2-130, ch/2-155, false, 1, 0, nil, "", 255, 255, 255, "Hiruko", 50, tweet, 1)

		end
	end
	menuButton.tap = function() menu("menu") end
	menuButton:addEventListener("tap", menuButton)

	local function selectLetter(self, event)
		if #chosenLetters < 5 then
			if event.phase == "began" then
				playAudio(buttonSound1)
			elseif event.phase == "ended" then
				playAudio(buttonSound2)
				local xPos = cw/5
				local tablePos = #chosenLetters + 1
				print(tablePos)
				chosenLetters[tablePos] = self -- add the letter to one of the chosen letters
				self:setLinearVelocity(0, 0, self.x, self.y) -- remove any velocity
				self.overlay:setLinearVelocity(0, 0, self.x, self.y) -- remove any velocity
				self.text:setLinearVelocity(0, 0, self.x, self.y) -- remove any velocity
				self.multTxt:setLinearVelocity(0, 0, self.x, self.y) -- remove any velocity
				self.touch = nil
				--check to see if it is a correct answer AFTER it transitions
				local function formWord()
					word = ""
					for i = 1, #chosenLetters do
						word = word..tostring(chosenLetters[i].letter)
					end
					print(word, "WORD CREATED")
				end
				local scaleTime = 140
				local function moveToDock()
					--make sure no tiles are moving when they get placed into the dock
					self:setLinearVelocity(0, 0, self.x, self.y) -- remove any velocity
					self.overlay:setLinearVelocity(0, 0, self.x, self.y) -- remove any velocity
					self.text:setLinearVelocity(0, 0, self.x, self.y) -- remove any velocity
					self.multTxt:setLinearVelocity(0, 0, self.x, self.y) -- remove any velocity
					self.touch = nil
					local obj
					local numbLetterObjs = 4
					for i = 1, numbLetterObjs do
						if i == 1 then
							obj = self
						elseif i == 2 then
							obj = self.text
						elseif i == 3 then
							obj = self.overlay
						elseif i == 4 then
							obj = self.multTxt 
						end
						group:insert(obj) -- put rect in the top most group
						if i == 1 then --if its the square
							obj.x = (tablePos-1) * xPos + ((obj.width)/2) + 5 
							obj.y = botBar.y 
							transition.to( obj, { time=scaleTime, xScale = 1, yScale = 1, onComplete = function() obj.tap = nil end}) 
						elseif i == 2 or i == 3 then -- if its the text
							obj.x = self.x 
							obj.y = self.y 
							transition.to( obj, { time=scaleTime, xScale = 1, yScale = 1, onComplete = function() obj.tap = nil end}) 
						elseif i == 4 then --mult text
							obj.x, obj.y = self.x + (self.width/2) - 18, self.y - (self.height/2) + 18
							transition.to( obj, { time=scaleTime, xScale = 1, yScale = 1, onComplete = function() obj.tap = nil end}) 
						end

						if i == numbLetterObjs then
							formWord()
						end
						--transition.to( obj, { time=scaleTime, xScale = 1, yScale = 1 } )
						-- transition.to( obj.letterMultTxt, { time=scaleTime, xScale = 1, yScale = 1, onComplete = formWord } )
					end
				end
				transition.to( self, { time=scaleTime, xScale = 0.01, yScale = 0.01 } )
				transition.to( self.text, { time=scaleTime, xScale = 0.01, yScale = 0.01 } )
				transition.to( self.letterMultTxt, { time=scaleTime, xScale = 0.01, yScale = 0.01, x = self.letterMultTxt.x - 35, y = self.letterMultTxt.y + 35 } )
				transition.to( self.overlay, { time=scaleTime, xScale = 0.01, yScale = 0.01, onComplete = moveToDock } )
			end
		end
		return true
	end

	local function spawnLetters(position)
		local i = position
		local letter = math.random(1, 3)
		local chanceToMultiply = math.random(1, 100)
		local xPos = cw/5
		local randomLetter = randomLetter()

		local letterBox = display.newRect(letterGroup, 0, 0, cw/5 - 10, cw/5)
		letterBox:setFillColor(220, 220, 220)
		letterBox.strokeWidth = 4
		letterBox.x, letterBox.y = i*xPos + ((letterBox.width)/2) + 5, letterSpawnY
		letterBox.value = randomLetter.value
		letterBox.multiplier = 1
		physics.addBody(letterBox, {isSensor = true, density = 5})
		letterBox:setLinearVelocity(0, letterSpeed, letterBox.x, letterBox.y)
		letterBox.letter = randomLetter.text
		
		--letter overlay
		local letterOverlay = display.newRect(letterGroup, letterBox.x, letterBox.y, cw/5-10, cw/5)
		letterOverlay.x, letterOverlay.y = letterBox.x, letterBox.y
		letterOverlay:setFillColor(255, 0, 0)
		letterOverlay.alpha = 0.01
		physics.addBody(letterOverlay, {isSensor = true, density = 5})
		letterOverlay:setLinearVelocity(0, letterSpeed, letterBox.x, letterBox.y)
		letterBox.overlay = letterOverlay
		--create letter
		local letter = display.newText(letterGroup, "A", letterBox.x, letterBox.y, "Hiruko", 80)
		letter.x, letter.y = letterBox.x, letterBox.y
		letter.text = randomLetter.text
		letter:setTextColor(64, 64, 64)
		physics.addBody(letter, {isSensor = true, density = 5})
		letter:setLinearVelocity(0, letterSpeed, letterBox.x, letterBox.y)
		letterBox.text = letter

		if chanceToMultiply > doubleChance then
			local letterMultTxt = display.newText(letterGroup, "x2", 0, 0, "Hiruko", 20)
			physics.addBody(letterMultTxt, {isSensor = true, density = 5})
			letterMultTxt:setLinearVelocity(0, letterSpeed, letterBox.x, letterBox.y)
			letterMultTxt.x, letterMultTxt.y = letterBox.x + (letterBox.width/2) - 18, letterBox.y - (letterBox.height/2) + 18
			letterOverlay.alpha = 0.25
			letterBox.letterMultTxt = letterMultTxt
			letterOverlay:setFillColor(0, 0, 255)
			letterBox.multiplier = 2
			letterBox.multTxt = letterMultTxt
		else 
			local letterMultTxt = display.newText(letterGroup, " ", 0, 0, "Hiruko", 20)
			physics.addBody(letterMultTxt, {isSensor = true, density = 5})
			letterMultTxt:setLinearVelocity(0, letterSpeed, letterBox.x, letterBox.y)
			letterMultTxt.x, letterMultTxt.y = letterBox.x + (letterBox.width/2) - 18, letterBox.y - (letterBox.height/2) + 18
			letterBox.letterMultTxt = letterMultTxt
			letterBox.multTxt = letterMultTxt		
		end
		letterBox.touch = selectLetter
		letterBox:addEventListener("touch", letterBox)
	end
	if gameMode ~= "WallToWall" then
		local position = math.random(0, 4)
		spawnLetters(position)
	end

	--neatly delete letters
	local function clearChosenLetter(letter)
		display.remove(letter.text)
		display.remove(letter.overlay)
		display.remove(letter.multTxt)
		display.remove(letter)
	end

	--dictionary function
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

	--swipe function
	local function dockListener (event)
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
			if swipeStartX < swipeEndX and xDif > 50 then -- check X for swipe
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
						playAudio(correctSound)
						print("YOU WIN YOU WINNER!")
						scoreToAdd = 0
						--use multipliers
						local multiplier = 0

						for i = 1, #chosenLetters do
							if chosenLetters[i].multiplier > 1 then
								multiplier = multiplier + chosenLetters[i].multiplier
							end
							scoreToAdd = scoreToAdd + chosenLetters[i].value
							scoreTxt.text = score
							transition.to(chosenLetters[i], {x = 1000, onComplete = function() end})
							transition.to(chosenLetters[i].text, {x = 1000, onComplete = function() end})
							transition.to(chosenLetters[i].overlay, {x = 1000, onComplete = function() end})	
							if i == #chosenLetters then
								transition.to(chosenLetters[i].multTxt, {x = 1000, onComplete = function() clearChosenLetter(chosenLetters[i]) word = "" chosenLetters = {} end})	
							else 
								transition.to(chosenLetters[i].multTxt, {x = 1000, onComplete = function() clearChosenLetter(chosenLetters[i])end})	
							end
						end
						--multiplier
						if multiplier > 0 then
							scoreToAdd = scoreToAdd * multiplier
						end
						--add to the time
						print("currentTime=", currentTime)

						--add to the score
						if gameMode ~= "WallToWall" then
							scoreToAdd = scoreToAdd * 1.5
						end
						scoreToAdd = scoreToAdd * #chosenLetters
						currentTime = currentTime + scoreToAdd
						--print stuff
						print("Score=",score)
						print("Score To Add=",scoreToAdd)
						print("currentTimeAfter=", currentTime)
						print("timeCapacity=", timeCapacity)
						score = math.round(score + scoreToAdd + 100)
						--scoreTxt.text = currentScore
						
					elseif isWordValid ~= true then 
						for i = 1, #chosenLetters do 
							chosenLetters[i].overlay:setFillColor(255, 0, 0)
							transition.to(chosenLetters[i].overlay, {alpha = 0.6, time=200})
						end
					end
				end
			else -- if it wasn't a swipe
				if #chosenLetters > 0 then
					playAudio(clearSound)
				end
				for i = 1, #chosenLetters do 
					if chosenLetters[i] then
						local function dealWithLetters()
							--remove the current selected words
							clearChosenLetter(chosenLetters[i])
							--clear the table and word at end of for loop
							if i == #chosenLetters then
								chosenLetters = {}
								word = ""
							end
						end
						transition.to(chosenLetters[i].text, {xScale = 0.01, yScale = 0.01, time = 150})
						transition.to(chosenLetters[i].overlay, {xScale = 0.01, yScale = 0.01, time = 150})
						transition.to(chosenLetters[i].multTxt, {xScale = 0.01, yScale = 0.01, x = chosenLetters[i].multTxt.x - 35, y = chosenLetters[i].multTxt.y + 35, time = 150})
						transition.to(chosenLetters[i], {xScale = 0.01, yScale = 0.01, time = 150,  onComplete = dealWithLetters})
					end	
				end
			end
		elseif event.phase == "canceled" then
		end
		return true
	end
	botBar:addEventListener("touch", dockListener)

	local function endGame()
		menu("end")
	end

	enterFrame = function ()
		bg:toBack()
		if letterSpawnCooldown > 0 then
			letterSpawnCooldown = letterSpawnCooldown - 1
		elseif letterSpawnCooldown <= 0 then
			if gameMode == "Rush" or gameMode == "InfiniFall" then
				local position = math.random(0, 4)
				spawnLetters(position)
			elseif gameMode == "WallToWall" then
				for i = 0, 4 do
					spawnLetters(i)
				end
			end
			letterSpawnCooldown = letterSpawnTime
		end
		--update score
		if currentScore < score then
			currentScore = currentScore + 2
			scoreTxt.text = currentScore
		elseif currentScore > score then
			currentScore = score
			scoreTxt.text = currentScore
		end
		--update time
		if gameMode == "Rush" or gameMode == "WallToWall" then
			currentTime = currentTime - timeSubtractor
			updateTimeBar()
		elseif gameMode == "InfiniFall" then
			--dont subtract timer
		end
		if currentTime <= 0.1 then
			if canDisplayGameOver then
				canDisplayGameOver = false
				endGame()
			end
		end
		--change difficulty (time subtraction amount)
		if difficultyCooldown > 0 then
			difficultyCooldown = difficultyCooldown - 1
		elseif difficultyCooldown <= 0 then
			-- letterSpeed = letterSpeed + 1
			print("Change difficulty")
			if letterSpawnTime > 50 then
				letterSpawnTime = letterSpawnTime - 1
			end
			if letterSpeed < 165 then
				letterSpeed = letterSpeed + 2.5
			end
			--timeSubtractor = timeSubtractor + 0.01
			for i = 1, letterGroup.numChildren do
				letterGroup[i]:setLinearVelocity(0, letterSpeed, letterGroup[i].x, letterGroup[i].y)
			end
			difficultyCooldown = difficultyTimer
		end
	end
	setEnterFrame(enterFrame)

	return group
end

return M