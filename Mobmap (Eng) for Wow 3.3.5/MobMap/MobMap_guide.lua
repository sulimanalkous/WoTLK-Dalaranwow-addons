MOBMAP_REFTYPE_NPC = 1;
MOBMAP_REFTYPE_POI = 0;


function MobMap_Guide_DecodePosition(data)
	local reftype=MobMap_Mask(data,mobmap_poweroftwo[2]);
	local refid=MobMap_Mask(data/mobmap_poweroftwo[2],mobmap_poweroftwo[16]);
	local xcoord=MobMap_Mask(data/mobmap_poweroftwo[18],mobmap_poweroftwo[10])/10;
	local ycoord=MobMap_Mask(data/mobmap_poweroftwo[28],mobmap_poweroftwo[10])/10;
	local zoneid=MobMap_Mask(data/mobmap_poweroftwo[38],mobmap_poweroftwo[9]);
	local zonelevel=MobMap_Mask(data/mobmap_poweroftwo[47],mobmap_poweroftwo[3]);
	local hordeFriendly=(MobMap_Mask(data/mobmap_poweroftwo[50],mobmap_poweroftwo[1])==1);
	local allianceFriendly=(MobMap_Mask(data/mobmap_poweroftwo[51],mobmap_poweroftwo[1])==1);
	return reftype, refid, xcoord, ycoord, zoneid, zonelevel, hordeFriendly, allianceFriendly;	
end

