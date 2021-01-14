




RegisterEvent("liveColorSend","liveColorSend")

function clog(text) clog(text, true) end
function clog(text, saveToDisk)
	if text == nil then
		return
	end

	if type(text) == "table" then
		text = tableToString(text)
	end

	print(os.date("[%d/%m/%Y %H:%M:%S]").." [liveColorUpdates] "..text)

	if saveToDisk then
		file = io.open("log.txt", "a")
		file:write(os.date("[%d/%m/%Y %H:%M:%S] ")..text.."\n")
		file:close()
	end
end

clog("loading...")

function TriggerClientEventForAllExcept(excludeID, eventName, eventData)
	for k,v in pairs(GetPlayers()) do
		if k ~= excludeID then
			--print("telling "..k.." that "..excludeID.." did the thing")
			TriggerClientEvent(k, eventName, eventData)
		end
	end
end

function printNameWithID(playerID) return GetPlayerName(playerID).."("..playerID..")" end
function starts_with(str, start)
   return str:sub(1, #start) == start
end

function liveColorSend(playerID, data)
	data = string.gsub(data, ";", ":")
	--print(data)
	clog(printNameWithID(playerID).." changed color")
	TriggerClientEventForAllExcept(playerID, "liveColorReceive", data)
end


clog("loaded!")
