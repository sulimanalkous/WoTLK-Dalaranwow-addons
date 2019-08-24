-- MobMap - an ingame mob position database - v3.53
-- main code file

-- coded 2007-2009 by Slarti on EU-Blackhand


-- global constants

mobmap_shiftconst = {
	[0] = 1,
	[1] = 256,
	[2] = 65536,
	[3] = 1,
	[4] = 16777216,
	[5] = 4294967296,
	[6] = 1099511627776,
	[7] = 1,
}

mobmap_poweroftwo = {
	[0] = 1,
	[1] = 2,
	[2] = 4,
	[3] = 8,
	[4] = 16,
	[5] = 32,
	[6] = 64,
	[7] = 128,
	[8] = 256,
	[9] = 512,
	[10] = 1024,
	[11] = 2048,
	[12] = 4096,
	[13] = 8192,
	[14] = 16384,
	[15] = 32768,
	[16] = 65536,
	[17] = 131072,
	[18] = 262144,
	[19] = 524288,
	[20] = 1048576,
	[21] = 2097152,
	[22] = 4194304,
	[23] = 8388608,
	[24] = 16777216,
	[25] = 33554432,
	[26] = 67108864,
	[27] = 134217728,
	[28] = 268435456,
	[29] = 536870912,
	[30] = 1073741824,
	[31] = 2147483648,
	[32] = 4294967296,
	[33] = 8589934592,
	[34] = 17179869184,
	[35] = 34359738368,
	[36] = 68719476736,
	[37] = 137438953472,
	[38] = 274877906944,
	[39] = 549755813888,
	[40] = 1099511627776,
	[41] = 2199023255552,
	[42] = 4398046511104,
	[43] = 8796093022208,
	[44] = 17592186044416,
	[45] = 35184372088832,
	[46] = 70368744177664,
	[47] = 140737488355328,
	[48] = 281474976710656,
	[49] = 562949953421312,
	[50] = 1125899906842624,
	[51] = 2251799813685248,
	[52] = 4503599627370496,
}

MOBMAP_POSITION_DATABASE = 1;
MOBMAP_QUEST_DATABASE = 2;
MOBMAP_MERCHANT_DATABASE = 3;
MOBMAP_RECIPE_DATABASE = 4;
MOBMAP_ITEMNAME_HELPER_DATABASE = 5;
MOBMAP_MOBNAME_DATABASE = 6;
MOBMAP_DROP_DATABASE = 7;
MOBMAP_PICKUP_DATABASE = 8;
MOBMAP_PICKUP_QUEST_ITEM_DATABASE = 9;
MOBMAP_PICKUP_FISHING_DATABASE = 10;
MOBMAP_PICKUP_MINING_DATABASE = 11;
MOBMAP_PICKUP_HERBS_DATABASE = 12;
MOBMAP_ITEM_TOOLTIP_DATABASE = 13;
MOBMAP_QUEST_COMMENT_DATABASE = 14;

MOBMAP_SPELL_MINING=1;
MOBMAP_SPELL_HERBGATHERING=2;
MOBMAP_SPELL_SKINNING=3;
MOBMAP_SPELL_PROSPECTING=4;
MOBMAP_SPELL_LOCKPICKING=5;
MOBMAP_SPELL_PICKPOCKETING=6;
MOBMAP_SPELL_OPENING=7;
MOBMAP_SPELL_DISENCHANTING=8;
MOBMAP_SPELL_ITEMOPENING=9;
MOBMAP_SPELL_MILLING=10;
MOBMAP_SPELL_ENGINEERING=11;

MOBMAP_DBVERSION = "0018";

MOBMAP_EXPORT_MAXSIZE = 180000;

MOBMAP_ISONAMAC = IsMacClient();

MOBMAP_PARSETYPE_ITEMNAME = 1;

-- global variables

