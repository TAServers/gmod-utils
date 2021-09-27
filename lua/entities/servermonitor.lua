AddCSLuaFile()

DEFINE_BASECLASS("base_anim")

ENT.PrintName = "Server Monitor"
ENT.Author = "Total Anarchy Servers"
ENT.Purpose = "Displays server usage stats"
ENT.Category = "TAS Utilities"

ENT.Spawnable = true

local BASE_MODEL = "models/hunter/plates/plate1x2.mdl"
util.PrecacheModel(BASE_MODEL)

if CLIENT then
	-- Setup DHTML monitor
	local url = "http://www.tasservers.com/gmod/utils/servermonitor.html"
	local rt = GetRenderTarget("TASUtils.ServerMonitor", 1024, 1024)
	
	local html = vgui.Create("DHTML")
	html:SetSize(1024, 512)
	html:SetAlpha(0)
	html:SetMouseInputEnabled(false)
	html:OpenURL(url)

	hook.Add("PreRender", "TASUtils.ServerMonitor", function()
		html:UpdateHTMLTexture()
		local htmlMat = html:GetHTMLMaterial()
		
		if not htmlMat then return end
		
		render.PushRenderTarget(rt)	
			cam.Start2D()
				surface.SetMaterial(htmlMat)
				surface.SetDrawColor(255, 255, 255)
				surface.DrawTexturedRect(0, 0, 1024, 1024)
			cam.End2D()
		render.PopRenderTarget()

		html:Call(string.format("setServerCPU(%d);setServerRAM(%d)", TASUtils.GetUsage()))
		html:Call(string.format("setE2CPU(%d);setE2RAM(%d)", TASUtils.GetE2Usage()))
		html:Call(string.format("setStarfallCPU(%d);setStarfallRAM(%d)", TASUtils.GetStarfallUsage()))
	end)

	TASUtils.Materials.ServerMonitor = CreateMaterial(
		"TASUtils_ServerMonitor",
		"VertexLitGeneric",
		{["$basetexture"] = rt:GetName()}
	)
end

function ENT:SpawnFunction(plr, tr, ClassName)
	if !tr.Hit then return end

	local ent = ents.Create(ClassName)
	ent:SetPos(tr.HitPos + tr.HitNormal * 20)
	ent:Spawn()
	ent:Activate()

	return ent
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()

		if self.Screen then
			render.SuppressEngineLighting(true)
			render.SetMaterial(TASUtils.Materials.ServerMonitor)
			
			cam.PushModelMatrix(self:GetWorldTransformMatrix())
			self.Screen:Draw()
			cam.PopModelMatrix()
			
			render.SuppressEngineLighting(false)
		end
	end
end

function ENT:Initialize()
	if CLIENT then
		self.Screen = Mesh()
		
		-- Calculate corners and scale
		local bottomLeft = self:OBBMins()-- - self:OBBCenter()
		local topRight = self:OBBMaxs()-- - self:OBBCenter()
		local scale = topRight - bottomLeft
		
		-- Calculate minor axis and adjust to plane
		local minor = math.min(scale.x, scale.y, scale.z)
		local v0, v1, v2, v3 = topRight
		if minor == scale.x then
			v1 = Vector(topRight.x, bottomLeft.y, topRight.z)
			v2 = Vector(topRight.x, bottomLeft.y, bottomLeft.z)
			v3 = Vector(topRight.x, topRight.y, bottomLeft.z)
		elseif minor == scale.y then
			v1 = Vector(topRight.x, topRight.y, bottomLeft.z)
			v2 = Vector(bottomLeft.x, topRight.y, bottomLeft.z)
			v3 = Vector(bottomLeft.x, topRight.y, topRight.z)
		else
			v1 = Vector(topRight.x, bottomLeft.y, topRight.z)
			v2 = Vector(bottomLeft.x, bottomLeft.y, topRight.z)
			v3 = Vector(bottomLeft.x, topRight.y, topRight.z)
		end
		
		mesh.Begin(self.Screen, MATERIAL_QUADS, 1)
		mesh.Quad(v0, v1, v2, v3)
		mesh.End()
	end

	self:SetModel(BASE_MODEL)

	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	if SERVER then self:PhysicsInit(SOLID_VPHYSICS) end

	self:PhysWake()

	if SERVER then self:GetPhysicsObject():SetMass(20) end
end
