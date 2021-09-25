-- Adds addon(s) to the workshop download queue (since they dont do it themselves)

local addons = {
    "104990330" -- WAC AIRCRAFT ONLY!!
}

for _, id in pairs(addons) do
    resource.AddWorkshop(id)
end