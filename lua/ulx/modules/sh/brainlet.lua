local opentdb = TASUtils.OpenTDB
if not opentdb then error("ULX loads modules before TASUtils") end
local brainlet = function() end

if SERVER then
	--[[
		Colour scheme
	]]
	local ColourScheme = {
		Default = Color(255, 255, 255),
		Parameter = Color(240, 224, 86),
		Good = Color(80, 255, 80),
		Bad = Color(255, 80, 80)
	}

	--[[
		Streak tracking
	]]
	local DB_NAME = "tasutils_brainlet_streaks"
	sql.Query("CREATE TABLE IF NOT EXISTS " .. DB_NAME .. "(id INTEGER, streak INTEGER);")

	local function streakExists(plr)
		local r = sql.Query(string.format("SELECT 1 FROM %s WHERE id = %u;", DB_NAME, plr:SteamID64()))
		if r then return true else return false end
	end

	local function streakAdd(plr)
		if not streakExists(plr) then
			sql.Query(string.format(
				"INSERT INTO %s(id, streak) VALUES(%u, %u);", DB_NAME,
				plr:SteamID64(), 1
			))
		else
			sql.Query(string.format("UPDATE %s SET streak = streak + 1 WHERE id = %u;", DB_NAME, plr:SteamID64()))
		end
	end

	local function streakRemove(plr)
		if not streakExists(plr) then return end
		sql.Query(string.format("DELETE FROM %s WHERE id = %u;", DB_NAME, plr:SteamID64()))
	end

	local function streakGet(plr)
		if not streakExists(plr) then return 0 end
		return sql.QueryValue(string.format("SELECT streak FROM %s WHERE id = %u;", DB_NAME, plr:SteamID64()))
	end

	util.AddNetworkString("TASUtils.Brainlet")
	local questionTime = CreateConVar("brainlet_time", 30, FCVAR_ARCHIVE, "Number of seconds users get to answer a question", 1)
	local outstandingBrainlets = {}

	-- Invalidate and apply brainlets
	hook.Add("Think", "TASUtils.Brainlet", function()
		local curtime = CurTime()
		for plr, question in pairs(outstandingBrainlets) do
			if not IsValid(plr) then -- If the player is invalid remove their brainlet
				outstandingBrainlets[plr] = nil
			elseif curtime >= question.deadline then -- They've failed to answer the brainlet in time
				outstandingBrainlets[plr] = nil
				TASUtils.Broadcast(
					team.GetColor(plr:Team()), plr:Nick(),
					ColourScheme.Default, " failed to answer the brainlet in time, their streak was ",
					ColourScheme.Parameter, streakGet(plr)
				)
				Relay.CachePost({
					type = "custom",
					body = plr:Nick() .. " failed to answer the brainlet in time, their streak was " .. tostring(streakGet(plr))
				})
				ULib.kick(plr, "You are officially a dumbass, your win streak was " .. tostring(streakGet(plr)))
				streakRemove(plr)
			end
		end
	end)

	net.Receive("TASUtils.Brainlet", function(_, plr)
		if not outstandingBrainlets[plr] then return end

		local answer = net.ReadString()
		if answer == outstandingBrainlets[plr].answer then
			TASUtils.Broadcast(
				team.GetColor(plr:Team()), plr:Nick(),
				ColourScheme.Default, " correctly answered the brainlet \"",
				ColourScheme.Parameter, TASUtils.URLDecode(outstandingBrainlets[plr].question),
				ColourScheme.Default, "\""
			)
			Relay.CachePost({
				type = "custom",
				body = plr:Nick() .. " correctly answered the brainlet `" .. TASUtils.URLDecode(outstandingBrainlets[plr].question) .. "`"
			})
			streakAdd(plr)
		else
			TASUtils.Broadcast(
				team.GetColor(plr:Team()), plr:Nick(),
				ColourScheme.Default, " incorrectly answered the brainlet \"",
				ColourScheme.Parameter, TASUtils.URLDecode(outstandingBrainlets[plr].question),
				ColourScheme.Default, "\", the right answer was \"",
				ColourScheme.Good, TASUtils.URLDecode(outstandingBrainlets[plr].answer),
				ColourScheme.Default, "\", but they answered \"",
				ColourScheme.Bad, TASUtils.URLDecode(answer),
				ColourScheme.Default, "\", their streak was ",
				ColourScheme.Parameter, streakGet(plr)
			)
			Relay.CachePost({
				type = "custom",
				body = string.format(
					"%s incorrectly answered the brainlet `%s`, the right answer was `%s`, but they answered `%s`, their streak was %u",
					plr:Nick(),
					TASUtils.URLDecode(outstandingBrainlets[plr].question),
					TASUtils.URLDecode(outstandingBrainlets[plr].answer),
					TASUtils.URLDecode(answer),
					streakGet(plr)
				)
			})
			ULib.kick(plr, "You are officially a dumbass, your win streak was " .. tostring(streakGet(plr)))
			streakRemove(plr)
		end

		outstandingBrainlets[plr] = nil
	end)

	brainlet = function(caller, target, category, difficulty)
		if outstandingBrainlets[target] then
			caller:ChatPrint("That player is already being brainlet'd")
			return
		end

		-- Fetch question from trivia API/dataset
		opentdb.FetchQuestions(function(success, questions)
			-- Check the request was successful
			if not success or #questions == 0 then
				caller:ChatPrint("Failed to get a question from the OpenTDB API")
				return
			end

			local question = questions[1]
			local deadline = CurTime() + questionTime:GetFloat()

			-- Register brainlet (tracked serverside so without svlua there's literally no way to bypass, unlike a certain server's brainlet :trollhd:)
			outstandingBrainlets[target] = {
				question = question.question,
				answer = question.correct_answer,
				deadline = deadline
			}

			-- Send question to target client to be answered
			-- Packet schema:
			-- category               : string
			-- difficulty             : string
			-- question               : string
			-- multipleChoice         : bool
			-- if multipleChoice:
			--     numAnswers         : uint8
			--     answers            : string[numAnswers]
			-- deadline               : float
			net.Start("TASUtils.Brainlet")
				net.WriteString(question.category)
				net.WriteString(question.difficulty)
				net.WriteString(question.question)

				if question.type == "multiple" then
					net.WriteBool(true)

					local numAnswers = #question.incorrect_answers + 1
					question.incorrect_answers[numAnswers] = question.correct_answer
					TASUtils.ShuffleTable(question.incorrect_answers) -- Shuffle the table so the correct answer is always in a random position

					net.WriteUInt(numAnswers, 8)
					for i = 1, numAnswers do
						net.WriteString(question.incorrect_answers[i])
					end
				else
					net.WriteBool(false)
				end

				net.WriteFloat(deadline) -- Note this isn't used for validation, just the timer GUI
			net.Send(target)

			-- Log that a brainlet was initiated
			ulx.fancyLogAdmin(caller, "#A is testing the intelligence of #T", target)
		end, 1, opentdb.Category[category], opentdb.Difficulty[difficulty])
	end
