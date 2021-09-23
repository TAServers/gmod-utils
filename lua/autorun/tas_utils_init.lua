if SERVER then
	AddCSLuaFile()

	-- Load everything from tas utils for serverside
	for _, filename in ipairs(file.Find("sv-tas-utils/*.lua", "LUA")) do
		include("sv-tas-utils/" .. filename)
	end

	-- AddCSLuaFile everything from tas utils for clientside
	for _, filename in ipairs(file.Find("cl-tas-utils/*.lua", "LUA")) do
		AddCSLuaFile("cl-tas-utils/" .. filename)
	end
else
	-- Load everything from tas utils for clientside
	for _, filename in ipairs(file.Find("cl-tas-utils/*.lua", "LUA")) do
		include("cl-tas-utils/" .. filename)
	end
end
