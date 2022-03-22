local DoubleJumpEnabled = CreateConVar( "doublejump_enabled", 1, FCVAR_ARCHIVE, "", 0, 1)

-- options menu drawing
local function OptionsMenu( optionsPanel )

    dj_checkbox = vgui.Create( "DCheckBoxLabel" )
    dj_checkbox:SetText( "Toggle Double Jump" )
    dj_checkbox:SetTextColor( Color(0, 0, 0) )
    dj_checkbox:AlignLeft( 30 )
    dj_checkbox:SetChecked( DoubleJumpEnabled:GetBool() )
    optionsPanel:AddItem( dj_checkbox )
    function dj_checkbox:OnChange( val )
        DoubleJumpEnabled:SetBool( val )
    end
    -- another idea was to add a color selector with alpha for the text that comes up when you try to noclip in pvp
    -- as well as the color and thickness of the halo that appears around players in build mode
end

-- if someone changes the convar with console, then update the box
cvars.AddChangeCallback( "doublejump_enabled", function(name, old, new)
    dj_checkbox:SetChecked( new )

    net.Start( "TASUtils.DoubleJump" )
    net.WriteBool( DoubleJumpEnabled:GetBool() )
    net.SendToServer()
end)

hook.Add( "PopulateToolMenu", "AddTASOptionsCategory", function()
    spawnmenu.AddToolMenuOption( "Options", "TAS Utilities", "TAS_MenuSettings", "General", "", "", OptionsMenu, {
        DoubleJumpEnable = "doublejump_enabled"
    })
end)