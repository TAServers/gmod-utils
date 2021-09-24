local opentdb = {
	Difficulty = {
		Easy = "easy",
		Medium = "medium",
		Hard = "hard"
	},
	Category = {
		GeneralKnowledge = 9,
		Books = 10,
		Film = 11,
		Music = 12,
		Theatre = 13,
		Television = 14,
		VideoGames = 15,
		BoardGames = 16,
		ScienceAndNature = 17,
		Computers = 18,
		Mathematics = 19,
		Mythology = 20,
		Sports = 21,
		Geography = 22,
		History = 23,
		Politics = 24,
		Art = 25,
		Celebrities = 26,
		Animals = 27,
		Vehicles = 28,
		Comics = 29,
		Gadgets = 30,
		AnimeAndManga = 31,
		Animations = 32
	}
}

if SERVER then
	-- Fetch questions from the api (callback should take success: bool, questions: table)
	function opentdb.fetchQuestions(callback, amount, category, difficulty)
		amount = amount or 1
		category = category or opentdb.Category.GeneralKnowledge
		difficulty = difficulty or opentdb.Difficulty.Easy

		-- TODO: Implement a locally stored trivia dataset fallback
		http.Fetch(
			string.format("https://opentdb.com/api.php?amount=%i&category=%i&difficulty=%s", amount, category, difficulty),
			function(body, size, headers, statusCode)
				if statusCode != 200 then callback(false, {}) end

				body = util.JSONToTable(body)
				if body["response_code"] != 0 then callback(false, {}) end

				callback(true, body.results)
			end,
			function() callback(false, {}) end
		)
	end
end

local function brainlet(caller, target, category, difficulty)
	print(string.format("Caller: %s, Target: %s, Category %s, Difficulty %s", caller, target, category, difficulty))

	-- Fetch question from trivia API/dataset

	-- Send question to target client

	-- Log that a brainlet was initiated
end

-- Register CMD
local cmd = ulx.command("TAS Utilities", "ulx brainlet", brainlet, "!brainlet")

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