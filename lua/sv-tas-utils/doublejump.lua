local STATE_JUMPED = 0
local STATE_LANDED = 1
-- How far the player needs to be from the ground to double jump
-- This is primarily so people who walk off ledges don't accidentally jump
local DIST_FROM_GROUND = 20
-- How long it has to be before a player may double jump
local DOUBLE_JUMP_TIME = 0.03
-- How much to add forward velocity (adds much more of a "leap" feel)
local FORWARD_INFLUENCE = 64
-- How much more power to let the double jump have
local POWER_INCREASE = 1.5

AddCSLuaFile("effects/doublejump.lua")

-- The star of the script
local function onDoubleJump(ply)
	local doubleJumpPower = ply:GetJumpPower() * ply:GetPhysicsObject():GetMass() * POWER_INCREASE
	local forwardVector = ply:GetAimVector() * FORWARD_INFLUENCE

	ply:SetVelocity(Vector(0, 0, doubleJumpPower) + forwardVector)

	local fxData = EffectData()
	fxData:SetOrigin(ply:GetPos())
	fxData:SetEntity(ply)
	util.Effect("doublejump", fxData, true, true)
end

-- Player's current jump/land status
local states = {}

-- Changes the state of a player
local function changeState(ply, state)
	assert(IsValid(ply) and ply, "Player is not valid")

	states[ply] = state
	if state == STATE_JUMPED then
		ply.lastJump = CurTime()
	end
end

-- Retrieves the lazily loaded state of a player
local function getState(ply)
	assert(IsValid(ply) and ply, "Player is not valid")
	if not states[ply] then
		changeState(ply, STATE_LANDED)
	end

	return states[ply]
end

-- Returns whether a player is on the ground or not
local function onGround(ply)
	assert(IsValid(ply) and ply, "Player is not valid")
	local trace = {
		start = ply:GetPos(),
		endpos = ply:GetPos() + Vector(0, 0, -DIST_FROM_GROUND),
		filter = ply
	}

	local result = util.TraceLine(trace)
	return result.Hit
end

-- Updates every player's jump status
-- NOTE: This also checks if they want to jump - but it's not exactly a reliable method
-- we have a reliable method that is the one that primarily checks if they want to jump (and double jump!)
local function updateStates()
	for _, ply in pairs(player.GetAll()) do
		local state = getState(ply)

		if state == STATE_LANDED and not onGround(ply) then
			-- Player is reporting they've landed, but they're not actually on the ground
			-- aka: they jumped
			changeState(ply, STATE_JUMPED)
		elseif state == STATE_JUMPED and onGround(ply) then
			-- Player is reporting they've jumped, but they're actually on the ground
			-- aka: they landed
			changeState(ply, STATE_LANDED)
			ply.doubleJumped = false -- Reset the double jump status 
		end
	end
end

-- Analyzes the CMoveData and determines if the player wants to jump
local function onMove(ply, data)
	local keyPressed = data:KeyPressed(IN_JUMP)
	local velocityCheck = data:GetFinalJumpVelocity().z > 0 -- This is here because I dont know if
	-- the keyPressed variable works if someone rebinds their jump key (who the fuck would do that)

	if keyPressed or velocityCheck then
		local state = getState(ply)

		if state == STATE_LANDED then
			-- Player is on the ground and wants to jump
			changeState(ply, STATE_JUMPED)
		elseif state == STATE_JUMPED and not ply.doubleJumped then
			local duration = CurTime() - ply.lastJump
			if duration < DOUBLE_JUMP_TIME then
				return 
			end

			-- They're mid-air, so invoke the double jump
			ply.doubleJumped = true 
			onDoubleJump(ply)
		end
	end
end

hook.Add("Think", "TASUtils.DoubleJumpUpdate", updateStates)
hook.Add("Move", "TASUtils.DoubleJumpMove", onMove)