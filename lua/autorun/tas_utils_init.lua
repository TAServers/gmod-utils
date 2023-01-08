TASUtils = {}
TASUtils.Materials = {}
TASUtils.Category = "TAS Utilities"

local function paths()
	if SERVER then
		return {
			["sv-tas-utils"] = function(path)
				pcall(include, path)
			end,
			["sh-tas-utils"] = function(path)
				pcall(include, path)
				AddCSLuaFile(path)
			end,
			["cl-tas-utils"] = function(path)
				AddCSLuaFile(path)
			end,
		}
	end

	return {
		["sh-tas-utils"] = function(path)
			pcall(include, path)
		end,
		["cl-tas-utils"] = function(path)
			pcall(include, path)
		end,
	}
end

-- Load
for path, func in pairs(paths()) do
	for _, filename in ipairs(file.Find(path .. "/*.lua", "LUA")) do
		func(path .. "/" .. filename)
	end

	hook.Add("InitPostEntity", "TAS.PostAutorunIncludes." .. path, function()
		for _, filename in
			ipairs(file.Find(path .. "/initpostentity/*.lua", "LUA"))
		do
			func(path .. "/initpostentity/" .. filename)
		end
		hook.Remove("InitPostEntity", "TAS.PostAutorunIncludes." .. path)
	end)
end
