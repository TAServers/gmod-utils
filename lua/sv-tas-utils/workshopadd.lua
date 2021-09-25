-- Adds addon(s) to the workshop download queue (since they dont do it themselves)

local addons = {
    "104990330", -- WAC AIRCRAFT ONLY!!
    -- TFA Insurgency --
    "866368346",
    "873701799",
    "878962980",
    "1490124474",
    "1676032134",
    "1429966932"
}

for _, id in pairs(addons) do
    resource.AddWorkshop(id)
end