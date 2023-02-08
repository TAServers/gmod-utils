-- This should contain all the configs to be run after lua has finished initialising

-- Enable relay
RunConsoleCommand("relay_connection", "172.17.0.1:8080")
RunConsoleCommand("relay_start")

-- Wiremod
RunConsoleCommand("wire_expression2_quotasoft", 100000)
RunConsoleCommand("wire_expression2_quotahard", 100000)
RunConsoleCommand("wire_expression2_quotatick", 25000)
RunConsoleCommand("wire_expression2_quotatime", 0.005)

-- Starfall
RunConsoleCommand("sf_timebuffer", 0.005)
RunConsoleCommand("sf_timebuffersize", 100)
