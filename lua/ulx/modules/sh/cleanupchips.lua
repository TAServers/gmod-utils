local CHIP_CLASSES = { "gmod_wire_expression2", "starfall_processor" }

local function cleanupChips(callingPlayer, targets)
	for _, player in pairs(targets) do
		if IsValid(player) then
			for _, entityClass in ipairs(CHIP_CLASSES) do
				for _, chip in ipairs(ents.FindByClass(entityClass)) do
					if chip:IsValid() and chip:CPPIGetOwner() == player then
						chip:Remove()
					end
				end
			end
		end
	end

	ulx.fancyLogAdmin(callingPlayer, "#A cleaned up #T's chips", targets)
end

local cleanupCmd = ulx.command(
	TASUtils.Category,
	"ulx cleanupchips",
	cleanupChips,
	"!cleanupchips"
)
cleanupCmd:defaultAccess(ULib.ACCESS_ADMIN)
cleanupCmd:help(
	"Removes the Expression2 and StarfallEx chips owned by the target(s)"
)
cleanupCmd:addParam({
	type = ULib.cmds.PlayersArg,
	default = "^",
	ULib.cmds.optional,
})
