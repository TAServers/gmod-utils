AddCSLuaFile()

DEFINE_BASECLASS("base_anim")

ENT.PrintName = "Server Monitor"
ENT.Author = "Total Anarchy Servers"
ENT.Purpose = "Displays server usage stats"
ENT.Category = TASUtils.Category

ENT.Spawnable = true

local BASE_MODEL = "models/hunter/plates/plate1x2.mdl"
util.PrecacheModel(BASE_MODEL)

if CLIENT then
	-- Setup DHTML monitor
	local url = "https://www.taservers.com/gmod/utils/servermonitor.html"
	local rt = GetRenderTarget("TASUtils.ServerMonitor", 1024, 1024)
	
	local html = vgui.Create("DHTML")
	html:SetSize(1024, 512)
	html:SetAlpha(0)
	html:SetMouseInputEnabled(false)
	html:OpenURL(url)

	html:AddFunction("servermonitor", "onload", function()
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
		end)

		local updateRate = GetConVar("tasutils_usage_updaterate")
		local tickAmount = 0
		hook.Add("Think", "TASUtils.ServerMonitor", function()
			if not updateRate then
				-- Attempt to fetch our console variable first
				updateRate = GetConVar("tasutils_usage_updaterate")
				return
			end

			-- Wait until enough ticks have passed to update
			if tickAmount >= updateRate:GetInt() then
				-- Our panel is invisible, the JavaScript queue will not function properly, so we run the
				-- JS code manually
				html:RunJavascript(
					string.format("setServerCPU(%.7f);setServerRAM(%.7f);", TASUtils.GetUsage()) ..
					string.format("setE2CPU(%.7f);setE2RAM(%.7f);", TASUtils.GetE2Usage()) ..
					string.format("setStarfallCPU(%.7f);setStarfallRAM(%.7f);", TASUtils.GetStarfallUsage())
				)

				tickAmount = 0
			else
				tickAmount = tickAmount + 1
			end
		end)
	end)

	TASUtils.Materials.ServerMonitor = CreateMaterial(
		"TASUtils_ServerMonitor",
		"VertexLitGeneric",
		{["$basetexture"] = rt:GetName()}
	)
end

function ENT:SpawnFunction(plr, tr, ClassName)
	if not tr.Hit then return end

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
