local DoubleJumpEnabled = CreateConVar("doublejump_enabled", 1, FCVAR_ARCHIVE, "toggle doublejumping", 0, 1)

local function NetDJ(bool) -- i just made it a function for convenience
	net.Start("TASUtils.DoubleJump")
	net.WriteBool(bool)
	net.SendToServer()
end

hook.Add("InitPostEntity", "initial netmsg", function()
	NetDJ(DoubleJumpEnabled:GetBool())
end)

-- options menu drawing
local function OptionsMenu(optionsPanel) -- called on join when spawnmenu is initialized
	dj_checkbox = vgui.Create("DCheckBoxLabel")
	dj_checkbox:SetText("Toggle Double Jump")
	dj_checkbox:SetTextColor(Color(0, 0, 0)) -- for some reason without this the text doesn't look correct :xok:
	dj_checkbox:AlignLeft(30) -- maybe try to use this for any future options we add to make it look consistent and not weird
	dj_checkbox:SetChecked(DoubleJumpEnabled:GetBool())
	optionsPanel:AddItem(dj_checkbox)

	function dj_checkbox:OnChange(val)
		DoubleJumpEnabled:SetBool(val)
	end
	-- another idea was to add a color selector with alpha for the text that comes up when you try to noclip in pvp
	-- as well as the color and thickness of the halo that appears around players in build mode
end

-- if the convar is changed, update the box 
cvars.AddChangeCallback("doublejump_enabled", function(name, old, new)
	dj_checkbox:SetChecked(new)
	NetDJ(DoubleJumpEnabled:GetBool())
end)

hook.Add( "PopulateToolMenu", "AddTASOptionsCategory", function()
	spawnmenu.AddToolMenuOption("Options", "TAS Utilities", "TAS_MenuSettings", "General", "", "", OptionsMenu,
	{
		DoubleJumpEnable = "doublejump_enabled"
	})
end)