local chromiumBranches = {
	chromium = true,
	["x86-64"] = true
}

setmetatable(chromiumBranches, {
	__index = function() return false end -- if the branch isn't in the list, return false
})

TASUtils.Chromium = chromiumBranches[BRANCH]
