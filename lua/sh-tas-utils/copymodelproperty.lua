
AddCSLuaFile()

properties.Add("copy_model", {
	MenuLabel = "Copy Model",
	Order = 2137,
	MenuIcon = "icon16/page_copy.png",
	Filter = function(self, ent, ply)
		if not ent or not ent:IsValid() or ent:IsPlayer() then return end
		return true
	end,
	Action = function(self, ent)
		local mdl = ent:GetModel()
		if not mdl then return end
		SetClipboardText(mdl)
		surface.PlaySound("garrysmod/content_downloaded.wav")
	end,
})
