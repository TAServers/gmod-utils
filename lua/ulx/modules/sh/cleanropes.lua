local cleanRopes = ulx.command(
	TASUtils.Category,
	"ulx cleanropes",
	function(calling_ply)
		local count = 0
		local ropes = ents.FindByClass("keyframe_rope")
		for _, v in ipairs(ropes) do
			if v.Ent1 and v.Ent1:IsWorld() and v.Ent2 and v.Ent2:IsWorld() then
				v:Remove()
				count = count + 1
			end
		end

		ulx.fancyLogAdmin(calling_ply, "#A cleaned up #i world ropes", count)
	end,
	"!cleanropes"
)

cleanRopes:defaultAccess(ULib.ACCESS_ADMIN)
cleanRopes:help("Removes all ropes connected only to world")
