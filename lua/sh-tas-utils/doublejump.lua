-- How much to add forward velocity (adds much more of a "leap" feel)
local FORWARD_INFLUENCE = 256
-- How much more power to let the double jump have
local POWER_INCREASE = 1.5

-- Make sure clients also get our effect
AddCSLuaFile("effects/doublejump.lua")

-- The star of the script
local function onDoubleJump(ply)
	-- This sends the player primarily flying upwards, but also adds some forward velocity
	local doubleJumpPower = ply:GetJumpPower() * POWER_INCREASE
	local forwardVector = ply:GetAimVector() * FORWARD_INFLUENCE

	ply:SetVelocity(Vector(0, 0, doubleJumpPower) + forwardVector)

	-- Play a little effect when we jump
	-- We also still need this on server even on shared, because this will replicate other players' effects
	local fxData = EffectData()
	fxData:SetOrigin(ply:GetPos())
	fxData:SetEntity(ply)
	local recipients = nil 

	if SERVER then
		recipients = RecipientFilter()
		recipients:AddAllPlayers()
		recipients:RemovePlayer(ply) -- Remove ourselves since we do it on the client
	end
	
	util.Effect("doublejump", fxData, true, recipients)
end

local function onKeyPress(ply, btn)
	-- If we jump, check if its a double jump, which only occurrs mid-air
	if btn == IN_JUMP and not ply:OnGround() and not ply.doubleJumped then
		ply.doubleJumped = true
		onDoubleJump(ply)
	end
end

hook.Add("KeyPress", "TASUtils.DoubleJumpDetect", onKeyPress)
hook.Add("OnPlayerHitGround", "TASUtils.DoubleJumpReset", function(ply)
	-- Simply reset their double jump flag, not enough to move it into its own function
	ply.doubleJumped = false
end)