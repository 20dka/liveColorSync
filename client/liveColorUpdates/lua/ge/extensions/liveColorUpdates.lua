--====================================================================================
-- All work by tventy.
-- You have no permission to edit, redistribute or upload. Contact me for more info!
--====================================================================================

local M = {}
log("I","liveColor","liveColor Initialising...")



local sinceLastCheck = 0
local tickrate = 1--0.0166

local colorTable = {}

local function col_match(c1, c2)
	return c1.r == c2.r and c1.g == c2.g and c1.b == c2.b and c1.a == c2.a
end

local function pal_match(p1, p2)
	local main = col_match(p1.main, p2.main)
	local pal0 = col_match(p1.pal0, p2.pal0)
	local pal1 = col_match(p1.pal1, p2.pal1)
		
	--if main and pal0 and pal1 then return true else
	--	if not main then print("main doesnt match") end
	--	if not pal0 then print("pal0 doesnt match") end
	--	if not pal1 then print("pal1 doesnt match") end
	--	dump(p1)
	--	dump(p2)
	--	return false
	--end
	return main and pal0 and pal1
end

local function sendColor(tab)
	local strpos = jsonEncode(tab)
	strpos = string.gsub(strpos, ":", ";")
	TriggerServerEvent("liveColorSend", strpos)
end

local function tick()
	for i = 0, be:getObjectCount()-1 do -- For each vehicle
		local veh = be:getObject(i) --  Get vehicle
		local vehID = veh:getID()
		if MPVehicleGE.isOwn(tostring(vehID)) then
			local t = {}
			t.vehID = MPVehicleGE.getServerVehicleID(tostring(vehID))
			t.main = { r=veh.color.x, g=veh.color.y, b=veh.color.z, a=veh.color.w }
			t.pal0 = { r=veh.colorPalette0.x, g=veh.colorPalette0.y, b=veh.colorPalette0.z, a=veh.colorPalette0.w }
			t.pal1 = { r=veh.colorPalette1.x, g=veh.colorPalette1.y, b=veh.colorPalette1.z, a=veh.colorPalette1.w }
			if not colorTable[vehID] then
				colorTable[vehID] = t
				print('first color, sending')
				sendColor(t)
			else
				local lastCol = colorTable[vehID]
				
				if not pal_match(t, lastCol) then
				
				--if lastCol.main.r ~= t.main.r or lastCol.main.g ~= t.main.g or lastCol.main.b ~= t.main.b or lastCol.main.a ~= t.main.a or 
				--	lastCol.pal0.r ~= t.pal0.r or lastCol.pal0.g ~= t.pal0.g or lastCol.pal0.b ~= t.pal0.b or lastCol.pal0.a ~= t.main.a or 
				--	lastCol.pal1.r ~= t.pal1.r or lastCol.pal1.g ~= t.pal1.g or lastCol.pal1.b ~= t.pal1.b or lastCol.pal1.a ~= t.main.a then
					colorTable[vehID] = t
					print('color changed, sending')
					sendColor(t)
				end
			end
		end
	end
end


local function setTickrate(x)
	tickrate = 1/x
	log("I", "liveColor", "setting tickrate to "..tostring(x).."Hz")
end


local function onUpdate(dt)
	sinceLastCheck = sinceLastCheck + dt
	if sinceLastCheck > tickrate then
		sinceLastCheck = 0 -- Reset the delay
		tick()
	end
end


local function liveColorReceive(rawData)
	print("color received")
	if rawData:sub(1,1) == ":" then rawData = rawData:sub(2) end -- cut off the leading :
	local data = jsonDecode(rawData)
	
	local gameVehicleID = MPVehicleGE.getGameVehicleID(data.vehID)
	local veh = be:getObjectByID(gameVehicleID)

	if not veh then print("veh not found, ignoring") return end

	veh.color = Point4F(data.main.r, data.main.g, data.main.b, data.main.a)
	veh.colorPalette0 = Point4F(data.pal0.r, data.pal0.g, data.pal0.b, data.pal0.a)
	veh.colorPalette1 = Point4F(data.pal1.r, data.pal1.g, data.pal1.b, data.pal1.a)
end


AddEventHandler("liveColorReceive",	liveColorReceive)


M.onUpdate			= onUpdate
M.setTickrate 		= setTickrate

log("I","liveColor","liveColor Loaded.")
return M
