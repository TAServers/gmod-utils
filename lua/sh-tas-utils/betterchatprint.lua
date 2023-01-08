if SERVER then
	util.AddNetworkString("TASUtils.ChatPrint")

	local function encodeMsg(args)
		for _, v in ipairs(args) do
			local isColor = IsColor(v)
			net.WriteBool(isColor)

			if isColor then
				net.WriteColor(v, false)
			else
				net.WriteString(tostring(v))
			end
		end

		if net.BytesWritten() > 1024 * 64 then
			error("Tried to send too much data", 3)
		end
	end

	-- Takes a vararg of colours and things to print (each item must have a valid tostring metamethod present)
	function TASUtils.Broadcast(...)
		local args = { ... }

		net.Start("TASUtils.ChatPrint")
		net.WriteUInt(#args, 16)
		encodeMsg({ ... })
		net.Broadcast()
	end

	FindMetaTable("Player").ChatPrint = function(self, ...)
		local args = { ... }

		net.Start("TASUtils.ChatPrint")
		net.WriteUInt(#args, 16)
		encodeMsg({ ... })
		net.Send(self)
	end
else
	net.Receive("TASUtils.ChatPrint", function()
		local args = {}

		for i = 1, net.ReadUInt(16) do
			args[i] = net.ReadBool() and net.ReadColor(false)
				or net.ReadString()
		end

		-- Display the parsed message
		chat.AddText(unpack(args))
	end)
end
