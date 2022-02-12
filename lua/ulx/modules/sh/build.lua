local buildCB, pvpCB
local buildModePlayers = {}

hook.Add("PlayerNoClip", "TASUtils.BuildMode", function(plr, desiredNoClipState)
	if not buildModePlayers[plr] and desiredNoClipState then -- desiredNoClipState check in case a user somehow gets into noclip while in PVP and tries to disable it
		return false
	end
end)

if SERVER then
	local max_force_convar = CreateConVar(
		"buildmode_prop_max_force", 10000, FCVAR_ARCHIVE,
		"Maximum force a builder's prop can have before it no longer collides with players",
		0
	)

	local function negateDamage(dmgInfo)
		dmgInfo:SetDamage(0)
		dmgInfo:SetDamageForce(Vector(0))
		dmgInfo:SetDamageType(DMG_PREVENT_PHYSICS_FORCE)
	end

	hook.Add("EntityTakeDamage", "TASUtils.BuildMode", function(target, dmgInfo)
		-- Prevent build mode players from taking damage
		if buildModePlayers[target] then
			negateDamage(dmgInfo)
			return
		end

		-- Prevent players in build mode from dealing damage
		if buildModePlayers[dmgInfo:GetAttacker()] then
			negateDamage(dmgInfo)
			return
		end

		-- Prevent entities owned by build mode players from taking damage
		local owner = (target and target:IsValid() and not target:IsPlayer()) and (target.CPPIGetOwner and target:CPPIGetOwner() or target:GetOwner())
		if owner and buildModePlayers[owner] then
			negateDamage(dmgInfo)
			return
		end

		-- Prevent entities owned by build mode players from dealing damage
		local inflictor = dmgInfo:GetInflictor()
		owner = (inflictor and inflictor:IsValid() and not inflictor:IsPlayer()) and (inflictor.CPPIGetOwner and inflictor:CPPIGetOwner() or inflictor:GetOwner())
		if owner and buildModePlayers[owner] then
			negateDamage(dmgInfo)
			return
		end
	end)

	hook.Add("Think", "TASUtils.BuildMode", function()
		-- Disable player collisions on all fast moving builder owned props (prevents uncombatable proppush)
		if NADMOD then
			local fMax = max_force_convar:GetFloat()
			for _, prop in pairs(NADMOD.Props) do
				local ent = prop.Ent
				if ent and ent:IsValid() then
					local phys = ent:GetPhysicsObject()
					if phys:IsValid() then
						local vMax2 = fMax * phys:GetInvMass()
						vMax2 = vMax2 * vMax2

						-- >= means frozen props will have no player cols (ie a builder cant place a prop over someone and freeze it, trapping them in)
						if buildModePlayers[prop.Owner] and ent:GetVelocity():LengthSqr() >= vMax2 then
							if not ent.TASOldColGroup then
								ent.TASOldColGroup = ent:GetCollisionGroup()
								ent:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
							end
						elseif ent.TASOldColGroup then
							ent:SetCollisionGroup(ent.TASOldColGroup)
							ent.TASOldColGroup = nil
						end
					end
				end
			end
		end
	end)

	function buildCB(caller, target)
		if not IsValid(target) then return end
		if buildModePlayers[target] then return end

		buildModePlayers[target] = true
		ulx.fancyLogAdmin(caller, caller == target and "#T entered build mode" or "#A made #T enter build mode", target)
	end

	function pvpCB(caller, target)
		if not IsValid(target) then return end
		if not buildModePlayers[target] then return end

		target:SetMoveType(MOVETYPE_WALK)

		buildModePlayers[target] = nil
		ulx.fancyLogAdmin(caller, caller == target and "#T exited build mode" or "#A made #T exit build mode", target)
	end
else
	function buildCB(caller, target)
		buildModePlayers[target] = true
	end

	function pvpCB(caller, target)
		buildModePlayers[target] = nil
	end
end

--[[
	Register Commands
]]

local buildCmd = ulx.command(TASUtils.Category, "ulx build", buildCB, "!build")

buildCmd:addParam({
	type = ULib.cmds.PlayerArg,
	default = "^",
	ULib.cmds.optional
})

buildCmd:defaultAccess(ULib.ACCESS_ALL)
buildCmd:help("Changes the target player (or yourself if no target is specified) to Build Mode")

local pvpCmd = ulx.command(TASUtils.Category, "ulx pvp", pvpCB, "!pvp")

pvpCmd:addParam({
	type = ULib.cmds.PlayerArg,
	default = "^",
	ULib.cmds.optional
})

pvpCmd:defaultAccess(ULib.ACCESS_ALL)
pvpCmd:help("Changes the target player (or yourself if no target is specified) to PVP Mode")
