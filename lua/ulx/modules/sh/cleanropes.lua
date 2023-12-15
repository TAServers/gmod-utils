local cleanRopes = ulx.command(
	TASUtils.Category,
	"ulx cleanropes",
	function(calling_ply)
		local ropes = ents.FindByClass("keyframe_rope")
		for k, v in ipairs(ropes) do
			if v.Ent1 and v.Ent1:IsWorld() and v.Ent2 and v.Ent2:IsWorld() then
				v:Remove()
			end
		end

		ulx.fancyLogAdmin(calling_ply, "#A cleaned up #i world ropes", #ropes)
	end,
	"!cleanropes"
)

cleanRopes:defaultAccess(ULib.ACCESS_ADMIN)
cleanRopes:help("Removes all ropes connected only to world")