else
	local windowWidth = CreateConVar("brainlet_window_w", 0.6, FCVAR_ARCHIVE, "Width of the brainlet window (as a percentage of your screen res)", 0.1, 0.9)
	local windowHeight = CreateConVar("brainlet_window_h", 0.6, FCVAR_ARCHIVE, "Height of the brainlet window (as a percentage of your screen res)", 0.1, 0.9)

	local function CreateBrainletPopup(category, difficulty, question, answers, deadline)
		local startTime = CurTime()
		local frame = vgui.Create("DFrame")

		local scrw, scrh = ScrW(), ScrH()
		local width, height = windowWidth:GetFloat(), windowHeight:GetFloat()
		frame:SetPos((0.5 - width / 2) * scrw, (0.5 - height / 2) * scrh)

		width, height = width * scrw, height * scrh
		local margin = 10
		local buttonMinSize = 0.15 * height
		local buttonXPad = 10
		local borderRadius = 16

		local background = Color(34, 38, 41)
		local timerBackground = Color(71, 75, 79)
		local accent = Color(247, 125, 26)
		local accentText = Color(224, 240, 243)

		local buttonHover = Color(248, 144, 58)
		local buttonPressed = Color(238, 122, 26)

		frame:SetSize(width, height)
		frame:SetTitle("")
		frame:SetVisible(true)
		frame:SetDraggable(false)
		frame:ShowCloseButton(false)

		function frame:Paint(w, h)
			draw.RoundedBox(borderRadius, 0, 0, w, h, background)
		end

		local title = vgui.Create("DLabel", frame)
		title:SetText(("%s: %s"):format(TASUtils.URLDecode(category), TASUtils.URLDecode(difficulty)))
		title:SetFont("DermaLarge")
		title:SetTextColor(Color(240, 123, 22))
		title:SizeToContents()
		title:SetPos(0, margin)
		title:CenterHorizontal()

		local timer = vgui.Create("DPanel", frame)
		timer:SetSize(width - 0.1 * width, 0.2 * height)
		timer:SetPos(0, 2 * margin + title:GetTall())
		timer:CenterHorizontal()

		function timer:Paint(w, h)
			draw.RoundedBox(borderRadius, 0, 0, w, h, timerBackground)
			draw.RoundedBox(borderRadius, 0, 0, w * (deadline - CurTime()) / (deadline - startTime), h, accent)
			draw.Text({
				text = TASUtils.URLDecode(question),
				font = "DermaLarge",
				pos = { w / 2, h / 2 },
				xalign = TEXT_ALIGN_CENTER,
				yalign = TEXT_ALIGN_CENTER,
				color = accentText
			})
		end

		local answerButtons = vgui.Create("DPanel", frame)
		answerButtons:SetSize(width, height - 3 * margin - title:GetTall() - timer:GetTall())
		answerButtons.buttons = {}
		function answerButtons:Paint() end

		local function ButtonPaint(self, w, h)
			local colour = accent
			if self:IsDown() then
				colour = buttonPressed
			elseif self:IsHovered() then
				colour = buttonHover
			end

			draw.RoundedBox(borderRadius, 0, 0, w, h, colour)
		end

		for i, answer in ipairs(answers) do
			local button = vgui.Create("DButton", answerButtons)
			button:SetText(TASUtils.URLDecode(answer))
			button:SetFont("DermaLarge")
			button:SetTextColor(accentText)

			button:SizeToContents()
			button:SetSize(
				button:GetWide() + buttonXPad < buttonMinSize and buttonMinSize or button:GetWide() + buttonXPad,
				buttonMinSize
			)

			button.Paint = ButtonPaint
			function button:DoClick()
				net.Start("TASUtils.Brainlet")
				net.WriteString(answer)
				net.SendToServer()
				frame:Remove()
			end

			answerButtons.buttons[i] = button
		end

		function answerButtons:PerformLayout(w, h)
			local row = {}
			local rowSize = 0
			local rowWidth = 0

			local offsetY = 0

			local function drawRow()
				if rowSize == 0 then return end

				local offsetX = (w - rowWidth) / 2

				for i = 1, rowSize do
					row[i]:SetPos(offsetX, offsetY)
					offsetX = offsetX + margin + row[i]:GetWide()
				end

				row = {}
				rowSize = 0
				rowWidth = 0

				offsetY = offsetY + margin + buttonMinSize
			end

			for _, button in ipairs(self.buttons) do
				local buttonWidth = button:GetWide()

				if buttonWidth > w - (2 + rowSize) * margin then
					button:SetWidth(w - 2 * margin)
				end

				if rowWidth + buttonWidth > w - (2 + rowSize) * margin then
					drawRow()
				end

				rowSize = rowSize + 1
				row[rowSize] = button
				rowWidth = rowWidth + buttonWidth
			end

			drawRow()

			local usedHeight = offsetY - margin
			answerButtons:SetPos(0, (h - usedHeight) / 2 + 2 * margin + title:GetTall() + timer:GetTall())
		end

		frame:MakePopup()
	end

	-- Even if someone goes in and removes the netmsg receiver clientside, they'll still get timed out by the server
	net.Receive("TASUtils.Brainlet", function()
		-- Read packet
		local category = net.ReadString()
		local difficulty = net.ReadString()
		local question = net.ReadString()

		local answers = {}
		if net.ReadBool() then -- Multiple choice
			for i = 1, net.ReadUInt(8) do
				answers[i] = net.ReadString()
			end
		else -- True/False
			answers = {"True", "False"}
		end

		local deadline = net.ReadFloat()
		CreateBrainletPopup(category, difficulty, question, answers, deadline)
	end)
end

-- Register CMD
local cmd = ulx.command(TASUtils.Category, "ulx brainlet", brainlet, "!brainlet")

cmd:addParam({type = ULib.cmds.PlayerArg, hint = "Player to brainlet"})
cmd:addParam({
	type = ULib.cmds.StringArg,
	hint = "Question category (defaults to GeneralKnowledge)",
	error = "Invalid category \"%s\"",
	completes = table.GetKeys(opentdb.Category),

	-- Flags
	ULib.cmds.optional, ULib.cmds.restrictToCompletes
})
cmd:addParam({
	type = ULib.cmds.StringArg,
	hint = "Question difficulty (defaults to Easy)",
	error = "Invalid difficulty \"%s\"",
	completes = table.GetKeys(opentdb.Difficulty),

	-- Flags
	ULib.cmds.optional, ULib.cmds.restrictToCompletes
})

cmd:defaultAccess(ULib.ACCESS_OPERATOR)
cmd:help("Makes a player have to answer a simple trivia question to not get kicked")