function MobMap_Guide_GetNearestPosition(data)
	if(data==nil) then return; end
	local localx, localy, localzonename = MobMap_GetPlayerCoordinates(true);
	if(localx==nil) then return; end
	local playerIsHorde=(UnitFactionGroup("player")=="Horde");
	local i;
	local nearestreftype, nearestrefid, nearestxcoord, nearestycoord, nearestzoneid, nearestzonelevel = nil;
	local nearestdistance=-1;
	for i=1, #data, 1 do
		local reftype, refid, xcoord, ycoord, zoneid, zonelevel, hordeFriendly, allianceFriendly = MobMap_Guide_DecodePosition(data[i]);
		if((playerIsHorde and hordeFriendly) or (not playerIsHorde and allianceFriendly)) then
			local distance=MobMap_QuestTracker_CalcDistanceToCoord(localx, localy, localzonename, xcoord/100, ycoord/100, MobMap_GetZoneName(zoneid));
			if(#data==1 or (distance and (nearestdistance<0 or distance<nearestdistance))) then
				nearestdistance=distance;
				nearestreftype, nearestrefid, nearestxcoord, nearestycoord, nearestzoneid, nearestzonelevel = reftype, refid, xcoord, ycoord, zoneid, zonelevel;
			end
		end
	end

	return nearestreftype, nearestrefid, nearestxcoord, nearestycoord, nearestzoneid, nearestzonelevel;
end

function MobMap_Guide_GetAllPositions(data)
	local ids={};
	local positions={};
	local playerIsHorde=(UnitFactionGroup("player")=="Horde");
	local idtype=nil;
	for i=1, #data, 1 do
		local reftype, refid, xcoord, ycoord, zoneid, zonelevel, hordeFriendly, allianceFriendly = MobMap_Guide_DecodePosition(data[i]);
		idtype=reftype;
		if(idtype==reftype and ((playerIsHorde and hordeFriendly) or (not playerIsHorde and allianceFriendly))) then
			table.insert(ids, refid);
			table.insert(positions, {x=xcoord, y=ycoord, zoneid=zoneid, zonelevel=zonelevel});
		end
	end
	return idtype, ids, positions;
end

function MobMap_Guide_Toggle()
	MobMapGuideDropDownFrame.displayMode="MENU";
	ToggleDropDownMenu(1, mobmap_guidedata, MobMapGuideDropDownFrame, "cursor");
end

function MobMap_Guide_DropDown_OnLoad()
	UIDropDownMenu_Initialize(this, MobMap_Guide_DropDown_Initialize, "MENU");
end

function MobMap_Guide_DropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();

	if(UIDROPDOWNMENU_MENU_LEVEL==1) then
		info.isTitle = true;
		info.text = MOBMAP_GUIDE_TITLE;
		info.textHeight = 12;
		info.notCheckable = true;
		info.notClickable = true;
		UIDropDownMenu_AddButton(info);
	end

	local num, value;
	if(UIDROPDOWNMENU_MENU_VALUE and UIDROPDOWNMENU_MENU_VALUE.sub) then
		for num, value in pairs(UIDROPDOWNMENU_MENU_VALUE.sub) do
			info.isTitle = false;
			info.text = value.title;
			info.textHeight = 12;
			info.notCheckable = 1;
			if(value.sub and #value.sub>0) then
				info.hasArrow = true;
				info.func = nil;
				info.notClickable = false;
				info.disabled = false;
			else
				info.hasArrow = false;
				info.func = MobMap_Guide_DropDown_Click;
				info.notClickable = false;
				info.disabled = false;
			end
			info.value = value;
			UIDropDownMenu_AddButton(info,UIDROPDOWNMENU_MENU_LEVEL);
		end
	end
end

function MobMap_Guide_ShowDropDown(x, y, data)
	local frame=nil;
	if(#mobmap_guide_framecache==0) then
		mobmap_guide_framecount=mobmap_guide_framecount+1;
		frame=CreateFrame("Frame", "MobMapGuideFrame"..mobmap_guide_framecount, UIParent, "MobMapGuideDropDownFrameTemplate");
		frame:SetFrameStrata("DIALOG");
	else
		frame=table.remove(mobmap_guide_framecache);
	end
	table.insert(mobmap_guide_frames_used, frame);
	frame:SetPoint("CENTER", 0, 0);
	frame:Show();
end

function MobMap_Guide_DropDown_Click()
	local value=this.value;
	mobmap_questsearch=true;
	if(value.pos~=nil) then
		if(not IsShiftKeyDown()) then
			local reftype, refid, xcoord, ycoord, zoneid, zonelevel = MobMap_Guide_GetNearestPosition(value.pos);
			local targettext=nil;
			if(reftype) then
				if(reftype==MOBMAP_REFTYPE_NPC) then
					MobMap_LoadDatabase(MOBMAP_POSITION_DATABASE);
					MobMap_ShowMobByID(refid);
					local mobname,subtitle=MobMap_GetMobName(refid);
					if(mobname) then
						if(subtitle) then
							targettext=mobname.." <"..subtitle..">";
						else
							targettext=mobname;
						end
					end
				end
				if(reftype==MOBMAP_REFTYPE_POI) then
					targettext=value.title;
					MobMap_ShowSinglePositionOnMap(math.floor(xcoord+0.5), math.floor(ycoord+0.5), targettext, MobMap_GetZoneName(zoneid), zonelevel);
				end
				
				if(targettext) then
					MobMap_QuestTracker_CreateWaypoint(xcoord, ycoord, MobMap_GetZoneName(zoneid), targettext);
				end
			else
				MobMap_DisplayMessage(MOBMAP_GUIDE_NOTHING_FOUND);
			end
		else
			local reftype, refids, positions = MobMap_Guide_GetAllPositions(value.pos);
			if(reftype) then
				local localx, localy, localzonename, localzonelevel = MobMap_GetPlayerCoordinates(true);
				if(reftype==MOBMAP_REFTYPE_NPC) then
					MobMap_LoadDatabase(MOBMAP_POSITION_DATABASE);
					MobMap_ShowMultipleMobs(refids, value.title, localzonename, localzonelevel);
					HideUIPanel(MobMapFrame);
				end
				if(reftype==MOBMAP_REFTYPE_POI) then
					MobMap_ShowMultiplePositionsInDifferentZonesOnMap(MobMap_Guide_SortPositionsByZones(positions), value.title, localzonename, localzonelevel);
					HideUIPanel(MobMapFrame);
				end
			end
		end
	end

	mobmap_questsearch=false;
	CloseDropDownMenus();
end

function MobMap_Guide_SortPositionsByZones(data)
	local zones={};
	local k,v;
	for k,v in pairs(data) do
		local zoneidentifier=v.zoneid.."/"..v.zonelevel;
		if(not zones[zoneidentifier]) then zones[zoneidentifier]={zoneid=v.zoneid, zonelevel=v.zonelevel, posdata={}}; end
		table.insert(zones[zoneidentifier].posdata, {x=math.floor(v.x+0.5), y=math.floor(v.y+0.5)});
	end
	local result={};
	for k,v in pairs(zones) do
		table.insert(result, v);
	end
	return result;
end