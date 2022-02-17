-- Freezes all non-world entities, or entities from a specific target
---@param caller Player Person who called this command
---@param targets? Player[] Players to freeze props of
local function nolag(caller, targets)
    if not NADMOD then return end -- We should always have NADMOD installed, so the sanity check just needs to return

    local targetLut = {}
    for _, plr in ipairs(targets) do targetLut[plr] = true end

    local count = 0
    for _, prop in pairs(NADMOD.Props) do
        if prop.Owner ~= game.GetWorld() and (not targets or targetLut[prop.Owner]) and IsValid(prop.Ent) then
            local phys = prop.Ent:GetPhysicsObject()
            if IsValid(phys) then
                phys:EnableMotion(false)
                count = count + 1
            end
        end
    end

    local suffix = count == 1 and "" or "s"
    ulx.fancyLogAdmin(caller, ("#A froze %u prop%s owned by #T"):format(count, suffix), targets)
end

local cmd = ulx.command(TASUtils.Category, "ulx nolag", nolag, "!nolag")
cmd:defaultAccess(ULib.ACCESS_ADMIN)
cmd:help("Freezes entities owned by players")
cmd:addParam({
	type = ULib.cmds.PlayersArg,
	default = "*",
	ULib.cmds.optional
})