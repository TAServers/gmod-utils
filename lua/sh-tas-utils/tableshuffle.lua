local math_random = math.random

-- https://gist.github.com/Uradamus/10323382, Fisher-Yates, self modifying
function TASUtils.ShuffleTable(tbl)
	for i = #tbl, 2, -1 do
		local j = math_random(i)
		tbl[i], tbl[j] = tbl[j], tbl[i]
	end
end
