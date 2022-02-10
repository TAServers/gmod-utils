local MAP_LOCATIONS = {
	gm_bigcity = {
		{Vector(-512.656250, 1631.562500, -11080.437500), Angle(0, 0, 0)}
	}
}

local curMapLocs = MAP_LOCATIONS[game.GetMap()]
if curMapLocs and #curMapLocs > 0 then
	for _, location in ipairs(curMapLocs) do
		local monitor = ents.Create("servermonitor")
		monitor:SetPos(location[1])
		monitor:SetAngles(location[2])
		monitor:PhysicsDestroy()
		monitor:Spawn()
	end
end
