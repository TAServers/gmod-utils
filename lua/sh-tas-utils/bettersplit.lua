local string_gmatch, table_insert = string.gmatch, table.insert

function TASUtils.SplitString(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end

	local t = {}
	for str in string_gmatch(inputstr, "([^" .. sep .. "]+)") do
		table_insert(t, str)
	end

	return t
end
