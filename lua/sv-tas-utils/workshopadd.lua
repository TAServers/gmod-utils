-- Adds addon(s) to the workshop download queue (since they dont do it themselves)

local addons = {
    "415143062", -- TFA Base
	"870165339", -- VFire

    -- TFA Insurgency --
    "866368346",  -- Shared Parts
	"1676032134", -- AR-15
	"1304932254", -- Beretta M9
	"1243621966", -- H&K MP5K
	"870165339"   -- Hyper's RFB
}

for _, id in pairs(addons) do
    resource.AddWorkshop(id)
end
