local cleanGibsCmd = ulx.command(TASUtils.Category, "ulx cleangibs", function() for _, ent in pairs(ents.FindByClass("gib")) do SafeRemoveEntity(ent) end end, "!cleangibs")

cleanGibsCmd:defaultAccess(ULib.ACCESS_ADMIN)
cleanGibsCmd:help("Cleans up all gibs on the map")