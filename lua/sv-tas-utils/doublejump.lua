-- How long it has to be before a player may double jump, this helps immediate double jump issues
local DOUBLE_JUMP_TIME = 0.03
-- How much to add forward velocity (adds much more of a "leap" feel)
local FORWARD_INFLUENCE = 64
-- How much more power to let the double jump have
local POWER_INCREASE = 1.5

-- Make sure clients also get our effect
AddCSLuaFile("effects/doublejump.lua")

-- The star of the script
local function onDoubleJump(ply)
	-- This sends the plater primarily flying upwards, but also adds some forward velocity
	local doubleJumpPower = ply:GetJumpPower() * ply:GetPhysicsObject():GetMass() * POWER_INCREASE
	local forwardVector = ply:GetAimVector() * FORWARD_INFLUENCE

	ply:SetVelocity(Vector(0, 0, doubleJumpPower) + forwardVector)

	-- Play a little effect when we jump
	local fxData = EffectData()
	fxData:SetOrigin(ply:GetPos())
	fxData:SetEntity(ply)
	util.Effect("doublejump", fxData, true, true)
end

-- Analyzes the CMoveData and determines if the player wants to jump
local function onMove(ply, data)
	local keyPressed = data:KeyPressed(IN_JUMP)
	local velocityCheck = data:GetFinalJumpVelocity().z > 0 -- This is here because I dont know if
	-- the keyPressed variable works if someone rebinds their jump key (who the fuck would do that)

	if keyPressed or velocityCheck then
		if not ply:OnGround() and not ply.doubleJumped then
			-- Without this, the double jump would occur instantly
			local duration = CurTime() - ply.lastJump
			if duration < DOUBLE_JUMP_TIME then
				return 
			end

			-- They're mid-air, so invoke the double jump
			ply.doubleJumped = true 
			onDoubleJump(ply)
		else
			-- If this is a normal jump, record it
			ply.lastJump = CurTime()
		end
	end
end

hook.Add("Move", "TASUtils.DoubleJumpMove", onMove)
hook.Add("OnPlayerHitGround", "TASUtils.DoubleJumpReset", function(ply)
	-- Simply reset their double jump flag, not enough to move it into its own function
	ply.doubleJumped = false
end)