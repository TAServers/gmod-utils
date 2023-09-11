local function stopChips(calling_ply, targets)
	for _, ply in pairs(targets) do
		if IsValid(ply) then
			for _, chip in ipairs(ents.FindByClass("gmod_wire_expression2")) do
				if chip:IsValid() and chip:CPPIGetOwner() == ply then
					if chip.error then
						return
					end
					chip:Destruct()
					chip:Error(
						"Execution halted (Triggered by: "
							.. calling_ply:Nick()
							.. ")",
						"Execution halted"
					)
				end
			end
			for _, chip in ipairs(ents.FindByClass("starfall_processor")) do
				if chip:IsValid() and chip:CPPIGetOwner() == ply then
					chip:Error({ message = "Killed by admin", traceback = "" })
					net.Start("starfall_processor_kill")
					net.WriteEntity(chip)
					net.Broadcast()
				end
			end
		end
	end

	ulx.fancyLogAdmin(calling_ply, "#A stopped #T's chips", targets)
end

local cleanupCmd =
	ulx.command(TASUtils.Category, "ulx stopchips", stopChips, "!stopchips")
cleanupCmd:defaultAccess(ULib.ACCESS_ADMIN)
cleanupCmd:help(
	"Stops/halts the Expression2 and StarfallEx chips owned by target(s)"
)
cleanupCmd:addParam({
	type = ULib.cmds.PlayersArg,
	default = "^",
	ULib.cmds.optional,
})
