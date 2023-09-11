local function cleanupChips(calling_ply, targets)
	for _, ply in pairs(targets) do
		if IsValid(ply) then
			for _, chip in ipairs(ents.FindByClass("gmod_wire_expression2")) do
				if chip:IsValid() and chip:CPPIGetOwner() == ply then
					chip:Remove()
				end
			end
			for _, chip in ipairs(ents.FindByClass("starfall_processor")) do
				if chip:IsValid() and chip:CPPIGetOwner() == ply then
					chip:Remove()
				end
			end
		end
	end

	ulx.fancyLogAdmin(calling_ply, "#A cleaned up #T's chips", targets)
end

local cleanupCmd = ulx.command(
	TASUtils.Category,
	"ulx cleanupchips",
	cleanupChips,
	"!cleanupchips"
)
cleanupCmd:defaultAccess(ULib.ACCESS_ADMIN)
cleanupCmd:help(
	"Cleans up the Expression2 and StarfallEx chips owned by target(s)"
)
cleanupCmd:addParam({
	type = ULib.cmds.PlayersArg,
	default = "^",
	ULib.cmds.optional,
})