mobmap_enabled = true;
mobmap_scanning = true;
mobmap_minimap = true;
mobmap_positions = {};
mobmap_quests = {};
mobmap_merchantstock = {};
mobmap_tradeskills = {};
mobmap_loot = {};
mobmap_objects = {};
mobmap_trainer = {};
mobmap_comments = {};
mobmap_event_objectives = {};
mobmap_npc_spells = {};
mobmap_monitor = {};
mobmap_monitor_quest = {};
mobmap_event_objective_state = {};
mobmap_completed_quests={};
mobmap_language = nil;
mobmap_button_position = 1;
mobmap_display_database_loading_info = false;
mobmap_show_world_map_tooltips = true;
mobmap_request_item_details = true;
mobmap_hide_questlog_buttons = false;
mobmap_hide_questtracker_buttons = false;
mobmap_hide_reagent_buttons = false;
mobmap_hide_questgossip_buttons = false;
mobmap_window_height = 430;
mobmap_optimize_response_times = false;
mobmap_minimap_button_visible = true;
mobmap_outer_dot_color = {["r"] = 0, ["g"] = 0, ["b"] = 0, ["a"] = 1};
mobmap_inner_dot_color = {["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1};
mobmap_use_quest_comments = true;
mobmap_quest_comment_identification = true;
mobmap_battlefield_minimap = false;
mobmap_flash_positions = true;
mobmap_autoshow_comments = true;
mobmap_track_quest_completion = true;
mobmap_use_questtracker = true;
mobmap_quicksearch_omit_map = false;
mobmap_autocreate_waypoints = true;
mobmap_tomtom_waypoint = nil;
mobmap_minimap_icons = {};
mobmap_minimap_icon_cache = {};
mobmap_minimap_icon_counter = 0;
mobmap_init_finished = false;
mobmap_questsearch_preferredzone = nil;

mobmap_disabled = false;
mobmap_debug = false;

-- general database functions

function MobMap_GetZoneName(id)
	return mobmap_zones[id];
end

function MobMap_GetZoneID(zonename)
	local k,v;
	for k,v in pairs(mobmap_zones) do
		if(v==zonename) then
			return k;
		end
	end
	return 0;
end

function MobMap_GetMobCount()
	return mobmap_dbinfo["mobcount"];
end

function MobMap_GetQuestCount()
	return mobmap_dbinfo["questcount"];
end

function MobMap_GetMerchantCount()
	return mobmap_dbinfo["merchantcount"];
end

function MobMap_GetRecipeCount()
	return mobmap_dbinfo["recipecount"];
end

function MobMap_GetCommentCount()
	return mobmap_dbinfo["commentcount"];
end

function MobMap_GetDBVersion()
	return mobmap_dbinfo["version"];	
end

function MobMap_GetDBBuildTime()
	return mobmap_dbinfo["buildtime"];	
end

function MobMap_GetDBLanguage()
	return mobmap_dbinfo["language"];	
end

-- minimap button

function MobMap_MinimapButton_OnMove(self)
	MobMap_MoveMinimapButton(self);
end

function MobMap_MinimapButton_OnLoad(self)
	self:RegisterForDrag("LeftButton");
	self:SetMovable(true);
	MobMap_MoveMinimapButton(self,true);
end

function MobMap_MinimapButton_UpdateVisibility()
	if(mobmap_minimap_button_visible~=true or mobmap_disabled==true) then
		MobMapMinimapButtonFrame:Hide();
	else
		MobMapMinimapButtonFrame:Show();
	end
end

function MobMap_MoveMinimapButton(self,initial)
	self:ClearAllPoints();
	
	local uiscale=UIParent:GetScale();
	local cursorX, cursorY = GetCursorPosition();
	local minimapX, minimapY = Minimap:GetCenter();
	if(initial==true) then
		cursorX=minimapX;
		cursorY=minimapY+1;
	end
	cursorX=cursorX/uiscale;
	cursorY=cursorY/uiscale;
	
	local distanceX=cursorX-minimapX;
	local distanceY=cursorY-minimapY;
	local distance=sqrt(distanceX*distanceX+distanceY*distanceY);
	if(distance<85) then
		local angle=atan(distanceY/distanceX);
		if(distanceX<0) then
			angle=angle+180;
		end
		self:SetClampedToScreen(false);
		self:SetPoint("CENTER", Minimap, "CENTER", 80*cos(angle), 80*sin(angle));
		self:SetFrameLevel(Minimap:GetFrameLevel()+10);
	else
		self:SetClampedToScreen(true);
		self:SetPoint("CENTER", nil, "BOTTOMLEFT", cursorX, cursorY);
	end
end

-- quest objective parsing

mobmap_questsearch=false;

function MobMap_ParseQuestObjective(objective, typeID, objectivetext)
	MobMap_LoadDatabase(MOBMAP_POSITION_DATABASE);
	MobMap_LoadDatabase(MOBMAP_DROP_DATABASE);
	MobMap_LoadDatabase(MOBMAP_PICKUP_DATABASE);
	local filtered=string.match(objective, "^%d+/%d+ (.*)$");
	if(filtered==nil) then
		filtered=objective;
	end

	if(typeID==nil or typeID==MOBMAP_PARSETYPE_ITEMNAME) then
		local ihid=MobMap_GetIHIDByItemName(filtered);
		if(ihid~=nil) then
			if(typeID==MOBMAP_PARSETYPE_ITEMNAME) then
				MobMap_LoadDatabase(MOBMAP_RECIPE_DATABASE);
				local itemID=MobMap_GetItemDataByIHID(ihid);
				local alternateItemID=mobmap_tradeskillreagentmappings[itemID];
				if(alternateItemID) then
					local alternateIHID=MobMap_GetIHIDByItemID(alternateItemID);
					if(alternateIHID) then 
						ihid=alternateIHID;
						filtered=MobMap_GetItemNameByItemID(alternateItemID);
					end
				end
			end
			local isDropped=MobMap_IsInDropRateDatabase(filtered, 1.0);
			local isPickedUp=MobMap_IsInQuestPickupDatabase(filtered);
			if(isDropped==true) then
				ShowUIPanel(MobMapFrame);
				mobmap_questsearch=true;
				MobMap_DoDropRateItemSearch(filtered);
				mobmap_questsearch=false;
				return;
			elseif(isPickedUp==true) then
				ShowUIPanel(MobMapFrame);
				mobmap_questsearch=true;
				MobMap_DoQuestPickupDatabaseSearch(filtered);
				mobmap_questsearch=false;
				return;
			else
				isDropped=MobMap_IsInDropRateDatabase(filtered);
				if(isDropped==true) then
					ShowUIPanel(MobMapFrame);
					mobmap_questsearch=true;
					MobMap_DoDropRateItemSearch(filtered);
					mobmap_questsearch=false;
					return;
				else
					MobMap_LoadDatabase(MOBMAP_MERCHANT_DATABASE);
					local isSold=MobMap_IsInMerchantDatabase(filtered);
					if(isSold==true) then
						ShowUIPanel(MobMapFrame);
						mobmap_questsearch=true;
						MobMap_DoMerchantItemSearch(ihid);
						mobmap_questsearch=false;
						return;
					end
				end
			end
		end
	end

	if(typeID==nil) then
		if(MobMap_GetQuestEventIDs(filtered)~=nil) then
			ShowUIPanel(MobMapFrame);
			mobmap_questsearch=true;
			MobMap_DoQuestEventSearch(filtered);
			mobmap_questsearch=false;
			return;
		end
	end

	if(typeID==nil) then
		parts={};
		partcount=0;
		for w in string.gmatch(filtered, "%S+") do
			parts[partcount]=w;
			partcount=partcount+1;
		end
		local startingpoint, length, i;
		for startingpoint=0,partcount-1,1 do
			for length=partcount-startingpoint,1,-1 do
				local str="";
				for i=1,length,1 do
					str=str..parts[i+startingpoint-1];
					if(i<length) then str=str.." "; end
				end
				local mobid=MobMap_GetIDForMobName(str);
				if(mobid~=nil) then
					ShowUIPanel(MobMapFrame);
					MobMap_ShowPanel("MobMapMobSearchFrame");
					mobmap_questsearch=true;
					MobMap_ShowMobByName(str);
					mobmap_questsearch=false;
					return;
				end
			end
		end
	end

	if(typeID==nil) then
		MobMap_DisplayMessage(MOBMAP_QUEST_PARSING_FAILED);
		ShowUIPanel(MobMapFrame);
	else
		if(typeID==MOBMAP_PARSETYPE_ITEMNAME) then
			MobMap_DisplayMessage(MOBMAP_ITEM_PARSING_FAILED);
		end
	end
end

function MobMap_ParseQuestTitle(questtitle, objectivetext)
	MobMap_LoadDatabase(MOBMAP_QUEST_DATABASE);
	if(MobMap_ShowQuestDetailsByTitle(questtitle, objectivetext)==false) then
		MobMap_DisplayMessage(MOBMAP_QUEST_TITLE_NOT_FOUND);		
	end
end

function MobMap_ParseQuestTitleOrObjective(unknowntext)
	MobMap_LoadDatabase(MOBMAP_QUEST_DATABASE);
	if(MobMap_ShowQuestDetailsByTitle(unknowntext)==false) then
		MobMap_ParseQuestObjective(unknowntext);
	end
end

function MobMap_ParseQuestID(blizzid)
	MobMap_LoadDatabase(MOBMAP_QUEST_DATABASE);
	return MobMap_ShowQuestDetailsByBlizzID(blizzid);
end

-- data acquisition

function MobMap_GetDateCode(encode)
	local weekday, month, day, year = CalendarGetDate();
	if(weekday and month and day and year) then
		local datecode=floor((year-2009)*372+(month-1)*31+(day-1));
		if(encode) then
			return MobMap_Base36(datecode);
		else
			return datecode;
		end
	else
		return nil;
	end
end

function MobMap_ScanTarget()
	local targetguid=MobMap_GetMobIDFromGUID(UnitGUID("target"));
	local targetname=UnitName("target");
	if(targetguid and targetname and targetname~=UNKNOWNOBJECT) then
		if(not UnitPlayerControlled("target") and not UnitIsPlayer("target") and not UnitIsDeadOrGhost("target") and CheckInteractDistance("target", 3)) then
			local datecode=MobMap_GetDateCode(false);
			if((not WorldMapFrame:IsVisible()) and datecode) then
				local moblevel=UnitLevel("target");
				local mobreaction=UnitReaction("player","target");
				if(mobreaction) then
					local factionoffset=0;
					if(UnitFactionGroup("player")=="Horde") then factionoffset=10; end
					if(mobreaction>4) then mobreaction=2+factionoffset;
					elseif(mobreaction<4) then mobreaction=0+factionoffset;
					else mobreaction=1+factionoffset;
					end
				end
				if(mobmap_positions[targetguid]==nil) then
					mobmap_positions[targetguid]={};
					mobmap_positions[targetguid]["date"]=datecode;
				end
				mobmap_positions[targetguid]["react"]=mobreaction;
				if(mobmap_positions[targetguid]["name"]==nil) then
					mobmap_positions[targetguid]["name"]=targetname;
				end
				local x, y, zonename, zonelevel = MobMap_GetPlayerCoordinates();
				if(x==nil or y==nil or zonename==nil or zonelevel==nil) then return; end
				if(mobmap_positions[targetguid][zonename.."#"..zonelevel]==nil) then
					mobmap_positions[targetguid][zonename.."#"..zonelevel]={};
				end
				if(mobmap_positions[targetguid]["min"]==nil) then
					mobmap_positions[targetguid]["min"]=moblevel;
				else
					if(moblevel<mobmap_positions[targetguid]["min"]) then mobmap_positions[targetguid]["min"]=moblevel; end
				end
				if(mobmap_positions[targetguid]["max"]==nil) then
					mobmap_positions[targetguid]["max"]=moblevel;
				else
					if(moblevel>mobmap_positions[targetguid]["max"]) then mobmap_positions[targetguid]["max"]=moblevel; end
				end
				if(mobmap_positions[targetguid][zonename.."#"..zonelevel][x.."/"..y]==nil) then
					mobmap_positions[targetguid][zonename.."#"..zonelevel][x.."/"..y]=1;
					if(mobmap_debug) then MobMap_DisplayMessage("found "..targetguid.." in zone "..zonename.." (level "..zonelevel..") at "..x.." / "..y); end
				end
			end
		end
	end
end

mobmap_original_AcceptQuest=nil;

function MobMap_HookAcceptQuest()
	mobmap_original_AcceptQuest=AcceptQuest;
	AcceptQuest=MobMap_AcceptQuest;
end

function MobMap_AcceptQuest(...)
	MobMap_ScanQuest(false);
	mobmap_original_AcceptQuest(...);
end

mobmap_original_CompleteQuest=nil;

function MobMap_HookCompleteQuest()
	mobmap_original_CompleteQuest=CompleteQuest;
	CompleteQuest=MobMap_CompleteQuest;
end

function MobMap_CompleteQuest(...)
	MobMap_ScanQuest(true);
	mobmap_original_CompleteQuest(...);
end

function MobMap_ScanQuest(completing)
	if(not QuestFrame:IsVisible()) then return; end
	local title=MobMap_FilterQuestTitle(GetTitleText());
	local objectiveText, level, tag, time, id = MobMap_GetQuestInfoFromQuestLog(title);
	if(completing and objectiveText) then return; end
	local objective=MobMap_GetOriginalQuestText(GetObjectiveText());
	local npcname=MobMap_GetQuestGiver();
	local datecode=MobMap_GetDateCode(false);
		
	local zonename=GetRealZoneText();
	local playerfaction=UnitFactionGroup("player");
	if(title==nil or objective==nil or npcname==nil or datecode==nil) then return; end

	local completetitle=title;
	local counter=0;
	while(mobmap_quests[completetitle]~=nil) do
		if(objective=="" or mobmap_quests[completetitle].obj==objective) then
			return;
		end
		counter=counter+1;
		completetitle=title.."|"..counter;
	end
	mobmap_quests[completetitle]={obj=objective, level=0, npc=npcname, zone=zonename, group="solo", faction=playerfaction, id=0, time=0, date=datecode};
	MobMap_QuestMonitor_ClearData();
	mobmap_monitor_quest.action="newquest";
	mobmap_monitor_quest.timestamp=MobMap_Monitor_GetTimestamp();
	mobmap_monitor_quest.title=completetitle;
end

function MobMap_GetOriginalQuestText(str)
	if(str==nil) then return ""; end
	str=string.gsub(str,UnitName("player").."([%s%.,:;%(%)%!%-%?'])","$N%1");
	str=string.gsub(str,UnitClass("player").."([%s%.,:;%(%)%!%-%?'])", "$C%1");
	str=string.gsub(str,string.lower(UnitClass("player")).."([%s%.,:;%(%)%!%-%?'])", "$c%1");
	str=string.gsub(str,UnitRace("player").."([%s%.,:;%(%)%!%-%?'])","$R%1");
	str=string.gsub(str,string.lower(UnitRace("player")).."([%s%.,:;%(%)%!%-%?'])","$r%1");
	return str;
end

function MobMap_ScanQuestLog()
	if(mobmap_monitor_quest.timestamp==nil) then return; end
	MobMap_QuestMonitor_CheckForTimeout(2);
	if(mobmap_monitor_quest.title==nil or mobmap_monitor_quest.action~="newquest") then return; end
	local quest=mobmap_quests[mobmap_monitor_quest.title];
	if(quest==nil) then return; end
	local purifiedQuestTitle=string.match(mobmap_monitor_quest.title, "(.*)|%d*");
	if(not purifiedQuestTitle) then purifiedQuestTitle=mobmap_monitor_quest.title; end
	local objective, level, tag, time, id = MobMap_GetQuestInfoFromQuestLog(purifiedQuestTitle);
	if(objective==nil) then return; end
	if(MobMap_GetOriginalQuestText(objective)==quest.obj) then
		quest.group=tag;
		quest.level=level;
		quest.time=time;
		quest.id=id;
		MobMap_QuestMonitor_ClearData();
	end
end

mobmap_original_GetQuestReward=nil;

function MobMap_HookGetQuestReward()
	mobmap_original_GetQuestReward=GetQuestReward;
	GetQuestReward=MobMap_GetQuestReward;
end

function MobMap_GetQuestReward(...)
	if(mobmap_scanning) then
		MobMap_FinishQuest();
	end
	if(mobmap_track_quest_completion) then
		MobMap_CompletingQuest();
	end
	mobmap_original_GetQuestReward(...);
end

function MobMap_FinishQuest()
	if(not QuestFrame:IsVisible()) then return; end
	local title=MobMap_FilterQuestTitle(GetTitleText());
	local objectiveText, level, tag, time, id = MobMap_GetQuestInfoFromQuestLog(title);
	if(objectiveText==nil) then objectiveText=""; end
	local objective=MobMap_GetOriginalQuestText(objectiveText);
	local npcname=MobMap_GetQuestGiver();
	local datecode=MobMap_GetDateCode(false);
	if(title==nil or objective==nil or npcname==nil or datecode==nil) then return; end

	local completetitle=title;
	local counter=0;
	local quest=nil;
	while(mobmap_quests[completetitle]~=nil) do
		if(mobmap_quests[completetitle].obj==objective) then
			quest=mobmap_quests[completetitle];
			break;
		end
		counter=counter+1;
		completetitle=title.."|"..counter;
	end
	if(quest==nil) then
		mobmap_quests[completetitle]={};
		quest=mobmap_quests[completetitle];
		quest.obj=objective;
		quest.id=id;
		quest.date=datecode;
	end
	quest.endnpc=npcname;
	MobMap_QuestMonitor_ClearData();
	mobmap_monitor_quest.timestamp=MobMap_Monitor_GetTimestamp();
	mobmap_monitor_quest.action="endquest";
	mobmap_monitor_quest.title=completetitle;
end

function MobMap_GetQuestGiver()
	local target=MobMap_GetMobIDFromGUID(UnitGUID("npc"));
	if(not UnitExists("npc")) then
		if(mobmap_monitor.action=="questitem") then
			local item=mobmap_monitor.target;
			if(item==nil) then item=""; end
			MobMap_Monitor_ClearData();
			return "ITEM:"..item;
		else
			target=UnitName("npc");
			if(target==nil) then return nil; end
			MobMap_SaveObject(target, "quest");
			return "OBJECT:"..target;
		end
	else
		return target;
	end
end

function MobMap_GetQuestIdFromQuestLog(i)
	local id=nil;
	local questLink;
	if(FLV_GetQuestLink==GetQuestLink and FLV_Orig_GetQuestLink) then
		-- workaround for Fizzwidgets Levelator which unfortunately hooks GetQuestLink and fucks up its output
		-- we just call the original function because we know in which global variable the Levelator stores it
		questLink=FLV_Orig_GetQuestLink(i);
	else
		questLink=GetQuestLink(i);
	end

	if(questLink) then id=MobMap_GetQuestIDFromQuestLink(questLink); end
	if(id) then id=tonumber(id); end
	return id;
end

function MobMap_GetQuestInfoFromQuestLog(title)
	local selected=GetQuestLogSelection();
	local collapsed={};
	local i=1;
	local objective=nil;
	local unlocalizedQuestTag="solo";
	local level=nil;
	local time=nil;
	local id=nil;
	while(i<=GetNumQuestLogEntries()) do
		local questTitle, questLevel, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily = GetQuestLogTitle(i);
		if(questTitle) then
			questTitle=MobMap_FilterQuestTitle(questTitle);
			if(isHeader) then
				if(isCollapsed) then
					collapsed[questTitle]=true;
					ExpandQuestHeader(i);
				end
			else
				if(questTitle==title) then
					SelectQuestLogEntry(i);
					_, objective = GetQuestLogQuestText();
					unlocalizedQuestTag="solo";
					if(questTag==ELITE) then unlocalizedQuestTag="elite"; end
					if(questTag==LFG_TYPE_DUNGEON) then unlocalizedQuestTag="dungeon"; end
					if(questTag==PVP) then unlocalizedQuestTag="pvp"; end
					if(questTag==RAID) then unlocalizedQuestTag="raid"; end
					if(questTag==GROUP) then unlocalizedQuestTag="group"; end
					if(questTag==DUNGEON_DIFFICULTY2) then unlocalizedQuestTag="heroic"; end
					if(isDaily) then unlocalizedQuestTag="daily"; end
					level=questLevel;
					time=GetQuestLogTimeLeft();
					if(time==nil) then time=0; end
					id=MobMap_GetQuestIdFromQuestLog(i);
				end
			end
		end
		i=i+1;
	end

	i=1;
	while(i<=GetNumQuestLogEntries()) do
		local questTitle, questLevel, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily = GetQuestLogTitle(i);
		if(questTitle) then
			questTitle=MobMap_FilterQuestTitle(questTitle);
			if(isHeader) then
				if(collapsed[questTitle]) then
					CollapseQuestHeader(i);
				end
			end
		end
		i=i+1;
	end

	SelectQuestLogEntry(selected);

	return objective, level, unlocalizedQuestTag, time, id;
end

function MobMap_GetQuestIDFromQuestLogByTitle(title)
	local selected=GetQuestLogSelection();
	local collapsed={};
	local i=1;
	local id=nil;

	while(i<=GetNumQuestLogEntries()) do
		local questTitle, questLevel, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily = GetQuestLogTitle(i);
		if(questTitle) then
			questTitle=MobMap_FilterQuestTitle(questTitle);
			if(isHeader) then
				if(isCollapsed) then
					collapsed[questTitle]=true;
					ExpandQuestHeader(i);
				end
			else
				if(questTitle==title) then
					id=MobMap_GetQuestIdFromQuestLog(i);
					break;
				end
			end
		end
		i=i+1;
	end

	i=1;
	while(i<=GetNumQuestLogEntries()) do
		local questTitle, questLevel, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily = GetQuestLogTitle(i);
		if(questTitle) then
			questTitle=MobMap_FilterQuestTitle(questTitle);
			if(isHeader) then
				if(collapsed[questTitle]) then
					CollapseQuestHeader(i);
				end
			end
		end
		i=i+1;
	end

	return id;
end


function MobMap_ScanEventQuestObjectivesForUpdates()
	if(QuestLogFrame:IsVisible()) then return; end
	local selected=GetQuestLogSelection();
	local collapsed={};
	local i=1;

	while(i<=GetNumQuestLogEntries()) do
		local questTitle, questLevel, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily = GetQuestLogTitle(i);
		if(questTitle) then
			questTitle=MobMap_FilterQuestTitle(questTitle);
			if(isHeader) then
				if(isCollapsed) then
					collapsed[questTitle]=true;
					ExpandQuestHeader(i);
				end
			else
				local id=MobMap_GetQuestIdFromQuestLog(i);
				local objnr;
				if(id) then
					for objnr=1, GetNumQuestLeaderBoards(i), 1 do
						local leaderboardTxt, itemType, isDone = GetQuestLogLeaderBoard(objnr, i);
						if(isDone) then isDone=1; else isDone=0; end
						if(leaderboardTxt and (itemType=="object" or itemType=="event" or (itemType=="monster" and not MobMap_Deformat(QUEST_MONSTERS_KILLED, leaderboardTxt)))) then
							if(mobmap_event_objective_state[id]==nil) then mobmap_event_objective_state[id]={}; end
							local objectiveText=nil;
							local datecode=MobMap_GetDateCode(true);
							if(itemType=="object" or itemType=="monster") then
								objectiveText=string.match(leaderboardTxt, "^(.+): %d+/%d+$");
								if(objectiveText==nil) then objectiveText=leaderboardTxt; end
							else
								objectiveText=leaderboardTxt;
							end
							if(datecode) then
								objectiveText=objectiveText.."#"..datecode;
								if(mobmap_event_objective_state[id][objectiveText]~=nil) then
									if(isDone~=mobmap_event_objective_state[id][objectiveText] and isDone==1) then
										if(questTag~=nil or GetNumPartyMembers()==0) then
											local x, y, zonename, zonelevel = MobMap_GetPlayerCoordinates();
											if(x~=nil and y~=nil and zonename~=nil and zonelevel~=nil) then
												if(mobmap_event_objectives[id]==nil) then mobmap_event_objectives[id]={}; end
												if(mobmap_event_objectives[id][objectiveText]==nil) then mobmap_event_objectives[id][objectiveText]={}; end
												if(mobmap_event_objectives[id][objectiveText][zonename.."#"..zonelevel]==nil) then mobmap_event_objectives[id][objectiveText][zonename.."#"..zonelevel]={}; end
												mobmap_event_objectives[id][objectiveText][zonename.."#"..zonelevel][x.."/"..y]=1;
											end
										end
									end
								end
								mobmap_event_objective_state[id][objectiveText]=isDone;
							end
						end
					end
				end
			end
		end
		i=i+1;
	end

	i=1;
	while(i<=GetNumQuestLogEntries()) do
		local questTitle, questLevel, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily = GetQuestLogTitle(i);
		if(questTitle) then
			questTitle=MobMap_FilterQuestTitle(questTitle);
			if(isHeader) then
				if(collapsed[questTitle]) then
					CollapseQuestHeader(i);
				end
			end
		end
		i=i+1;
	end

	SelectQuestLogEntry(selected);
end

function MobMap_ScanMerchant()
	if(not MerchantFrame:IsVisible()) then return; end
	local i;
	local merchantName=MobMap_GetMobIDFromGUID(UnitGUID("npc"));
	local datecode=MobMap_GetDateCode(false);
	if(merchantName==nil or datecode==nil) then return; end
	local merchantItemCount=GetMerchantNumItems();

	if(mobmap_merchantstock[merchantName]==nil) then mobmap_merchantstock[merchantName]={}; end

	local item;
	for item=1, merchantItemCount, 1 do
		local itemData={};
		local itemlink=GetMerchantItemLink(item);
		if(itemlink~=nil) then
			local itemid=MobMap_GetItemIDFromItemLink(itemlink);
			local name, texture, price, quantity, numAvailable, isUsable, extendedCost = GetMerchantItemInfo(item);
			if(itemid) then 
				itemData["id"]=tonumber(itemid);
				itemData["price"]=price;
				itemData["quantity"]=quantity;
				if(numAvailable~=-1) then
					itemData["limited"]=1;
				else
					itemData["limited"]=0;
				end

				local dataComplete=true;

				if(extendedCost) then
					local honorPoints, arenaPoints, itemCount = GetMerchantItemCostInfo(item);
					itemData["honorprice"]=honorPoints;
					itemData["arenaprice"]=arenaPoints;
					local token;
					for token=1, itemCount, 1 do
						local itemTexture, itemValue = GetMerchantItemCostItem(item, token);
						if(itemTexture and itemValue) then
							MobMapScanTooltip:Show();
							MobMapScanTooltip:SetOwner(UIParent, "ANCHOR_NONE");
							MobMapScanTooltip:SetMerchantCostItem(item, token);
							local itemName=MobMapScanTooltipTextLeft1:GetText();
							MobMapScanTooltip:Hide();
							if(itemName) then
								itemData["token"..token]=itemName.."|"..itemTexture.."|"..itemValue;
							end
						else
							dataComplete=false;
						end
					end
				end

				if(dataComplete==true) then mobmap_merchantstock[merchantName][tostring(item)]=itemData; end
			end
		end
	end
	if(CanMerchantRepair()) then mobmap_merchantstock[merchantName][tostring(merchantItemCount+1)]={id=947264, quantity=1, limited=0, price=datecode};
	else mobmap_merchantstock[merchantName][tostring(merchantItemCount+1)]={id=947264, quantity=0, limited=0, price=datecode}; end
end

mobmap_original_GetTradeSkillInfo=nil;
mobmap_last_tradeskill_scan=0;

function MobMap_HookGetTradeSkillInfo()
	mobmap_original_GetTradeSkillInfo=GetTradeSkillInfo;
	GetTradeSkillInfo=MobMap_GetTradeSkillInfo;
end

function MobMap_GetTradeSkillInfo(skillIndex)
	local skillName, skillType, numAvailable, isExpanded, altVerb = mobmap_original_GetTradeSkillInfo(skillIndex);

	if(skillName~=nil and skillType~="header" and mobmap_tradeskills[skillName]==nil) then
		if(mobmap_last_tradeskill_scan+2.0<GetTime()) then
			mobmap_last_tradeskill_scan=GetTime();
			local tradeskillItem={};
			if(mobmap_tradeskills[skillName]~=nil) then
				tradeskillItem=mobmap_tradeskills[skillName];
			end

			local tradeskillName, tradeskillLevel = GetTradeSkillLine();
			
			if(tradeskillName~=nil) then
				tradeskillItem["category"]=tradeskillName;
				local itemlink=GetTradeSkillItemLink(skillIndex);
				local producttype=MobMap_GetTradeSkillType(itemlink);
				local errors=false;
				if(itemlink and producttype) then
					local reagentCount=GetTradeSkillNumReagents(skillIndex);			
					local i;
					for i=1,reagentCount,1 do
						local currentReagent={};
						local reagentName, reagentTexture, reagentCount = GetTradeSkillReagentInfo(skillIndex, i);
						local link=GetTradeSkillReagentItemLink(skillIndex, i);
						if(link==nil) then
							errors=true;
							break;
						end
						local itemid=MobMap_GetItemIDFromItemLink(link);
						currentReagent.itemid=itemid;
						currentReagent.count=reagentCount;
						tradeskillItem["reagent"..i]=currentReagent;
					end
					local minMade, maxMade = GetTradeSkillNumMade(skillIndex);
					if(producttype=="item") then
						tradeskillItem["itemid"]=MobMap_GetItemIDFromItemLink(itemlink);
					elseif(producttype=="enchant") then
						tradeskillItem["enchantid"]=MobMap_GetEnchantIDFromEnchantLink(itemlink);
					elseif(producttype=="spell") then
						tradeskillItem["spellid"]=MobMap_GetSpellIDFromSpellLink(itemlink);
					end
					tradeskillItem["level"]=tradeskillLevel;
					if(minMade~=1 or maxMade~=1) then
						tradeskillItem["minmade"]=minMade;
						tradeskillItem["maxmade"]=maxMade;
					end

					if(errors==false) then 
						mobmap_tradeskills[skillName]=tradeskillItem;
					end
				end
			end
		end
	end

	return skillName, skillType, numAvailable, isExpanded, altVerb;
end

function MobMap_GetTradeSkillType(link)
	if(link and string.len(link)>20) then
		if(string.sub(link,13,17)=="item:") then return "item"; end
		if(string.sub(link,13,20)=="enchant:") then return "enchant"; end
		if(string.sub(link,13,18)=="spell:") then return "spell"; end
	else
		return nil;
	end	
end

function MobMap_ScanLoot()
	local mobname=nil;
	MobMap_Monitor_CheckForTimeout(4);
	if(IsFishingLoot()) then
		mobname="FISH";
	elseif(mobmap_monitor.action=="spellsuccess" and mobmap_monitor.target~=nil) then
		if(mobmap_monitor.spelltype==MOBMAP_SPELL_PICKPOCKETING and mobmap_monitor.target=="n"..MobMap_GetMobIDFromGUID(UnitGUID("target"))) then
			mobname="PIPO"..mobmap_monitor.target;
		elseif(mobmap_monitor.spelltype==MOBMAP_SPELL_HERBGATHERING) then
			mobname="HERB"..mobmap_monitor.target;
		elseif(mobmap_monitor.spelltype==MOBMAP_SPELL_MINING) then
			mobname="MING"..mobmap_monitor.target;
		elseif(mobmap_monitor.spelltype==MOBMAP_SPELL_SKINNING) then
			mobname="SKIN"..mobmap_monitor.target;
		elseif(mobmap_monitor.spelltype==MOBMAP_SPELL_ENGINEERING) then
			mobname="ENGN"..mobmap_monitor.target;
		elseif(mobmap_monitor.spelltype==MOBMAP_SPELL_PROSPECTING) then
			mobname="PRSP"..mobmap_monitor.target;
		elseif(mobmap_monitor.spelltype==MOBMAP_SPELL_MILLING) then
			mobname="MILL"..mobmap_monitor.target;
		elseif(mobmap_monitor.spelltype==MOBMAP_SPELL_DISENCHANTING) then
			mobname="DISN"..mobmap_monitor.target;
		elseif(mobmap_monitor.spelltype==MOBMAP_SPELL_OPENING or mobmap_monitor.spelltype==MOBMAP_SPELL_LOCKPICKING) then
			mobname="OPEN"..mobmap_monitor.target;
		elseif(mobmap_monitor.spelltype==MOBMAP_SPELL_ITEMOPENING) then
			mobname="ITEM"..mobmap_monitor.target;
		else
			mobname="UNKN";
		end
	else
		local targetname=MobMap_GetMobIDFromGUID(UnitGUID("target"));
		if(targetname) then
			if(CheckInteractDistance("target",4) and UnitIsDead("target") and not UnitIsFriend("player", "target") and not UnitIsPlayer("target")) then
				mobname="n"..targetname;
			else
				mobname="UNKN";
			end
		else
			mobname="UNKN";
		end
	end
	MobMap_Monitor_ClearData();
	local x, y, zonename, zonelevel = MobMap_GetPlayerCoordinates();
	local datecode=MobMap_GetDateCode(true);
	if(x==nil or y==nil or zonename==nil or zonelevel==nil or datecode==nil) then return; end
	zonename=zonename..MobMap_GetDifficulty();
	local combinedname=mobname.."#"..x.."#"..y.."#"..zonename.."#"..zonelevel;

	local lootstring="+";
	local i;
	for i=1,GetNumLootItems(),1 do
		if(LootSlotIsItem(i)) then
			local itemid, suffixid, uniqueid = MobMap_GetItemIDFromItemLink(GetLootSlotLink(i));
			if(not(tonumber(suffixid)<0)) then
				uniqueid=0;
			end
			local _, _, count = GetLootSlotInfo(1);
			lootstring=lootstring..itemid..":"..suffixid..":"..uniqueid..":"..count..":"..datecode.."#";
		elseif(LootSlotIsCoin(i)) then
			local _, moneystring = GetLootSlotInfo(i);
			local money=MobMap_GetMoneyFromMoneyString(moneystring);
			lootstring=lootstring..money.."#";
		end
	end
	if(lootstring=="+") then return; end

	if(mobmap_loot[combinedname]~=nil) then
		mobmap_loot[combinedname]=mobmap_loot[combinedname]..lootstring;
	else
		mobmap_loot[combinedname]=lootstring;
	end
end

function MobMap_ScanTrainer()
	if(not UnitExists("npc")) then return; end
	local npcname=MobMap_GetMobIDFromGUID(UnitGUID("target"));

	local i;
	local currentGroup="";
	for i=1,GetNumTrainerServices(),1 do
		local name, rank, category = GetTrainerServiceInfo(i);
		if(name~=nil and category~=nil) then
			if(category=="header") then
				currentGroup=name;
			else
				local trainerOffer={};
				if(rank==nil) then rank=""; end
				local level=GetTrainerServiceLevelReq(i);
				if(level==nil) then level=0; end
				trainerOffer.level=level;
				local cost=GetTrainerServiceCost(i);
				if(cost==nil) then cost=0; end
				trainerOffer.cost=cost;
				local skillName, skillRank = GetTrainerServiceSkillReq(i);
				if(skillName~=nil and skillRank~=nil) then
					trainerOffer.skillName=skillName;
					trainerOffer.skillRank=skillRank;
				end
				local fullName=name.."|"..rank.."|"..currentGroup;

				if(not mobmap_trainer[npcname]) then
					mobmap_trainer[npcname]={};
					local datecode=MobMap_GetDateCode(false);
					if(datecode) then
						mobmap_trainer[npcname]["date"]={};
						mobmap_trainer[npcname]["date"].level=0;
						mobmap_trainer[npcname]["date"].cost=datecode;
					end
				end

				if(not mobmap_trainer[npcname][fullName]) then
					mobmap_trainer[npcname][fullName]=trainerOffer;
				end
			end
		end
	end
end

function MobMap_UseContainerItem(bag, slot)
	if(not MerchantFrame:IsShown() and bag~=nil and slot~=nil) then
		local itemLink=GetContainerItemLink(bag, slot);
		if(itemLink==nil) then return; end
		local itemID=MobMap_GetItemIDFromItemLink(itemLink);

		MobMapScanTooltip:Show();
		MobMapScanTooltip:SetOwner(UIParent, "ANCHOR_NONE");
		MobMapScanTooltip:SetBagItem(bag, slot);

		local i;
		for i=2, MobMapScanTooltip:NumLines(), 1 do
			local line=getglobal("MobMapScanTooltipTextLeft"..i):GetText();
			if(line==ITEM_OPENABLE) then
				MobMap_Monitor_ClearData();
				mobmap_monitor.action="spellsuccess";
				mobmap_monitor.spelltype=MOBMAP_SPELL_ITEMOPENING;
				mobmap_monitor.timestamp=MobMap_Monitor_GetTimestamp();
				mobmap_monitor.target="i"..itemID;
				break;
			elseif(line==ITEM_STARTS_QUEST) then
				MobMap_Monitor_ClearData();
				mobmap_monitor.action="questitem";
				mobmap_monitor.timestamp=MobMap_Monitor_GetTimestamp();
				mobmap_monitor.target=itemID;
				break;
			end
		end

		MobMapScanTooltip:Hide();
	end
end

function MobMap_HookUseContainerItem()
	hooksecurefunc("UseContainerItem", MobMap_UseContainerItem);
end

function MobMap_SaveObject(objectName, objectType)
	if(objectName==nil or objectType==nil) then return; end
	local x, y, zonename, zonelevel = MobMap_GetPlayerCoordinates();
	local datecode=MobMap_GetDateCode(true);
	if(x==nil or y==nil or zonename==nil or zonelevel==nil or datecode==nil) then return; end
	local combinedname=objectName.."#"..objectType;
	if(mobmap_objects[combinedname]==nil) then
		mobmap_objects[combinedname]={};
	end
	local position=x.."#"..y.."#"..zonename.."#"..zonelevel.."#"..datecode;
	if(mobmap_objects[combinedname][position]==nil) then
		mobmap_objects[combinedname][position]=1;
	end
end

function MobMap_Monitor_SpellCastSent(unit, spell, rank, target)
	if(unit~="player") then return; end
	local spellType=MobMap_Monitor_GetSpellType(spell);
	if(spellType==nil) then return; end
	mobmap_monitor.action="spellcast";
	mobmap_monitor.spelltype=spellType;
	mobmap_monitor.timestamp=MobMap_Monitor_GetTimestamp();
	if(target==nil or target=="") then
		if(spellType==MOBMAP_SPELL_DISENCHANTING or spellType==MOBMAP_SPELL_PROSPECTING or spellType==MOBMAP_SPELL_MILLING) then
			local itemName, itemLink = GameTooltip:GetItem();
			if(itemLink) then
				local itemID=MobMap_GetItemIDFromItemLink(itemLink);
				target="i"..itemID;
			end
		else
			target=GameTooltipTextLeft1:GetText();
			if(target=="") then target=nil; end
		end
	end

	if((spellType==MOBMAP_SPELL_HERBGATHERING or spellType==MOBMAP_SPELL_MINING or spellType==MOBMAP_SPELL_PICKPOCKETING or spellType==MOBMAP_SPELL_ENGINEERING) and target~=nil) then
		if(UnitName("target")==target and target~=nil) then
			local guid=MobMap_GetMobIDFromGUID(UnitGUID("target"));
			if(guid) then
				target="n"..guid;
			else
				target=nil;
			end
		else
			target="o"..target;
		end
	end

	if(spellType==MOBMAP_SPELL_SKINNING and target~=nil) then
		target="n"..target;
	end

	if((spellType==MOBMAP_SPELL_OPENING or spellType==MOBMAP_SPELL_LOCKPICKING) and target~=nil) then
		MobMap_SaveObject(target, "container");
		target="o"..target;
	elseif(spellType==MOBMAP_SPELL_HERBGATHERING and target~=nil and string.len(target)>1 and string.sub(target,1,1)=="o") then
		MobMap_SaveObject(string.sub(target,2), "herb");
	elseif(spellType==MOBMAP_SPELL_MINING and target~=nil and string.len(target)>1 and string.sub(target,1,1)=="o") then
		MobMap_SaveObject(string.sub(target,2), "mine");
	end


	if(target~=nil and string.len(target)>1 and (string.sub(target,1,1)=="n" or string.sub(target,1,1)=="o" or string.sub(target,1,1)=="i")) then
		mobmap_monitor.target=target;
	else
		MobMap_Monitor_ClearData();
	end
end

function MobMap_Monitor_SpellCastFailed(unit)
	if(unit=="player") then
		MobMap_Monitor_ClearData();
	end	
end

function MobMap_Monitor_SpellCastInterrupted(unit)
	if(unit=="player") then
		MobMap_Monitor_ClearData();
	end
end

function MobMap_Monitor_SpellCastSucceeded(unit, spell, rank)
	local spellType=MobMap_Monitor_GetSpellType(spell);
	if(unit=="player" and mobmap_monitor.action=="spellcast" and mobmap_monitor.spelltype==spellType) then
		mobmap_monitor.action="spellsuccess";
		mobmap_monitor.timestamp=MobMap_Monitor_GetTimestamp();
	end
end

function MobMap_Monitor_GetTimestamp()
	return GetTime();
end

function MobMap_Monitor_CheckForTimeout(timeout)
	if(mobmap_monitor.timestamp~=nil) then
		if(MobMap_Monitor_GetTimestamp()-mobmap_monitor.timestamp>timeout) then
			MobMap_Monitor_ClearData();
		end
	end
end

function MobMap_Monitor_ClearData()
	mobmap_monitor={};
end

function MobMap_Monitor_GetSpellType(spellname)
	spellname=string.lower(spellname);
	if(string.find(spellname, MOBMAP_MONITOR_SPELL_OPENING)) then
		return MOBMAP_SPELL_OPENING;
	elseif(string.find(spellname, MOBMAP_MONITOR_SPELL_DISENCHANTING)) then
		return MOBMAP_SPELL_DISENCHANTING;
	elseif(string.find(spellname, MOBMAP_MONITOR_SPELL_MINING)) then
		return MOBMAP_SPELL_MINING;
	elseif(string.find(spellname, MOBMAP_MONITOR_SPELL_HERBGATHERING)) then
		return MOBMAP_SPELL_HERBGATHERING;
	elseif(string.find(spellname, MOBMAP_MONITOR_SPELL_SKINNING)) then
		return MOBMAP_SPELL_SKINNING;
	elseif(string.find(spellname, MOBMAP_MONITOR_SPELL_ENGINEERING)) then
		return MOBMAP_SPELL_ENGINEERING;
	elseif(string.find(spellname, MOBMAP_MONITOR_SPELL_PROSPECTING)) then
		return MOBMAP_SPELL_PROSPECTING;
	elseif(string.find(spellname, MOBMAP_MONITOR_SPELL_LOCKPICKING)) then
		return MOBMAP_SPELL_LOCKPICKING;
	elseif(string.find(spellname, MOBMAP_MONITOR_SPELL_PICKPOCKETING)) then
		return MOBMAP_SPELL_PICKPOCKETING;
	elseif(string.find(spellname, MOBMAP_MONITOR_SPELL_MILLING)) then
		return MOBMAP_SPELL_MILLING;
	end

	return nil;
end

function MobMap_QuestMonitor_CheckForTimeout(timeout)
	if(mobmap_monitor_quest.timestamp~=nil) then
		if(MobMap_Monitor_GetTimestamp()-mobmap_monitor_quest.timestamp>timeout) then
			MobMap_QuestMonitor_ClearData();
		end
	end
end

function MobMap_QuestMonitor_ClearData()
	mobmap_monitor_quest={};
end

function MobMap_QuestMonitor_XPGained(msg)
	if(mobmap_monitor_quest.timestamp==nil) then return; end
	MobMap_QuestMonitor_CheckForTimeout(2);
	if(mobmap_monitor_quest.title==nil or mobmap_monitor_quest.action~="endquest") then return; end
	local quest=mobmap_quests[mobmap_monitor_quest.title];
	if(quest==nil) then return; end
	local xp=MobMap_Deformat(COMBATLOG_XPGAIN_FIRSTPERSON_UNNAMED, msg);
	if(xp==nil) then return; end
	xp=tonumber(xp);
	quest.xp=xp;
end

function MobMap_QuestMonitor_FactionChange(msg)
	if(mobmap_monitor_quest.timestamp==nil) then return; end
	MobMap_QuestMonitor_CheckForTimeout(2);
	if(mobmap_monitor_quest.title==nil or mobmap_monitor_quest.action~="endquest") then return; end
	local quest=mobmap_quests[mobmap_monitor_quest.title];
	if(quest==nil) then return; end
	local faction, reputation = MobMap_Deformat(FACTION_STANDING_INCREASED, msg);
	if(faction) then
		MobMap_QuestMonitor_RegisterFactionChange(quest, faction, tonumber(reputation));
		return;
	end
	faction, reputation = MobMap_Deformat(FACTION_STANDING_DECREASED, msg);
	if(faction) then 
		MobMap_QuestMonitor_RegisterFactionChange(quest, faction, -tonumber(reputation));
	end
end

function MobMap_QuestMonitor_RegisterFactionChange(quest, faction, amount)
	if(quest==nil or faction==nil or amount==nil) then return; end
	local _, race = UnitRace("player");
	if(race=="Human" and amount>0) then
		amount=math.floor(amount/1.1+0.5);
	end
	if(quest.reputation==nil) then
		quest.reputation={};
	end
	if(quest.reputation[faction]==nil) then
		quest.reputation[faction]=amount;
	else
		quest.reputation[faction]=quest.reputation[faction]+amount;
	end
end

function MobMap_ProcessCombatLog(event, source, sourceflags, spellid)
	if(event~=nil and string.match(event, "^SPELL_CAST")) then
		local sourceid=MobMap_GetMobIDFromGUID(source);
		if(sourceid~=nil and (bit.band(sourceflags, 0x00000A08)==0x00000A08 or bit.band(sourceflags, 0x00002208)==0x00002208)) then -- only if source is NPC/Guardian and NPC-controlled and affiliated to the world
			local spellid=arg9;
			if(spellid) then
				local identifier="m"..sourceid..MobMap_GetDifficulty();
				if(not mobmap_npc_spells[identifier]) then
					mobmap_npc_spells[identifier]={};
				end
				if(not mobmap_npc_spells[identifier][spellid]) then
					mobmap_npc_spells[identifier][spellid]=1;
				else
					mobmap_npc_spells[identifier][spellid]=mobmap_npc_spells[identifier][spellid]+1;
				end
			end
		end
	end
end

function MobMap_GetDifficulty()
	local inInstance, instanceType = IsInInstance();
	if(inInstance) then
		if(instanceType=="party") then
			local dungeonDifficulty=GetDungeonDifficulty();
			if(dungeonDifficulty==2) then return "HEROIC"; end
		elseif(instanceType=="raid") then
			local raidDifficulty=GetRaidDifficulty();
			if(raidDifficulty==1) then return "RAID1N"; end
			if(raidDifficulty==2) then return "RAID2N"; end
			if(raidDifficulty==3) then return "RAID1H"; end
			if(raidDifficulty==4) then return "RAID2H"; end
		end
	end
	return "";
end


--- user interface

function MobMapButtonFrame_OnLoad()
	SLASH_MOBMAP1 = "/mobmap";
	SlashCmdList["MOBMAP"] = MobMap_Command;
end

function MobMap_PlaceMobMapButtonFrame()
	if(Cartographer) then
		MobMapDotParentFrame:SetFrameStrata(WorldMapPositioningGuide:GetFrameStrata());
		MobMapDotParentFrame:SetWidth(WorldMapPositioningGuide:GetWidth());
		MobMapDotParentFrame:SetHeight(WorldMapPositioningGuide:GetHeight());
		MobMapDotParentFrame:SetScale(WorldMapFrame:GetScale());
		MobMapDotParentFrame:ClearAllPoints();
		MobMapDotParentFrame:SetAllPoints(WorldMapPositioningGuide);
		MobMapButtonFrame:SetParent(UIParent);
		MobMapButtonFrame:SetFrameStrata(WorldMapPositioningGuide:GetFrameStrata());
	else
		MobMapButtonFrame:SetParent(WorldMapFrame);
	end
	if(mobmap_button_position==0) then
		MobMapButtonFrame:Hide();
	end
	if(mobmap_button_position==2) then
		MobMapButtonFrame:SetPoint("TOPRIGHT","WorldMapPositioningGuide","TOPRIGHT",-4,-24);
		MobMapButtonFrame:SetFrameLevel(WorldMapPositioningGuide:GetFrameLevel()+20);
		MobMapButton:ClearAllPoints();
		MobMapButton:SetPoint("TOPRIGHT","MobMapButtonFrame","TOPRIGHT",0,0);
		MobMapCheckButton:ClearAllPoints();
		MobMapCheckButton:SetPoint("TOPRIGHT","MobMapButtonFrame","TOPRIGHT",-100,-2);
		MobMapButtonFrameCurrentMobFrame:ClearAllPoints();
		MobMapButtonFrameCurrentMobFrame:SetPoint("TOPRIGHT","MobMapButtonFrame","TOPRIGHT",-4,-24);
		MobMapButtonFrameCurrentMob:SetJustifyH("right");
		MobMapCheckButton:SetChecked(mobmap_enabled);
		MobMapButtonFrame:Show();
	end
	if(mobmap_button_position==1) then
		if(WorldMapFrame.scale==WORLDMAP_RATIO_MINI) then
			MobMapButtonFrame:SetPoint("BOTTOMLEFT","WorldMapPositioningGuide","BOTTOMLEFT",10,-10);
		else
			MobMapButtonFrame:SetPoint("BOTTOMLEFT","WorldMapPositioningGuide","BOTTOMLEFT",0,4);
		end
		MobMapButtonFrame:SetFrameLevel(WorldMapPositioningGuide:GetFrameLevel()+20);
		MobMapButton:ClearAllPoints();
		MobMapButton:SetPoint("BOTTOMLEFT","MobMapButtonFrame","BOTTOMLEFT",4,0);
		MobMapCheckButton:ClearAllPoints();
		MobMapCheckButton:SetPoint("LEFT","MobMapButton","RIGHT",0,0);
		MobMapButtonFrameCurrentMobFrame:ClearAllPoints();
		MobMapButtonFrameCurrentMobFrame:SetPoint("LEFT","MobMapCheckButton","RIGHT",6,0);
		MobMapButtonFrameCurrentMob:SetJustifyH("left");
		MobMapCheckButton:SetChecked(mobmap_enabled);
		MobMapButtonFrame:Show();
	end
	if(mobmap_button_position==3) then
		MobMapButtonFrame:SetPoint("BOTTOMRIGHT","WorldMapPositioningGuide","BOTTOMRIGHT",0,4);
		MobMapButtonFrame:SetFrameLevel(WorldMapPositioningGuide:GetFrameLevel()+20);
		MobMapButton:ClearAllPoints();
		MobMapButton:SetPoint("BOTTOMRIGHT","MobMapButtonFrame","BOTTOMRIGHT",-4,0);
		MobMapCheckButton:ClearAllPoints();
		MobMapCheckButton:SetPoint("RIGHT","MobMapButton","LEFT",0,0);
		MobMapButtonFrameCurrentMobFrame:ClearAllPoints();
		MobMapButtonFrameCurrentMobFrame:SetPoint("RIGHT","MobMapCheckButton","LEFT",-6,-1);
		MobMapButtonFrameCurrentMob:SetJustifyH("right");
		MobMapCheckButton:SetChecked(mobmap_enabled);
		MobMapButtonFrame:Show();
	end
end

function MobMap_ShowMobMapFrame()
	if(mobmap_disabled) then return; end
	if(not MobMapFrame:IsVisible()) then
		ShowUIPanel(MobMapFrame);
		if(MobMapMobSearchFrame) then MobMap_UpdateMobMapFrame(); end
	end
end

function MobMap_ToggleMobMapFrame()
	if(mobmap_disabled) then return; end
	if(MobMapFrame:IsVisible()) then
		HideUIPanel(MobMapFrame);
	else
		ShowUIPanel(MobMapFrame);
		if(MobMapMobSearchFrame) then MobMap_UpdateMobMapFrame(); end
	end
end

function MobMap_ShowExportFrame()
	if(MobMapExportFrame:IsVisible()) then
		HideUIPanel(MobMapExportFrame);
	else
		if(GetLocale()~="deDE" and GetLocale()~="enUS" and GetLocale()~="enGB") then
			MobMap_DisplayMessage(MOBMAP_UNSUPPORTED_LOCALE);
		else
			MobMap_ExportData();
		end
	end
end

function MobMapFrame_OnLoad(self)
	self:RegisterEvent("WORLD_MAP_UPDATE");
	self:RegisterEvent("ADDON_LOADED");
	MobMap_ShowPanel("MobMapAboutFrame");
end

mobmap_lastzone="";
mobmap_lastzonelevel=0;

function MobMapFrame_OnEvent(self)
	if(event=="COMBAT_LOG_EVENT_UNFILTERED") then
		if(mobmap_scanning) then
			MobMap_ProcessCombatLog(arg2, arg3, arg5, arg9);
		end
	elseif(event=="WORLD_MAP_UPDATE") then
		if(mobmap_enabled and WorldMapFrame:IsVisible()) then
			if(mobmap_button_position>0) then MobMapButtonFrame:Show(); end
			MobMapDotParentFrame:Show();
		end
		if(mobmap_enabled and (WorldMapFrame:IsVisible() or (BattlefieldMinimap and BattlefieldMinimap:IsVisible())) and (MobMapMobSearchFrame or MobMapPickupListFrame or MobMapQuestListFrame or mobmap_currentlyshown or mobmap_multidisplay)) then
			if(mobmap_lastzone~=MobMap_GetCurrentMapZoneName() or mobmap_lastzonelevel~=GetCurrentMapDungeonLevel()) then
				mobmap_lastzone=MobMap_GetCurrentMapZoneName();
				mobmap_lastzonelevel=GetCurrentMapDungeonLevel();
				MobMap_Display();
			end
		end
	elseif(event=="PLAYER_TARGET_CHANGED") then
		if(mobmap_scanning) then 
			MobMap_ScanTarget();
		else
			self:UnregisterEvent("PLAYER_TARGET_CHANGED");
		end
	elseif(event=="UNIT_SPELLCAST_SENT") then
		if(mobmap_scanning) then
			MobMap_Monitor_SpellCastSent(arg1, arg2, arg3, arg4);
		else
			self:UnregisterEvent("UNIT_SPELLCAST_SENT");
		end
	elseif(event=="UNIT_SPELLCAST_SUCCEEDED") then
		if(mobmap_scanning) then
			MobMap_Monitor_SpellCastSucceeded(arg1, arg2, arg3);
		else
			self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED");
		end
	elseif(event=="UNIT_SPELLCAST_FAILED") then
		if(mobmap_scanning) then
			MobMap_Monitor_SpellCastFailed(arg1);
		else
			self:UnregisterEvent("UNIT_SPELLCAST_FAILED");
		end
	elseif(event=="UNIT_SPELLCAST_INTERRUPTED") then
		if(mobmap_scanning) then
			MobMap_Monitor_SpellCastInterrupted(arg1);
		else
			self:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTED");
		end
	elseif(event=="CHAT_MSG_COMBAT_XP_GAIN") then
		if(mobmap_scanning) then
			MobMap_QuestMonitor_XPGained(arg1);
		else
			self:UnregisterEvent("CHAT_MSG_COMBAT_XP_GAIN");
		end
	elseif(event=="CHAT_MSG_COMBAT_FACTION_CHANGE") then
		if(mobmap_scanning) then
			MobMap_QuestMonitor_FactionChange(arg1);
		else
			self:UnregisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE");
		end
	elseif(event=="LOOT_OPENED") then
		if(mobmap_scanning) then
			MobMap_ScanLoot();
		else
			self:UnregisterEvent("LOOT_OPENED");
		end
	elseif(event=="QUEST_LOG_UPDATE") then
		if(mobmap_scanning) then 
			MobMap_ScanQuestLog();
			MobMap_ScanEventQuestObjectivesForUpdates();
		end
		if(mobmap_use_questtracker) then
			MobMap_QuestTracker_FullUpdate();
		end
	elseif(event=="MERCHANT_SHOW") then
		if(mobmap_scanning) then 
			MobMap_ScanMerchant();
		end
	elseif(event=="MERCHANT_UPDATE") then
		if(mobmap_scanning) then 
			MobMap_ScanMerchant();
		end
	elseif(event=="TRAINER_SHOW") then
		if(mobmap_scanning) then
			MobMap_ScanTrainer();
		end
	elseif(event=="TRAINER_UPDATE") then
		if(mobmap_scanning) then
			MobMap_ScanTrainer();
		end
	elseif(event=="ZONE_CHANGED_NEW_AREA") then
		if(mobmap_use_questtracker) then
			MobMap_QuestTracker_FullUpdate();
		end	
	elseif(event=="ADDON_LOADED") then
		if(arg1=="MobMap") then
			self:UnregisterEvent("ADDON_LOADED");			
			local addonsAvailable=true;
			local i;
			for i=1,13,1 do
				local name, _, _, _, loadable = GetAddOnInfo("MobMapDatabaseStub"..i);
				if(name==nil or loadable==nil) then addonsAvailable=false; end
			end

			if(addonsAvailable==false) then
				MobMap_DisplayMessage(MOBMAP_ERROR_ON_LOAD);
				mobmap_disabled=true;
			else
				if(mobmap_dbinfo==nil) then
					MobMap_ErrorMessage(MOBMAP_ERROR_NO_DB_INSTALLED);
					mobmap_disabled=true;
				else
					if(MobMap_GetDBVersion()~=MOBMAP_DBVERSION) then
						MobMap_ErrorMessage(MOBMAP_ERROR_INCOMPATIBLE_DB);
						mobmap_disabled=true;
					else
						MobMap_DisplayMessage(MOBMAP_VERSION.." loaded");
					end
				end
			end

			if(not mobmap_disabled) then
				SLASH_MOBMAP1 = "/mobmap";
				SlashCmdList["MOBMAP"] = MobMap_Command;
			else
				MobMapButtonFrame:Hide();
			end

			if(mobmap_scanning==true and (GetLocale()~="deDE" and GetLocale()~="enUS" and GetLocale()~="enGB")) then
				mobmap_scanning=false;
			end

			if(mobmap_scanning==true or mobmap_use_questtracker==true) then
				self:RegisterEvent("QUEST_LOG_UPDATE");
			end

			if(mobmap_scanning==true) then
				local k,v;
				local count=0;
				for k,v in pairs(mobmap_positions) do
					count=count+1;
				end
				if(count>2000) then
					MobMap_DisplayMessage(MOBMAP_DATA_SIZE_WARNING);
				end				
				self:RegisterEvent("PLAYER_TARGET_CHANGED");
				self:RegisterEvent("MERCHANT_SHOW");
				self:RegisterEvent("MERCHANT_UPDATE");
				self:RegisterEvent("TRAINER_UPDATE");
				self:RegisterEvent("TRAINER_SHOW");
				self:RegisterEvent("LOOT_OPENED");
				self:RegisterEvent("UNIT_SPELLCAST_SENT");
				self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
				self:RegisterEvent("UNIT_SPELLCAST_FAILED");
				self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED");
				self:RegisterEvent("CHAT_MSG_COMBAT_XP_GAIN");
				self:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE");
				self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
				self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
				MobMap_HookGetTradeSkillInfo();
				MobMap_HookUseContainerItem();				
				MobMap_HookAcceptQuest();
				MobMap_HookCompleteQuest();
			end
			if(mobmap_scanning or mobmap_track_quest_completion) then
				MobMap_HookGetQuestReward();
			end
			if(mobmap_language~=nil and GetLocale()~=mobmap_language) then
				MobMap_DeletePositionData();
			end
			mobmap_language=GetLocale();
			mobmap_game_version=GetBuildInfo().."|"..GetCVar("realmList");
			if(not mobmap_disabled) then
				if(mobmap_alternate_button_position==true) then
					mobmap_button_position=2;
				end
				MobMap_PlaceMobMapButtonFrame();
			end
			MobMap_MinimapButton_UpdateVisibility();
			MobMap_QuestTracker_Setup();
			mobmap_astrolabe_library:Register_OnEdgeChanged_Callback(MobMap_AstrolabeOnEdgeChangedCallback, "MobMapAstrolabeEdgeCallback");
			mobmap_init_finished=true;
		end
	elseif(event=="QUEST_QUERY_COMPLETE") then
		MobMap_FinishCompletedQuestSync();
	end
end

function MobMapDotFrame_OnClick(self)
	if(Cartographer_Waypoints and Cartographer:IsModuleActive(Cartographer_Waypoints)) then 
		Cartographer_Waypoints:SetPointAsWaypoint(self.xcoord/100, self.ycoord/100);
		Cartographer_Waypoints:UpdateWaypoint();
	elseif(TomTom) then
		if(mobmap_tomtom_waypoint) then
			TomTom:RemoveWaypoint(mobmap_tomtom_waypoint);
		end
		local zoneindex=mobmap_zoneindex[MobMap_GetCurrentMapZoneName()];
		if(zoneindex) then
			mobmap_tomtom_waypoint=TomTom:AddZWaypoint(zoneindex.c, zoneindex.z, self.xcoord, self.ycoord, MobMapButtonFrameCurrentMob:GetText());
			TomTom:SetCrazyArrow(mobmap_tomtom_waypoint, TomTom.profile.arrow.arrival, MobMapButtonFrameCurrentMob:GetText());
			return;
		end
	end
end

function MobMap_GetCurrentMapZoneName(useOldWay)
	if(not useOldWay) then
		local zonename=mobmap_areaidtozonename[GetCurrentMapAreaID()-1];
		if(zonename) then return zonename; end
	end
	local zonenames={GetMapZones(GetCurrentMapContinent())};
	return zonenames[GetCurrentMapZone()];
end

mobmap_zonenametoareaid = {};
mobmap_areaidtozonename = {};
function MobMap_SetupZoneNameToAreaIDLookupTable()
	local zonename;
	local areaid
	for areaid=1, 1000, 1 do
		SetMapByID(areaid);
		if((GetCurrentMapAreaID()-1)==areaid) then
			zonename=MobMap_GetCurrentMapZoneName(true);
			if(zonename and zonename~=mobmap_areaidtozonename[4]) then
				mobmap_zonenametoareaid[zonename]=areaid;
				mobmap_areaidtozonename[areaid]=zonename;
			end
		end
	end

	for zonename,areaid in pairs(MOBMAP_ADDITIONAL_ZONE_TO_AREAID_MAPPINGS) do
		mobmap_zonenametoareaid[zonename]=areaid;
		mobmap_areaidtozonename[areaid]=zonename;
	end
end
MobMap_SetupZoneNameToAreaIDLookupTable();

function MobMap_SetMapToZone(zonename, zonelevel)
	if(zonename==MobMap_GetCurrentMapZoneName() and (zonelevel==nil or zonelevel==GetCurrentMapDungeonLevel())) then return true; end
	local areaid=mobmap_zonenametoareaid[zonename];
	if(areaid) then
		SetMapByID(areaid);
		if(zonelevel) then SetDungeonMapLevel(zonelevel); end
		return true;
	end
	--local continentnames={GetMapContinents()};
	--for k,v in pairs(continentnames) do
	--	local zonenames={GetMapZones(k)};
	--	for x,y in pairs(zonenames) do
	--		if(y==zonename) then
	--			SetMapZoom(k,x);
	--			if(zonelevel) then SetDungeonMapLevel(zonelevel); end
	--			return true;
	--		end
	--	end
	--end
	return false;
end


mobmap_timer=0;
mobmap_tracker_was_updated=false;
mobmap_last_x=0;
mobmap_last_y=0;

mobmap_astrolabe_library_minimap_update_time=0.2;
mobmap_astrolabe_library_time_changed=false;

function MobMapTimerFrame_OnUpdate()
	mobmap_timer=mobmap_timer-arg1;
	if(mobmap_timer<=0) then
		MobMapQuestWatchButtons_Update();
		MobMapQuestLogButtons_Update();
		MobMapReagentButtons_Update();
		MobMapQuestGossipButtons_Update();

		local x, y = GetPlayerMapPosition("player");
		if(not(x==0 and y==0)) then
			local continent, zone, localx, localy = mobmap_astrolabe_library:GetCurrentPlayerPosition();
			local localzonename=nil;
			if(mobmap_continentindex[continent] and mobmap_continentindex[continent][zone]) then
				localzonename=mobmap_continentindex[continent][zone];
			end

			if((localx~=mobmap_last_x or localy~=mobmap_last_y) and localzonename) then
				-- update MobMap minimap icons
				if(mobmap_astrolabe_library and mobmap_minimap==true and mobmap_enabled==true) then
					MobMap_UpdateMinimapIcons();
				end

				-- update Quest Tracker
				if(not mobmap_tracker_was_updated) then
					if(localx~=nil and mobmap_astrolabe_library and mobmap_use_questtracker and mobmap_questtracker_status.visible and mobmap_questtracker_status.showdistance) then
						MobMap_QuestTracker_UpdateQuests(localx, localy, localzonename, true);
					end
					mobmap_tracker_was_updated=true;
				else
					mobmap_tracker_was_updated=false;
				end

				mobmap_last_x=localx;
				mobmap_last_y=localy;
			end
		end

		mobmap_timer=0.2;
	end
end

function MobMap_ShowPanel(panel)
	if(MobMapMobSearchFrame~=nil) then MobMapMobSearchFrame:Hide(); end
	if(MobMapQuestListFrame~=nil) then MobMapQuestListFrame:Hide(); end
	if(MobMapMerchantListFrame~=nil) then MobMapMerchantListFrame:Hide(); end
	if(MobMapRecipeListFrame~=nil) then MobMapRecipeListFrame:Hide(); end
	if(MobMapDropListFrame~=nil) then MobMapDropListFrame:Hide(); end
	if(MobMapPickupListFrame~=nil) then MobMapPickupListFrame:Hide(); end
	if(MobMapQuestEventFrame~=nil) then MobMapQuestEventFrame:Hide(); end
	if(MobMapAboutFrame~=nil) then MobMapAboutFrame:Hide(); end
	PanelTemplates_DeselectTab(MobMapSearchModeButton);
	PanelTemplates_DeselectTab(MobMapQuestModeButton);
	PanelTemplates_DeselectTab(MobMapMerchantModeButton);
	PanelTemplates_DeselectTab(MobMapRecipeModeButton);
	PanelTemplates_DeselectTab(MobMapDropModeButton);
	PanelTemplates_DeselectTab(MobMapPickupModeButton);
	PanelTemplates_DeselectTab(MobMapQuestEventModeButton);
	PanelTemplates_DeselectTab(MobMapAboutModeButton);
	if(panel=="MobMapMobSearchFrame") then
		MobMap_LoadDatabase(MOBMAP_POSITION_DATABASE);
		PanelTemplates_SelectTab(MobMapSearchModeButton);
		MobMapMobSearchFrame:Show();
		MobMap_UpdateMobMapFrame();
	end

	if(panel=="MobMapQuestListFrame") then
		MobMap_LoadDatabase(MOBMAP_QUEST_DATABASE);
		MobMapQuestListFrame:Show();
		PanelTemplates_SelectTab(MobMapQuestModeButton);
		if(mobmap_questlist==nil) then
			MobMap_RefreshQuestList();
		end
	end

	if(panel=="MobMapMerchantListFrame") then
		MobMap_LoadDatabase(MOBMAP_MERCHANT_DATABASE);
		MobMapMerchantListFrame:Show();
		PanelTemplates_SelectTab(MobMapMerchantModeButton);
		if(mobmap_merchantlist==nil) then
			MobMap_RefreshMerchantList();
		end
	end

	if(panel=="MobMapRecipeListFrame") then
		MobMap_LoadDatabase(MOBMAP_RECIPE_DATABASE);
		MobMapRecipeListFrame:Show();
		PanelTemplates_SelectTab(MobMapRecipeModeButton);
		if(mobmap_recipelist==nil) then
			MobMap_RefreshRecipeList();
		end
	end

	if(panel=="MobMapDropListFrame") then
		MobMap_LoadDatabase(MOBMAP_DROP_DATABASE);
		MobMapDropListFrame:Show();
		PanelTemplates_SelectTab(MobMapDropModeButton);
	end

	if(panel=="MobMapPickupListFrame") then
		MobMap_LoadDatabase(MOBMAP_PICKUP_DATABASE);
		MobMapPickupListFrame:Show();
		PanelTemplates_SelectTab(MobMapPickupModeButton);
	end

	if(panel=="MobMapQuestEventFrame") then
		MobMap_LoadDatabase(MOBMAP_POSITION_DATABASE);
		PanelTemplates_SelectTab(MobMapQuestEventModeButton);
		MobMapQuestEventFrame:Show();
	end

	if(panel=="MobMapAboutFrame") then
		PanelTemplates_SelectTab(MobMapAboutModeButton);
		MobMapAboutFrame:Show();
	end
	MobMap_ResizeWindow();
end

local mobmap_max_watch_lines=0;

function MobMapQuestWatchButtons_Update()
	if(mobmap_disabled) then return; end
	if(WatchFrame:IsVisible()) then
		local linecount=#(WATCHFRAME_QUESTLINES);
		if(WatchFrame.collapsed) then linecount=0; end
		local i;
		for i=1,linecount,1 do
			local frame=WATCHFRAME_QUESTLINES[i].text;
			local button=getglobal("MobMapQuestWatchButton"..i);
			if(mobmap_hide_questtracker_buttons==false) then
				local questobj=frame:GetText();
				if(questobj) then
					local parent=frame:GetParent();
					if(button==nil) then
						button=CreateFrame("Frame","MobMapQuestWatchButton"..i,QuestWatchFrame,"MobMapQuestButtonFrameTemplate");
						button:ClearAllPoints();
						button:SetScale(UIParent:GetScale()*0.8);
						button:SetPoint("RIGHT",frame,"LEFT",-9,0);
						button:SetAlpha(1.0);
					end
					if(parent.dash:IsVisible() and parent.dash:GetText()==QUEST_DASH) then
						button.questobj=questobj;
						button.questtitle=nil;
						button.unknowntext=nil;
						button.questid=nil;
						button:SetScale(UIParent:GetScale()*0.6);
						button:SetPoint("RIGHT",frame,"LEFT",-9,0);
						button:Show();
					else
						local title=MobMap_FilterQuestTitle(questobj);
						button.questtitle=title;
						button.questobj=nil;
						button.unknowntext=nil;
						local blizzid = MobMap_GetQuestIDFromQuestLogByTitle(title);
						button.questid=blizzid;
						local k=1;
						local poiButton=getglobal("WatchFrameQuestPOI"..k);
						local hasPoi=false;
						while(poiButton~=nil) do
							if(poiButton:IsVisible()) then
								local point, relativeTo = poiButton:GetPoint(1);
								if(relativeTo==parent) then
									button:ClearAllPoints();
									button:SetPoint("RIGHT",frame,"LEFT",-32*(1/UIParent:GetScale()),0);
									hasPoi=true;
									break;
								end
							end
							k=k+1;
							poiButton=getglobal("WatchFrameQuestPOI"..k);
						end
						if(not hasPoi) then
							k=MAX_QUESTLOG_QUESTS+1;
							poiButton=getglobal("WatchFrameQuestPOI"..k);
							while(poiButton~=nil) do
								if(poiButton:IsVisible()) then
									local point, relativeTo = poiButton:GetPoint(1);
									if(relativeTo==parent) then
										button:ClearAllPoints();
										button:SetPoint("RIGHT",frame,"LEFT",-32*(1/UIParent:GetScale()),0);
										hasPoi=true;
										break;
									end
								end
								k=k+1;
								poiButton=getglobal("WatchFrameQuestPOI"..k);
							end
							if(not hasPoi) then
								k=1;
								poiButton=getglobal("WatchFrameCompletedQuest"..k);
								while(poiButton~=nil) do
									if(poiButton:IsVisible()) then
										local point, relativeTo = poiButton:GetPoint(1);
										if(relativeTo==parent) then
											button:ClearAllPoints();
											button:SetPoint("RIGHT",frame,"LEFT",-18*(1/UIParent:GetScale()),0);
											hasPoi=true;
											break;
										end
									end
									k=k+1;
									poiButton=getglobal("WatchFrameQuestPOI"..k);
								end
							end
						end
						if(not hasPoi) then
							button:SetPoint("RIGHT",frame,"LEFT",-2,0);
						end
						button:SetScale(UIParent:GetScale()*0.8);
						button:Show();
					end
				end
			else
				if(button~=nil) then button:Hide(); end
			end
		end
		if(linecount<mobmap_max_watch_lines) then
			for i=linecount+1, mobmap_max_watch_lines, 1 do
				local button=getglobal("MobMapQuestWatchButton"..i);
				if(button~=nil) then button:Hide(); end
			end			
		end
		mobmap_max_watch_lines=linecount;
	end
	if(EQL3_QuestWatchFrame~=nil and EQL3_QuestWatchFrame:IsVisible()) then
		local i;
		for i=1,30,1 do
			local frame=getglobal("EQL3_QuestWatchLine"..i);
			local button=getglobal("MobMapELQ3QuestWatchButton"..i);
			if(frame:IsVisible() and mobmap_hide_questtracker_buttons==false) then
				local questobj=frame:GetText();
				if(questobj) then
					if(button==nil) then
						button=CreateFrame("Frame","MobMapELQ3QuestWatchButton"..i,EQL3_QuestWatchFrame,"MobMapQuestButtonFrameTemplate");
						button:ClearAllPoints();
						button:SetPoint("RIGHT","EQL3_QuestWatchLine"..i,"LEFT",0,0);
						button:SetAlpha(1.0);
					end
					if(string.find(questobj, "^Quest Tracker.*")==nil) then
						questobj=MobMap_FilterQuestTitle(questobj);
						button.questobj=nil;
						button.questtitle=nil;
						button.unknowntext=questobj;
						button.questid=nil;
						button:Show();
					else
						button:Hide();
					end
				end
			else
				if(button~=nil) then button:Hide(); end
			end
		end
	end
end

function MobMapQuestWatchButtons_HideAll()
	local i;
	for i=1,30,1 do
		local frame=getglobal("MobMapQuestWatchButton"..i);
		if(frame~=nil) then frame:Hide(); end
	end
	for i=1,30,1 do
		local frame=getglobal("MobMapELQ3QuestWatchButton"..i);
		if(frame~=nil) then frame:Hide(); end
	end
end

function MobMapQuestLogButtons_Update()
	if(mobmap_disabled) then return; end
	if(QuestLogFrame:IsVisible()) then		
		local frame=getglobal("QuestInfoTitleHeader");
		local button=getglobal("MobMapQuestLogTitleButton");
		if(button==nil) then
			button=CreateFrame("Frame","MobMapQuestLogTitleButton",QuestLogDetailScrollChildFrame,"MobMapQuestButtonFrameTemplate");
			button:ClearAllPoints();
			button:SetFrameStrata("MEDIUM");
			button:SetPoint("LEFT","QuestInfoTitleHeader","RIGHT",-12,-2);
			button:SetAlpha(1.0);
		end
		local title=MobMap_FilterQuestTitle(frame:GetText());
		button.questtitle=title;
		button.questobj=nil;
		button.unknowntext=nil;
		button.questid=MobMap_GetQuestIdFromQuestLog(GetQuestLogSelection());
		button.questobjectivetext=QuestInfoDescriptionText:GetText();
		if(mobmap_hide_questlog_buttons==false) then
			button:Show();
		else
			button:Hide();
		end

		local i;
		for i=1,10,1 do
			frame=getglobal("QuestInfoObjective"..i);
			button=getglobal("MobMapQuestLogButton"..i);
			if(frame:IsVisible() and mobmap_hide_questlog_buttons==false) then
				local questobj=frame:GetText();
				if(questobj) then
					if(button==nil) then
						button=CreateFrame("Frame","MobMapQuestLogButton"..i,QuestLogDetailScrollChildFrame,"MobMapQuestButtonFrameTemplate");
						button:ClearAllPoints();
						button:SetFrameStrata("MEDIUM");
						button:SetPoint("LEFT","QuestInfoObjective"..i,"RIGHT",-16,0);
						button:SetAlpha(1.0);
						button:SetScale(UIParent:GetScale());
					end
					button.questobj=questobj;
					button.questtitle=nil;
					button.unknowntext=nil;
					button.questid=nil;
					button:Show();
				end
			else
				if(button~=nil) then button:Hide(); end
			end
		end
	end

	if(EQL3_QuestLogFrame~=nil and EQL3_QuestLogFrame:IsVisible()) then		
		local frame=getglobal("EQL3_QuestLogQuestTitle");
		local button=getglobal("MobMapELQ3QuestLogTitleButton");
		if(button==nil) then
			button=CreateFrame("Frame","MobMapELQ3QuestLogTitleButton",EQL3_QuestLogDetailScrollChildFrame,"MobMapQuestButtonFrameTemplate");
			button:ClearAllPoints();
			button:SetFrameStrata("MEDIUM");
			button:SetPoint("LEFT","EQL3_QuestLogQuestTitle","RIGHT",-8,0);
			button:SetAlpha(1.0);
		end
		local title=MobMap_FilterQuestTitle(frame:GetText());
		button.questtitle=title;
		button.questid=MobMap_GetQuestIdFromQuestLog(GetQuestLogSelection());
		button.questobj=nil;
		button.unknowntext=nil;
		button.questobjectivetext=nil;
		if(mobmap_hide_questlog_buttons==false) then
			button:Show();
		else
			button:Hide();
		end

		local i;
		for i=1,10,1 do
			frame=getglobal("EQL3_QuestLogObjective"..i);
			button=getglobal("MobMapELQ3QuestLogButton"..i);
			if(frame:IsVisible() and mobmap_hide_questlog_buttons==false) then
				local questobj=frame:GetText();
				if(questobj) then
					if(button==nil) then
						button=CreateFrame("Frame","MobMapELQ3QuestLogButton"..i,EQL3_QuestLogDetailScrollChildFrame,"MobMapQuestButtonFrameTemplate");
						button:ClearAllPoints();
						button:SetFrameStrata("MEDIUM");
						button:SetPoint("LEFT","EQL3_QuestLogObjective"..i,"RIGHT",-16,0);
						button:SetAlpha(0.6);
					end
					button.questobj=questobj;
					button.questtitle=nil;
					button.unknowntext=nil;
					button.questid=nil;
					button:Show();
				end
			else
				if(button~=nil) then button:Hide(); end
			end
		end
	end
	
	if(UberQuest_Details~=nil and UberQuest_Details:IsVisible()) then		
		local frame=getglobal("UberQuest_Details_ScrollChild_QuestTitle");
		local button=getglobal("MobMapUberQuestQuestLogTitleButton");
		if(button==nil) then
			button=CreateFrame("Frame","MobMapUberQuestQuestLogTitleButton",UberQuest_Details_ScrollChild,"MobMapQuestButtonFrameTemplate");
			button:ClearAllPoints();
			button:SetFrameStrata("MEDIUM");
			button:SetPoint("LEFT","UberQuest_Details_ScrollChild_QuestTitle","RIGHT",-8,0);
			button:SetAlpha(0.6);
		end
		local title=MobMap_FilterQuestTitle(frame:GetText());
		button.questtitle=title;
		button:Show();

		local i;
		for i=1,10,1 do
			frame=getglobal("UberQuest_Details_ScrollChild_Objective"..i);
			button=getglobal("MobMapUberQuestQuestLogButton"..i);
			if(frame:IsVisible() and mobmap_hide_questlog_buttons==false) then
				local questobj=frame:GetText();
				if(questobj) then
					if(button==nil) then
						button=CreateFrame("Frame","MobMapUberQuestQuestLogButton"..i,UberQuest_Details_ScrollChild,"MobMapQuestButtonFrameTemplate");
						button:ClearAllPoints();
						button:SetFrameStrata("MEDIUM");
						button:SetPoint("LEFT","UberQuest_Details_ScrollChild_Objective"..i,"RIGHT",-16,0);
						button:SetAlpha(0.6);
					end
					button.questobj=questobj;
					button:Show();
				end
			else
				if(button~=nil) then button:Hide(); end
			end
		end
	end
end

function MobMapQuestLogButtons_HideAll()
	local i;
	frame=getglobal("MobMapQuestLogTitleButton");
	if(frame~=nil) then frame:Hide(); end
	for i=1,10,1 do
		frame=getglobal("MobMapQuestLogButton"..i);
		if(frame~=nil) then frame:Hide(); end
	end
	frame=getglobal("MobMapELQ3QuestLogTitleButton");
	if(frame~=nil) then frame:Hide(); end
	for i=1,10,1 do
		frame=getglobal("MobMapELQ3QuestLogButton"..i);
		if(frame~=nil) then frame:Hide(); end
	end
end

function MobMapReagentButtons_Update()
	if(mobmap_disabled or TradeSkillFrame==nil) then return; end
	if(TradeSkillFrame:IsVisible()) then
		local i;
		local parentFrame;
		local reagentFrame;
		local iStart;
		if(ATSWFrame and ATSWFrame:IsVisible()) then
			parentFrame=ATSWFrame;
			reagentFrame="ATSWReagent";
			iStart=9;
		else
			parentFrame=TradeSkillFrame;
			reagentFrame="TradeSkillReagent";
			iStart=1;
		end
		for i=1,8,1 do
			local frame=getglobal(reagentFrame..i);
			local button=getglobal("MobMapReagentSearchButton"..(i+iStart));
			if(frame:IsVisible() and mobmap_hide_reagent_buttons==false) then
				local reagentName=getglobal(reagentFrame..i.."Name"):GetText();
				if(button==nil) then
					button=CreateFrame("Frame","MobMapReagentSearchButton"..(i+iStart),getglobal(reagentFrame..i),"MobMapQuestButtonFrameTemplate");
					button:ClearAllPoints();
					button:SetPoint("BOTTOMRIGHT",reagentFrame..i,"BOTTOMRIGHT",-2,4);
					button:SetFrameLevel(100000);
					button:SetFrameStrata(getglobal(reagentFrame..i):GetFrameStrata());
					button:SetAlpha(1.0);
					button:SetScale(0.6);
				end
				button.reagentname=reagentName;
				button:Show();
			else
				if(button~=nil) then button:Hide(); end
			end
		end
	end
end

function MobMapQuestGossipButtons_Update()
	if(mobmap_disabled) then return; end
	if(QuestFrame:IsVisible()) then		
		local frame=nil;
		local parentframe=nil;
		local objectiveframe=nil;
		if(QuestProgressTitleText and QuestProgressTitleText:IsVisible()) then
			frame=QuestProgressTitleText;
			parentframe=QuestProgressScrollChildFrame;
		elseif(QuestTitleText and QuestTitleText:IsVisible()) then
			frame=QuestTitleText;
			parentframe=QuestDetailScrollChildFrame;
			objectiveframe=QuestObjectiveText;
		elseif(QuestRewardTitleText and QuestRewardTitleText:IsVisible()) then
			frame=QuestRewardTitleText;
			parentframe=QuestRewardScrollChildFrame;
		elseif(QuestInfoTitleHeader and QuestInfoTitleHeader:IsVisible()) then
			frame=QuestInfoTitleHeader;
			parentframe=frame:GetParent();
			objectiveframe=QuestInfoObjectivesText;
		end
		local button=getglobal("MobMapQuestGossipTitleButton");
		if(frame~=nil) then
			if(button==nil) then
				button=CreateFrame("Frame","MobMapQuestGossipTitleButton",parentframe,"MobMapQuestButtonFrameTemplate");
			end
			button:SetParent(parentframe);
			button:ClearAllPoints();
			button:SetFrameStrata("MEDIUM");
			button:SetPoint("LEFT",frame,"RIGHT",-8,0);
			button:SetAlpha(0.6);
			local title=MobMap_FilterQuestTitle(frame:GetText());
			button.questtitle=title;
			if(objectiveframe) then
				button.questobjectivetext=objectiveframe:GetText();
			else
				button.questobjectivetext=nil;
			end
			if(mobmap_hide_questgossip_buttons==false) then
				button:Show();
			else
				button:Hide();
			end
		else
			if(button) then button:Hide(); end
		end
	end
end

-- position display

mobmap_currentlist = {};
mobmap_zonelist = {};
mobmap_currentlyshown = nil;
mobmap_multidisplay = nil;
mobmap_multidisplay_preferredzone = nil;
mobmap_multidisplay_caption = nil;

mobmap_displayed_dot_count = 0;
mobmap_flash_timeout = 0;

function MobMap_ProcessDotEffects(self,arg1)
	if(mobmap_flash_timeout>0) then
		mobmap_flash_timeout=mobmap_flash_timeout-arg1;
		if(floor(mobmap_flash_timeout*3)%2==0) then
			if(self:GetAlpha()>0.5) then self:SetAlpha(0.0000001); end
		else
			if(self:GetAlpha()<0.5) then self:SetAlpha(1.0); end
		end
	else
		if(self:GetAlpha()<0.5) then self:SetAlpha(1.0); end
	end
end

function MobMap_DisplayPositionData(posdata, mobid, ihid, freetext)
	if(posdata==nil) then return; end
	for k,v in pairs(posdata) do
		for x=v.x1,v.x2,1 do
			local frame=getglobal("MobMapDot"..x.."_"..v.y);
			if(frame==nil) then 
				frame=CreateFrame("Button","MobMapDot"..x.."_"..v.y,MobMapDotParentFrame,"MobMapDotFrameTemplate");
				frame:SetPoint("TOPLEFT",MobMapDotParentFrame,"TOPLEFT",x*frame:GetWidth(),-v.y*frame:GetHeight());
				frame:SetFrameStrata("FULLSCREEN");
				frame:SetFrameLevel(MobMapDotParentFrame:GetFrameLevel()+21);
				frame.xcoord=x;
				frame.ycoord=v.y;
			end
			if(mobid) then
				if(frame.idtable==nil) then frame.idtable={}; end
				table.insert(frame.idtable,mobid);
			end
			if(ihid) then
				if(frame.ihidtable==nil) then frame.ihidtable={}; end
				table.insert(frame.ihidtable,ihid);
			end
			if(freetext) then
				frame.freetext=freetext;
			end
			mobmap_displayed_dot_count=mobmap_displayed_dot_count+1;
			getglobal(frame:GetName().."Texture"):SetVertexColor(mobmap_outer_dot_color.r,mobmap_outer_dot_color.g,mobmap_outer_dot_color.b);
			getglobal(frame:GetName().."Texture"):SetAlpha(mobmap_outer_dot_color.a);
			getglobal(frame:GetName().."Texture2"):SetVertexColor(mobmap_inner_dot_color.r,mobmap_inner_dot_color.g,mobmap_inner_dot_color.b);
			getglobal(frame:GetName().."Texture2"):SetAlpha(mobmap_inner_dot_color.a);
			frame:Show();

			-- battlefield minimap frame
			if(BattlefieldMinimap and mobmap_battlefield_minimap==true) then
				local frame=getglobal("MobMapBattlefieldMinimapDot"..x.."_"..v.y);
				if(frame==nil) then
					frame=CreateFrame("Button","MobMapBattlefieldMinimapDot"..x.."_"..v.y,BattlefieldMinimap,"MobMapBattlefieldMinimapDotFrameTemplate");
					frame:SetPoint("TOPLEFT",BattlefieldMinimap,"TOPLEFT",x*frame:GetWidth(),-v.y*frame:GetHeight());
					frame:SetFrameStrata("BACKGROUND");
					frame:SetFrameLevel(BattlefieldMinimap:GetFrameLevel()+21);
					frame.xcoord=x;
					frame.ycoord=v.y;
				end
				if(mobid) then
					if(frame.idtable==nil) then frame.idtable={}; end
					table.insert(frame.idtable,mobid);
				end
				if(ihid) then
					if(frame.ihidtable==nil) then frame.ihidtable={}; end
					table.insert(frame.ihidtable,ihid);
				end
				if(freetext) then
					frame.freetext=freetext;
				end
				getglobal(frame:GetName().."Texture"):SetVertexColor(mobmap_inner_dot_color.r,mobmap_inner_dot_color.g,mobmap_inner_dot_color.b);
				getglobal(frame:GetName().."Texture"):SetAlpha(mobmap_inner_dot_color.a);
				frame:Show();
			end
		end
	end

	if(mobmap_displayed_dot_count>0) then
		MobMapDotParentFrame:Show();
		if(mobmap_flash_positions==true) then mobmap_flash_timeout=3.0; end
	end
end

function MobMap_HideAllDots()
	mobmap_displayed_dot_count=0;
	for x=0,100,1 do
		for y=0,100,1 do
			local frame=getglobal("MobMapDot"..x.."_"..y);
			if(frame~=nil) then 
				frame:Hide();
				frame.idtable=nil;
				frame.ihidtable=nil;
				frame.freetext=nil;
			end
		end
	end
	MobMap_HideAllMinimapDots();
	MobMap_HideAllBattlefieldMinimapDots();
end

function MobMap_HideAllBattlefieldMinimapDots()
	for x=0,100,1 do
		for y=0,100,1 do
			local frame=getglobal("MobMapBattlefieldMinimapDot"..x.."_"..y);
			if(frame~=nil) then
				frame:Hide();
				frame.idtable=nil;
				frame.ihidtable=nil;
				frame.freetext=nil;
			end
		end
	end
end

function MobMap_DisplayDotTooltip(self)
	WorldMapPOIFrame.allowBlobTooltip = false;
	if(self.idtable) then
		WorldMapTooltip:SetOwner(self, "ANCHOR_TOPLEFT");
		WorldMapTooltip:AddDoubleLine("Position:",self.xcoord..","..self.ycoord,1,1,1,1,1,1);
		local k,v;
		for k,v in pairs(self.idtable) do
			WorldMapTooltip:AddLine(MobMap_GetMobName(v));
		end
		WorldMapTooltip:Show();
	end
	if(self.ihidtable) then
		WorldMapTooltip:SetOwner(self, "ANCHOR_TOPLEFT");
		WorldMapTooltip:AddDoubleLine("Position:",self.xcoord..","..self.ycoord,1,1,1,1,1,1);
		local k,v;
		for k,v in pairs(self.ihidtable) do
			local itemname=MobMap_GetItemNameByIHID(v);
			local itemid, quality = MobMap_GetItemDataByIHID(v);
			WorldMapTooltip:AddLine(MobMap_ConstructColorizedItemName(quality, itemname));
		end
		WorldMapTooltip:Show();
	end
	if(self.freetext) then
		WorldMapTooltip:SetOwner(self, "ANCHOR_TOPLEFT");
		WorldMapTooltip:AddDoubleLine("Position:",self.xcoord..","..self.ycoord,1,1,1,1,1,1);
		WorldMapTooltip:AddLine(self.freetext);
		WorldMapTooltip:SetFrameStrata("TOOLTIP");
		WorldMapTooltip:Show();
	end
end

function MobMap_HideDotTooltip()
	WorldMapPOIFrame.allowBlobTooltip = true;
	WorldMapTooltip:Hide();
end

--function MobMap_WorldMap_ToggleSizeUp()
--	MobMapDotParentFrame:SetScale(WORLDMAP_RATIO_SMALL);
--end
--hooksecurefunc("WorldMap_ToggleSizeUp", MobMap_WorldMap_ToggleSizeUp);

--function MobMap_WorldMap_ToggleSizeDown()
--	MobMapDotParentFrame:SetScale(WORLDMAP_RATIO_SMALL);
--end
--hooksecurefunc("WorldMap_ToggleSizeDown", MobMap_WorldMap_ToggleSizeDown);

-- minimap handling

function MobMap_UpdateMinimapIcons()	
	local alcontinent,alzone,playerx,playery=mobmap_astrolabe_library:GetCurrentPlayerPosition();
	if(playerx==nil or playery==nil) then return; end

	if(mobmap_multidisplay~=nil) then
		local i,k;
		local zonestats={};
		local zonename=MobMap_GetCurrentMapZoneName();
		for key, entity in pairs(mobmap_multidisplay) do
			for key2, zone in pairs(entity.zones) do
				if(zone.posdata and zone.zonename==zonename) then
					MobMap_DisplayDotsOnMinimap(alcontinent,alzone,playerx,playery,zone.posdata);
				end
			end
		end
	else
		if(mobmap_currentlyshown==nil) then return; end
		if(MobMap_GetCurrentMapZoneName()~=mobmap_currentlyshown.zonename and mobmap_currentlyshown.zonename~=nil) then return; end	
		MobMap_DisplayDotsOnMinimap(alcontinent,alzone,playerx,playery,mobmap_currentlyshown.posdata);
	end
end

function MobMap_DisplayDotsOnMinimap(continent,zone,playerx,playery,posdata)
	for k,v in pairs(posdata) do
		for x=v.x1,v.x2,1 do			
			MobMap_DisplayDotOnMinimap(continent,zone,playerx,playery,x,v.y);
		end
	end
end

function MobMap_GetUnusedMinimapDotFromCache()
	local frame;
	if(#(mobmap_minimap_icon_cache)>0) then
		frame=table.remove(mobmap_minimap_icon_cache);
	else
		frame=CreateFrame("Frame","MobMapMinimapDot"..mobmap_minimap_icon_counter,Minimap,"MobMapMinimapDotFrameTemplate");
		frame.isMinimapButton=true;
		mobmap_minimap_icon_counter=mobmap_minimap_icon_counter+1;
	end
	frame.isUsed=true;
	return frame;
end

function MobMap_ReturnMinimapDotToCache(frame)
	frame.isUsed=nil;
	table.insert(mobmap_minimap_icon_cache, frame);
end

function MobMap_DisplayDotOnMinimap(continent,zone,playerx,playery,x,y)
	local iconindex=x.."/"..y;
	local newDots=false;
	if(MobMap_GetDistanceSquare(playerx,playery,x/100,y/100)<0.01) then
		if(not mobmap_minimap_icons[iconindex]) then
			local frame=MobMap_GetUnusedMinimapDotFromCache();
			mobmap_astrolabe_library:PlaceIconOnMinimap(frame, continent, zone, x/100, y/100);
			mobmap_minimap_icons[iconindex]=frame;
			frame:Show();
			newDots=true;
		end
	else
		if(mobmap_minimap_icons[iconindex]) then
			mobmap_astrolabe_library:RemoveIconFromMinimap(mobmap_minimap_icons[iconindex]);
			mobmap_minimap_icons[iconindex]:Hide();
			MobMap_ReturnMinimapDotToCache(mobmap_minimap_icons[iconindex]);
			mobmap_minimap_icons[iconindex]=nil;
		end
	end
	if(newDots==true) then
		mobmap_astrolabe_library:CalculateMinimapIconPositions();
		MobMap_AstrolabeOnEdgeChangedCallback();
	end
end

function MobMap_AstrolabeOnEdgeChangedCallback()
	for key, icon in pairs(mobmap_minimap_icons) do
		if(mobmap_astrolabe_library:IsIconOnEdge(icon)) then
			icon:Hide();
		else
			icon:Show();
		end
	end
end

function MobMap_GetDistanceSquare(x1,y1,x2,y2)
	return (x1-x2)*(x1-x2)+(y1-y2)*(y1-y2);
end

function MobMap_HideAllMinimapDots()
	for key, icon in pairs(mobmap_minimap_icons) do
		mobmap_astrolabe_library:RemoveIconFromMinimap(icon);
		MobMap_ReturnMinimapDotToCache(icon);
	end
	mobmap_minimap_icons={};
end

-- end minimap handling

function MobMap_UnsetMob()
	mobmap_mobid_currentlyshown=nil;
	MobMapMobSearchFrameMobHighlightFrame:Hide();
	MobMapMobSearchFrameSelectionDetails:Hide();
	MobMap_UnsetZone();
end

function MobMap_UnsetZone()
	mobmap_currentlyshown=nil;
	MobMapZoneHighlightFrame:Hide();
end

function MobMap_UpdatePositions()
	if(mobmap_currentlyshown==nil) then 
		if(mobmap_multidisplay~=nil) then
			local i,k;
			local zonestats={};
			if(#(mobmap_multidisplay)==1 and mobmap_multidisplay[1].itemtype~=nil) then
				for i=1,#(mobmap_multidisplay[1].zones),1 do
					local positionData=MobMap_GetItemPositions(mobmap_multidisplay[1].itemtype, mobmap_multidisplay[1].ihid, mobmap_multidisplay[1].zones[i].zoneid);
					mobmap_multidisplay[1].zones[i].posdata=positionData;
				end
				MobMap_MakeSureMapIsVisible();
				MobMap_SetMapToZone(MobMap_GetZoneName(mobmap_multidisplay[1].zones[1].zoneid), mobmap_multidisplay[1].zones[1].zonelevel);
			else
				for i=1,#(mobmap_multidisplay),1 do
					local zonetable=MobMap_GetMobZonesByMobID(mobmap_multidisplay[i].id);
					if(zonetable~=nil) then
						mobmap_multidisplay[i].zones={};
						for k=1,#(zonetable),1 do
							local positionData=MobMap_GetMobPositions(mobmap_multidisplay[i].id, zonetable[k].id, zonetable[k].level);
							local zonename=MobMap_GetZoneName(zonetable[k].id);
							table.insert(mobmap_multidisplay[i].zones,{zoneid=zonetable[k].id, zonelevel=zonetable[k].level, zonename=zonename, posdata=positionData});
							if(zonestats[zonetable[k]]==nil) then
								zonestats[zonetable[k]]=1;
							else
								zonestats[zonetable[k]]=zonestats[zonetable[k]]+1;
							end
						end
						local forcedzone=nil;
						local maxvalue=0;
						local key, value;
						for key, value in pairs(zonestats) do
							if(mobmap_multidisplay_preferredzone~=nil and key.id==mobmap_multidisplay_preferredzone.id and key.level==mobmap_multidisplay_preferredzone.level) then
								forcedzone=mobmap_multidisplay_preferredzone;
								break;
							else
								if(value>maxvalue) then
									forcedzone=key;
									maxvalue=value;
								end
							end
						end
						if(forcedzone) then
							MobMap_MakeSureMapIsVisible();
							MobMap_SetMapToZone(MobMap_GetZoneName(forcedzone.id), forcedzone.level);
						end
					end
				end
			end
		end
		return;
	end
	local pos;
	if(mobmap_currentlyshown.itemtype~=nil) then
		pos=MobMap_GetItemPositions(mobmap_currentlyshown.itemtype, mobmap_currentlyshown.ihid, mobmap_currentlyshown.zoneid, mobmap_currentlyshown.zonelevel);
	else
		pos=MobMap_GetMobPositions(mobmap_currentlyshown.mobid, mobmap_currentlyshown.zoneid, mobmap_currentlyshown.zonelevel);
	end
	mobmap_currentlyshown.posdata=pos;
end

mobmap_astrolabe_version = "Astrolabe-0.4";
mobmap_astrolabe_library = DongleStub(mobmap_astrolabe_version);

function MobMap_Display()
	if(WorldMapFrame:IsVisible()==false) then return; end
	if(mobmap_currentlyshown==nil) then 
		if(mobmap_multidisplay==nil) then
			MobMapButtonFrameCurrentMob:SetText("");
			MobMapButtonFrameCurrentMobFrame.itemid=nil;
			MobMap_HideAllDots();
			return;
		else
			MobMap_SwitchMapAndDisplay();
			return;
		end
	end
	
	MobMapButtonFrameCurrentMobFrame.itemid=nil;
	if(mobmap_currentlyshown.mobname) then 
		MobMapButtonFrameCurrentMob:SetText(mobmap_currentlyshown.mobname);
	elseif(mobmap_currentlyshown.ihid) then
		MobMapButtonFrameCurrentMob:SetText(MobMap_ConstructColorizedItemName(mobmap_currentlyshown.itemquality, mobmap_currentlyshown.itemname));
		MobMapButtonFrameCurrentMobFrame.itemid=mobmap_currentlyshown.itemid;
		MobMapButtonFrameCurrentMobFrame.ihid=mobmap_currentlyshown.ihid;
	elseif(mobmap_currentlyshown.freetext) then
		MobMapButtonFrameCurrentMob:SetText(mobmap_currentlyshown.freetext);
	end

	if(mobmap_currentlyshown.zonename and (MobMap_GetCurrentMapZoneName()~=mobmap_currentlyshown.zonename or GetCurrentMapDungeonLevel()~=mobmap_currentlyshown.zonelevel)) then 
		MobMap_HideAllDots();
		return;
	end
	if(mobmap_enabled) then
		MobMap_SwitchMapAndDisplay();
	else
		MobMap_HideAllDots();
	end
end

function MobMap_SwitchMapAndDisplay()
	mobmap_displayed_dot_count=0;
	if(mobmap_currentlyshown==nil) then 
		if(mobmap_multidisplay==nil) then
			MobMapButtonFrameCurrentMob:SetText("");
			MobMapButtonFrameCurrentMobFrame.itemid=nil;
			MobMap_HideAllDots();
			return;
		else
			local showed=false;
			if(not WorldMapFrame:IsVisible()) then showed=true; end
			MobMap_MakeSureMapIsVisible(true);
			local i,k;
			MobMap_HideAllDots();
			for i=1,#(mobmap_multidisplay),1 do
				if(mobmap_multidisplay[i].zones~=nil) then
					for k=1,#(mobmap_multidisplay[i].zones) do
						if(mobmap_multidisplay[i].zones[k].posdata~=nil and (mobmap_multidisplay[i].zones[k].zoneid==-1 or (MobMap_GetZoneName(mobmap_multidisplay[i].zones[k].zoneid)==MobMap_GetCurrentMapZoneName() and mobmap_multidisplay[i].zones[k].zonelevel==GetCurrentMapDungeonLevel()))) then
							if(mobmap_multidisplay[i].itemtype) then	
								MobMap_DisplayPositionData(mobmap_multidisplay[i].zones[k].posdata, nil, mobmap_multidisplay[i].ihid);
							elseif(mobmap_multidisplay[i].id) then
								MobMap_DisplayPositionData(mobmap_multidisplay[i].zones[k].posdata, mobmap_multidisplay[i].id);
							elseif(mobmap_multidisplay[i].text) then
								MobMap_DisplayPositionData(mobmap_multidisplay[i].zones[k].posdata, nil, nil, mobmap_multidisplay[i].text);
							else
								MobMap_DisplayPositionData(mobmap_multidisplay[i].zones[k].posdata);
							end
						end
					end
				end
			end
			MobMapButtonFrameCurrentMob:SetText("");
			MobMapButtonFrameCurrentMobFrame.itemid=nil;
			if(#(mobmap_multidisplay)==1 and mobmap_multidisplay[1].itemtype~=nil) then
				MobMapButtonFrameCurrentMob:SetText(MobMap_ConstructColorizedItemName(mobmap_multidisplay[1].itemquality, mobmap_multidisplay[1].itemname));
				MobMapButtonFrameCurrentMobFrame.itemid=mobmap_multidisplay[1].itemid;
				MobMapButtonFrameCurrentMobFrame.ihid=mobmap_multidisplay[1].ihid;
			else
				if(mobmap_multidisplay_caption) then
					MobMapButtonFrameCurrentMob:SetText(mobmap_multidisplay_caption);
				end
			end
			return;
		end
	end
	local showed=false;
	if(not WorldMapFrame:IsVisible()) then showed=true; end
	MobMap_MakeSureMapIsVisible(true);
	if(mobmap_currentlyshown.zonename and MobMap_SetMapToZone(mobmap_currentlyshown.zonename, mobmap_currentlyshown.zonelevel)==false) then 
		if(showed) then HideUIPanel(WorldMapFrame); end
		MobMap_DisplayMessage(MOBMAP_ZONE_HAS_NO_MAP_1..mobmap_currentlyshown.zonename..MOBMAP_ZONE_HAS_NO_MAP_2);
		return; 
	end
	if(mobmap_currentlyshown.posdata==nil) then MobMap_UpdatePositions(); end
	MobMap_HideAllDots();
	MobMapButtonFrameCurrentMobFrame.itemid=nil;
	if(mobmap_currentlyshown.mobname) then 
		MobMapButtonFrameCurrentMob:SetText(mobmap_currentlyshown.mobname);
		MobMap_DisplayPositionData(mobmap_currentlyshown.posdata, mobmap_currentlyshown.mobid);
	elseif(mobmap_currentlyshown.ihid) then
		MobMapButtonFrameCurrentMob:SetText(MobMap_ConstructColorizedItemName(mobmap_currentlyshown.itemquality, mobmap_currentlyshown.itemname));
		MobMapButtonFrameCurrentMobFrame.itemid=mobmap_currentlyshown.itemid;
		MobMap_DisplayPositionData(mobmap_currentlyshown.posdata, nil, mobmap_currentlyshown.ihid);
	elseif(mobmap_currentlyshown.freetext) then
		MobMapButtonFrameCurrentMob:SetText(mobmap_currentlyshown.freetext);
		MobMap_DisplayPositionData(mobmap_currentlyshown.posdata, nil, nil, mobmap_currentlyshown.freetext);
	end
end

function MobMap_ShowSinglePositionOnMap(x, y, text, zonename, zonelevel)
	if(x>0 and x<100 and y>0 and y<100) then
		MobMap_ShowMultiplePositionsOnMap({{x=x, y=y}}, text, zonename, zonelevel);
	end
end

function MobMap_ShowMultiplePositionsOnMap(data, text, zonename, zonelevel)
	if(not zonelevel) then zonelevel=0; end
	local k,v;
	mobmap_multidisplay=nil;
	mobmap_currentlyshown={};
	mobmap_currentlyshown.zonename=zonename;
	mobmap_currentlyshown.zonelevel=zonelevel;
	mobmap_currentlyshown.freetext=text;
	mobmap_currentlyshown.posdata={};
	for k,v in pairs(data) do
		if(v.x and v.y) then
			table.insert(mobmap_currentlyshown.posdata, {x1=v.x, x2=v.x, y=v.y});
		elseif(v.x1 and v.x2 and v.y) then
			mobmap_currentlyshown.posdata=data;
			break;
		end
	end
	mobmap_enabled=true;
	MobMapCheckButton:SetChecked(true);
	MobMap_SwitchMapAndDisplay();
end

function MobMap_ShowMultiplePositionsInDifferentZonesOnMap(data, text, preferredzone, preferredlevel)
	mobmap_currentlyshown=nil;
	mobmap_multidisplay={{}};
	mobmap_multidisplay[1].zones={};
	mobmap_multidisplay[1].text=text;
	local k,v,zone,posdata;
	local maxzonename=nil;
	local maxlevel=nil;
	local maxcount=0;
	for k,zone in pairs(data) do
		local zonedata={zoneid=zone.zoneid, zonelevel=zone.zonelevel, zonename=MobMap_GetZoneName(zone.zoneid), posdata={}};
		for k,v in pairs(zone.posdata) do
			if(v.x and v.y) then
				table.insert(zonedata.posdata, {x1=v.x, x2=v.x, y=v.y});
			elseif(v.x1 and v.x2 and v.y) then
				zonedata.posdata=zone.posdata;
				break;
			end
		end
		local count=0;
		for k,posdata in pairs(zonedata.posdata) do
			count=count+(posdata.x2-posdata.x1+1)
		end
		if(count>maxcount or (preferredzone==zonedata.zonename and preferredlevel==zonedata.zonelevel)) then
			maxzonename=zonedata.zonename;
			maxlevel=zonedata.zonelevel;
			if(preferredzone==zonedata.zonename and preferredlevel==zonedata.zonelevel) then
				maxcount=999999;
			else
				maxcount=count;
			end
		end
		table.insert(mobmap_multidisplay[1].zones, zonedata);
	end
	if(maxzonename and maxlevel) then
		MobMap_MakeSureMapIsVisible();
		MobMap_SetMapToZone(maxzonename, maxlevel);
	end
	mobmap_multidisplay_preferredzone=nil;
	mobmap_multidisplay_caption=text;
	MobMapCheckButton:SetChecked(true);
	MobMap_SwitchMapAndDisplay();
end

function MobMap_MakeSureMapIsVisible(putMobMapWindowOnTop)
	if(not WorldMapFrame:IsVisible()) then ShowUIPanel(WorldMapFrame); end
	if(putMobMapWindowOnTop==true) then
		if(MobMapFrame:IsVisible()) then
			MobMapFrame:Hide();
			MobMapFrame:Show();
		end
	end
end

-- item name selection frame

function MobMap_ShowItemNameSelectionFrame(startihid)
	MobMap_LoadDatabase(MOBMAP_ITEMNAME_HELPER_DATABASE);
	if(startihid~=nil) then
		mobmap_itemnameselection_selecteditem=startihid;
	else
		mobmap_itemnameselection_selecteditem=nil;
	end
	MobMap_RefreshItemNameSelectionFrame();
	MobMapItemNameSelectionFrame:Show();
end

mobmap_itemnameselectionlist=nil;

function MobMap_RefreshItemNameSelectionFrame()
	local filtername=MobMapItemNameSelectionFrameNameFilter:GetText();
	mobmap_itemnameselectionlist=MobMap_GetItemNameList(filtername);
	FauxScrollFrame_SetOffset(MobMapItemNameSelectionFrameScrollFrame, 0);
	MobMap_UpdateItemNameSelectionFrame();
end

function MobMap_UpdateItemNameSelectionFrame()
	local itemnamecount=#(mobmap_itemnameselectionlist);
	local offset=FauxScrollFrame_GetOffset(MobMapItemNameSelectionFrameScrollFrame);
	MobMapItemNameSelectionFrameItemHighlightFrame:Hide();

	for i=1,9,1 do
		local itemindex=i+offset;
		if(itemindex>itemnamecount) then
			MobMap_UpdateItemNameEntry(i, nil);
		else
			MobMap_UpdateItemNameEntry(i, mobmap_itemnameselectionlist[itemindex]);
		end
	end

	FauxScrollFrame_Update(MobMapItemNameSelectionFrameScrollFrame, itemnamecount, 9, 22);
end

function MobMap_UpdateItemNameEntry(pos, ihid)
	local frame=getglobal("MobMapItemSelection"..pos);
	local frame_button=getglobal("MobMapItemSelection"..pos.."ItemName");
	local frame_text=getglobal("MobMapItemSelection"..pos.."ItemNameText");
	if(ihid==nil) then
		frame:Hide();
	else
		local itemname=MobMap_GetItemNameByIHID(ihid);
		local itemid, quality = MobMap_GetItemDataByIHID(ihid);
		if(itemname~=nil and itemid~=nil) then
			local r, g, b = GetItemQualityColor(quality);
			frame_text:SetText(itemname);
			frame_text:SetTextColor(r,g,b);
			frame.itemid=itemid;
			frame.ihid=ihid;
			frame:Show();
			if(ihid==mobmap_itemnameselection_selecteditem) then
				MobMapItemNameSelectionFrameItemHighlightFrame:Show();
				MobMapItemNameSelectionFrameItemHighlightFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 2);
				MobMapItemNameSelectionFrameItemHighlightFrame:SetAlpha(0.5);
				MobMapItemHighlight:SetVertexColor(1.0, 1.0, 1.0);
			end
		end
	end
end

mobmap_itemnameselection_selecteditem=nil;
mobmap_itemnameselection_selectionfunc=nil;

function MobMap_SelectItem(self)
	MobMapItemNameSelectionFrameItemHighlightFrame:Show();
	MobMapItemNameSelectionFrameItemHighlightFrame:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 2);
	MobMapItemNameSelectionFrameItemHighlightFrame:SetAlpha(0.5);
	MobMapItemHighlight:SetVertexColor(1.0, 1.0, 1.0);
	mobmap_itemnameselection_selecteditem=self:GetParent().ihid;
end

function MobMap_CallSelectionFunc()
	if(mobmap_itemnameselection_selectionfunc~=nil and mobmap_itemnameselection_selecteditem~=nil) then
		mobmap_itemnameselection_selectionfunc(mobmap_itemnameselection_selecteditem);
	end
end

function MobMap_SetSelectionFunc(selectionfunc)
	mobmap_itemnameselection_selectionfunc=selectionfunc;
end

-- about frame

function MobMap_AboutFrame_OnShow()
	local buildtimestring;
	if(GetLocale()=="deDE") then
		buildtimestring=date("%d.%m.%Y um %H:%M Uhr", MobMap_GetDBBuildTime());
	else
		buildtimestring=date("%m/%d/%y at %I:%M %p", MobMap_GetDBBuildTime());
	end
	MobMapAboutFrameDBInfoBuildTime:SetText(MOBMAP_DATABASE_INFO_1..buildtimestring);
	local language;
	if(MobMap_GetDBLanguage()=="ger") then language=MOBMAP_DATABASE_LANGUAGE_GERMAN; end
	if(MobMap_GetDBLanguage()=="eng") then language=MOBMAP_DATABASE_LANGUAGE_ENGLISH; end
	MobMapAboutFrameDBInfoLanguage:SetText(MOBMAP_DATABASE_INFO_2..language);
	local mobcountstring=MobMap_GetMobCount();
	MobMapAboutFrameDBInfoMobCount:SetText(MOBMAP_DATABASE_INFO_3..mobcountstring);
	local questcountstring;
	if(MobMap_GetQuestCount()==-1) then
		questcountstring=MOBMAP_DATABASE_INFO_NOT_INSTALLED;
	else
		questcountstring=MobMap_GetQuestCount();
	end
	MobMapAboutFrameDBInfoQuestCount:SetText(MOBMAP_DATABASE_INFO_4..questcountstring);
	local merchantcountstring;
	if(MobMap_GetMerchantCount()==-1) then
		merchantcountstring=MOBMAP_DATABASE_INFO_NOT_INSTALLED;
	else
		merchantcountstring=MobMap_GetMerchantCount();
	end
	MobMapAboutFrameDBInfoMerchantCount:SetText(MOBMAP_DATABASE_INFO_5..merchantcountstring);
	local recipecountstring;
	if(MobMap_GetRecipeCount()==-1) then
		recipecountstring=MOBMAP_DATABASE_INFO_NOT_INSTALLED;
	else
		recipecountstring=MobMap_GetRecipeCount();
	end
	MobMapAboutFrameDBInfoRecipeCount:SetText(MOBMAP_DATABASE_INFO_6..recipecountstring);

	local commentcountstring;
	if(MobMap_GetCommentCount()==-1) then
		commentcountstring=MOBMAP_DATABASE_INFO_NOT_INSTALLED;
	else
		commentcountstring=MobMap_GetCommentCount();
	end
	MobMapAboutFrameDBInfoCommentCount:SetText(MOBMAP_DATABASE_INFO_7..commentcountstring);
	
	if(UpdateAddOnMemoryUsage==nil) then 
		MobMapAboutFrameMemInfo:Hide();
	else
		MobMapAboutFrameMemInfoText:SetText(MOBMAP_MEMORY_INFO_HEADER.." "..MOBMAP_MEMORY_INFO_UNKNOWN.."\n"..MOBMAP_MEMORY_INFO_UNKNOWN_SECONDLINE);
		MobMapAboutFrameMemInfo.main=nil;
		MobMapAboutFrameMemInfo.dbinfo=nil;
	end
end

function MobMap_UpdateMemoryUsage()
	collectgarbage();
	UpdateAddOnMemoryUsage();
	local main=GetAddOnMemoryUsage("MobMap");
	local DBs={};
	local i;
	local total=main;
	for i=1,14,1 do
		if(IsAddOnLoaded("MobMapDatabaseStub"..i)) then
			local usage=GetAddOnMemoryUsage("MobMapDatabaseStub"..i);
			DBs[i]=usage;
			total=total+usage;
		end
	end
	MobMapAboutFrameMemInfoText:SetText(MOBMAP_MEMORY_INFO_HEADER.." "..(floor(total*100)/100).." KByte\n"..MOBMAP_MEMORY_INFO_SECONDLINE);
	MobMapAboutFrameMemInfo.dbinfo=DBs;
	MobMapAboutFrameMemInfo.main=main;
	MobMapAboutFrameMemInfo:Show();
end

function MobMap_ShowMemoryUsageDetailTooltip(self)
	if(MobMapAboutFrameMemInfo.main==nil) then return; end
	MobMapTooltip:SetOwner(self, "ANCHOR_TOPLEFT");
	MobMapTooltip:SetFrameLevel(5000);
	MobMapTooltip:ClearLines();
	MobMapTooltip:AddLine("|cffffffff"..MOBMAP_MEMORY_INFO_DETAILS_HEADER.."|r");
	MobMapTooltip:AddLine("|cff00ff00"..MOBMAP_MEMORY_INFO_MAIN_ADDON..": "..(floor(MobMapAboutFrameMemInfo.main*100)/100).." KByte".."|r");
	local i;
	for i=1,14,1 do
		if(MobMapAboutFrameMemInfo.dbinfo[i]) then
			MobMapTooltip:AddLine("|cff00ff00"..MOBMAP_MEMORY_INFO_DATABASES[i]..": "..(floor(MobMapAboutFrameMemInfo.dbinfo[i]*100)/100).." KByte".."|r");
		else
			MobMapTooltip:AddLine("|cffff0000"..MOBMAP_MEMORY_INFO_DATABASES[i]..": not loaded".."|r");
		end
	end
	MobMapTooltip:Show();
end

-- export frame

function MobMap_ExportData()
	local continueExport=true;
	local complete_datastring="<MobMapData language=\""..GetLocale().."\" version=\"44\" gameversion=\""..mobmap_game_version.."\">";
	local mobmap_export_datastring="";

	local timestamp, data;
	for timestamp,data in pairs(mobmap_comments) do
		local datastring_to_add="";
		datastring_to_add=datastring_to_add.."<Questcomment timestamp=\""..MobMap_XMLArgumentEscape(timestamp).."\" title=\""..MobMap_XMLArgumentEscape(data["title"]).."\"";
		if(data["author"]) then datastring_to_add=datastring_to_add.." author=\""..MobMap_XMLArgumentEscape(data["author"]).."\""; end
		datastring_to_add=datastring_to_add.." objective=\""..MobMap_XMLArgumentEscape(data["objective"]).."\" text=\""..MobMap_XMLArgumentEscape(data["text"]).."\"";
		datastring_to_add=datastring_to_add.." />";

		if(string.len(complete_datastring)+string.len(mobmap_export_datastring)+string.len(datastring_to_add) > MOBMAP_EXPORT_MAXSIZE) then
			continueExport=false;
			break;
		else
			continueExport=true;
			mobmap_export_datastring=mobmap_export_datastring..datastring_to_add;
		end
	end

	complete_datastring=complete_datastring..mobmap_export_datastring;
	mobmap_export_datastring="";
	
	if(continueExport) then
		local targetname, zones, zone, positions, position, value;
		for targetname,zones in pairs(mobmap_positions) do
			if(zones["min"]~=nil and zones["max"]~=nil and zones["name"]~=nil and zones["react"]~=nil and zones["date"]~=nil) then
				local datastring_to_add="";
				datastring_to_add=datastring_to_add.."<Mob name=\""..MobMap_XMLArgumentEscape(zones["name"]).."\" blizzid=\""..tonumber(targetname).."\" min=\""..zones["min"].."\" max=\""..zones["max"].."\"".." react=\""..zones["react"].."\"".." date=\""..zones["date"].."\"";	
				datastring_to_add=datastring_to_add..">";
				for zone,positions in pairs(zones) do
					if(zone~="min" and zone~="max" and zone~="sub" and zone~="name" and zone~="react" and zone~="date") then
						local found, _, zonename, zonelevel = string.find(zone, "^(.*)#(%d*)$");
						if(zonelevel==nil) then zonename=zone; zonelevel="0"; end
						datastring_to_add=datastring_to_add.."<Zone name=\""..MobMap_XMLArgumentEscape(zonename).."\" level=\""..zonelevel.."\">";
						for position,value in pairs(positions) do
							datastring_to_add=datastring_to_add..position..",";
						end
						datastring_to_add=datastring_to_add.."</Zone>";
					end
				end
				datastring_to_add=datastring_to_add.."</Mob>";

				if(string.len(complete_datastring)+string.len(mobmap_export_datastring)+string.len(datastring_to_add) > MOBMAP_EXPORT_MAXSIZE) then
					continueExport=false;
					break;
				else
					continueExport=true;
					mobmap_export_datastring=mobmap_export_datastring..datastring_to_add;
				end
			end
		end

		complete_datastring=complete_datastring..mobmap_export_datastring;
		mobmap_export_datastring="";
	end

	if(continueExport) then
		local merchant, merchantdata;
		for merchant, merchantdata in pairs(mobmap_merchantstock) do
			local datastring_to_add="";
			datastring_to_add=datastring_to_add.."<Merchant name=\""..MobMap_XMLArgumentEscape(merchant).."\">";
			local item, itemdata;
			for item=1, 100, 1 do
				local itemdata=merchantdata[tostring(item)];
				if(itemdata) then
					datastring_to_add=datastring_to_add.."<MItem id=\""..itemdata["id"].."\" qty=\""..itemdata["quantity"].."\" ltd=\""..itemdata["limited"].."\" cost=\""..itemdata["price"];
					if(itemdata["arenaprice"]) then
						datastring_to_add=datastring_to_add.."\" arena=\""..itemdata["arenaprice"];
					end
					if(itemdata["honorprice"]) then
						datastring_to_add=datastring_to_add.."\" honor=\""..itemdata["honorprice"];
					end
					local token;
					for token=1,5,1 do
						if(itemdata["token"..token]) then
							datastring_to_add=datastring_to_add.."\" token"..token.."=\""..MobMap_XMLArgumentEscape(itemdata["token"..token]);
						end
					end
					datastring_to_add=datastring_to_add.."\"/>";
				end
			end
			datastring_to_add=datastring_to_add.."</Merchant>";

			if(string.len(complete_datastring)+string.len(mobmap_export_datastring)+string.len(datastring_to_add) > MOBMAP_EXPORT_MAXSIZE) then
				continueExport=false;
				break;
			else
				continueExport=true;
				mobmap_export_datastring=mobmap_export_datastring..datastring_to_add;
			end
		end

		complete_datastring=complete_datastring..mobmap_export_datastring;
		mobmap_export_datastring="";
	end

	if(continueExport) then
		local skillName, skillData;
		for skillName, skillData in pairs(mobmap_tradeskills) do
			local datastring_to_add="";
			datastring_to_add=datastring_to_add.."<Recipe name=\""..MobMap_XMLArgumentEscape(skillName).."\" skill=\""..MobMap_XMLArgumentEscape(skillData["category"]).."\" level=\""..skillData["level"].."\"";
			if(skillData["itemid"]~=nil) then datastring_to_add=datastring_to_add.." itemid=\""..skillData["itemid"].."\""; end
			if(skillData["enchantid"]~=nil) then datastring_to_add=datastring_to_add.." enchid=\""..skillData["enchantid"].."\""; end
			if(skillData["minmade"]~=nil) then datastring_to_add=datastring_to_add.." mincnt=\""..skillData["minmade"].."\""; end
			if(skillData["maxmade"]~=nil) then datastring_to_add=datastring_to_add.." maxcnt=\""..skillData["maxmade"].."\""; end
			datastring_to_add=datastring_to_add..">";
			local reagent;
			for reagent=1,10,1 do
				if(skillData["reagent"..reagent]~=nil) then
					datastring_to_add=datastring_to_add.."<Reagent id=\""..skillData["reagent"..reagent].itemid.."\" count=\""..skillData["reagent"..reagent].count.."\"/>";
				end
			end
			datastring_to_add=datastring_to_add.."</Recipe>";

			if(string.len(complete_datastring)+string.len(mobmap_export_datastring)+string.len(datastring_to_add) > MOBMAP_EXPORT_MAXSIZE) then
				continueExport=false;
				break;
			else
				continueExport=true;
				mobmap_export_datastring=mobmap_export_datastring..datastring_to_add;
			end
		end

		complete_datastring=complete_datastring..mobmap_export_datastring;
		mobmap_export_datastring="";
	end

	if(continueExport) then
		local lootName, lootData;
		for lootName, lootData in pairs(mobmap_loot) do
			local datastring_to_add="<Loot name=\""..MobMap_XMLArgumentEscape(lootName).."\">"..lootData.."</Loot>";

			if(string.len(complete_datastring)+string.len(mobmap_export_datastring)+string.len(datastring_to_add) > MOBMAP_EXPORT_MAXSIZE) then
				continueExport=false;
				break;
			else
				continueExport=true;
				mobmap_export_datastring=mobmap_export_datastring..datastring_to_add;
			end
		end

		complete_datastring=complete_datastring..mobmap_export_datastring;
		mobmap_export_datastring="";
	end

	if(continueExport) then
		local trainerName, trainerTable;
		for trainerName, trainerTable in pairs(mobmap_trainer) do
			local datastring_to_add="<Trainer name=\""..MobMap_XMLArgumentEscape(trainerName).."\">";
			local skillName, skillTable;
			for skillName, skillTable in pairs(trainerTable) do
				datastring_to_add=datastring_to_add.."<Skill name=\""..MobMap_XMLArgumentEscape(skillName);
				local paramName, paramValue;
				for paramName, paramValue in pairs(skillTable) do
					if(paramName=="level") then
						datastring_to_add=datastring_to_add.."\" level=\""..paramValue;
					elseif(paramName=="cost") then
						datastring_to_add=datastring_to_add.."\" cost=\""..paramValue;
					elseif(paramName=="skillName") then
						datastring_to_add=datastring_to_add.."\" skillname=\""..MobMap_XMLArgumentEscape(paramValue);
					elseif(paramName=="skillRank") then
						datastring_to_add=datastring_to_add.."\" skillrank=\""..paramValue;
					end
				end
				datastring_to_add=datastring_to_add.."\" />";
			end
			datastring_to_add=datastring_to_add.."</Trainer>";

			if(string.len(complete_datastring)+string.len(mobmap_export_datastring)+string.len(datastring_to_add) > MOBMAP_EXPORT_MAXSIZE) then
				continueExport=false;
				break;
			else
				continueExport=true;
				mobmap_export_datastring=mobmap_export_datastring..datastring_to_add;
			end
		end

		complete_datastring=complete_datastring..mobmap_export_datastring;
		mobmap_export_datastring="";
	end

	if(continueExport) then
		local questId, eventData;
		for questId, eventData in pairs(mobmap_event_objectives) do
			local objective, objData;
			for objective, objData in pairs(eventData) do
				local datastring_to_add="<EventObjective questid=\""..MobMap_XMLArgumentEscape(questId).."\" objective=\""..MobMap_XMLArgumentEscape(objective).."\">";
				local zone, zoneData;
				for zone, zoneData in pairs(objData) do
					local found, _, zonename, zonelevel = string.find(zone, "^(.*)#(%d*)$");
					if(zonelevel==nil) then zonename=zone; zonelevel="0"; end
					datastring_to_add=datastring_to_add.."<Zone name=\""..MobMap_XMLArgumentEscape(zonename).."\" level=\""..zonelevel.."\">";
					local position, value;
					for position, value in pairs(zoneData) do
						datastring_to_add=datastring_to_add..position..",";
					end
					datastring_to_add=datastring_to_add.."</Zone>";
				end
				datastring_to_add=datastring_to_add.."</EventObjective>";

				if(string.len(complete_datastring)+string.len(mobmap_export_datastring)+string.len(datastring_to_add) > MOBMAP_EXPORT_MAXSIZE) then
					continueExport=false;
					break;
				else
					continueExport=true;
					mobmap_export_datastring=mobmap_export_datastring..datastring_to_add;
				end
			end
		end

		complete_datastring=complete_datastring..mobmap_export_datastring;
		mobmap_export_datastring="";
	end

	if(continueExport) then
		local mobname, spells;
		for mobname, spells in pairs(mobmap_npc_spells) do
			local datastring_to_add="<MobSpell name=\""..MobMap_XMLArgumentEscape(mobname).."\">";
			local spellid, count;
			for spellid, count in pairs(spells) do
				datastring_to_add=datastring_to_add.."<Spell id=\""..MobMap_XMLArgumentEscape(spellid).."\" count=\""..MobMap_XMLArgumentEscape(count).."\"/>";
			end
			datastring_to_add=datastring_to_add.."</MobSpell>";
			if(string.len(complete_datastring)+string.len(mobmap_export_datastring)+string.len(datastring_to_add) > MOBMAP_EXPORT_MAXSIZE) then
				continueExport=false;
				break;
			else
				continueExport=true;
				mobmap_export_datastring=mobmap_export_datastring..datastring_to_add;
			end
		end
	end

	mobmap_export_datastring=mobmap_export_datastring.."</MobMapData>";
	complete_datastring=complete_datastring..mobmap_export_datastring;
	mobmap_export_datastring=MobMap_Base64(complete_datastring);
	MobMapExportFrameData.data=mobmap_export_datastring;
	MobMapExportFrameData:SetText(mobmap_export_datastring);
	MobMapExportFrame:Show();
end

function MobMap_DeletePositionData()
	mobmap_positions={};
	mobmap_quests={};
	mobmap_merchantstock={};
	mobmap_tradeskills={};
	mobmap_loot={};
	mobmap_trainer={};
	mobmap_objects={};
	mobmap_comments={};
	mobmap_event_objectives={};
	mobmap_npc_spells={};
end

function MobMapExportDelayFrame_OnUpdate()
	if(mobmap_export_status==3) then MobMap_ExportData(); end
end

-- error frame

function MobMap_ErrorMessage(msg)
	MobMapErrorMessageFrameText:SetText(msg);
	MobMapErrorMessageFrame:Show();
end

-- options frame

function MobMapOptionsFrame_OnLoad(self)
	self.name="MobMap";
	InterfaceOptions_AddCategory(self);
end

function MobMapOptionsFrame_OnShow()
	MobMapOptionsFrameWindowHeightSlider:SetValue(mobmap_window_height);
	MobMapOptionsFrameButtonSlider:SetValue(mobmap_button_position);
	MobMapOptionsFrameDatabaseLoadingInfoCheckButton:SetChecked(mobmap_display_database_loading_info);
	MobMapOptionsFrameWorldMapTooltipCheckButton:SetChecked(mobmap_show_world_map_tooltips);
	MobMapOptionsFrameRequestItemDetailsCheckButton:SetChecked(mobmap_request_item_details);
	MobMapOptionsFrameOptimizeResponseTimesCheckButton:SetChecked(mobmap_optimize_response_times);
	MobMapOptionsFrameShowMinimapButtonCheckButton:SetChecked(mobmap_minimap_button_visible);
	MobMapOptionsFrameShowQuestLogButtonsCheckButton:SetChecked(not mobmap_hide_questlog_buttons);
	MobMapOptionsFrameShowQuestTrackerButtonsCheckButton:SetChecked(not mobmap_hide_questtracker_buttons);
	MobMapOptionsFrameShowReagentButtonsCheckButton:SetChecked(not mobmap_hide_reagent_buttons);
	MobMapOptionsFrameShowQuestGossipButtonsCheckButton:SetChecked(not mobmap_hide_questgossip_buttons);
	MobMapOptionsFrameIgnoreQuestCommentsCheckButton:SetChecked(not mobmap_use_quest_comments);
	MobMapOptionsFrameFlashDotsCheckButton:SetChecked(mobmap_flash_positions);
	MobMapOptionsFrameAutoshowQuestCommentsCheckButton:SetChecked(mobmap_autoshow_comments);
	MobMapOptionsFrameAutoTrackCompletedQuestsCheckButton:SetChecked(mobmap_track_quest_completion);
	MobMap_OptionsFrame_SetDotColors();
end

function MobMapTrackerOptionsFrame_OnLoad(self)
	self.name="Quest-Tracker";
	self.parent="MobMap";
	InterfaceOptions_AddCategory(self);
end

function MobMapTrackerOptionsFrame_OnShow()
	MobMapTrackerOptionsFrameUseTrackerCheckButton:SetChecked(mobmap_use_questtracker);
	MobMapTrackerOptionsFrameAutocreateWaypointsCheckButton:SetChecked(mobmap_autocreate_waypoints);
	MobMapTrackerOptionsFrameOmitMapCheckButton:SetChecked(mobmap_quicksearch_omit_map);
	MobMapTrackerOptionsFrameShowDistanceCheckButton:SetChecked(mobmap_questtracker_status.showdistance);
	MobMapTrackerOptionsFrameShowAdditionalTargetsCheckButton:SetChecked(mobmap_questtracker_status.showadditionaltargets);
	MobMapTrackerOptionsFrameHideFinishedObjectivesCheckButton:SetChecked(mobmap_questtracker_status.hidefinishedobjectives);
	MobMapTrackerOptionsFrameHideFinishedQuestsCheckButton:SetChecked(mobmap_questtracker_status.hidefinishedquests);
	MobMapTrackerOptionsFrameSortQuestsByDistanceButton:SetChecked(mobmap_questtracker_status.sortbydistance);
	MobMapTrackerOptionsFrameUseExactPositioningButton:SetChecked(mobmap_questtracker_status.exactpositioning);
end

function MobMap_ResizeWindow()
	MobMapFrame:SetHeight(mobmap_window_height);
	MobMapBackgroundFrame:SetHeight(mobmap_window_height-96);
	if(MobMapOptionsFrame and MobMapOptionsFrame:IsVisible()) then
		MobMapOptionsFrame:SetHeight(mobmap_window_height-30);
	end
	if(MobMapMobSearchFrame and MobMapMobSearchFrame:IsVisible()) then
		MobMapMobSearchFrame:SetHeight(mobmap_window_height-30);
		MobMapMobSearchFrameZoneListScrollFrame:SetHeight(mobmap_window_height-190);
		MobMapMobSearchFrameZoneListScrollFrameInnerTexture:SetHeight(mobmap_window_height-200);
		MobMapMobSearchFrameMobListScrollFrame:SetHeight(mobmap_window_height-190);
		MobMapMobSearchFrameMobListScrollFrameInnerTexture:SetHeight(mobmap_window_height-200);
	end
	if(MobMapQuestListFrame and MobMapQuestListFrame:IsVisible()) then
		MobMapQuestListFrame:SetHeight(mobmap_window_height-30);
		MobMapQuestListScrollFrame:SetHeight(mobmap_window_height-200);
		MobMapQuestListScrollFrameInnerTexture:SetHeight(mobmap_window_height-220);
	end
	if(MobMapMerchantListFrame and MobMapMerchantListFrame:IsVisible()) then
		MobMapMerchantListFrame:SetHeight(mobmap_window_height-30);
		MobMapMerchantListScrollFrame:SetHeight(mobmap_window_height-200);
		MobMapMerchantListScrollFrameInnerTexture:SetHeight(mobmap_window_height-220);
		MobMapMerchantListMerchantDetailFrame:SetHeight(mobmap_window_height-110);
	end
	if(MobMapRecipeListFrame and MobMapRecipeListFrame:IsVisible()) then
		MobMapRecipeListFrame:SetHeight(mobmap_window_height-30);
		MobMapRecipeListScrollFrame:SetHeight(mobmap_window_height-150);
		MobMapRecipeListScrollFrameInnerTexture:SetHeight(mobmap_window_height-170);
	end
	if(MobMapDropListFrame and MobMapDropListFrame:IsVisible()) then
		MobMapDropListFrame:SetHeight(mobmap_window_height-30);
		MobMapDropListByItem:SetHeight(mobmap_window_height-30);
		MobMapDropListByBosses:SetHeight(mobmap_window_height-30);
		MobMapDropListItemScrollFrame:SetHeight(mobmap_window_height-156);
		MobMapDropListItemScrollFrameInnerTexture:SetHeight(mobmap_window_height-170);
		MobMapDropListMobScrollFrame:SetHeight(mobmap_window_height-130);
		MobMapDropListMobScrollFrameInnerTexture:SetHeight(mobmap_window_height-150);
		MobMapDropListBossScrollFrame:SetHeight(mobmap_window_height-130);
		MobMapDropListBossScrollFrameInnerTexture:SetHeight(mobmap_window_height-150);
		MobMapDropListBossLootTableScrollFrame:SetHeight(mobmap_window_height-180);
		MobMapDropListBossLootTableScrollFrameInnerTexture:SetHeight(mobmap_window_height-200);
	end
	if(MobMapPickupListFrame and MobMapPickupListFrame:IsVisible()) then
		MobMapPickupListFrame:SetHeight(mobmap_window_height-30);
		MobMapPickupItemListScrollFrame:SetHeight(mobmap_window_height-150);
		MobMapPickupItemListScrollFrameInnerTexture:SetHeight(mobmap_window_height-170);
		MobMapPickupZoneListScrollFrame:SetHeight(mobmap_window_height-150);
		MobMapPickupZoneListScrollFrameInnerTexture:SetHeight(mobmap_window_height-170);
	end
	if(MobMapQuestEventFrame and MobMapQuestEventFrame:IsVisible()) then
		MobMapQuestEventFrame:SetHeight(mobmap_window_height-30);
		MobMapQuestEventFrameEventListScrollFrame:SetHeight(mobmap_window_height-248);
		MobMapQuestEventFrameEventListScrollFrameInnerTexture:SetHeight(mobmap_window_height-260);
	end
end

mobmap_color_selector_target = nil;

function MobMap_DisplayColorSelector(target)
	if(ColorPickerFrame:IsShown()) then
		ColorPickerFrame:Hide();
	else
		mobmap_color_selector_target=target;
		ColorPickerFrame.previousValues={["r"]=target.r, ["g"]=target.g, ["b"]=target.b, ["a"]=target.a};
		ColorPickerFrame.cancelFunc=MobMap_ColorPicker_Cancelled;
		ColorPickerFrame.opacityFunc=MobMap_ColorPicker_SetColor;
		ColorPickerFrame.func=MobMap_ColorPicker_SetColor;
		ColorPickerFrame.hasOpacity=true;
		ColorPickerFrame.opacity=1-target.a;
		ColorPickerFrame:SetColorRGB(target.r, target.g, target.b);
		ColorPickerFrame:ClearAllPoints();
		ColorPickerFrame:SetFrameStrata("TOOLTIP");
		ColorPickerFrame:SetPoint("LEFT", "MobMapFrame", "LEFT", (MobMapFrame:GetWidth()-ColorPickerFrame:GetWidth())/2, 0);
		ColorPickerFrame:Show();
	end
end

function MobMap_ColorPicker_SetColor()
	if(mobmap_color_selector_target) then
		local r, g, b = ColorPickerFrame:GetColorRGB();
		local a=1-OpacitySliderFrame:GetValue();
		mobmap_color_selector_target.r=r;
		mobmap_color_selector_target.g=g;
		mobmap_color_selector_target.b=b;
		mobmap_color_selector_target.a=a;
		MobMap_OptionsFrame_SetDotColors();
		MobMap_QuestTracker_Setup();
	end
end

function MobMap_ColorPicker_Cancelled()
	if(mobmap_color_selector_target) then
		mobmap_color_selector_target.r=ColorPickerFrame.previousValues.r;
		mobmap_color_selector_target.g=ColorPickerFrame.previousValues.g;
		mobmap_color_selector_target.b=ColorPickerFrame.previousValues.b;
		mobmap_color_selector_target.a=ColorPickerFrame.previousValues.a;
	end
	mobmap_color_selector_target=nil;
end

function MobMap_OptionsFrame_SetDotColors()
	MobMapOptionsFrameDotColorSettingsExampleTexture:SetVertexColor(mobmap_outer_dot_color.r, mobmap_outer_dot_color.g, mobmap_outer_dot_color.b);
	MobMapOptionsFrameDotColorSettingsExampleTexture:SetAlpha(mobmap_outer_dot_color.a);
	MobMapOptionsFrameDotColorSettingsExampleTexture2:SetVertexColor(mobmap_inner_dot_color.r, mobmap_inner_dot_color.g, mobmap_inner_dot_color.b);
	MobMapOptionsFrameDotColorSettingsExampleTexture2:SetAlpha(mobmap_inner_dot_color.a);
end

-- completed quests tracker functions

function MobMap_IsQuestCompleted(questid)
	if(mobmap_completed_quests[questid]==1) then
		return true;
	else
		return false;
	end
end

function MobMap_SetQuestCompletionStatus(questid, status)
	if(not questid) then return; end
	if(status==true) then
		mobmap_completed_quests[questid]=1;
	else
		mobmap_completed_quests[questid]=nil;
	end
end

function MobMap_CompletingQuest()
	if(not QuestFrame:IsVisible()) then return; end
	local title=MobMap_FilterQuestTitle(GetTitleText());
	if(not title) then return; end
	local id = MobMap_GetQuestIDFromQuestLogByTitle(title);
	if(id) then
		MobMap_SetQuestCompletionStatus(tonumber(id), true);
	end
end

-- general utilities

function MobMap_Command(cmd)
	local parts={};
	local partcount=0;
	for w in string.gmatch(cmd, "%S+") do
    		parts[partcount]=w;
	    	partcount=partcount+1;
	end
	if(partcount==0) then
		MobMap_DisplayMessage(MOBMAP_COMMANDS1);
		MobMap_DisplayMessage(MOBMAP_COMMANDS2);
		MobMap_DisplayMessage(MOBMAP_COMMANDS3);
    		return;
	end
	if(partcount==1) then
		if(parts[0]=="show") then
			MobMap_ShowMobMapFrame();
		end
		if(parts[0]=="clear") then
			MobMap_DeletePositionData();
			MobMap_DisplayMessage(MOBMAP_CLEARED);
		end
		if(parts[0]=="trackerposreset") then
			MobMap_QuestTracker_ResetTrackerPos();
		end
	end
end

function MobMap_Base64(str)
	local encodedString="";
	local partcount;
	for partcount=0,ceil(string.len(str)/300)-1,1 do
		local substringlength=string.len(str)-(partcount*300);
		if(substringlength>300) then substringlength=300; end
		local substring=string.sub(str,partcount*300+1,partcount*300+substringlength);
		local encodedSubstring=base64_encode(substring);
		encodedString=encodedString..encodedSubstring;
	end
	return encodedString;
end

mobmap_zoneindex={};
for cidx,c in ipairs{GetMapContinents()} do
	for zidx,z in ipairs{GetMapZones(cidx)} do
		mobmap_zoneindex[z]={z=zidx,c=cidx};
	end
end

mobmap_continentindex={};
for cidx,c in ipairs{GetMapContinents()} do
	local zoneindex={};
	for zidx,z in ipairs{GetMapZones(cidx)} do
		zoneindex[zidx]=z;
	end
	mobmap_continentindex[cidx]=zoneindex;
end

function MobMap_GetPlayerCoordinates(exact)
	local zonename = GetRealZoneText();
	if(WorldMapFrame:IsVisible() or (NxMap1 and NxMap1:IsVisible())) then
		local continentid=GetCurrentMapContinent();
		local zoneid=GetCurrentMapZone();
		if(continentid==0 or zoneid==0) then return nil; end
		if(not (mobmap_continentindex[continentid] and mobmap_continentindex[continentid][zoneid] and mobmap_continentindex[continentid][zoneid]==zonename)) then return nil; end
	else
		SetMapToCurrentZone();
	end
	local x, y = GetPlayerMapPosition("player");
	local zonelevel = GetCurrentMapDungeonLevel();
	if(not exact) then
		if(x>0 and y>0) then
			x=math.floor(x*1000+0.5)/10;
			y=math.floor(y*1000+0.5)/10;
		else
			x=-1;
			y=-1;
		end
	end
	if(not zonelevel) then zonelevel=0; end
	return x,y,zonename,zonelevel;
end

function MobMap_GetMobIDFromGUID(guid)
	if(not guid) then return nil; end
	local creaturetype, mobid=string.match(guid, "0x(%w%w%w)000(%w%w%w%w)%w%w%w%w%w%w");
	if(not creaturetype or not mobid) then return nil; end
	return "0x"..mobid;
end

function MobMap_GetMoneyFromMoneyString(str)
	local gold, silver, copper;
	gold=string.match(str,"(%d+) "..MOBMAP_GOLD);
	if(gold==nil) then gold=0; end
	silver=string.match(str,"(%d+) "..MOBMAP_SILVER);
	if(silver==nil) then silver=0; end
	copper=string.match(str,"(%d+) "..MOBMAP_COPPER);
	if(copper==nil) then copper=0; end	
	return gold*10000+silver*100+copper;
end

function MobMap_Deformat(template, msg)
	template=string.gsub(template,"%%s","(.+)");
	template=string.gsub(template,"%%%d*$s","(.+)");
	template=string.gsub(template,"%%d","(%%d+)");
	template=string.gsub(template,"%%%d*$d","(%%d+)");
	local _,_,capture1,capture2=string.find(msg, template);
	return capture1,capture2;
end

function MobMap_FilterQuestTitle(title)
	if(title==nil) then return nil; end
	local filteredtitle=string.match(title,".*%] (.*)");
	if(filteredtitle~=nil) then
		return filteredtitle;
	else
		return title;
	end
end

function MobMap_GetItemIDFromItemLink(link)
	local found, _, itemString = string.find(link, "^|%x+|H(.+)|h%[.+%]")
	local found2, _, itemId, enchantId, jewelId1, jewelId2, jewelId3, jewelId4, suffixId, uniqueId, level = string.find(itemString, "^item:(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%-?%d+):(%-?%d+):(%d+)")
	return itemId, suffixId, uniqueId;
end

function MobMap_GetItemIDFromItemString(str)
	local found, _, itemId, enchantId, jewelId1, jewelId2, jewelId3, jewelId4, suffixId, uniqueId, level = string.find(str, "^item:(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%-?%d+):(%-?%d+):(%d+)")
	return itemId;
end

function MobMap_GetEnchantIDFromEnchantLink(link)
	local found, _, itemString = string.find(link, "^|%x+|H(.+)|h%[.+%]")
	local found2, _, enchantId = string.find(itemString, "^enchant:(%d+)")
	return enchantId;
end

function MobMap_GetSpellIDFromSpellLink(link)
	local found, _, spellString = string.find(link, "^|%x+|H(.+)|h%[.+%]");
	local found2, _, spellId = string.find(spellString, "^spell:(%d+)")
	return spellId;
end

function MobMap_GetQuestIDFromQuestLink(link)
	local found, _, questString = string.find(link, "^|%x+|H(.+)|h%[.+%]");
	return MobMap_GetQuestIDFromQuestString(questString);
end

function MobMap_GetQuestIDFromQuestString(str)
	local found, _, questId, questLevel = string.find(str, "^quest:(%d+):(.+)");
	return questId;
end

function MobMap_ConstructEnchantLink(enchantid, enchantname)
	local enchantLink="|cffffd000|Henchant:"..enchantid.."|h["..enchantname.."]|h|r";
	return enchantLink;
end

function MobMap_ConstructItemString(itemid)
	local itemString="item:"..itemid..":0:0:0:0:0:0:0";
	return itemString;
end

function MobMap_DisplayMessage(msg)
	DEFAULT_CHAT_FRAME:AddMessage(msg);
end

function MobMap_DisplayDebugMessage(msg)
	if(mobmap_debug and msg) then DEFAULT_CHAT_FRAME:AddMessage("MobMap Debug: "..msg); end
end

function MobMap_XMLArgumentEscape(str)
	str=string.gsub(str, "|", "||");
	str=string.gsub(str, "&", "&amp;");
	str=string.gsub(str, "\"", "&quot;");
	str=string.gsub(str, "'", "&apos;");
	str=string.gsub(str, "<", "&lt;");
	str=string.gsub(str, ">", "&gt;");
	str=string.gsub(str, "ü", "|uuml|");
	str=string.gsub(str, "ä", "|auml|");
	str=string.gsub(str, "ö", "|ouml|");
	str=string.gsub(str, "Ü", "|Uuml|");
	str=string.gsub(str, "Ä", "|Auml|");
	str=string.gsub(str, "Ö", "|Ouml|");
	str=string.gsub(str, "ß", "|szlig|");
	str=string.gsub(str, "\n", "$B");
	str=string.gsub(str, "\r", "");
	return str;
end

function MobMap_QuestTextEscape(str)
	str=string.gsub(str, "\r\n", "\n");
	str=string.gsub(str, "\n", "\\n");
	return str;
end

function MobMap_PatternEscape(str)
	if(str==nil) then return nil; end
	str=string.gsub(str,"%^","%%%^");
	str=string.gsub(str,"%(","%%%(");
	str=string.gsub(str,"%)","%%%)");
	str=string.gsub(str,"%%","%%%%");
	str=string.gsub(str,"%.","%%%.");
	str=string.gsub(str,"%[","%%%[");
	str=string.gsub(str,"%]","%%%]");
	str=string.gsub(str,"%*","%%%*");
	str=string.gsub(str,"%+","%%%+");
	str=string.gsub(str,"%-","%%%-");
	str=string.gsub(str,"%?","%%%?");
	return str;	
end

function MobMap_LoadDatabase(dbtype, doLoadDependencies, doGC)
	if(doLoadDependencies==nil or doLoadDependencies==true) then
		if(dbtype==MOBMAP_POSITION_DATABASE) then
			if(MobMap_LoadDatabase(MOBMAP_MOBNAME_DATABASE, true, false)==false) then return false; end
		elseif(dbtype==MOBMAP_QUEST_DATABASE) then
			if(MobMap_LoadDatabase(MOBMAP_MOBNAME_DATABASE, true, false)==false) then return false; end
			if(MobMap_LoadDatabase(MOBMAP_ITEMNAME_HELPER_DATABASE, true, false)==false) then return false; end
		elseif(dbtype==MOBMAP_MERCHANT_DATABASE) then
			if(MobMap_LoadDatabase(MOBMAP_MOBNAME_DATABASE, true, false)==false) then return false; end
			if(MobMap_LoadDatabase(MOBMAP_ITEMNAME_HELPER_DATABASE, true, false)==false) then return false; end
		elseif(dbtype==MOBMAP_RECIPE_DATABASE) then
			if(MobMap_LoadDatabase(MOBMAP_ITEMNAME_HELPER_DATABASE, true, false)==false) then return false; end
		elseif(dbtype==MOBMAP_DROP_DATABASE) then
			if(MobMap_LoadDatabase(MOBMAP_MOBNAME_DATABASE, true, false)==false) then return false; end
			if(MobMap_LoadDatabase(MOBMAP_ITEMNAME_HELPER_DATABASE, true, false)==false) then return false; end
		elseif(dbtype==MOBMAP_PICKUP_DATABASE) then
			if(MobMap_LoadDatabase(MOBMAP_MOBNAME_DATABASE, true, false)==false) then return false; end
			if(MobMap_LoadDatabase(MOBMAP_ITEMNAME_HELPER_DATABASE, true, false)==false) then return false; end
		elseif(dbtype==MOBMAP_ITEMNAME_HELPER_DATABASE) then
			if(MobMap_LoadDatabase(MOBMAP_ITEM_TOOLTIP_DATABASE, true, false)==false) then return false; end
		end
	end
	if(IsAddOnLoaded("MobMapDatabaseStub"..dbtype)==nil) then
		local startTime=GetTime();
		local loaded,reason=LoadAddOn("MobMapDatabaseStub"..dbtype);
		local whatWasLoaded="position";
		local whatExactly="";
		if(dbtype==MOBMAP_QUEST_DATABASE) then whatWasLoaded="quest"; end
		if(dbtype==MOBMAP_MERCHANT_DATABASE) then whatWasLoaded="merchant"; end
		if(dbtype==MOBMAP_RECIPE_DATABASE) then whatWasLoaded="recipe"; end
		if(dbtype==MOBMAP_ITEMNAME_HELPER_DATABASE) then whatWasLoaded="item name helper"; end
		if(dbtype==MOBMAP_MOBNAME_DATABASE) then whatWasLoaded="mob name"; end
		if(dbtype==MOBMAP_DROP_DATABASE) then whatWasLoaded="drop chance"; end
		if(dbtype==MOBMAP_PICKUP_DATABASE) then whatWasLoaded="pickup"; whatExactly="access components "; end
		if(dbtype==MOBMAP_PICKUP_QUEST_ITEM_DATABASE) then whatWasLoaded="pickup"; whatExactly="(quest items) "; end
		if(dbtype==MOBMAP_PICKUP_FISHING_DATABASE) then whatWasLoaded="pickup"; whatExactly="(fishing) "; end
		if(dbtype==MOBMAP_PICKUP_MINING_DATABASE) then whatWasLoaded="pickup"; whatExactly="(mining) "; end
		if(dbtype==MOBMAP_PICKUP_HERBS_DATABASE) then whatWasLoaded="pickup"; whatExactly="(herbs) "; end
		if(dbtype==MOBMAP_ITEM_TOOLTIP_DATABASE) then whatWasLoaded="item tooltip"; end		
		if(dbtype==MOBMAP_QUEST_COMMENT_DATABASE) then whatWasLoaded="quest comment"; end
		if(not loaded) then
			if(mobmap_init_finished) then
				MobMap_DisplayMessage("The MobMap "..whatWasLoaded.." database "..whatExactly.."could not be dynamically loaded! You might try to uninstall and reinstall MobMap to fix this problem.");
			end
			return false;
		else
			local loadTime=floor((GetTime()-startTime)*1000)/1000;
			startTime=GetTime();
			if(doGC==nil or doGC==true or mobmap_display_database_loading_info==true) then collectgarbage(); end
			local gcTime=floor((GetTime()-startTime)*1000)/1000;
			UpdateAddOnMemoryUsage();
			local usedRAM=math.floor(GetAddOnMemoryUsage("MobMapDatabaseStub"..dbtype)+0.5);
			if(mobmap_display_database_loading_info==true) then
				MobMap_DisplayMessage("The MobMap "..whatWasLoaded.." database "..whatExactly.."just got dynamically loaded in "..loadTime.." seconds (+ "..gcTime.." seconds GC time) and occupies "..usedRAM.." kbytes of addon memory now.");
			end			
			return true;			
		end
	else
		return true;
	end
end

function MobMap_Mask(number1, number2)
	if(MOBMAP_ISONAMAC) then
		if(number1<0) then 
			return 0; 
		else 
			return floor(number1%number2); 
		end
	else
		return bit.band(number1,number2-1);
	end
end

function MobMap_RGBToHex(r, g, b)
	return string.format("%02x%02x%02x", r*255, g*255, b*255)
end

function MobMap_ConstructColorizedItemName(quality, name)
	local r,g,b = GetItemQualityColor(quality);
	return "|cff"..MobMap_RGBToHex(r,g,b).."["..name.."]|r";
end

function MobMap_ConstructColorizedText(text, r, g, b)
	return "|cff"..MobMap_RGBToHex(r,g,b)..text.."|r";
end

function MobMap_Base36(input)
    local b,k,output,i,d=36,"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ","",0;
    while input>0 do
        i=i+1;
        input,d=floor(input/b),mod(input,b)+1;
        output=string.sub(k,d,d)..output;
    end
    return output;
end

-- completed quest database sync

function MobMap_SyncCompletedQuestsWithServer()
	MobMapFrame:RegisterEvent("QUEST_QUERY_COMPLETE");
	MobMap_DisplayMessage("MobMap is requesting completed quest information from server...");
	QueryQuestsCompleted();
end

function MobMap_FinishCompletedQuestSync()
	MobMapFrame:UnregisterEvent("QUEST_QUERY_COMPLETE");
	local data=GetQuestsCompleted(nil);

	local k,v;
	local count=0;
	mobmap_completed_quests={};
	for k,v in pairs(data) do
		mobmap_completed_quests[k]=1;
		count=count+1;
	end

	MobMap_DisplayMessage("MobMap has synchronized local completed quest info ("..count.." quests) with server");
end

-- blizzard quest tracker stuff

function MobMap_SelectQuestPOIOnMap(questid)
	local i;
	for i=1, 25, 1 do
		local frame=getglobal("WorldMapQuestFrame"..i);
		if(not frame) then break; end
		if(frame.questId==questid) then
			WorldMapQuestPOI_OnClick(frame.poiIcon);
			break;
		end
	end
end