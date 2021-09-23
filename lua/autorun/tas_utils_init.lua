if SERVER then
	AddCSLuaFile()

	-- Load everything from tas utils for serverside
	for _, filename in ipairs(file.Find("sv-tas-utils/*.lua", "LUA")) do
		pcall(include, "sv-tas-utils/" .. filename)
	end

	hook.Add("InitPostEntity", "TAS.PostAutorunIncludes", function()
		for _, filename in ipairs(file.Find("sv-tas-utils/initpostentity/*.lua", "LUA")) do
			pcall(include, "sv-tas-utils/initpostentity/" .. filename)
		end
		hook.Remove("InitPostEntity", "TAS.PostAutorunIncludes")
	end)

	-- AddCSLuaFile everything from tas utils for clientside
	for _, filename in ipairs(file.Find("cl-tas-utils/*.lua", "LUA")) do
		AddCSLuaFile("cl-tas-utils/" .. filename)
	end
	for _, filename in ipairs(file.Find("cl-tas-utils/initpostentity/*.lua", "LUA")) do
		AddCSLuaFile("cl-tas-utils/initpostentity/" .. filename)
	end
else
	-- Load everything from tas utils for clientside
	for _, filename in ipairs(file.Find("cl-tas-utils/*.lua", "LUA")) do
		pcall(include, "cl-tas-utils/" .. filename)
	end

	hook.Add("InitPostEntity", "TAS.PostAutorunIncludes", function()
		for _, filename in ipairs(file.Find("cl-tas-utils/initpostentity/*.lua", "LUA")) do
			pcall(include, "cl-tas-utils/initpostentity/" .. filename)
		end
		hook.Remove("InitPostEntity", "TAS.PostAutorunIncludes")
	end)
end
