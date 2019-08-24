-----------------------------------------------------------------
-- Header
-----------------------------------------------------------------
	do
		WorldExplorer = CreateFrame("Frame", "WorldExplorer", UIParent); --Creates a new UI frame called "WorldExplorer"
		
		WorldExplorer.Name = "WorldExplorer";
		
		WorldExplorer.Version = GetAddOnMetadata(WorldExplorer.Name, "Version");
		WorldExplorer.sVersionType = GetAddOnMetadata(WorldExplorer.Name, "X-VersionType");
		WorldExplorer.LoadedStatus = {}; -- Says what stage the addon loading is at.
		WorldExplorer.LoadedStatus["Initialized"] = 0; -- Say that the addon has not loaded yet.
		WorldExplorer.LoadedStatus["RunLevel"] = 3; -- Specifies what level the addon is "Running"
	end;
-----------------------------------------------------------------



-----------------------------------------------------------------
-- Libraries
-----------------------------------------------------------------
	local ZMC, L; -- Registering local variables outside hider do
	do
		WorldExplorer.Astrolabe = DongleStub("Astrolabe-0.4");
		WorldExplorer.Dongle = DongleStub("Dongle-1.2"):New("DongleWorldExplorerTemplate");
		
		ZMC = LibStub("LibZasMsgCtr-1.0");
		WorldExplorer.ZMC = ZMC; -- Store a copy of this application so it can be used again by any bolton addons
		ZMC:Initialize(WorldExplorer, WorldExplorer.Name, ZMC.COLOUR_BLUE, 1) -- Initialize the debugging/messaging library's settings for this addon (CallingAddon, AddonName, DefaultColour1, Debug_Frame, DefaultColour2, DefaultErrorColour, DefaultMsgFrame)
		
		L = LibStub("AceLocale-3.0"):GetLocale(WorldExplorer.Name, false);
		WorldExplorer.L = L; -- Store a copy of this application so it can be used again by any bolton addons
	end;
-----------------------------------------------------------------



----------------------------------------------------------------------------------------------------------------------
-- DEFAULTS and Variable declarations
----------------------------------------------------------------------------------------------------------------------
	do
		if (WorldExplorer.Default_Enabled == nil) then
			WorldExplorer.Default_Enabled = true;
		end;
		
		WorldExplorer.Icons = {}
		
		WorldExplorer.Icons.Cross = {};
		WorldExplorer.Icons.Cross.Texture = "Interface\\Addons\\WorldExplorer\\Images\\WE_WhiteCross";
		WorldExplorer.Icons.Cross.Width = 5;
		WorldExplorer.Icons.Cross.Height = 5;
		
		WorldExplorer.Icons.Circle = {};
		WorldExplorer.Icons.Circle.Texture = "Interface\\Addons\\WorldExplorer\\Images\\WE_WhiteCircle";
		WorldExplorer.Icons.Circle.Width = 10;
		WorldExplorer.Icons.Circle.Height = 10;
		
		WorldExplorer.Icons.Square = {};
		WorldExplorer.Icons.Square.Texture = "Interface\\Addons\\WorldExplorer\\Images\\WE_WhiteSquare";
		WorldExplorer.Icons.Square.Width = 10;
		WorldExplorer.Icons.Square.Height = 10;
		
		WorldExplorer.Colour = {};
		WorldExplorer.Colour[1] = "FFFFFF";
		WorldExplorer.Colour[2] = "990000";
		WorldExplorer.Colour[3] = "FF0000";
		WorldExplorer.Colour[4] = "009900";
		WorldExplorer.Colour[5] = "999900";
		WorldExplorer.Colour[6] = "FF9900";
		WorldExplorer.Colour[7] = "000099";
		WorldExplorer.Colour[8] = "990099";
		WorldExplorer.Colour[9] = "FF0099";
		WorldExplorer.Colour[10] = "009999";
		WorldExplorer.Colour[11] = "999999";
		WorldExplorer.Colour[12] = "FF9999";
		WorldExplorer.Colour[13] = "00FF00";
		WorldExplorer.Colour[14] = "99FF00";
		WorldExplorer.Colour[15] = "FFFF00";		
		WorldExplorer.Colour[16] = "0000FF";
		WorldExplorer.Colour[17] = "9900FF";
		WorldExplorer.Colour[18] = "FF00FF";
		WorldExplorer.Colour[19] = "00FFFF";
		WorldExplorer.Colour[20] = "99FFFF";
		WorldExplorer.Colour[21] = "B7B7B7";
		WorldExplorer.Colour[22] = "0099FF";
		WorldExplorer.Colour[23] = "9999FF";
		WorldExplorer.Colour[24] = "FF99FF";
		WorldExplorer.Colour[25] = "00FF99";
		WorldExplorer.Colour[26] = "99FF99";
		WorldExplorer.Colour[27] = "FFFF99";
		WorldExplorer.Colour[28] = "000000";
	end;
----------------------------------------------------------------------------------------------------------------------



-----------------------------------------------------------------
-- KeyBinding Variables
-----------------------------------------------------------------
	do
		BINDING_HEADER_WORLDEXPLORER = "WorldExplorer";
		BINDING_NAME_WorldExplorer_ToggleAddon = L["Enable/Disable WorldExplorer"];
		--[[BINDING_NAME_WorldExplorer_ToggleBreadDrop = L["Start/Stop Dropping WorldExplorer"];
		BINDING_NAME_WorldExplorer_ToggleHideBread = L["Hide/Show WorldExplorer"];
		BINDING_NAME_WorldExplorer_ToggleDropWhenDead = L["Start/Stop Dropping WorldExplorer when Dead"];]]--
	end;
-----------------------------------------------------------------



-----------------------------------------------------------------
-- Local Functions
-----------------------------------------------------------------
	local function TableCount(tableToCount) -- TableCount: Counts table members
		----------------------------------------------
		-- Default: If DebugTxt is set to true all of
		-- the debug msgs in THIS function will apear!
		----------------------------------------------
			local DebugTxt = false;
			-- DebugTxt = true; -- Uncomment this to debug
		----------------------------------------------
		
		ZMC:Msg(WorldExplorer, "TableCount(tableToCount = "..tostring(tableToCount)..")",true,DebugTxt);
		ZMC:Msg(WorldExplorer, "type(tableToCount) = "..tostring(type(tableToCount)),true,DebugTxt);
		
		if (type(tableToCount) == "table") then -- This is a table so count it and return number
			local TableCount=0;
			
			for _ in pairs(tableToCount) do
				TableCount=TableCount+1;
			end;
			
			ZMC:Msg(WorldExplorer,"Table Count = "..tostring(TableCount),true,DebugTxt);
			
			return TableCount;
		else -- This is NOT a table so return 0
			return 0;
		end;
	end;
	
	local WorldExplorer_DefaultChatFrame_DisplayTimePlayed = ChatFrame_DisplayTimePlayed; -- Stores the time played chat frame so we can supress it when we want to use it...
-----------------------------------------------------------------

function WorldExplorer:OnEvent(event)
	----------------------------------------------
	-- Default: If DebugTxt is set to true all of
	-- the debug msgs in THIS function will apear!
	----------------------------------------------
		local DebugTxt = false;
		-- DebugTxt = true; -- Uncomment this to debug
	----------------------------------------------
	
	ZMC:Msg(self, "WorldExplorer:OnEvent("..tostring(event)..") self.LoadedStatus[Initialized] = "..tostring(self.LoadedStatus["Initialized"]).." arg1 = "..tostring(arg1).. " and self.LoadedStatus[RunLevel] = "..tostring(self.LoadedStatus["RunLevel"]),true,DebugTxt);
	
	if (event == "ADDON_LOADED" and self.LoadedStatus["Initialized"] == 0 and arg1 == "WorldExplorer") then
		ZMC:Msg(self, "event == ADDON_LOADED and self.LoadedStatus[Initialized] == "..tostring(self.LoadedStatus["Initialized"]).." and arg1 == WorldExplorer",true,DebugTxt);
		
		self:Initialize();
	elseif(event == "WORLD_MAP_UPDATE" and self.LoadedStatus["Initialized"] == self.LoadedStatus["RunLevel"]) then
		ZMC:Msg(self, "event == WORLD_MAP_UPDATE and self.LoadedStatus[Initialized] == "..tostring(self.LoadedStatus["Initialized"]),true,DebugTxt);
		
		self:UpdateMap();
		self:UpdateMap();
	elseif(event == "UI_INFO_MESSAGE" and self.LoadedStatus["Initialized"] and self.LoadedStatus["Initialized"] >= 1) then -- Needed as Achievements can't be used below level 10!
		ZMC:Msg(self, "event == UI_INFO_MESSAGE and self.LoadedStatus[Initialized] == "..tostring(self.LoadedStatus["Initialized"]),true,DebugTxt);
		
		self:RequestUpdateKnownZoneList();
	end
end;

function WorldExplorer:Initialize() -- Initialize the addon
	----------------------------------------------
	-- Default: If DebugTxt is set to true all of
	-- the debug msgs in THIS function will apear!
	----------------------------------------------
		local DebugTxt = false;
		-- DebugTxt = true; -- Uncomment this to debug
	----------------------------------------------
	
	ZMC:Msg(self, "WorldExplorer:Initialize()",true,DebugTxt);
	
	self:UnregisterEvent("ADDON_LOADED");
	
	self:VarInit(); -- Initialize the variables
	
	--- Slash Command Handler
	SLASH_WorldExplorer1 = "/WE";
	SLASH_WorldExplorer2 = "/WorldExplorer";
	SlashCmdList["WorldExplorer"] = function(msg)
		self:SlashCmdHandler(msg);
	end;
	
	if not self.UpdateFrame then
		self.UpdateFrame = CreateFrame("Frame");
		self.UpdateFrame:SetScript("OnUpdate", function(frame, elapsed) WorldExplorer:Update(frame, elapsed); end);
	end;
	
	self:AddInterfaceOptions(); -- Creates and adds the options window to the Bliz interface tab
	
	if not(WorldExplorer_Options["Enabled"]) then
		ZMC:Msg(self, L["WARNING: Addon disabled!"],false,DebugTxt,true);
	end;
	
	self:TogAddon(WorldExplorer_Options["Enabled"]);
	
	self:RegisterEvent("WORLD_MAP_UPDATE"); -- Catches when the WorldMap is updated
	self:RegisterEvent("UI_INFO_MESSAGE"); -- Catches when a UI info message is recived
	-- self:RegisterEvent("ZONE_CHANGED_NEW_AREA"); -- Catches when you change areas
	
	local numOverlays = WorldExplorer:GetNumberOfMapOverlays(true); -- Returns the number of overlays that exist including blank ones.
	WorldExplorer.lastNumOverlays = numOverlays;
	
	self:InitLevel(1); -- Says that the first part of the setup is done. Need to get a zone update yet though.
