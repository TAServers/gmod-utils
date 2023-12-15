properties.Add("copy_model", {
	MenuLabel = "Copy Model",
	Order = 2137,
	MenuIcon = "icon16/page_copy.png",
	Filter = function(_, ent)
		return ent and ent:IsValid() and not ent:IsPlayer()
	end,
	Action = function(_, ent)
		local mdl = ent:GetModel()
		if not mdl then
			return
		end
		SetClipboardText(mdl)
		surface.PlaySound("garrysmod/content_downloaded.wav")
	end,
})
