local gm = gmod.GetGamemode()
local buildModePlayers = {}

FindMetaTable("Player").HasBuildMode = function(self)
	if self and buildModePlayers[self] then return true else return false end
end

if SERVER then
	util.AddNetworkString("TASUtils.BuildMode")

	util.AddNetworkString("TASUtils.BuildModeTooltip")
	local function triggerTooltip(plr)
		net.Start("TASUtils.BuildModeTooltip")
		net.Send(plr)
	end

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
			triggerTooltip(dmgInfo:GetAttacker())
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
			triggerTooltip(owner)
			negateDamage(dmgInfo)
			return
		end
	end)

	hook.Add("PlayerShouldTakeDamage", "TASUtils.BuildMode", function(plr, attacker)
		if plr:HasBuildMode() or (attacker:IsPlayer() and attacker:HasBuildMode()) then return false end
	end)

	hook.Add("PlayerNoClip", "TASUtils.BuildMode", function(plr, desiredNoClipState)
		if not buildModePlayers[plr] and desiredNoClipState then -- desiredNoClipState check in case a user somehow gets into noclip while in PVP and tries to disable it
			return false
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

	-- Remove players from the buildmode table if they're leaving
	hook.Add("PlayerDisconnected", "TASUtils.BuildMode", function(plr)
		if buildModePlayers[plr] then
			buildModePlayers[plr] = nil
			net.Start("TASUtils.BuildMode")
			net.WriteBool(false)
			net.WriteEntity(plr)
			net.Broadcast()
		end
	end)

	FindMetaTable("Player").BuildEnable = function(self)
		if not self or not IsEntity(self) or not self:IsValid() or not self:IsPlayer() then
			error("Attempted to use invalid player")
		end
		if buildModePlayers[self] then return end

		buildModePlayers[self] = true
		net.Start("TASUtils.BuildMode")
		net.WriteBool(true)
		net.WriteEntity(self)
		net.Broadcast()
	end

	FindMetaTable("Player").BuildDisable = function(self)
		if not self or not IsEntity(self) or not self:IsValid() or not self:IsPlayer() then
			error("Attempted to use invalid player")
		end
		if not buildModePlayers[self] then return end

		self:SetMoveType(MOVETYPE_WALK)
		self:SetHealth(self:GetMaxHealth())
		self:SetArmor(0)
		self:SetWalkSpeed(200)
		self:SetRunSpeed(400)
		self:ExitVehicle()

		if not self:IsFrozen() then -- prevent frozen players from abusing build and pvp mode to move themselves
			local spawnpoint = hook.Call("PlayerSelectSpawn", gm, self, false)
			if spawnpoint and IsEntity(spawnpoint) and spawnpoint:IsValid() then
				self:SetPos(spawnpoint:GetPos())
				self:SetEyeAngles(spawnpoint:GetAngles())
			end
		end

		buildModePlayers[self] = nil
		net.Start("TASUtils.BuildMode")
		net.WriteBool(false)
		net.WriteEntity(self)
		net.Broadcast()
	end
else -- CLIENT
	net.Receive("TASUtils.BuildMode", function()
		if net.ReadBool() then
			buildModePlayers[net.ReadEntity()] = true
		else
			buildModePlayers[net.ReadEntity()] = nil
		end
	end)

	--[[
		Build mode outline
	]]
	hook.Add("PreDrawHalos", "TASUtils.BuildMode", function()
		local plrs, count = {}, 0

		for plr, _ in pairs(buildModePlayers) do
			if plr:IsValid() and plr:Alive() then
				count = count + 1
				plrs[count] = plr
			end
		end

		halo.Add(plrs, Color(0, 0, 255), 0, 0, 1, true, false)
	end)

	--[[
		Tooltip Code
	]]

	surface.CreateFont("TASUtils.BuildModeTooltip", {
		font = "Roboto",
		size = 24
	})

	local tooltipPos, tooltipFadeTime = {0.5, 0.46}, 2 -- Constants
	local tooltip, tooltipColour, tooltipLastTrigger = "", Color(255, 255, 255), 0 -- Configurables

	--- Equation for the fade effect
	---@param t number Time (in seconds) since the tooltip was activated
	---@return number alpha Alpha value to give the text
	local function fade(t)
		-- Make sure t is within bounds
		if t > tooltipFadeTime then return 0 end
		if t <= 0 then return 255 end

		-- Normalise elapsed time to [0, 1]
		t = t / tooltipFadeTime

		local transparency = 1 - math.sqrt(1 - t * t)

		return math.floor(transparency * -255 + 255)
	end

	hook.Add("HUDPaint", "TASUtils.BuildMode", function()
		draw.DrawText(
			tooltip, "TASUtils.BuildModeTooltip",
			ScrW() * tooltipPos[1], ScrH() * tooltipPos[2],
			Color(tooltipColour.r, tooltipColour.g, tooltipColour.b, fade(CurTime() - tooltipLastTrigger)),
			TEXT_ALIGN_CENTER
		)
	end)

	--[[
		Server triggered tooltips
	]]
	net.Receive("TASUtils.BuildModeTooltip", function()
		-- As of now the only tooltip the server could ever want to show is for builders dealing damage
		tooltip = "You cannot deal damage while in build mode, exit with !pvp"
		tooltipColour = Color(30, 30, 180)
		tooltipLastTrigger = CurTime()
	end)

	--[[
		Noclip prevention
	]]
	hook.Add("PlayerNoClip", "TASUtils.BuildMode", function(plr, desiredNoClipState)
		if not plr:HasBuildMode() and desiredNoClipState then -- desiredNoClipState check in case a user somehow gets into noclip while in PVP and tries to disable it
			if plr == LocalPlayer() then
				tooltip = "You cannot noclip while in pvp, enter build mode with !build"
				tooltipColour = Color(180, 30, 30)
				tooltipLastTrigger = CurTime()
			end
			return false
		end
	end)
end

--[[
	Register Commands
]]

-- For chatprints
local ulxEchoColour = Color(151, 211, 255)
local ulxSelfColour = Color(75, 0, 130)

local buildCmd = ulx.command(TASUtils.Category, "ulx build", function(caller, target)
	if not IsValid(target) then return end
	if target:HasBuildMode() then
		timer.Simple(0, function() -- Delay the print by a frame so it comes *after* the chat msg
			if IsValid(caller) then
				if caller == target then
					caller:ChatPrint(ulxSelfColour, "You", ulxEchoColour, " are already in build mode")
				else
					caller:ChatPrint(team.GetColor(target:Team()), target:Nick(), ulxEchoColour, " is already in build mode")
				end
			else -- Caller is console
				print(target:Nick() .. " is already in build mode")
			end
		end)

		return
	end

	target:BuildEnable()

	ulx.fancyLogAdmin(caller, caller == target and "#T entered build mode" or "#A made #T enter build mode", target)
end, "!build")

buildCmd:addParam({
	type = ULib.cmds.PlayerArg,
	default = "^",
	ULib.cmds.optional
})

buildCmd:defaultAccess(ULib.ACCESS_ALL)
buildCmd:help("Changes the target player (or yourself if no target is specified) to Build Mode")

local pvpCmd = ulx.command(TASUtils.Category, "ulx pvp", function(caller, target)
	if not IsValid(target) then return end
	if not target:HasBuildMode() then
		timer.Simple(0, function() -- Delay the print by a frame so it comes *after* the chat msg
			if IsValid(caller) then
				if caller == target then
					caller:ChatPrint(ulxSelfColour, "You", ulxEchoColour, " are already out of build mode")
				else
					caller:ChatPrint(team.GetColor(target:Team()), target:Nick(), ulxEchoColour, " is already out of build mode")
				end
			else -- Caller is console
				print(target:Nick() .. " is already out of build mode")
			end
		end)

		return
	end

	target:BuildDisable()

	ulx.fancyLogAdmin(caller, caller == target and "#T exited build mode" or "#A made #T exit build mode", target)
end, "!pvp")

pvpCmd:addParam({
	type = ULib.cmds.PlayerArg,
	default = "^",
	ULib.cmds.optional
})

pvpCmd:defaultAccess(ULib.ACCESS_ALL)
pvpCmd:help("Changes the target player (or yourself if no target is specified) to PVP Mode")
