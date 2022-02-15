local entMeta = FindMetaTable("Entity")
local remove = entMeta.Remove
entMeta.Remove = function(self)
	if not self or not IsEntity(self) then return end

	if self:GetClass() == "info_player_start" then
		TASUtils.Broadcast("Something just deleted a spawnpoint entity, check the console for a traceback")
		print("\n=================\nTRACEBACK\n=================")
		debug.Trace()
	end

	remove(self)
end


