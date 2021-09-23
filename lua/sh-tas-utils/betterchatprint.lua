if SERVER then
	util.AddNetworkString("TASUtils.ChatPrint")

	-- Takes a vararg of colours and things to print (each item must have a valid tostring present)
	function TASUtils.ChatPrint(...)
		local header = ""
		local body = ""
		for _, v in ipairs({...}) do
			if IsColor(v) then
				header = header .. "c"
				body = body .. string.format("%c%c%c", v:Unpack())
			else
				header = header .. "s"
				body = body .. tostring(v) .. "\0"
			end
		end

		net.Start("TASUtils.ChatPrint")
		net.WriteData(util.Compress(header .. "\0" .. body))
		net.Broadcast()
	end
else
	net.Receive("TASUtils.ChatPrint", function(len)
		local data = util.Decompress(net.ReadData(len))
		if not data then
			error("Failed to decompress TASUtils.ChatPrint data")
			return
		end

		local dataPtr = 1

		-- Parse header
		local header, headerLen = "", 0
		while true do
			if data[dataPtr] == "\0" then break end

			header = header .. data[dataPtr]
			headerLen = headerLen + 1
			dataPtr = dataPtr + 1
		end

		dataPtr = dataPtr + 1 -- Skip over the null char that caused the above loop to break

		-- Parse body
		local args = {}
		for i = 1, headerLen do
			if header[i] == "c" then -- Colours
				table.insert(args, Color(string.byte(data, dataPtr, dataPtr + 2)))
				dataPtr = dataPtr + 3 -- Skip over the three colour values
			elseif header[i] == "s" then -- Strings
				local substring = ""
				while data[dataPtr] ~= "\0" do
					substring = substring .. data[dataPtr]
					dataPtr = dataPtr + 1
				end
				dataPtr = dataPtr + 1 -- Skip over null char

				table.insert(args, substring)
			end
		end

		-- Display the parsed message
		chat.AddText(unpack(args))
	end)
end