end;

function WorldExplorer:VarInit() -- Initialize the variables
	----------------------------------------------
	-- Default: If DebugTxt is set to true all of
	-- the debug msgs in THIS function will apear!
	----------------------------------------------
		local DebugTxt = false;
		-- DebugTxt = true; -- Uncomment this to debug
	----------------------------------------------
	
	ZMC:Msg(self, "WorldExplorer:VarInit()",true,DebugTxt);
	
	WorldExplorer_Options = WorldExplorer_Options or {}; -- Initializes WorldExplorer_Options if it doesn't already exist
	WorldExplorer_KnownAreas = WorldExplorer_KnownAreas or {}; -- Initializes WorldExplorer_KnownAreas if it doesn't already exist
	
	self.UpdateKnownZoneListRequest = 0; -- Initializes the request for all zone overlays updates flag.
	
	if (WorldExplorer_Options["Enabled"] == nil) then -- Initializes WorldExplorer_Options["Enabled"] with the default value of self.Default_Enabled if it doesn't already exist
		WorldExplorer_Options["Enabled"] = self.Default_Enabled;
	end;
	
	if (WorldExplorer_Options["AdvancedCheck"] == nil) then -- Initializes WorldExplorer_Options["AdvancedCheck"] with the default value of self.Version if it doesn't already exist
		WorldExplorer_Options["AdvancedCheck"] = false; -- This is the default value and should only be used by people who know what they are doing. Mainly the Author but if you have read the code and know to do the correct checks you can enable this!
	end;
	
	if (WorldExplorer_Options["CurrentDBVersion"] == nil) then -- Initializes WorldExplorer_Options["CurrentDBVersion"] with the default value of self.Version if it doesn't already exist
		WorldExplorer_Options["CurrentDBVersion"] = self.Version;
	end;
	
	--------------------------------------------
	-- Store all names for all Zones & Continent
	--------------------------------------------
		self.ZoneNames = {GetMapContinents()}; -- Array that stores the Continent & Zone Names Use WorldExplorer.ZoneNames[##Continent Number##][##Zone Number##]
		
		for Key,Value in pairs(self.ZoneNames) do
			ZMC:Msg(self, "Key = "..tostring(Key)..",Value = "..tostring(Value).."", true, DebugTxt);
			
			self.ZoneNames[Key] = {GetMapZones(Key)};
			self.ZoneNames[Key]["Name"] = Value; -- Moves the name up a level
		end;
	--------------------------------------------
	
	self.UpdatedMap = false; -- Used to say if the map has been updated.
	
	self.LoadedStatus["AddonVariables"] = true;
end

function WorldExplorer:InitLevel(Level) -- Initializes the addon to the level specified (used to set specific variables etc as the addon loads up)
	----------------------------------------------
	-- Default: If DebugTxt is set to true all of
	-- the debug msgs in THIS function will apear!
	----------------------------------------------
		local DebugTxt = false;
		-- DebugTxt = true; -- Uncomment this to debug
	----------------------------------------------
	
	ZMC:Msg(self, "WorldExplorer:InitLevel(Level = "..tostring(Level)..")",true,DebugTxt);
	
	ZMC:Msg(self, "Request to initializing addon from level  = '"..tostring(self.LoadedStatus["Initialized"]).."' to level = '"..tostring(Level).."'", true, DebugTxt);
	
	if (Level == 1) and (self.LoadedStatus["Initialized"] == 0) then
		self.LoadedStatus["Initialized"] = Level; -- Updates addon initialiation to specified level
		
		self.Dongle:ScheduleTimer("WorldExplorer_StartupZoneUpdate", function() self:RequestUpdateKnownZoneList(2); end, 2); -- Requests the time the player has played and when it gets the time it does a full update of all points
	elseif (Level == 2) and (self.LoadedStatus["Initialized"] == 1) then
		self.LoadedStatus["Initialized"] = Level; -- Updates addon initialiation to specified level
		
		self:InitLevel(3);
	elseif (Level == 3) and (self.LoadedStatus["Initialized"] == 2) then
		self.LoadedStatus["Initialized"] = Level; -- Updates addon initialiation to specified level
		
		self:MapUpdated(); -- Runs when the map has finished updating and is ready to get the Overlay info from it.
		
		if (not(WorldExplorer_Options["CurrentDBVersion"] == self.Version) or not(WorldExplorer_Options["LastUpdateDBVersion"] == self.Version)) then -- Ether the current db doesn't match the current version or there hasn't been an update to the db since the last update
			-- All old DB are currently compatable with newer ones so all SHOULD be OK (I think!)
			
			if not(WorldExplorer_Options["LastUpdateDBVersion"]) then -- There isn't a last update db version so set it to the version the db is currently
				WorldExplorer_Options["LastUpdateDBVersion"] = WorldExplorer_Options["CurrentDBVersion"];
			end;
			
			if (WorldExplorer_Options["CurrentDBVersion"] < self.Version) then
				ZMC:Msg(self, "WARNING: You have updated WorldExplorer to a new version. If you have any trouble try resetting the settings to default using the command '"..tostring(SLASH_WorldExplorer1).." reset'.", false, DebugTxt, true); -- Warn the user that they have updated to a newer version of WorldExplorer so if they have problems they should reset all the WorldExplorer settings
			elseif (WorldExplorer_Options["CurrentDBVersion"] > self.Version) then
				ZMC:Msg(self, "WARNING: You have DOWNGRADED WorldExplorer to a version OLDER than your Database! This is NOT adviced as the DB structure MAY have changed... If you have any trouble try resetting the settings to default using the command '"..tostring(SLASH_WorldExplorer1).." resetALL'.", false, DebugTxt, true); -- Warn the user that they have DOWNGRADED to a older version of WorldExplorer than there DB so if they have problems they should reset all the WorldExplorer settings
			end;
		elseif (WorldExplorer_Updater) then
			ZMC:Msg(self, "WARNING: You have an old WorldExplorer update addon installed that isn't needed... Please uninstall WorldExplorer and delete the addon's folders 'WorldExplorer' & 'WorldExplorer_Updater' and download the newest version of WorldExplorer from Curse.com to ensure it all runs smoothly! ;-)", false, DebugTxt, true);
			
			if not(WorldExplorer_Admin) then -- Ensure the Admin module isn't running (as we may need the update module for that
				DisableAddOn("WorldExplorer_Updater"); -- Disables this module the next time the UI is restarted as we are done with it now.
			end;
		end;
		
		if (WorldExplorer_Options.UpdateDBComplete) then
			WorldExplorer_Options.UpdateDBComplete = nil; -- Remove this as it isn't needed.
		end;
		
		ZMC:Msg(self, L["Loaded"]..". "..L["For help type"].." "..tostring(SLASH_WorldExplorer1).." "..L["or"].." "..tostring(SLASH_WorldExplorer2));
	else
		ZMC:Msg(self, "Addon's current level ("..tostring(self.LoadedStatus["Initialized"])..") doesn't match expected level to progress to level ("..tostring(Level)..") or requested level isn't known... Aborting!'", false, DebugTxt, true);
	end;
end;

function WorldExplorer:SlashCmdHandler(msg) -- Slash Command Handler
	----------------------------------------------
	-- Default: If DebugTxt is set to true all of
	-- the debug msgs in THIS function will apear!
	----------------------------------------------
		local DebugTxt = false;
		-- DebugTxt = true; -- Uncomment this to debug
	----------------------------------------------
	
	ZMC:Msg(self, "Initialize",true,DebugTxt);
	ZMC:Msg(self, "msg = '"..tostring(msg).."'",true,DebugTxt);
	
	ZMC:Msg(self, "strlower(strsub(msg,1,8) = "..tostring(strlower(strsub(msg,1,8))),true,DebugTxt);
	
	if (msg == nil or msg == "") then
		if (WorldExplorer_Options["Enabled"]) then
			ZMC:Msg(self, L["is Enabled"],false,DebugTxt);
		else
			ZMC:Msg(self, L["is Disabled"],false,DebugTxt,true);
		end;
		
		ZMC:Msg(self, L["Use"].." '"..tostring(SLASH_WorldExplorer1).." options' "..L["to open up the Addon's Options screen"], false, DebugTxt);
	elseif ((strlower(strsub(msg,1,7)) == "options") or (strlower(strsub(msg,1,6)) == "config")) then -- This is the macro checking in...
		ZMC:Msg(self, L["Opening WorldExplorer Options Panel"]);
		
		InterfaceOptionsFrame_OpenToCategory("WorldExplorer");
	elseif(strlower(strsub(msg,1,8)) == "resetall") then -- This is the macro checking in...
		ZMC:Msg(self, "Reloading Defaults and DELETING ALL DATA!!!");
		
		StaticPopup_Show ("ResetALLWorldExplorersSettings"); -- Shows the Reset WorldExplorer Settings warning question dialog box
	elseif(strlower(strsub(msg,1,5)) == "reset") then -- This is the macro checking in...
		ZMC:Msg(self, L["Reloading Defaults"]);
		
		StaticPopup_Show ("ResetWorldExplorersSettings"); -- Shows the Reset WorldExplorer Settings warning question dialog box
	elseif(strlower(strsub(msg,1,6)) == "enable") then -- This is the macro checking in...
		ZMC:Msg(self, L["Enableing WorldExplorer"]);
		
		self:TogAddon(true);
	elseif(strlower(strsub(msg,1,7)) == "disable") then -- This is the macro checking in...
		ZMC:Msg(self, L["Disabling WorldExplorer"]);
		
		self:TogAddon(false);
	else
		ZMC:Msg(self, "Message not known = '"..tostring(msg).."'",true,Debugtxt);
	end;
end;

function WorldExplorer:Update(frame, elapsed) -- Runs all the time (thousands of times a second!)
	----------------------------------------------
	-- Default: If DebugTxt is set to true all of
	-- the debug msgs in THIS function will apear!
	----------------------------------------------
		local DebugTxt = false;
		-- DebugTxt = true; -- Uncomment this to debug
	----------------------------------------------
	
	-- ZMC:Msg(self, "WorldExplorer:Update()",true,DebugTxt);
	
	if not((WorldExplorer_Options["Enabled"]) and (self.LoadedStatus["Initialized"] == self.LoadedStatus["RunLevel"])) then -- Addon is disabled so exit
		return;
	end;
	
	if (self.UpdatedMap) then -- When the map has been updated this will run.
		self:MapUpdated(); -- Runs when the map has finished updating and is ready to get the Overlay info from it.
		
		self.UpdatedMap = false; -- Sets it back to false to wait for the next update.
	end;	
end;

function WorldExplorer:AddInterfaceOptions() -- Creates and adds the options window to the Bliz interface tab
	----------------------------------------------
	-- Default: If DebugTxt is set to true all of
	-- the debug msgs in THIS function will apear!
	----------------------------------------------
		local DebugTxt = false;
		-- DebugTxt = true; -- Uncomment this to debug
	----------------------------------------------
	
	ZMC:Msg(self, "WorldExplorer:AddInterfaceOptions()",true,DebugTxt);
	
	if (WorldExplorer_Options.RepairInterfaceOptionsFrameStrataTog) then
		-- ZMC:Msg(self, "Repair InterfaceOptionsFrame Strata ENABLED", true,DebugTxt);
		InterfaceOptionsFrame:SetFrameStrata(WorldExplorer_Options.RepairInterfaceOptionsFrameStrata); -- Repair InterfaceOptionsFrame Strata as other addon's make it above dialogs!!! You know who you are "LibBetterBlizzOptions"
	-- else
		-- ZMC:Msg(self, "Repair InterfaceOptionsFrame Strata DISABLED", true,DebugTxt);
	end;
	
	local sVersion; -- Sets the string for version infomation
	if (self.sVersionType == "ALPHA") then -- If this is a ALPHA version then
		sVersion = ZMC.COLOUR_RED..L["Version"]..": "..tostring(self.Version).." "..L["ALPHA"]..ZMC.COLOUR_CLOSE
	elseif (self.sVersionType == "BETA") then -- If this is a BETA version then
		sVersion = ZMC.COLOUR_ORANGE..L["Version"]..": "..tostring(self.Version).." "..L["BETA"]..ZMC.COLOUR_CLOSE
	else
		sVersion = self.ZMC_DefaultColour1..L["Version"]..": "..tostring(self.Version)..ZMC.COLOUR_CLOSE
	end;
	
	self.ResetVisable = false; -- Ensures the reset button is disabled!
	
	---------------------------------------------------------
	-- Reset Settings Static Popup Dialog
	---------------------------------------------------------
		StaticPopupDialogs["ResetWorldExplorersSettings"] = {
			text = L["Are you sure you want to reset ALL WorldExplorer Settings to default?"],
			button1 = "Yes",
			button2 = "No",
			OnAccept = function()
				self:ResetAllSettings(); -- Deletes all settings and restarts UI
			end,
			OnCancel = function()
				self.ResetVisable = false; -- Disables the button again
				LibStub("AceConfigRegistry-3.0"):NotifyChange(self.Name) -- Refreshes Options Window
			end,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
		}
	---------------------------------------------------------
	
	---------------------------------------------------------
	-- Reset ALL Settings Static Popup Dialog
	---------------------------------------------------------
		StaticPopupDialogs["ResetALLWorldExplorersSettings"] = {
			text = "THIS WILL DELETE ALL GATHERED DATA! Are you sure you want to reset ALL WorldExplorer Settings to default AND Delete ALL data?",
			button1 = "Yes",
			button2 = "No",
			OnAccept = function()
				self:ResetAllSettings(true); -- Deletes all settings and restarts UI
			end,
			OnCancel = function()
				self.ResetVisable = false; -- Disables the button again
				LibStub("AceConfigRegistry-3.0"):NotifyChange(self.Name) -- Refreshes Options Window
			end,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
		}
	---------------------------------------------------------
	
	local Options = {
		type = "group",
		childGroups = "tab",
		name = "WorldExplorer("..self.ZMC_DefaultColour1.."Zasurus"..ZMC.COLOUR_CLOSE..") "..sVersion,
		desc = L["These options allow you to configure various aspects of WorldExplorer."],
		args = {
			Enabled = { -- Creates and Sets Up the Addon Enable Toggle
				type = "toggle",
				name = L["WorldExplorer Enabled (KeyBinding Available)"],
				desc = L["Turns WorldExplorer On/Off. If you don't plan to use it for a long time or just don't want to use it on this toon your better disabling it via the 'Addon' menu on the toon selection screen to save memory."],
				order = 1,
				get = function(info)
					return WorldExplorer_Options["Enabled"];
				end,
				set = function(info, value)
					self:TogAddon(value);
				end,
				width = "full",
			},
			--[[Other options
			Drop = { -- Creates and Sets Up the Addon Drop Toggle
				type = "toggle",
				name = L["Drop Breadcrumbs (KeyBinding Available)"],
				desc = L["Drop WorldExplorer On/Off. This starts and stops the dropping of breadcrumbs."],
				order = 2,
				get = function(info)
					return WorldExplorer_Options["Dropping"];
				end,
				set = function(info, value)
					self:TogBreadDrop(value);
				end,
				width = "full",
			},
			HideTog = { -- Creates and Sets Up the Addon Hide Toggle
				type = "toggle",
				name = L["Hide Breadcrumbs (KeyBinding Available)"],
				desc = L["Hides or Unhides the breadcrumbs. This doesn't stop the dropping just hides them."],
				order = 3,
				get = function(info)
					return WorldExplorer_Options["Hidden"];
				end,
				set = function(info, value)
					self:TogHideBread(value);
				end,
				width = "full",
			},
			ResetOnReload = { -- Creates and Sets Up the Addon "Reset points on reload/load" Toggle
				type = "toggle",
				name = L["Reset Trail on Load/Reload"],
				desc = L["Enable to start a fresh trail every time the addon is loaded/reloaded."],
				order = 4,
				get = function(info)
					return WorldExplorer_Options["ResetOnReload"];
				end,
				set = function(info, value)
					WorldExplorer_Options["ResetOnReload"] = value;
				end,
				width = "full",
			},
			DontDropWhenDead = { -- Creates and Sets Up the Addon "Don't Drop when Dead" Toggle
				type = "toggle",
				name = L["Don't Drop Breadcrumbs when Dead (KeyBinding Available)"],
				desc = L["Enable to stops dropping WorldExplorer when you die so you don't have a useless trail from the grave and lose your berings!"],
				order = 5,
				get = function(info)
					return WorldExplorer_Options["DontDropWhenDead"];
				end,
				set = function(info, value)
					self:TogDropWhenDead(value);
				end,
				width = "full",
			},
			DistBetweenPoints = { -- Creates and Sets Up the DistBetweenPoints slider
				type = "range",
				name = L["Space Between Points"],
				desc = L["This slider specifies how close together the points are that make up the line. Closer together gives a better looking line but makes it shorter."].."\n\n"..self.ZMC_DefaultColour1..L["NOTE: This will also affect the length of the line so you may need to also adjust the number of points used for the line."].."\n\n"..L["Also this will only affect new WorldExplorer and not your existing trail."].."|r",
				order = 6,
				min = 1,
				max = 100,
				step = 1,
				get = function(info)
					return WorldExplorer_Options["DistBetweenPoints"];
				end,
				set = function(info, value)
					WorldExplorer_Options["DistBetweenPoints"] = value;
				end,
				
			},
			NumberOfPoints = { -- Creates and Sets Up the NumberOfPoints slider
				type = "range",
				name = L["Number of Points"],
				desc = L["This slider specifies how many points are used to create the line and therefore how long it will be."].."\n\n"..self.ZMC_DefaultColour1..L["NOTE: Use this and the spacing one to crate the line you want."].."\n\n"..L["ALSO this will reset your WorldExplorer(remove your trail)! So ensure you make a note of which way you have come from."].."|r\n\n"..self.ZMC_DefaultErrorColour..L["WARNING! Setting this higher MAY slow the game down!"].."|r",
				order = 7,
				min = 2, -- Can't be <2!
				max = 100,
				step = 1,
				get = function(info)
					return WorldExplorer_Options["NumPoints"];
				end,
				set = function(info, value)
					if (WorldExplorer_Options["NumPoints"] == value) then -- If no change then don't do anything!
						ZMC:Msg(self, "WorldExplorer_Options.NumPoints == value",true,DebugTxt);
						return;
					end;
					
					WorldExplorer_Options["NumPoints"] = value; -- Set the number of points to the ones specified
					
					self:GeneratePoints(); -- Recreate the new number of points
					
					if (HudMapCluster) then
						ZMC:Msg(self, "HudMapCluster Exists!",true,DebugTxt);
						
						if (HudMapCluster:IsShown()) then
							ZMC:Msg(self, "and HudMapCluster is Shown!",true,DebugTxt);
							
							HudMapCluster:Hide(); -- Hide the SexyMap's HUD
							HudMapCluster:Show(); -- Now Show the SexyMap's HUD again to reset everything.
						-- else
							-- ZMC:Msg(self, "and HudMapCluster is NOT Shown!",true,DebugTxt);
						end;
					-- else
						-- ZMC:Msg(self, "HudMapCluster Does NOT Exist!",true,DebugTxt);
					end;
				end,
			},
			LastNumToHide = { -- Creates and Sets Up the LastNumToHide slider
				type = "range",
				name = L["Hide Closest # Points"],
				desc = L["This slider specifies how many of the closest points to the player (if any) should be hidden."].."\n\n"..L["This is to help prevent the players arrow from being covered."],
				order = 8,
				min = 1,
				max = 50,
				step = 1,
				get = function(info)
					return WorldExplorer_Options["LastNumToHide"];
				end,
				set = function(info, value)
					WorldExplorer_Options.LastNumToHide = value;
					
					self:UpdateGradiants(); -- Updates the gradiants with any new colours/transparancys
					
					self:UpdatePoints();
				end,
			},
			---------------------------------------------------------------------------------------------------------------------------------
			-- Minimap
			---------------------------------------------------------------------------------------------------------------------------------
				MinimapGroup = {
					type = "group",
					name = "Minimap",
					order = 9,
					args = {
						---------------------------------------------------------------------------------------------------------------------------------
						-- First Point's Colour/Opacity for the Minimap
						---------------------------------------------------------------------------------------------------------------------------------
							MinimapColour2 = { -- Creates and Sets Up the Last Point's Colour/Opacity for the Minimap
								type = "color",
								name = L["to"],
								desc = L["This sets the Colour & Opacity level of the last point that make up the WorldExplorer when on the Minimap."],
								order = 1,
								hasAlpha = true,
								width = "half",
								get = function(info)
									local Red = WorldExplorer_Options.MinimapColour2.Red;
									local Green = WorldExplorer_Options.MinimapColour2.Green;
									local Blue = WorldExplorer_Options.MinimapColour2.Blue;
									local TextureOpacity = WorldExplorer_Options.MinimapColour2.TextureOpacity;
									
									return Red, Green, Blue, TextureOpacity;
								end,
								set = function(info, Red, Green, Blue, TextureOpacity)
									ZMC:Msg(self, "MinimapColour2 - setFunc(Red = "..tostring(Red)..", Green = "..tostring(Green)..", Blue = "..tostring(Blue)..", TextureOpacity = "..tostring(TextureOpacity)..")", true, DebugTxt);
									WorldExplorer_Options.MinimapColour2.Red = Red;
									WorldExplorer_Options.MinimapColour2.Green = Green;
									WorldExplorer_Options.MinimapColour2.Blue = Blue;
									WorldExplorer_Options.MinimapColour2.TextureOpacity = TextureOpacity;
									
									self:UpdateGradiants(); -- Updates the gradiants with any new colours/transparancys
									
									self:UpdatePoints(); -- Updates the Colour/Opacity and Size of all of the points
								end,
								hidden = function()
									ZMC:Msg(self, "return not(WorldExplorer_Options.MinimapGradiant("..tostring(WorldExplorer_Options.MinimapGradiant).."));", true, DebugTxt);
									return not(WorldExplorer_Options.MinimapGradiant);
								end,
							},
							MinimapColour1 = { -- Creates and Sets Up the First Point's Colour/Opacity for the Minimap
								type = "color",
								name = L["Colour/Opacity (Minimap)"],
								desc = L["This sets the Colour & Opacity level of the first point (or all if gradiant is disabled) that make up the WorldExplorer when on the Minimap."],
								order = 2,
								hasAlpha = true,
								width = "double",
								get = function(info)
									local Red = WorldExplorer_Options.MinimapColour1.Red;
									local Green = WorldExplorer_Options.MinimapColour1.Green;
									local Blue = WorldExplorer_Options.MinimapColour1.Blue;
									local TextureOpacity = WorldExplorer_Options.MinimapColour1.TextureOpacity;
									
									return Red, Green, Blue, TextureOpacity;
								end,
								set = function(info, Red, Green, Blue, TextureOpacity)
									ZMC:Msg(self, "MinimapColour1 - setFunc", true, DebugTxt);
									WorldExplorer_Options.MinimapColour1.Red = Red;
									WorldExplorer_Options.MinimapColour1.Green = Green;
									WorldExplorer_Options.MinimapColour1.Blue = Blue;
									WorldExplorer_Options.MinimapColour1.TextureOpacity = TextureOpacity;
									
									self:UpdateGradiants(); -- Updates the gradiants with any new colours/transparancys
									
									self:UpdatePoints(); -- Updates the Colour/Opacity and Size of all of the points
								end,
							},
							MinimapGradiant = { -- Creates and Sets Up the Minimap Gradiant Toggle
								type = "toggle",
								name = L["Gradiant"],
								desc = L["Gradually change the colour/transparancy between the first and last point on the Minimap"],
								order = 3,
								get = function(info)
									return WorldExplorer_Options["MinimapGradiant"];
								end,
								set = function(info, value)
									self:TogMiniGrad(value);
								end,
								width = "full",
							},
							-- if (WorldExplorer_Options.MinimapGradiant) then -- Minimap Gradiant is disabled so disable options
								-- self.OptionsPanel.MinimapColour2:Enable(); -- Enable the colour picker for the last point as it's needed now.
								-- self.OptionsPanel.MinimapColour2:Show(); -- Show the colour picker for the last point as it's needed now.
								-- panel.MinimapColour1:SetPoint("TOPLEFT", panel.MinimapColour2, "TOPRIGHT", 15, 0); -- Move the First colour picker to the right of the second one
							-- else
								-- self.OptionsPanel.MinimapColour2:Disable(); -- Disable the colour picker for the last point as it's not needed any more.
								-- panel.MinimapColour2:Hide();
								-- panel.MinimapColour1:SetPoint("TOPLEFT", panel.MinimapColour2, "TOPLEFT", 0, 0);
							-- end;
						---------------------------------------------------------------------------------------------------------------------------------
						
						---------------------------------------------------------------------------------------------------------------------------------
						-- Minimap Size Settings
						---------------------------------------------------------------------------------------------------------------------------------
							MinimapSizeOfPoints2 = { -- Creates and Sets Up the MinimapSizeOfPoints2 slider
								type = "range",
								name = L["Last Point Size to -->"],
								desc = L["This slider specifies the size of the first point on the minimap is."],
								order = 4,
								min = 1,
								max = 50,
								step = 1,
								get = function(info)
									return WorldExplorer_Options["MinimapSizeOfPoints2_Width"];
								end,
								set = function(info, value)
									WorldExplorer_Options.MinimapSizeOfPoints2_Width = value;
									WorldExplorer_Options.MinimapSizeOfPoints2_Height = value;
									
									self:UpdateGradiants(); -- Updates the gradiants with any new colours/transparancys
									
									self:UpdatePoints();
								end,
								hidden = function()
									ZMC:Msg(self, "return not(WorldExplorer_Options.MinimapSizeGradiant("..tostring(WorldExplorer_Options.MinimapSizeGradiant).."));", true, DebugTxt);
									return not(WorldExplorer_Options.MinimapSizeGradiant);
								end,
							},
							MinimapSizeOfPoints1 = { -- Creates and Sets Up the MinimapSizeOfPoints1 slider
								type = "range",
								name = L["Size(Minimap)"],
								desc = L["This slider specifies how big the last point on the minimap is."],
								order = 5,
								min = 1,
								max = 50,
								step = 1,
								get = function(info)
									return WorldExplorer_Options["MinimapSizeOfPoints1_Width"];
								end,
								set = function(info, value)
									WorldExplorer_Options.MinimapSizeOfPoints1_Width = value;
									WorldExplorer_Options.MinimapSizeOfPoints1_Height = value;
									
									self:UpdateGradiants(); -- Updates the gradiants with any new colours/transparancys
									
									self:UpdatePoints();
								end,
							},
							MinimapSizeGradiant = { -- Creates and Sets Up the Minimap Size Gradiant Toggle
								type = "toggle",
								name = L["Gradiant"],
								desc = L["Gradually change the size between the first and last point on the Minimap"],
								order = 6,
								get = function(info)
									return WorldExplorer_Options["MinimapSizeGradiant"];
								end,
								set = function(info, value)
									self:TogMinimapSizeGrad(value);
								end,
								width = "full",
							},
							-- if (WorldExplorer_Options.MinimapSizeGradiant) then -- Minimap Size Gradiant is disabled so disable options
								-- self.OptionsPanel.MinimapSizeOfPoints2:Enable(); -- Enable the size slider for the last point as it's needed now.
								-- self.OptionsPanel.MinimapSizeOfPoints2:Show(); -- Show the size slider for the last point as it's needed now.
								-- panel.MinimapSizeOfPoints1:SetPoint("TOPLEFT", panel.MinimapSizeOfPoints2, "TOPRIGHT", 15, 0); -- Move the First size slider to the right of the second one
							-- else
								-- self.OptionsPanel.MinimapSizeOfPoints2:Disable(); -- Disable the slider for the last point as it's not needed any more.
								-- panel.MinimapSizeOfPoints2:Hide();
								-- panel.MinimapSizeOfPoints1:SetPoint("TOPLEFT", panel.MinimapSizeOfPoints2, "TOPLEFT", 0, 0);
							-- end;
							
							-- if (not(HudMapCluster)) then -- The SexyMap Minimap doesn't exist so disable options
								-- panel.MinimapSizeGradiant:Disable();
							-- end;
						---------------------------------------------------------------------------------------------------------------------------------
					},
				},
			---------------------------------------------------------------------------------------------------------------------------------
			
			
			
			---------------------------------------------------------------------------------------------------------------------------------
			-- SexyMap HUD
			---------------------------------------------------------------------------------------------------------------------------------
				HUDGroup = {
					type = "group",
					name = "SexyMapHUD",
					order = 10,
					args = {
						---------------------------------------------------------------------------------------------------------------------------------
						-- First Point's Colour/Opacity for the HUD
						---------------------------------------------------------------------------------------------------------------------------------
							HUDColour2 = { -- Creates and Sets Up the Last Point's Colour/Opacity for the HUD
								type = "color",
								name = L["to"],
								desc = L["This sets the Colour & Opacity level of the last point that make up the WorldExplorer when on the Minimap."],
								order = 1,
								hasAlpha = true,
								width = "half",
								get = function(info)
									local Red = WorldExplorer_Options.HUDColour2.Red;
									local Green = WorldExplorer_Options.HUDColour2.Green;
									local Blue = WorldExplorer_Options.HUDColour2.Blue;
									local TextureOpacity = WorldExplorer_Options.HUDColour2.TextureOpacity;
									
									return Red, Green, Blue, TextureOpacity;
								end,
								set = function(info, Red, Green, Blue, TextureOpacity)
									ZMC:Msg(self, "HUDColour2 - setFunc", true, DebugTxt);
									WorldExplorer_Options.HUDColour2.Red = Red;
									WorldExplorer_Options.HUDColour2.Green = Green;
									WorldExplorer_Options.HUDColour2.Blue = Blue;
									WorldExplorer_Options.HUDColour2.TextureOpacity = TextureOpacity;
									
									self:UpdateGradiants(); -- Updates the gradiants with any new colours/transparancys
									
									self:UpdatePoints(); -- Updates the Colour/Opacity and Size of all of the points
								end,
								hidden = function()
									ZMC:Msg(self, "return not(WorldExplorer_Options.HUDGradiant("..tostring(WorldExplorer_Options.HUDGradiant).."));", true, DebugTxt);
									return not(WorldExplorer_Options.HUDGradiant);
								end,
							},
							HUDColour1 = { -- Creates and Sets Up the First Point's Colour/Opacity for the HUD
								type = "color",
								name = L["Colour/Opacity (Minimap)"],
								desc = L["This sets the Colour & Opacity level of the first point (or all if gradiant is disabled) that make up the WorldExplorer when on the Minimap."],
								order = 2,
								hasAlpha = true,
								width = "double",
								get = function(info)
									local Red = WorldExplorer_Options.HUDColour1.Red;
									local Green = WorldExplorer_Options.HUDColour1.Green;
									local Blue = WorldExplorer_Options.HUDColour1.Blue;
									local TextureOpacity = WorldExplorer_Options.HUDColour1.TextureOpacity;
									
									return Red, Green, Blue, TextureOpacity;
								end,
								set = function(info, Red, Green, Blue, TextureOpacity)
									ZMC:Msg(self, "HUDColour1 - setFunc", true, DebugTxt);
									WorldExplorer_Options.HUDColour1.Red = Red;
									WorldExplorer_Options.HUDColour1.Green = Green;
									WorldExplorer_Options.HUDColour1.Blue = Blue;
									WorldExplorer_Options.HUDColour1.TextureOpacity = TextureOpacity;
									
									self:UpdateGradiants(); -- Updates the gradiants with any new colours/transparancys
									
									self:UpdatePoints(); -- Updates the Colour/Opacity and Size of all of the points
								end,
							},
							HUDGradiant = { -- Creates and Sets Up the HUD Gradiant Toggle
								type = "toggle",
								name = L["Gradiant"],
								desc = L["Gradually change the colour/transparancy between the first and last point on the HUD"],
								order = 3,
								get = function(info)
									return WorldExplorer_Options["HUDGradiant"];
								end,
								set = function(info, value)
									self:TogHUDGrad(value);
								end,
								width = "full",
							},
						---------------------------------------------------------------------------------------------------------------------------------
						
						
						---------------------------------------------------------------------------------------------------------------------------------
						-- HUD Size Settings
						---------------------------------------------------------------------------------------------------------------------------------
							HUDSizeOfPoints2 = { -- Creates and Sets Up the HUDSizeOfPoints2 slider
								type = "range",
								name = L["Last Point Size to -->"],
								desc = L["This slider specifies how big the points on the SexyMapHUD are."],
								order = 4,
								min = 1,
								max = 50,
								step = 1,
								get = function(info)
									return WorldExplorer_Options["HUDSizeOfPoints2_Width"];
								end,
								set = function(info, value)
									WorldExplorer_Options.HUDSizeOfPoints2_Width = value;
									WorldExplorer_Options.HUDSizeOfPoints2_Height = value;
									
									self:UpdateGradiants(); -- Updates the gradiants with any new colours/transparancys
									
									self:UpdatePoints();
								end,
								hidden = function()
									ZMC:Msg(self, "return not(WorldExplorer_Options.HUDSizeGradiant("..tostring(WorldExplorer_Options.HUDSizeGradiant).."));", true, DebugTxt);
									return not(WorldExplorer_Options.HUDSizeGradiant);
								end,
							},
							MinimapSizeOfPoints1 = { -- Creates and Sets Up the MinimapSizeOfPoints1 slider
								type = "range",
								name = L["Size(SexyMapHUD)"],
								desc = L["This slider specifies the size of the first point (or all if Gradian is diabled) on the SexyMapHUD."],
								order = 5,
								min = 1,
								max = 50,
								step = 1,
								get = function(info)
									return WorldExplorer_Options["HUDSizeOfPoints1_Width"];
								end,
								set = function(info, value)
									WorldExplorer_Options.HUDSizeOfPoints1_Width = value;
									WorldExplorer_Options.HUDSizeOfPoints1_Height = value;
									
									self:UpdateGradiants(); -- Updates the gradiants with any new colours/transparancys
									
									self:UpdatePoints();
								end,
							},
							MinimapSizeGradiant = { -- Creates and Sets Up the HUD Size Gradiant Toggle
								type = "toggle",
								name = L["Gradiant"],
								desc = L["Gradually change the size between the first and last point on the SexyMapHUD"],
								order = 6,
								get = function(info)
									return WorldExplorer_Options["HUDSizeGradiant"];
								end,
								set = function(info, value)
									self:TogHUDSizeGrad(value);
								end,
								width = "full",
							},
						---------------------------------------------------------------------------------------------------------------------------------	
					},
				},
			---------------------------------------------------------------------------------------------------------------------------------
			
			
			
			---------------------------------------------------------------------------------------------------------------------------------
			-- Others
			---------------------------------------------------------------------------------------------------------------------------------
				OtherGroup = {
					type = "group",
					name = "Other Settings",
					order = 11,
					args = {
						EnableReset = { -- Creates and Sets Up the HUD Size Gradiant Toggle
							type = "toggle",
							name = L["Enable Reset"],
							desc = L["This enables the reset button (so you don't click it by acident!)"],
							order = 1,
							get = function(info)
								return self.ResetVisable;
							end,
							set = function(info, value)
								self.ResetVisable = value;
							end,
						},
						ResetButton = { -- Creates and Sets up the Reset Settings Button
							type = "execute",
							name = L["Reset Settings"],
							desc = L["This resets ALL WorldExplorer settings back to there defaults (Like a fresh install)!"].."\n\n"..ZMC.COLOUR_ORANGE..L["WARNING! This will reload the UI!"]..ZMC.COLOUR_CLOSE,
							order = 2,
							func = function(info)
								StaticPopup_Show ("ResetWorldExplorersSettings"); -- Shows the Reset WorldExplorer Settings warning question dialog box
							end,
							disabled = function(info)
								return not(self.ResetVisable);
							end,
						},
						RepairInterfaceStrata = { -- Creates and Sets Up the Interface Strata Repair Toggle
							type = "toggle",
							name = L["Repair Interface Strata"],
							desc = L["This repairs the InterfaceOptionsFrame's Strata back to: '"]..ZMC.COLOUR_RED..tostring(WorldExplorer_Options.RepairInterfaceOptionsFrameStrata)..ZMC.COLOUR_CLOSE..L["' default normally '"]..ZMC.COLOUR_ORANGE..tostring(self.Default_RepairInterfaceOptionsFrameStrata)..ZMC.COLOUR_CLOSE..L["') as some addon's (you know who you are 'LibBetterBlizzOptions-1.0') make it so high no other frame can be ontop of it!"].."\n\n"..ZMC.COLOUR_ORANGE..L["The UI will need reloading for this to take affect!"]..ZMC.COLOUR_CLOSE,
							order = 3,
							width = "double",
							get = function(info)
								return WorldExplorer_Options.RepairInterfaceOptionsFrameStrataTog;
							end,
							set = function(info, value)
								WorldExplorer_Options.RepairInterfaceOptionsFrameStrataTog = value;
							end,
						},
					},
				},
			--]]-------------------------------------------------------------------------------------------------------------------------------
		},
	};
	
	------------------------------------------------------------------------------
	-- Uses the options table just created to 
	------------------------------------------------------------------------------
		LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(self.Name, Options) -- Registers the "options" table ready to be used
		self.BCOptionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("WorldExplorer", "WorldExplorer") -- Refreshes the open window (encase an external function changes the "options" table)
	------------------------------------------------------------------------------
end;

function WorldExplorer:TogAddon(value) -- Enables or Disables WorldExplorer
	----------------------------------------------
	-- Default: If DebugTxt is set to true all of
	-- the debug msgs in THIS function will apear!
	----------------------------------------------
		local DebugTxt = false;
		-- DebugTxt = true; -- Uncomment this to debug
	----------------------------------------------
	
	ZMC:Msg(self, "WorldExplorer:TogAddon(value = "..tostring(value)..")",true,DebugTxt);
	
	if (value == nil) then -- No value has been passed so just invert the current one
		if WorldExplorer_Options["Enabled"] == true then
			value = false;
		else
			value = true;
		end;
	end;
	
	if (value == true) then -- True passed so enable addon
		if (WorldExplorer_Options["Enabled"] == false) then
			ZMC:Msg(self, L["Enabled."],false,DebugTxt);
		end;
		
		WorldExplorer_Options["Enabled"] = true;
		
		LibStub("AceConfigRegistry-3.0"):NotifyChange(self.Name) -- Updates the options window
	elseif (value == false) then -- False passed so enable addon
		WorldExplorer_Options["Enabled"] = false;
		
		LibStub("AceConfigRegistry-3.0"):NotifyChange(self.Name) -- Updates the options window
		
		ZMC:Msg(self, L["Disabled."],false,DebugTxt,true);
	else
		ZMC:Msg(self, "ERROR value not specified",true,DebugTxt,true);
	end;
end;

function WorldExplorer:ResetAllSettings() -- Deletes all settings and restarts UI
	----------------------------------------------
	-- Default: If DebugTxt is set to true all of
	-- the debug msgs in THIS function will apear!
	----------------------------------------------
		local DebugTxt = false;
		-- DebugTxt = true; -- Uncomment this to debug
	----------------------------------------------
	
	ZMC:Msg(self, "WorldExplorer:ResetAllSettings()",true,DebugTxt);
	
	self:TogAddon(false); -- Disables WorldExplorer to ensure it doesn't error
	WorldExplorer_Options = nil; -- Wipes the settings
	
	ReloadUI(); -- Reloads the UI so WorldExplorer reinitialize correctly
end;

function WorldExplorer:UpdateMap() -- Kicks off when the world map is updated
	----------------------------------------------
	-- Default: If DebugTxt is set to true all of
	-- the debug msgs in THIS function will apear!
	----------------------------------------------
		local DebugTxt = false;
		-- DebugTxt = true; -- Uncomment this to debug
	----------------------------------------------
	
	ZMC:Msg(self, "WorldExplorer:UpdateMap()",true,DebugTxt);
	
	self.UpdatedMap = true; -- Says that the map has updated
end;

function WorldExplorer:GetNumberOfMapOverlays(bBlanks) -- Returns the number of overlays that exist.
	----------------------------------------------
	-- Default: If DebugTxt is set to true all of
	-- the debug msgs in THIS function will apear!
	----------------------------------------------
	local DebugTxt = false;
	-- DebugTxt = true; -- Uncomment this to debug
	----------------------------------------------
	
	ZMC:Msg(self, "WorldExplorer:GetNumberOfMapOverlays(bBlanks = "..tostring(bBlanks)..")",true,DebugTxt);
	
	local numBlank = 0; -- Used to store the number of blank overlays (to take off the number of good overlays
	for i=1, 999 do -- Loops though all of the posible overlays (999 is ment to be WAY more than there ever can be to ensure we find the true number)
		local tname,tw,th,ofx,ofy = GetMapOverlayInfo(i) -- Pulls back this overlays details
		if not(tname) then -- Checks if this overlay exists
			ZMC:Msg(self, "Number of Overlays = "..tostring(i-1).." and there where '"..tostring(numBlank).."' blank overlays leaving '"..tostring(i-1-numBlank), true, DebugTxt);
			
			if (bBlanks) then -- We want to return the total number including blanks
				return i-1; -- If it doesn't exist then return the LAST overlay number as that was the last one!
			else -- We only want the number of none blank overlays.
				return i-1-numBlank; -- If it doesn't exist then return the LAST overlay number as that was the last one!
			end;
		elseif (tname == "") then -- No texture for this overlay so likely blank (not sure why!)
			numBlank = numBlank + 1; -- Increase the number of blank overlays by 1
		end;
	end;
end;

function WorldExplorer:MapUpdated() -- Runs when the map has finished updating and is ready to get the Overlay info from it. If variable "bBlanks" is true it will return total including blanks!
	----------------------------------------------
	-- Default: If DebugTxt is set to true all of
	-- the debug msgs in THIS function will apear!
	----------------------------------------------
		local DebugTxt = false;
		-- DebugTxt = true; -- Uncomment this to debug
	----------------------------------------------
	
	ZMC:Msg(self, "WorldExplorer:MapUpdated()",true,DebugTxt);
	
	----------------------------------------------------------
	-- Get the number of overlays
	----------------------------------------------------------
		local numOverlays = self:GetNumberOfMapOverlays(true) -- Returns the number of overlays that exist including blank ones.
		ZMC:Msg(self, "numOverlays = "..tostring(numOverlays).."", true, DebugTxt);
		ZMC:Msg(self, "numOverlays(NoBlanks) = "..tostring(self:GetNumberOfMapOverlays()).."", true, DebugTxt);
	----------------------------------------------------------
	
	
	
	----------------------------------------------------------
	-- Exit if the zone hasn't changed
	----------------------------------------------------------
		local MapContinentNum = GetCurrentMapContinent();
		local MapZoneNum = GetCurrentMapZone();
		
		self.LastCont = self.LastCont or 0; -- Sets up the Last Cont variable if doesn't exist
		self.LastZone = self.LastZone or 0; -- Sets up the Last Zone variable if doesn't exist
		
		if ((self.LastCont == MapContinentNum) and (self.LastZone == MapZoneNum)) then -- The zone hasn't changed so no need to do anything
			return;
		else -- Changed so save the new cont/zone and continue...
			self.LastCont = MapContinentNum;
			self.LastZone = MapZoneNum;
		end;
	----------------------------------------------------------
	
	
	
	----------------------------------------------------------
	-- Get names of the continent and zone
	----------------------------------------------------------
		local MapContinentName = "UNKNOWN CONTINENT!"; -- Default encase this continent isn't in the DB!
		local MapZoneName = "UNKNOWN ZONE!"; -- Default encase this zone isn't in the DB!
		
		ZMC:Msg(self, "MapContinentNum = "..tostring(MapContinentNum).."", true, DebugTxt);
		ZMC:Msg(self, "MapZoneNum = "..tostring(MapZoneNum).."", true, DebugTxt);
		
		if (MapZoneNum == 0) then -- The map is not showing a continent
			MapZoneName = "Entire Continent";
		end;
		
		if (MapContinentNum == 0) then -- The map is not showing a continent
			MapContinentName = "All of Azeroth";
		-- elseif (MapContinentNum == -1) then -- The map is not showing a continent
			-- Could be "Cosmic Map" or a "Battleground Map". Also when showing The Scarlet Enclave, the Death Knights' starting area.
			-- As there are so many it's easyer to say we don't know! ;)
		end;
		
		if (self.ZoneNames[MapContinentNum]) then
			MapContinentName = self.ZoneNames[MapContinentNum]["Name"];
			
			if (self.ZoneNames[MapContinentNum][MapZoneNum]) then
				MapZoneName = self.ZoneNames[MapContinentNum][MapZoneNum];
			end;
		end;
		
		ZMC:Msg(self, "MapContinentName = "..tostring(MapContinentName).."", true, DebugTxt);
		ZMC:Msg(self, "MapZoneName = "..tostring(MapZoneName).."", true, DebugTxt);
	----------------------------------------------------------
	
	
	
	
	----------------------------------------------------------
	-- Get details on the overlays (area's we have found)
	----------------------------------------------------------
		for i=1, numOverlays do
			local textureName, texWidth, texHeight, ofsX, ofsY, mapX, mapY = GetMapOverlayInfo(i); -- Pulls back this overlays details
			
			if not(textureName == "") then -- If there is a texture
				ZMC:Msg(self, "textureName = "..tostring(textureName)..", texWidth = "..tostring(texWidth)..", texHeight = "..tostring(texHeight)..", ofsX = "..tostring(ofsX)..", ofsY = "..tostring(ofsY)..", mapX = "..tostring(mapX)..", mapY = "..tostring(mapY).."", true, DebugTxt);
			end;
		end;
		
		self:AddPointsToMap(); -- Adds points to the map for this area
	----------------------------------------------------------
end;

function WorldExplorer:AddPointsToMap() -- Adds points to the map for this area
	----------------------------------------------
	-- Default: If DebugTxt is set to true all of
	-- the debug msgs in THIS function will apear!
	----------------------------------------------
		local DebugTxt = false;
		-- DebugTxt = true; -- Uncomment this to debug
	----------------------------------------------
	
	ZMC:Msg(self, "WorldExplorer:AddPointsToMap()",true,DebugTxt);
	
	self.DiscPoints = self.DiscPoints or {};
	
	local CurrentDiscPoint = 0;
	
	if (TableCount(self.DiscPoints) > 0) then -- There are already points so clear them
		for Key, DiscoverPoint in pairs(self.DiscPoints) do
			DiscoverPoint:Hide(); -- Hides the frame as we don't need it for a bit
		end;
	end;
	
	local ContNum = GetCurrentMapContinent();
	local ZoneNum = GetCurrentMapZone();
	
	local icT;
	if (Nx) then -- Carbonite exits so setup the icon types for it (Also clears any existing icons)
		ZMC:Msg(self, "Carbonite exits so setup the icon types for it", true, DebugTxt);
		
		----------------------------------------------------------
		-- Setup the icon types for this addon (also wipes all old
		-- icons from the same addon)
		----------------------------------------------------------
			local CarbMap=Nx.Map:GeM(1);
			icT = "!"..tostring(self.Name); -- Name of the addon
			local drM = "WP"; -- This specifies it's a waypoint
			local tex = ""; -- This is a texture. Don't know what this is for as it's almost always blank.
			local w = 10; -- This is the Width of the icon
			local h = 10; -- This is the Hight of the icon
			CarbMap:IIT(icT,drM,tex,w,h);
			
			CarbMap:SITA("!WorldExplorer",1); -- Set the Alpha of these points. 0.7
			CarbMap:SITAS("!WorldExplorer",0.3);--0.5); -- Sets the scale these points disapears at.
		----------------------------------------------------------
	end;
	
	if (WorldExplorer_StaticData[ContNum] and WorldExplorer_StaticData[ContNum][ZoneNum]) then -- This Zone has info in the static DB
		ZMC:Msg(self, "This zone ("..tostring(ContNum)..", "..tostring(ZoneNum)..") has entrys in the static date DB", true, DebugTxt);
		
		local ZoneName;
		if (self.ZoneNames[ContNum] and self.ZoneNames[ContNum][ZoneNum]) then
			ZoneName = self.ZoneNames[ContNum][ZoneNum]; -- Pulls back the name for this zone
			ZMC:Msg(self, "ZoneName = "..tostring(ZoneName).."", true, DebugTxt);
		else
			ZMC:Msg(self, "ERROR: No entry in WorldExplorer.ZoneNames for Continent Number = '"..tostring(ContNum).."' and Zone Number = '"..tostring(ZoneNum).."'! Please report this to the Author (Zasurus) on Curse.com for help.", false, DebugTxt, true);
		end;
		
		ZMC:Msg(self, "Nx = "..tostring(Nx).." ZoneName = "..tostring(ZoneName).."", true, DebugTxt);
		
		local CurColourNum = 1;
		
		for Area, Discoverys in pairs(WorldExplorer_StaticData[ContNum][ZoneNum]) do -- Loop though all areas in this zone to make sure we have discovered it and display a point if we haven't
			ZMC:Msg(self, "", true, DebugTxt);
			ZMC:Msg(self, "Loop though all areas in this zone. Area = "..tostring(Area).."", true, DebugTxt);
			
			local Colour = self.Colour[CurColourNum]
			
			if (type(Discoverys) == "table") then -- Makes sure this isn't any of the name entrys for this zone
				ZMC:Msg(self, "Not a name variable", true, DebugTxt);
				
				local bKnownArea = false;
				if (WorldExplorer_KnownAreas[ContNum] and WorldExplorer_KnownAreas[ContNum][ZoneNum]) then -- Makes sure this has an entry
					ZMC:Msg(self, "WorldExplorer_KnownAreas[ContNum = "..tostring(ContNum).."][ZoneNum = "..tostring(ZoneNum).."][Area = "..tostring(Area).."] = "..tostring(WorldExplorer_KnownAreas[ContNum][ZoneNum][Area]).."", true, DebugTxt);
					bKnownArea = (WorldExplorer_KnownAreas[ContNum][ZoneNum][Area] == true)
				end;
				
				if not(bKnownArea) then -- We haven't yet discovered this area so add tbe dot(s)!
					ZMC:Msg(self, "We haven't yet discovered this area so add a dot!", true, DebugTxt);
					ZMC:Msg(self, "WorldExplorer_KnownAreas[ContNum = "..tostring(ContNum).."][ZoneNum = "..tostring(ZoneNum).."][Area = "..tostring(Area).."]", true, DebugTxt);
					
					if (WorldExplorer_StaticData[ContNum][ZoneNum][Area]) then -- Ensure this are exists in the static DB
						for DiscoveredPointNum, DiscoveredPoint in pairs(WorldExplorer_StaticData[ContNum][ZoneNum][Area]) do
							if (type(DiscoveredPoint) == "table") then -- Ensure this is a discovery point and not a text string for texture name etc...
								------------------------------------------
								-- Choice which icon to use
								------------------------------------------
									local Icon;
									
									if ((WorldExplorer_StaticData[ContNum][ZoneNum][Area][DiscoveredPointNum]) and (WorldExplorer_StaticData[ContNum][ZoneNum][Area][DiscoveredPointNum]["Dud"] == true)) then
										ZMC:Msg(self, "Area = "..tostring(Area).." Is a dud!", true, DebugTxt);
										Icon = self.Icons.Cross;
									elseif (WorldExplorer_StaticData[ContNum][ZoneNum][Area] and (WorldExplorer_StaticData[ContNum][ZoneNum][Area][DiscoveredPointNum]["Generated"] == true)) then
										ZMC:Msg(self, "Area = "..tostring(Area).." Is NOT a dud BUT is generated", true, DebugTxt);
										Icon = self.Icons.Square;
									else
										ZMC:Msg(self, "Area = "..tostring(Area).." Is nether a dud or generated", true, DebugTxt);
										Icon = self.Icons.Circle;
									end;
								------------------------------------------
								
								
								
								------------------------------------------
								-- Pull out the colours and alpha
								------------------------------------------
									local Colour_r=tonumber(strsub(Colour,1,2),16)/255;
									local Colour_g=tonumber(strsub(Colour,3,4),16)/255;
									local Colour_b=tonumber(strsub(Colour,5,6),16)/255;
									local Alpha = 1;
								------------------------------------------
								
								local IconNote;
								if (WorldExplorer_StaticData[ContNum][ZoneNum][Area]["AreaName"]) then
									IconNote = WorldExplorer_StaticData[ContNum][ZoneNum][Area]["AreaName"];
								else
									IconNote = Area;
								end;
								
								if ((CurrentDiscPoint + 1) < TableCount(self.DiscPoints)) then -- There is already a point we can use so don't create one
									local DiscoverPoint = self.DiscPoints[CurrentDiscPoint]; -- Pulls back a point(frame) out of the pot to reuse
									DiscoverPoint:SetWidth(Icon.Width);
									DiscoverPoint:SetHeight(Icon.Height);
									DiscoverPoint.icon:SetAllPoints();
									DiscoverPoint:SetScript("OnEnter", function() ChatFrame1:AddMessage("Button = "..tostring(IconNote)); end);
									DiscoverPoint.icon:SetTexture(Icon.Texture);
									DiscoverPoint.icon:SetVertexColor(Colour_r, Colour_g, Colour_b, Alpha) -- Sets the colour (Red, Green, Blue, Alpha)
									DiscoverPoint:SetFrameLevel(10000);
									DiscoverPoint:EnableMouse(true);
									DiscoverPoint:Show();
									self.DiscPoints[CurrentDiscPoint] = DiscoverPoint; -- Stores the point back into the pot (it won't be reused until we are done with it)
								else
									local DiscoverPoint=CreateFrame("Button", "ExplorerCoordsWorldTargetFrame",WorldMapDetailFrame );
									DiscoverPoint:SetWidth(Icon.Width);
									DiscoverPoint:SetHeight(Icon.Height);
									DiscoverPoint.icon = DiscoverPoint:CreateTexture("ARTWORK");
									DiscoverPoint.icon:SetAllPoints();
									DiscoverPoint:SetScript("OnEnter", function() ChatFrame1:AddMessage("Button = "..tostring(IconNote)); end);
									DiscoverPoint.icon:SetTexture(Icon.Texture);
									DiscoverPoint.icon:SetVertexColor(Colour_r, Colour_g, Colour_b, Alpha) -- Sets the colour (Red, Green, Blue, Alpha)
									DiscoverPoint:SetFrameLevel(10000);
									DiscoverPoint:EnableMouse(true);
									DiscoverPoint:Show();
									self.DiscPoints[CurrentDiscPoint] = DiscoverPoint; -- Stores the point back into the pot (it won't be reused until we are done with it)
								end;
								
								ZMC:Msg(self, "WorldExplorer_StaticData[ContNum = "..tostring(ContNum).."][ZoneNum = "..tostring(ZoneNum).."][Area = "..tostring(Area).."][DiscoveredPointNum = "..tostring(DiscoveredPointNum).."][CordX]", true, DebugTxt);
								local CordX = WorldExplorer_StaticData[ContNum][ZoneNum][Area][DiscoveredPointNum]["CordX"]
								local CordY = WorldExplorer_StaticData[ContNum][ZoneNum][Area][DiscoveredPointNum]["CordY"]
								
								ZMC:Msg(self, "CordX = "..tostring(CordX).." CordY = "..tostring(CordY).." Icon.Texture = "..tostring(Icon.Texture).."", true, DebugTxt);
								
								ZMC:Msg(self, "self.Astrolabe:PlaceIconOnWorldMap(WorldMapDetailFrame = "..tostring(WorldMapDetailFrame)..", self.DiscPoints[CurrentDiscPoint] = "..tostring(self.DiscPoints[CurrentDiscPoint])..", ContNum = "..tostring(ContNum)..", ZoneNum = "..tostring(ZoneNum)..", CordX = "..tostring(CordX)..", CordY = "..tostring(CordY)..");", true, DebugTxt);
								self.Astrolabe:PlaceIconOnWorldMap(WorldMapDetailFrame, self.DiscPoints[CurrentDiscPoint], ContNum, ZoneNum, CordX, CordY);
								
								if (Nx and ZoneName) then -- Carbonite exits so add the icons to that as well
									ZMC:Msg(self, "Carbonite exits so add this icon to that as well", true, DebugTxt);
									
									----------------------------------------------------------
									-- Creates an icon
									----------------------------------------------------------
										local mapName = ZoneName; -- This is the name of the zone e.g. "Tirisfal Glades"
										local zoneX = CordX * 100; -- This is how from the left to the right of the zone the icon is in %. So if this was 0 it would be the far left if it was 100 it would be far right and if it was 50 it would be half way across
										local zoneY = CordY * 100; -- This is a % of the Hight of the zone (same as the width)
										local texture = Icon.Texture; -- This is the texure that will be used for the icon(Picture)
										local iconNote = tostring(IconNote); -- This is the note text(the text that pops up when you mouse over the icon)
										
										ZMC:Msg(self, "mapName = "..tostring(mapName).." zoneX = "..tostring(zoneX).." zoneY = "..tostring(zoneY).." texture = "..tostring(texture).." iconNote = "..tostring(iconNote).."", true, DebugTxt);
										
										local map2=Nx.Map:GeM(1);
										local maI=Nx.MNTI1[mapName];
										if maI then
											local wx,wy=map2:GWP(maI,zoneX,zoneY);
											ZMC:Msg(self, "wx = "..tostring(wx)..",wy = "..tostring(wy).."", true, DebugTxt);
											local icon = map2:AIP(icT,wx,wy,Colour,texture);
											map2:SIT(icon, iconNote); -- This sets the note(the text that pops up when you mouse over the icon)
										end;
									----------------------------------------------------------
								end;
								
								CurrentDiscPoint = CurrentDiscPoint + 1; -- Increase the current point by one.
							end;
						end;
					end;
				end;
			end;
			
			CurColourNum = CurColourNum + 1;
			if (CurColourNum > TableCount(self.Colour)) then
				CurColourNum = 1;
			end;
		end;
	end;
end;

function WorldExplorer:RequestUpdateKnownZoneList(RequestType) -- Requests the time the player has played and when it gets the time it does a full update of all points
	----------------------------------------------
	-- Default: If DebugTxt is set to true all of
	-- the debug msgs in THIS function will apear!
	----------------------------------------------
		local DebugTxt = false;
		-- DebugTxt = true; -- Uncomment this to debug
	----------------------------------------------
	
	ZMC:Msg(self, "WorldExplorer:RequestUpdateKnownZoneList( = "..tostring(RequestType)..")",true,DebugTxt);
	
	WorldExplorer.UpdateKnownZoneListRequest = RequestType or 2; -- If no request type specified then say we want to update the list of discovered area's (Default)
	
	ZMC:Msg(self, "WorldExplorer.UpdateKnownZoneListRequest = "..tostring(WorldExplorer.UpdateKnownZoneListRequest).."", true, DebugTxt);
	
	if (self.LoadedStatus["Initialized"] == 1) then
		self:InitLevel(2); -- Says that the second part of the setup is done if it hasn't already been! Need to get a zone update yet though.
	end;
	
	self.Dongle:ScheduleTimer("WorldExplorer_UpdateKnownZones", function() self:UpdateKnownZoneList(); self:AddPointsToMap(); end, 1); -- Schedule function "UpdateKnownZoneList" to run in a second to try to prevent it from messing around with the discover zones function
end;

function WorldExplorer:UpdateKnownZoneList() -- Goes though all zones updating the area's that we have explored! (Should be run for the first time you play a toon with this addon and any time you have explored an area without the addon running
	----------------------------------------------
	-- Default: If DebugTxt is set to true all of
	-- the debug msgs in THIS function will apear!
	----------------------------------------------
		local DebugTxt = false;
		-- DebugTxt = true; -- Uncomment this to debug
	----------------------------------------------
	
	ZMC:Msg(self, "WorldExplorer:UpdateKnownZoneList()",true,DebugTxt);
	
	--[[
		"WorldExplorer.UpdateKnownZoneListRequest" is used by the calling function to tell this
		function what information to gather and what to do with it:
		
		0 = Do nothing drop out of function.
		2 = Update list of discovered area's (for when the addon first loads encase points where
			discovered when the addon wasn't loaded or this is the first time it has been loaded).
	]]--
	
	local TempLocationStore; -- The tempory variable we will use for updating (reduces if's for each different type)
	
	if (WorldExplorer.UpdateKnownZoneListRequest == 2) then
		ZMC:Msg(self, "Update request in place(2). Continuing update.", true, DebugTxt);
		TempLocationStore = WorldExplorer_KnownAreas; -- Store the current contence into the Temp Variable
	else
		ZMC:Msg(self, "No update request so exiting.", true, DebugTxt);
		return;
	end;
	
	-- if (UnitLevel("player") < 10) then -- For any level but mainly level < 9 as achivements can't be used to work it out.
		ZMC:Msg(self, "Toon is < level 10 ("..tostring(UnitLevel("player"))..") so use overlays to work out what they have discovered (Slower/More CPU than Achivements but can be done at any level!)", true, DebugTxt);
		if ((WorldExplorer.UpdateKnownZoneListRequest == 1) or (WorldExplorer.UpdateKnownZoneListRequest == 2)) then
			ZMC:Msg(self, "Clear the array", true, DebugTxt);
			TempLocationStore = {}; -- Clear the array. (ALL DATA WILL BE LOST!)
		end;
		
		local tempContinent = GetCurrentMapContinent(); -- Gets the Continent the map is currently showing (so we can put it back after)
		local tempZone = GetCurrentMapZone(); -- Gets the Continent the map is currently showing (so we can put it back after)
		
		for ContNum,ContInfo in pairs(self.ZoneNames) do -- Loop though all of the continents
			ContName = ContInfo["Name"]; -- Stores the Continent Name
			
			for ZoneNum,ZoneName in pairs(self.ZoneNames[ContNum]) do -- Loop though all of the zones for this continent
				ZMC:Msg(self, "[ContNum = "..tostring(ContNum)..", ZoneNum = "..tostring(ZoneNum).."] ContName = "..tostring(ContName).."ZoneName = "..tostring(ZoneName).."", true, DebugTxt);
				
				if not(ZoneNum == "Name") then -- Makes sure this is not the Continent Name Label
					SetMapZoom(ContNum, ZoneNum); -- Set the current map zoom of the world map to a specific continent and zone to get the info on it.
					
					local numOverlays = self:GetNumberOfMapOverlays(true); -- Returns the number of overlays that exist including blank ones.
					ZMC:Msg(self, "numOverlays = "..tostring(numOverlays).."", true, DebugTxt);
					
					if (self:GetNumberOfMapOverlays() > 0) then -- There are overlays for this zone so we have discovered something in it
						ZMC:Msg(self, "There are overlays("..tostring(self:GetNumberOfMapOverlays())..") for this zone("..tostring(ContName)..", "..tostring(ZoneName)..") so we have discovered something in it", true, DebugTxt);
						
						--------------------------------------------------------------
						-- Make sure that this zone and it's continent exist in the DB
						--------------------------------------------------------------
							if not(type(TempLocationStore[ContNum]) == "table") then -- Makes sure this is already an array and not a string etc...
								TempLocationStore[ContNum] = {};
							end;
							
							if not(type(TempLocationStore[ContNum][ZoneNum]) == "table") then -- Makes sure this is already an array and not a string etc...
								TempLocationStore[ContNum][ZoneNum] = {};
							end;
						--------------------------------------------------------------
						
						if not(TempLocationStore[ContNum][ZoneNum]["Name"]) then -- The name for this zone doesn't exist so take it from the ZoneNames array
							TempLocationStore[ContNum][ZoneNum]["Name"] = ZoneName; -- Store the name in it's own field
						end;
						
						local mapFileName, ZoneTextureHeight, ZoneTextureWidth = GetMapInfo();
						TempLocationStore[ContNum][ZoneNum]["mapFileName"] = mapFileName; -- Stores/Overwrites the map name for this zone
						----------------------------------------------------------
						-- Get details on the overlays (area's we have found)
						----------------------------------------------------------
							for i=1, numOverlays do -- Loop though all of the overlays
								local textureName, textureWidth, textureHeight, offsetX, offsetY, mapPointX, mapPointY = GetMapOverlayInfo(i);
								-- ZMC:Msg(self, "i = "..tostring(i).."", true, DebugTxt);
								if ( textureName and textureName ~= "" ) then -- Makes sure this overlay has a texture
									-- ZMC:Msg(self, "This overlay has a texture: "..tostring(textureName), true, DebugTxt);
									------------------------------------------------
									-- Work out the center coordinates of this overlay
									-- (CordX, CordY)
									------------------------------------------------
										local numTexturesWide = ceil(textureWidth/256);
										local numTexturesTall = ceil(textureHeight/256);
										
										local texturePixelHeight = mod(textureHeight, 256);
										if ( texturePixelHeight == 0 ) then
											texturePixelHeight = 256;
										end
										
										local texturePixelWidth = mod(textureWidth, 256);
										if ( texturePixelWidth == 0 ) then
											texturePixelWidth = 256;
										end
										
										local TotalWidth = (((offsetX + (256 * (numTexturesWide-1))) - offsetX) + texturePixelWidth);
										local TotalHeight = (((offsetY + (256 * (numTexturesTall - 1))) - offsetY) + texturePixelHeight);
										
										local TotalX = ((TotalWidth / 2) + offsetX);
										local TotalY = ((TotalHeight / 2) + offsetY);
										
										local CordX = ((TotalX * 0.75) / ZoneTextureWidth);
										local CordY = (TotalY / ZoneTextureHeight);
									------------------------------------------------
									
									local OverlayName = strsub(GetMapOverlayInfo(i), - (strfind(strrev(GetMapOverlayInfo(i)),"\\") -1))
									
									if (WorldExplorer.UpdateKnownZoneListRequest == 1) then -- This is a request for details on all known overlays (when new area's apear?)
										ZMC:Msg(self, "This is a request for details on all known overlays (when new area's apear?)", true, DebugTxt);
										
										if not(TempLocationStore[ContNum][ZoneNum][OverlayName]) then
											TempLocationStore[ContNum][ZoneNum][OverlayName] = {};
										end;
										
										local Generated;
										for Key, Value in pairs(TempLocationStore[ContNum][ZoneNum][OverlayName]) do
											if (TempLocationStore[ContNum][ZoneNum][OverlayName][Key]["Generated"] == true) then
												Generated = true; -- Store that this is the generated
											end;
										end;
										
										local weekday, month, day, year = CalendarGetDate();
										local hours,minutes = GetGameTime();
										local ServerDateTime = (tostring(year).."/"..tostring(month).."/"..tostring(day).." "..tostring(hours)..":"..tostring(minutes));
										
										if not(Generated) then -- There isn't a generated point for this so create one
											local NextPoint = TableCount(TempLocationStore[ContNum][ZoneNum][OverlayName]) + 1;
											-- Store as much usefull info about this as posible.
											-- It could be useful to work out when players reveal certain areas!
											TempLocationStore[ContNum][ZoneNum][OverlayName][NextPoint] = {};
											TempLocationStore[ContNum][ZoneNum][OverlayName][NextPoint]["Generated"] = true;
											TempLocationStore[ContNum][ZoneNum][OverlayName][NextPoint]["TextureName"] = textureName;
											TempLocationStore[ContNum][ZoneNum][OverlayName][NextPoint]["CordX"] = CordX;
											TempLocationStore[ContNum][ZoneNum][OverlayName][NextPoint]["CordY"] = CordY;
											TempLocationStore[ContNum][ZoneNum][OverlayName][NextPoint]["DateTime"] = ServerDateTime;
											TempLocationStore[ContNum][ZoneNum][OverlayName][NextPoint]["Realm"] = GetRealmName();
											TempLocationStore[ContNum][ZoneNum][OverlayName][NextPoint]["Race"] = UnitRace("player");
											TempLocationStore[ContNum][ZoneNum][OverlayName][NextPoint]["Class"] = UnitClass("player");
											TempLocationStore[ContNum][ZoneNum][OverlayName][NextPoint]["Faction"] = UnitFactionGroup("player");
											TempLocationStore[ContNum][ZoneNum][OverlayName][NextPoint]["Level"] = UnitLevel("player");
											
											-- User Specific (Optional B4 GoLive as it's not that important but might feel private to some people!)
											-- TempLocationStore[ContNum][ZoneNum][OverlayName][NextPoint]["UserName"] = UnitName("player");
											-- TempLocationStore[ContNum][ZoneNum][OverlayName][NextPoint]["Sex"] = UnitSex("player");
										end;
									elseif (WorldExplorer.UpdateKnownZoneListRequest == 2) then -- This is a request for an update of all known points (normally just after the addon loads)
										-- ZMC:Msg(self, "This is a request for an update of all known points (normally just after the addon loads)", true, DebugTxt);
										
										TempLocationStore[ContNum][ZoneNum][OverlayName] = true; -- Say we know about this area!
									-- else
										-- ZMC:Msg(self, "This is a request number we don't know! ("..tostring(WorldExplorer.UpdateKnownZoneListRequest)..")", true, DebugTxt);
									end;
								end
							end
						----------------------------------------------------------
					end;
				end;
			end;
		end;
		
		SetMapZoom(tempContinent, tempZone); -- Reset the map to the original zone.
	-- else -- Then the toon is level 10 or higher and we can therefore use the achivement system to get the history of what area's they have discovered
		-- ZMC:Msg(self, "Toon is level 10 or higher("..tostring(UnitLevel("player"))..") so use achivement system to work out what they have discovered (Quicker/Less CPU)", true, DebugTxt);
	-- end;
	
	if (WorldExplorer.UpdateKnownZoneListRequest == 2) then
		ZMC:Msg(self, "Update request in place(2). Finishing update.", true, DebugTxt);
		WorldExplorer_KnownAreas = TempLocationStore; -- Restore the Temp Variable into the original variable
	end;
	
	WorldExplorer.UpdateKnownZoneListRequest = 0; -- Resets back to 0 for next time.
end;

function WorldExplorer:GetRealPlayerLocation() -- Quickly switch to the current map and store the players current location
	----------------------------------------------
	-- Default: If DebugTxt is set to true all of
	-- the debug msgs in THIS function will apear!
	----------------------------------------------
		local DebugTxt = false;
		-- DebugTxt = true; -- Uncomment this to debug
	----------------------------------------------
	
	ZMC:Msg(self, "WorldExplorer:GetRealPlayerLocation()",true,DebugTxt);
	
	local tempContinent = GetCurrentMapContinent(); -- Gets the Continent the map is currently showing (so we can put it back after)
	local tempZone = GetCurrentMapZone(); -- Gets the Continent the map is currently showing (so we can put it back after)
	
	SetMapToCurrentZone(); -- Set the map to the zone the player is currently in
	
	local ReturnAry = {}; -- An array that will be returned with the players current location...
	ReturnAry[1] = GetCurrentMapContinent(); -- Get the current continent number
	ReturnAry[2] = GetCurrentMapZone(); -- Get the current zone number
	ReturnAry[3], ReturnAry[4] = GetPlayerMapPosition("player"); -- Get the players current location
	
	if not((self.CurContNum == tempContinent) and (self.CurZoneNum == tempZone)) then -- Only change the zone back if it has really changed!
		SetMapZoom(tempContinent, tempZone); -- Reset the map to the original zone.
	end;
	
	return ReturnAry; -- Say there where no errors (that we picked up on) so it's all OK!
end;

WorldExplorer:RegisterEvent("ADDON_LOADED"); -- BCatch when this addon has finished loading
WorldExplorer:SetScript("OnEvent", WorldExplorer.OnEvent);