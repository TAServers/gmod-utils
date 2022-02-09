-- Adds addon(s) to the workshop download queue (since they dont do it themselves)

local addons = {
    "104990330", -- WAC AIRCRAFT ONLY!!
    -- TFA Insurgency --
    "866368346",
    "873701799",
    "878962980",
    "1490124474",
    "1676032134",
    "1429966932",
    "1482030308",
    "866368352", -- The only sniper rifle..
    "860057535",
    "415143062", -- TFA Base
    "866368346" -- TFA Ins Shared Parts
}

for _, id in pairs(addons) do
    resource.AddWorkshop(id)
end
