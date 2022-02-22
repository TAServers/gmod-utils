
function EFFECT:Init(data)
	self.position = data:GetOrigin()
	self.particles = 24
	self.endTime = CurTime() + 1
	self.ent = data:GetEntity()
	
	-- Verified to be in HL2, not sure if that means everyone will have it but.. whatever
	self.mat = "particle/particle_noisesphere"
	
	local emitter = ParticleEmitter(self.position, false)
	for i = 1, self.particles do
		local particle = emitter:Add(self.mat, self.position)
		particle:SetColor(255, 255, 255)
		particle:SetStartSize(10)
		particle:SetEndSize(0)
		particle:SetStartAlpha(80)
		particle:SetEndAlpha(0)
		particle:SetDieTime(1)
		particle:SetGravity(Vector(0, 0, -20))
		-- Negated hemisphere
		particle:SetVelocity(Vector(math.Rand(-1, 1), math.Rand(-1, 1), -math.Rand(0, 1)) * 210)
		particle:SetCollide(true)
	end

	emitter:Finish()
end

function EFFECT:Think()
	-- A small little bit of light
	local deltaTime = CurTime() / self.endTime
	local light = DynamicLight(self.ent:EntIndex())
	light.pos = self.position
	light.Size = 100
	light.brightness = 2 * (1 - deltaTime)
	light.r = 190
	light.g = 190
	light.b = 255
	light.Decay = 1000
	light.DieTime = CurTime() + 1
	return self.endTime > CurTime()
end

function EFFECT:Render()
end	