local ARGS_LENGTH_BITS = 8
local BOOLEAN_BITS = 1
local COLOUR_CHANNEL_BITS = 8
local NULL_TERMINATOR_BITS = 8

local MAX_MESSAGE_SIZE_BITS = 4 * 1024 * 8
local MAX_ARGS = 2 ^ ARGS_LENGTH_BITS - 1

if SERVER then
	util.AddNetworkString("TASUtils.ChatPrint")

	--- Returns the size of a chat print net message in bits
	---@param args any[]
	---@return integer
	function TASUtils.getChatPrintMessageSizeBits(args)
		local size = ARGS_LENGTH_BITS

		for i, v in ipairs(args) do
			if i > MAX_ARGS then
				break
			end

			size = size + BOOLEAN_BITS

			if IsColor(v) then
				size = size + COLOUR_CHANNEL_BITS * 3
			else
				size = size + #tostring(v) * 8 + NULL_TERMINATOR_BITS
			end
		end

		return size
	end

	local function writeMessage(args)
		net.WriteUInt(#args, ARGS_LENGTH_BITS)

		for i, v in ipairs(args) do
			if i > MAX_ARGS then
				break
			end

			local isColor = IsColor(v)
			net.WriteBool(isColor)

			if isColor then
				net.WriteUInt(v.r, COLOUR_CHANNEL_BITS)
				net.WriteUInt(v.g, COLOUR_CHANNEL_BITS)
				net.WriteUInt(v.b, COLOUR_CHANNEL_BITS)
			else
				net.WriteString(tostring(v))
			end
		end
	end

	local function assertMessageSize(args)
		local messageSize = TASUtils.getChatPrintMessageSizeBits(args)
		if messageSize > MAX_MESSAGE_SIZE_BITS then
			error(
				string.format(
					"Message size %d is greater than maximum of %d bits",
					messageSize,
					MAX_MESSAGE_SIZE_BITS
				),
				2
			)
		end
	end

	--- Takes a vararg of colours and things to print (each item must have a valid tostring metamethod)
	---@param ... any
	function TASUtils.Broadcast(...)
		local args = { ... }

		assertMessageSize(args)

		net.Start("TASUtils.ChatPrint")
		writeMessage(args)
		net.Broadcast()
	end

	FindMetaTable("Player").ChatPrint = function(self, ...)
		local args = { ... }

		assertMessageSize(args)

		net.Start("TASUtils.ChatPrint")
		writeMessage(args)
		net.Send(self)
	end
else
	net.Receive("TASUtils.ChatPrint", function()
		local args = {}

		for i = 1, net.ReadUInt(ARGS_LENGTH_BITS) do
			if net.ReadBool() then
				args[i] = Color(
					net.ReadUInt(COLOUR_CHANNEL_BITS),
					net.ReadUInt(COLOUR_CHANNEL_BITS),
					net.ReadUInt(COLOUR_CHANNEL_BITS)
				)
			else
				args[i] = net.ReadString()
			end
		end

		-- Display the parsed message
		chat.AddText(unpack(args))
	end)
end
