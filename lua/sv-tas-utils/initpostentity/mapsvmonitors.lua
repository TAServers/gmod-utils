local MAP_LOCATIONS = {
	gm_bigcity = {
		{Vector(-512.656250, 1631.562500, -11080.437500), Angle(90, 180, 180)}
	},
	gm_construct = {
		{Vector(1024.375000, -126.218750, -83.250000), Angle(90, 0, 180)}
	}
}

local curMapLocs = MAP_LOCATIONS[game.GetMap()]
if curMapLocs and #curMapLocs > 0 then
	for _, location in ipairs(curMapLocs) do
		local monitor = ents.Create("servermonitor")
		monitor:SetPos(location[1])
		monitor:SetAngles(location[2])
		monitor:Spawn()
		monitor:SetPersistent(true)
		monitor:PhysicsDestroy()
	end
end
