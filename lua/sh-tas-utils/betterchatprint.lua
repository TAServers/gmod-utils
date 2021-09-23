if SERVER then
	util.AddNetworkString("TASUtils.ChatPrint")

	-- Takes a vararg of colours and things to print (each item must have a valid tostring present)
	function TASUtils.ChatPrint(...)
		local header = ""
		local body = ""
		for _, v in ipairs({...}) do
			if IsColor(v) then
				header = header .. "c"
				body = body .. string.format("%c%c%c\0", v:Unpack())
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
		len = #data

		local i = 0

		-- Parse header
		local header, headerLen = "", 0
		while true do
			i = i + 1
			if data[i] == "\0" then break end
			header = header .. data[i]
			headerLen = headerLen + 1
		end

		-- Parse body
		local args, headerLoc = {}, 1
		buffer = ""
		while true do
			i = i + 1
			if data[i] == "\0" then -- Handle buffer
				if header[headerLoc] == "c" then
					table.insert(args, Color(string.byte(buffer)))
				elseif header[headerLoc] == "s" then
					table.insert(args, buffer)
				end

				if i == len then break end -- We've reached the final null char

				headerLoc = headerLoc + 1
				buffer = ""

				if headerLoc > headerLen then
					error("Body length longer than header")
				end
			else
				buffer = buffer .. data[i]
			end
		end

		-- Display the parsed message
		chat.AddText(unpack(args))
	end)
end
