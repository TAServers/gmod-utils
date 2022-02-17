-- Freezes all non-world entities, or entities from a specific target
---@param caller Player Person who called this command
---@param target? Player Optional player to freeze props of
local function nolagLogic(caller, targets)
    if not NADMOD then return end -- We should always have NADMOD installed, so the sanity check just needs to return

    local targetLut = {}
    for _, plr in targets do targetLut[plr] = true end

    local count = 0
    for _, prop in ipairs(NADMOD) do
        if prop.Owner ~= game.GetWorld() and (not targets or targetLut[prop.Owner]) and IsValid(prop.Ent) then
            local phys = prop.Ent:GetPhysicsObject()
            if IsValid(phys) then
                phys:EnableMotion(false)
                count = count + 1
            end
        end
    end

    local msg = target and "#A froze %u prop%s owned by #T" or "#A froze %u prop%s"
    local suffix = count == 1 and "" or "s"
    ulx.fancyLogAdmin(caller, msg:format(count, suffix), target)
end

local nolagCmd = ulx.command(TASUtils.Category, "ulx nolag", nolagLogic, "!nolag")
nolagCmd:defaultAccess(ULib.ACCESS_ADMIN)
nolagCmd:help("Freezes entities on the server")
nolagCmd:addParam({
	type = ULib.cmds.PlayersArg,
	default = "*",
	ULib.cmds.optional
})