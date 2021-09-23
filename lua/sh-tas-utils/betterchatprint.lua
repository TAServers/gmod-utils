if SERVER then
	util.AddNetworkString("TASUtils.ChatPrint")

	-- Global caching
	local _ipairs = ipairs
	local string_char, _tostring = string.char, tostring
	local _IsColor = IsColor
	local util_Compress = util.Compress

	local net_Start, net_WriteData, net_Send, net_Broadcast = net.Start, net.WriteData, net.Send, net.Broadcast

	local function encodeMsgArgs(...)
		local header = ""
		local body = ""
		for _, v in _ipairs({...}) do
			if _IsColor(v) then
				header = header .. "c"
				body = body .. string_char(v:Unpack())
			else
				header = header .. "s"
				body = body .. _tostring(v) .. "\0"
			end
		end

		return _util.Compress(header .. "\0" .. body)
	end

	-- Takes a vararg of colours and things to print (each item must have a valid tostring metamethod present)
	function TASUtils.Broadcast(...)
		net_Start("TASUtils.ChatPrint")
		net_WriteData(encodeMsgArgs(...))
		net_Broadcast()
	end

	FindMetaTable("Player").ChatPrint = function(self, ...)
		net_Start("TASUtils.ChatPrint")
		net_WriteData(encodeMsgArgs(...))
		net_Send(self)
	end
else
	-- Global caching
	local util_Decompress = util.Decompress
	local net_ReadData = net.ReadData
	local _error, _unpack = error, unpack
	local table_insert = table.insert
	local _Color = Color
	local string_byte = string.byte
	local chat_AddText = chat.AddText

	net.Receive("TASUtils.ChatPrint", function(len)
		local data = util_Decompress(net_ReadData(len))
		if not data then
			_error("Failed to decompress TASUtils.ChatPrint data")
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
				table_insert(args, Color(string.byte(data, dataPtr, dataPtr + 3)))
				dataPtr = dataPtr + 4 -- Skip over the three colour values
			elseif header[i] == "s" then -- Strings
				local substring = ""
				while data[dataPtr] ~= "\0" do
					substring = substring .. data[dataPtr]
					dataPtr = dataPtr + 1
				end
				dataPtr = dataPtr + 1 -- Skip over null char

				table_insert(args, substring)
			end
		end

		-- Display the parsed message
		chat_AddText(_unpack(args))
	end)
end
