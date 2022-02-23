-- How much to add forward velocity (adds much more of a "leap" feel)
local FORWARD_INFLUENCE = 180
-- How much more power to let the double jump have
local POWER_INCREASE = 2

-- Make sure clients also get our effect
AddCSLuaFile("effects/doublejump.lua")

hook.Add("SetupMove", "TASUtils.DoubleJump", function(ply, move)
	-- Check if the move has a jump command, and check if its a double jump
	if move:KeyPressed(IN_JUMP) and not ply:OnGround() and not ply.doubleJumped then
		-- A double jump has been initiated
		ply.doubleJumped = true 
		-- This sends the player primarily flying upwards, but also adds some forward velocity
		local doubleJumpPower = ply:GetJumpPower() * POWER_INCREASE
		local forwardVector = ply:GetAimVector() * FORWARD_INFLUENCE

		-- Set the velocity of the double jump
		move:SetVelocity(move:GetVelocity() + Vector(0, 0, doubleJumpPower) + forwardVector)

		-- Play a little effect when we jump
		-- We also still need this on server even on shared, because this will replicate other players' effects
		local fxData = EffectData()
		fxData:SetOrigin(ply:GetPos())
		fxData:SetEntity(ply)
		local recipients = nil 

		-- Without this here - the client would play an effect, and the server would too - this
		-- prevents double effects
		if SERVER then
			recipients = RecipientFilter()
			recipients:AddAllPlayers()
			recipients:RemovePlayer(ply) -- Remove ourselves since we do it on the client
		end
		
		util.Effect("doublejump", fxData, true, recipients)
	end
end)

hook.Add("OnPlayerHitGround", "TASUtils.DoubleJump", function(ply)
	-- Simply reset their double jump flag, not enough to move it into its own function
	ply.doubleJumped = false
end)