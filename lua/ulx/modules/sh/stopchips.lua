local CHIP_CLASS_STOP_FUNCTIONS = {
	gmod_wire_expression2 = function(chip, callingPlayer)
		if chip.error then
			return
		end

		chip:Destruct()
		chip:Error(
			string.format(
				"Execution halted (Triggered by: %s)",
				callingPlayer:Nick()
			),
			"Execution halted"
		)
	end,
	starfall_processor = function(chip)
		chip:Error({ message = "Killed by admin", traceback = "" })
		net.Start("starfall_processor_kill")
		net.WriteEntity(chip)
		net.Broadcast()
	end,
}

local function stopChips(callingPlayer, targets)
	for _, player in ipairs(targets) do
		if IsValid(player) then
			for entityClass, stopFunction in pairs(CHIP_CLASS_STOP_FUNCTIONS) do
				for _, chip in ipairs(ents.FindByClass(entityClass)) do
					if chip:IsValid() and chip:CPPIGetOwner() == player then
						stopFunction(chip, callingPlayer)
					end
				end
			end
		end
	end

	ulx.fancyLogAdmin(callingPlayer, "#A stopped chips owned by #T", targets)
end

local cleanupCmd = ulx.command(
	TASUtils.Category,
	"ulx stopchips",
	stopChips,
	{ "!stopchips", "!haltchips", "!killchips", "!terminatechips" }
)
cleanupCmd:defaultAccess(ULib.ACCESS_ADMIN)
cleanupCmd:help(
	"Errors the Expression2 and StarfallEx chips owned by the target(s)"
)
cleanupCmd:addParam({
	type = ULib.cmds.PlayersArg,
	default = "^",
	ULib.cmds.optional,
})
