--[[
	This addon designed to be as lightweight as possible.
	It will only track, Mine, Herb, Fish, Gas and some Treasure nodes.
	This mods whole purpose is to be lean, simple and feature complete.
]]
-- Mixin AceEvent
local GatherMate = LibStub("AceAddon-3.0"):NewAddon("GatherMate2","AceConsole-3.0","AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("GatherMate2",false)
_G["GatherMate2"] = GatherMate

-- locals
local db, gmdbs, filter
local reverseTables = {}
-- defaults for storage
local defaults = {
	profile = {
		scale       = 0.75,
		alpha       = 1,
		show = {
			["Treasure"] = "always",
			["*"] = "with_profession"
		},
		showMinimap = true,
		showWorldMap = true,
		minimapTooltips = true,
		filter = {
			["*"] = {
				["*"] = true,
			},
		},
		trackColors = {
			["Herb Gathering"] = {Red = 0, Green = 1, Blue = 0, Alpha = 1},
			["Fishing"]        = {Red = 1, Green = 1, Blue = 0, Alpha = 1},
			["Mining"]         = {Red = 1, Green = 0, Blue = 0, Alpha = 1},
			["Extract Gas"]    = {Red = 0, Green = 1, Blue = 1, Alpha = 1},
			["Treasure"]       = {Red = 1, Green = 0, Blue = 1, Alpha = 1},
			["*"]              = {Red = 1, Green = 0, Blue = 1, Alpha = 1},
		},
		trackDistance = 100,
		trackShow = "always",
		nodeRange = true,
		cleanupRange = {
			["Herb Gathering"] = 15,
			["Fishing"]        = 15,
			["Mining"]         = 15,
			["Extract Gas"]    = 50,
			["Treasure"]	   = 15,
		},
		dbLocks = {
			["Herb Gathering"] = false,
			["Fishing"]        = false,
			["Mining"]         = false,
			["Extract Gas"]    = false,
			["Treasure"]	   = false,
		},
		importers = {
			["*"] = {
				["Style"] = "Merge",
				["Databases"] = {},
				["lastImport"] = 0,
				["autoImport"] = false,
				["bcOnly"] = false,
			},
		}
	},
}
local floor = floor
local next = next

--[[
	Setup a few databases, we sub divide namespaces for resetting/importing
	:OnInitialize() is called at ADDON_LOADED so savedvariables are loaded
]]
function GatherMate:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("GatherMateDB", defaults, "Default")
	self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")

	-- Setup our saved vars, we dont use AceDB, cause it over kills
	-- These 4 savedvars are global and doesnt need char specific stuff in it
	GatherMateHerbDB = GatherMateHerbDB or {}
	GatherMateMineDB = GatherMateMineDB or {}
	GatherMateGasDB = GatherMateGasDB or {}
	GatherMateFishDB = GatherMateFishDB or {}
	GatherMateTreasureDB = GatherMateTreasureDB or {}
	self.gmdbs = {}
	self.db_types = {}
	gmdbs = self.gmdbs
	self:RegisterDBType("Herb Gathering", GatherMate2HerbDB)
	self:RegisterDBType("Mining", GatherMate2MineDB)
	self:RegisterDBType("Fishing", GatherMate2FishDB)
	self:RegisterDBType("Extract Gas", GatherMate2GasDB)
	self:RegisterDBType("Treasure", GatherMate2TreasureDB)
	db = self.db.profile
	filter = db.filter
end

--[[
	Register a new node DB for usage in GatherMate
]]
function GatherMate:RegisterDBType(name, db)
	tinsert(self.db_types, name)
	self.gmdbs[name] = db
end

function GatherMate:OnProfileChanged(db,name)
	db = self.db.profile
	filter = db.filter
	GatherMate:SendMessage("GatherMate2ConfigChanged")
end
--[[
	create a reverse lookup table for input table (we use it for english names of nodes)
]]
function GatherMate:CreateReversedTable(tbl)
	if reverseTables[tbl] then
		return reverseTables[tbl]
	end
	local reverse = {}
	for k, v in pairs(tbl) do
		reverse[v] = k
	end
	reverseTables[tbl] = reverse
	return setmetatable(reverse, getmetatable(tbl))
end
--[[
	Clearing function
]]
function GatherMate:ClearDB(dbx)
	-- for our own DBs we just discard the table and be happy
	-- db lock check
	if GatherMate.db.profile.dbLocks[dbx] then
		return
	end
	if dbx == "Herb Gathering" then	GatherMate2HerbDB = {}; gmdbs[dbx] = GatherMate2HerbDB
	elseif dbx == "Fishing" then GatherMate2FishDB = {}; gmdbs[dbx] = GatherMate2FishDB
	elseif dbx == "Extract Gas" then GatherMate2GasDB = {}; gmdbs[dbx] = GatherMate2GasDB
	elseif dbx == "Mining" then GatherMate2MineDB = {}; gmdbs[dbx] = GatherMate2MineDB
	elseif dbx == "Treasure" then GatherMate2TreasureDB = {}; gmdbs[dbx] = GatherMate2TreasureDB
	else -- for custom DBs we dont know the global name, so we clear it old-fashion style
		local db = gmdbs[dbx]
		if not db then error("Trying to clear unknown database: "..dbx) end
		for k in pairs(db) do
			db[k] = nil
		end
	end
end
--[[
	create an ID for an x, y coordinate to save space, we use a very simple format: xxxxyyyy
]]
--function GatherMate:getID(x, y)
--	return floor(x * 10000 + 0.5) * 10000 + floor(y * 10000 + 0.5)
--end
--[[
	create X,Y from an ID
]]
--function GatherMate:getXY(id)
--	return floor(id / 10000) / 10000, (id % 10000) / 10000
--end

--[[
	how big is the zone
]]
function GatherMate:GetZoneSize(zone)
	local x = self.zoneData[zone]
	if x then return x[1], x[2]	else return 0, 0 end
end

--[[
	Convert a zone name to id
]]
--function GatherMate:GetZoneID(zone)
--	return self.zoneData[zone][3]
--end
--[[
	Add an item to the DB
]]
function GatherMate:AddNode(zoneID, x, y, level, nodeType, name)
	local db = gmdbs[nodeType]
	local id = self:getID(x, y)
	--local zoneID = self.zoneData[zone][3]
	-- db lock check
	if GatherMate.db.profile.dbLocks[nodeType] then
		return
	end
	db[zoneID] = db[zoneID] or {}
	db[zoneID][id] = self.nodeIDs[nodeType][name]
	self:SendMessage("GatherMate2NodeAdded", zone, nodeType, id, name)
end

--[[
	These 2 functions are only called by the importer/sharing. These
	do NOT fire GatherMateNodeAdded or GatherMateNodeDeleted messages.
]]
function GatherMate:InjectNode(zoneID, coords, nodeType, nodeID)
	local db = gmdbs[nodeType]
	-- db lock check
	if GatherMate.db.profile.dbLocks[nodeType] then
		return
	end
	db[zoneID] = db[zoneID] or {}
	db[zoneID][coords] = nodeID
end
function GatherMate:DeleteNode(zoneID, coords, nodeType)
	-- db lock check
	if GatherMate.db.profile.dbLocks[nodeType] then
		return
	end
	local db = gmdbs[nodeType][zoneID]
	if db then
		db[coords] = nil
	end
end

-- Do-end block for iterator
do
	local emptyTbl = {}
	local tablestack = setmetatable({}, {__mode = 'k'})

	local function dbCoordIterNearby(t, prestate)
		if not t then return nil end
		local data = t.data
		local state, value = next(data, prestate)
		local xLocal, yLocal, yw, yh = t.xLocal, t.yLocal, t.yw, t.yh
		local lLevel = t.lLevel
		local radiusSquared, filterTable, ignoreFilter = t.radiusSquared, t.filterTable, t.ignoreFilter
		while state do
			if filterTable[value] or ignoreFilter then
				-- inline the :getXY() here in critical minimap update loop
				local x2, y2, level2 = GatherMate.mapData:DecodeLoc(state)
				local x = (x2 - xLocal) * yw
				local y = (y2 - yLocal) * yh
				if x*x + y*y <= radiusSquared and level2 == lLevel then
					return state, value
				end
			end
			state, value = next(data, state)
		end
		tablestack[t] = true
		return nil, nil
	end

	--[[
		Find all nearby nodes within the radius of the given (x,y) for a nodeType and zone
		this function returns an iterator
	]]
	function GatherMate:FindNearbyNode(zone, x, y, level, nodeType, radius, ignoreFilter)
		local tbl = next(tablestack) or {}
		tablestack[tbl] = nil
		tbl.data = gmdbs[nodeType][self.zoneData[zone][3]] or emptyTbl
		tbl.yw, tbl.yh = self.zoneData[zone][1], self.zoneData[zone][2]
		tbl.radiusSquared = radius * radius
		tbl.xLocal, tbl.yLocal = x, y
		tbl.lLocal = level
		tbl.filterTable = filter[nodeType]
		tbl.ignoreFilter = ignoreFilter
		return dbCoordIterNearby, tbl, nil
	end

	local function dbCoordIter(t, prestate)
		if not t then return nil end
		local data = t.data
		local state, value = next(data, prestate)
		local filterTable = t.filterTable
		while state do
			if filterTable[value] then
				return state, value
			end
			state, value = next(data, state)
		end
		tablestack[t] = true
		return nil, nil
	end

	--[[
		This function returns an iterator for the given zone and nodeType
	]]
	function GatherMate:GetNodesForZone(zone, nodeType, ignoreFilter)
		local t = gmdbs[nodeType][self.zoneData[zone][3]] or emptyTbl
		if ignoreFilter then
			return pairs(t)
		else
			local tbl = next(tablestack) or {}
			tablestack[tbl] = nil
			tbl.data = t
			tbl.filterTable = filter[nodeType]
			return dbCoordIter, tbl, nil
		end
	end
end
--[[
	Get the distance between 2 points in a zone
]]
function GatherMate:Distance(...)
	return self:NodeDistanceSquared(...) ^ 0.5
end
--[[
	convert a point on the map to yard values
]]
function GatherMate:PointToYards(x,y,zone,level)
	--return self.mapData:PointToYards(zone,level,x,y)
	return 0,0
end
--[[
	Distance squared between 2 nodes in the same zone
]]
function GatherMate:NodeDistanceSquared(x1, y1, x2, y2, zone)
	local x = (x2 - x1) * self.zoneData[zone][1]
	local y = (y2 - y1) * self.zoneData[zone][2]
	return x*x + y*y
end
--[[
	Node id function forward and reverse
]]
function GatherMate:GetIDForNode(type, name)
	return self.nodeIDs[type][name]
end
--[[
	Get the name for a nodeID
]]
function GatherMate:GetNameForNode(type, nodeID)
	return self.reverseNodeIDs[type][nodeID]
end
--[[
	Remove an item from the DB
]]
function GatherMate:RemoveNode(zone, x, y, nodeType)
	local zoneID = self.zoneData[zone][3]
	local db = gmdbs[nodeType][zoneID]
	local coord = self:getID(x,y)
	if db[coord] then
		local t = self.reverseNodeIDs[nodeType][db[coord]]
		db[coord] = nil
		self:SendMessage("GatherMateNodeDeleted", zone, nodeType, coord, t)
	end
end
--[[
	Remove an item from the DB by node ID and type
]]
function GatherMate:RemoveNodeByID(zone, nodeType, coord)
	local zoneID = self.zoneData[zone][3]
	-- db lock check
	if GatherMate.db.profile.dbLocks[nodeType] then
		return
	end
	local db = gmdbs[nodeType][zoneID]
	if db[coord] then
		local t = self.reverseNodeIDs[nodeType][db[coord]]
		db[coord] = nil
		self:SendMessage("GatherMate2NodeDeleted", zone, nodeType, coord, t)
	end
end

--[[
	Function to cleanup the databases by removing nearby nodes of similar types
]]
function GatherMate:CleanupDB()
	local Collector = GatherMate:GetModule("Collector")
	local rares = Collector.rareNodes
	for zone,v in pairs(GatherMate.zoneData) do
		--self:Print(L["Processing "]..zone)
		for profession in pairs(gmdbs) do
			local range = db.cleanupRange[profession]
			for coord, nodeID in self:GetNodesForZone(zone, profession, true) do
				local x,y = self:getXY(coord)
				for _coord, _nodeID in self:FindNearbyNode(zone, x, y, profession, range, true) do
					if coord ~= _coord and (nodeID == _nodeID or (rares[_nodeID] and rares[_nodeID][nodeID])) then
						self:RemoveNodeByID(zone, profession, _coord)
					end
				end
			end
		end
	end
	self:SendMessage("GatherMate2Cleanup")
	self:Print(L["Cleanup Complete."])
end

--[[
	Function to delete all of a specified node from a specific zone
]]
function GatherMate:DeleteNodeFromZone(nodeType, nodeID, zone)
	local zoneID = self.zoneData[zone][3]
	local db = gmdbs[nodeType][zoneID]
	if db then
		for coord, node in pairs(db) do
			if node == nodeID then
				self:RemoveNodeByID(zone, nodeType, coord)
			end
		end
		self:SendMessage("GatherMate2Cleanup")
	end
end

