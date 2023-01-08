local data = {
	sv = {
		cpu = 0,
		ram = 0,
		e2 = {
			cpu = 0,
			ram = 0,
		},
		sf = {
			cpu = 0,
			ram = 0,
		},
	},
	cl = {
		cpu = 0,
		ram = 0,
		sf = {
			cpu = 0,
			ram = 0,
		},
	},
}

if SERVER then
	util.AddNetworkString("TASUtils.GetUsage")

	local svTpsMax = CreateConVar(
		"tasutils_tickrate",
		66,
		FCVAR_ARCHIVE,
		"Server desired tickrate used by TASUtils.GetUsage",
		0
	)
	local svRamMax = CreateConVar(
		"tasutils_ram_max",
		2,
		FCVAR_ARCHIVE,
		"Max point for server RAM usage returned by TASUtils.GetUsage (in gigabytes)",
		0.01
	)

	local function calcUsageSF(deltaTime)
		if SF.playerInstances then
			local total = 0
			for _, instances in pairs(SF.playerInstances) do
				for instance, _ in pairs(instances) do
					total = total + instance:movingCPUAverage()
				end
			end

			data.sv.sf.cpu = total / deltaTime -- Starfall CPU usage measured as a percentage of the frame
		end

		if SF.Instance and SF.Instance.RamAvg then
			data.sv.sf.ram = SF.Instance.RamAvg / SF.RamCap:GetInt()
		end
	end

	local e2RamMax
	local function calcUsageE2(deltaTime, ramUsage)
		if not e2RamMax then -- Wait for convar to exist
			e2RamMax =
				GetConVar("wire_expression2_ram_emergency_shutdown_total")
		else
			local total = 0
			for _, e2 in ipairs(ents.FindByClass("gmod_wire_expression2")) do
				if e2.context and e2.context.timebench then
					total = total + e2.context.timebench
				end
			end
			data.sv.e2.cpu = total / deltaTime

			data.sv.e2.ram = ramUsage / (e2RamMax:GetInt() * 1000) -- Yes this is the incorrect comparison, but it's what wire will terminate by so don't fix it until they do
		end
	end

	local lastFrameTime = SysTime()
	hook.Add("Think", "TASUtils.GetUsage", function()
		local curFrameTime = SysTime()
		local deltaTime = curFrameTime - lastFrameTime
		lastFrameTime = curFrameTime

		local ramUsage = collectgarbage("count")

		-- Update server usage
		do
			local max = svTpsMax:GetFloat()
			data.sv.cpu = math.max(1 - (1 / deltaTime) / max, 0)
		end
		data.sv.ram = ramUsage / (svRamMax:GetFloat() * 1024 * 1024)

		if E2Lib then
			calcUsageE2(deltaTime, ramUsage)
		end

		if SF then
			calcUsageSF(deltaTime)
		end

		net.Start("TASUtils.GetUsage")
		net.WriteFloat(data.sv.cpu)
		net.WriteFloat(data.sv.ram)
		net.WriteFloat(data.sv.e2.cpu)
		net.WriteFloat(data.sv.e2.ram)
		net.WriteFloat(data.sv.sf.cpu)
		net.WriteFloat(data.sv.sf.ram)
		net.Broadcast()
	end)
else
	net.Receive("TASUTils.GetUsage", function()
		data.sv.cpu = net.ReadFloat()
		data.sv.ram = net.ReadFloat()
		data.sv.e2.cpu = net.ReadFloat()
		data.sv.e2.ram = net.ReadFloat()
		data.sv.sf.cpu = net.ReadFloat()
		data.sv.sf.ram = net.ReadFloat()
	end)
end

function TASUtils.GetUsage()
	return data.sv.cpu, data.sv.ram
end

function TASUtils.GetE2Usage()
	return data.sv.e2.cpu, data.sv.e2.ram
end

function TASUtils.GetStarfallUsage()
	return data.sv.sf.cpu, data.sv.sf.ram
end
