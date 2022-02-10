TASUtils = {}
TASUtils.Materials = {}
TASUtils.Category = "TAS Utilities"

if SERVER then
	AddCSLuaFile()

	-- Paths to include/addcsluafile (each one should have an initpostentity folder for any code to run after autorun)
	local paths = {
		["sv-tas-utils"] = function(path) pcall(include, path) end,
		["sh-tas-utils"] = function(path) pcall(include, path) AddCSLuaFile(path) end,
		["cl-tas-utils"] = function(path) AddCSLuaFile(path) end
	}

	-- Load
	for path, func in pairs(paths) do
		for _, filename in ipairs(file.Find(path .. "/*.lua", "LUA")) do
			func(path .. "/" .. filename)
		end

		hook.Add("InitPostEntity", "TAS.PostAutorunIncludes." .. path, function()
			for _, filename in ipairs(file.Find(path .. "/initpostentity/*.lua", "LUA")) do
				func(path .. "/initpostentity/" .. filename)
			end
			hook.Remove("InitPostEntity", "TAS.PostAutorunIncludes." .. path)
		end)
	end
else
	-- Paths to include/addcsluafile (each one should have an initpostentity folder for any code to run after autorun)
	local paths = {
		["sh-tas-utils"] = function(path) pcall(include, path) end,
		["cl-tas-utils"] = function(path) pcall(include, path) end
	}

	-- Load
	for path, func in pairs(paths) do
		for _, filename in ipairs(file.Find(path .. "/*.lua", "LUA")) do
			func(path .. "/" .. filename)
		end

		hook.Add("InitPostEntity", "TAS.PostAutorunIncludes." .. path, function()
			for _, filename in ipairs(file.Find(path .. "/initpostentity/*.lua", "LUA")) do
				func(path .. "/initpostentity/" .. filename)
			end
			hook.Remove("InitPostEntity", "TAS.PostAutorunIncludes." .. path)
		end)
	end
end
