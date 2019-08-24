-- general database access functions for pickup databases

MOBMAP_PICKUP_TYPE_QUESTITEMS = 1;
MOBMAP_PICKUP_TYPE_FISHING = 2;
MOBMAP_PICKUP_TYPE_MINING = 3;
MOBMAP_PICKUP_TYPE_HERBS = 4;

function MobMap_GetPickupIndex(pickuptype)
	if(pickuptype==MOBMAP_PICKUP_TYPE_QUESTITEMS) then return mobmap_questpickupindex; end
	if(pickuptype==MOBMAP_PICKUP_TYPE_FISHING) then return mobmap_fishingpickupindex; end
	if(pickuptype==MOBMAP_PICKUP_TYPE_MINING) then return mobmap_miningpickupindex; end
	if(pickuptype==MOBMAP_PICKUP_TYPE_HERBS) then return mobmap_herbspickupindex; end
end

function MobMap_GetPickupPointers(pickuptype)
	if(pickuptype==MOBMAP_PICKUP_TYPE_QUESTITEMS) then return mobmap_questpickuppointers; end
	if(pickuptype==MOBMAP_PICKUP_TYPE_FISHING) then return mobmap_fishingpickuppointers; end
	if(pickuptype==MOBMAP_PICKUP_TYPE_MINING) then return mobmap_miningpickuppointers; end
	if(pickuptype==MOBMAP_PICKUP_TYPE_HERBS) then return mobmap_herbspickuppointers; end
end

function MobMap_GetPickupData(pickuptype)
	if(pickuptype==MOBMAP_PICKUP_TYPE_QUESTITEMS) then return mobmap_questpickupdata; end
	if(pickuptype==MOBMAP_PICKUP_TYPE_FISHING) then return mobmap_fishingpickupdata; end
	if(pickuptype==MOBMAP_PICKUP_TYPE_MINING) then return mobmap_miningpickupdata; end
	if(pickuptype==MOBMAP_PICKUP_TYPE_HERBS) then return mobmap_herbspickupdata; end
end

function MobMap_GetPickupItemList(pickuptype, namefilter)
	local index=MobMap_GetPickupIndex(pickuptype);
	local ihidlist={};
	local i;
	local idtofind;
	local exactmatch=false;

	if(namefilter) then
		if(string.sub(namefilter,1,1)=="\"" and string.sub(namefilter,-1)=="\"") then
			exactmatch=true;
			namefilter=string.sub(namefilter,2,string.len(namefilter)-1);
		else
			exactmatch=false;
		end

		if(string.sub(namefilter,1,3)=="id:") then
			 idtofind=tonumber(string.sub(namefilter,4));
		end
	end

	for i=1,table.getn(index),1 do
		local data=index[i];
		local ihid1=MobMap_Mask(data,mobmap_poweroftwo[16]);
		local ihid2=MobMap_Mask(data/mobmap_poweroftwo[25],mobmap_poweroftwo[16]);
		if(idtofind) then
			if(ihid1==idtofind) then
				table.insert(ihidlist, ihid1);
			end
		else
			local itemname=MobMap_GetItemNameByIHID(ihid1);
			if(namefilter==nil or ((exactmatch==false and string.find(string.lower(itemname),".-"..string.lower(namefilter)..".-")~=nil) or (exactmatch==true and string.lower(namefilter)==string.lower(itemname)))) then
				table.insert(ihidlist, ihid1);
			end
		end
		if(ihid2~=0) then
			if(idtofind) then
				if(ihid2==idtofind) then
					table.insert(ihidlist, ihid2);
				end
			else
				itemname=MobMap_GetItemNameByIHID(ihid2);
				if(namefilter==nil or ((exactmatch==false and string.find(string.lower(itemname),".-"..string.lower(namefilter)..".-")~=nil) or (exactmatch==true and string.lower(namefilter)==string.lower(itemname)))) then
					table.insert(ihidlist, ihid2);
				end
			end
		end
	end

	return ihidlist;
end

function MobMap_GetPickupItemZoneListData(pickuptype, ihid)
	local index=MobMap_GetPickupIndex(pickuptype);
	local ihidlist={};
	local i;
	local zonecount=0;

	for i=1,table.getn(index)*2,1 do
		local data=index[floor((i-1)/2)+1];
		local currihid=MobMap_Mask(data/mobmap_poweroftwo[25*((i-1)%2)],mobmap_poweroftwo[16]);
		local zones=MobMap_Mask(data/mobmap_poweroftwo[25*((i-1)%2)+16],mobmap_poweroftwo[8]);
		local isDrop=MobMap_Mask(data/mobmap_poweroftwo[25*((i-1)%2)+24],mobmap_poweroftwo[1]);
		if(isDrop==0) then isDrop=false; else isDrop=true; end
		if(currihid==ihid) then
			return zonecount, zones, isDrop;
		else
			zonecount=zonecount+zones;
		end
	end

	return nil;	
end

function MobMap_GetPickupItemZoneList(pickuptype, ihid)
	local zoneoffset, zonecount, isDrop = MobMap_GetPickupItemZoneListData(pickuptype, ihid);
	local pointers=MobMap_GetPickupPointers(pickuptype);

	if(zoneoffset==nil) then
		return nil;
	end

	local i;
	local zonelist={};

	for i=1,zonecount,1 do
		local data=pointers[i+zoneoffset];
		local zoneid=MobMap_Mask(data,mobmap_poweroftwo[8]);
		local zonelevel=MobMap_Mask(data/mobmap_poweroftwo[8],mobmap_poweroftwo[7]);
		local length=MobMap_Mask(data/mobmap_poweroftwo[15],mobmap_poweroftwo[16]);
		local position=MobMap_Mask(data/mobmap_poweroftwo[31],mobmap_poweroftwo[20]);
		table.insert(zonelist,{id=zoneid, level=zonelevel});
	end

	return zonelist, isDrop;
end

function MobMap_GetPickupItemPointer(pickuptype, ihid, zone, level)
	local zoneoffset, zonecount = MobMap_GetPickupItemZoneListData(pickuptype, ihid);
	local pointers=MobMap_GetPickupPointers(pickuptype);

	if(zoneoffset==nil) then
		return nil;
	end

	local i;
	for i=1,zonecount,1 do
		local data=pointers[i+zoneoffset];
		local zoneid=MobMap_Mask(data,mobmap_poweroftwo[8]);
		local zonelevel=MobMap_Mask(data/mobmap_poweroftwo[8],mobmap_poweroftwo[7]);
		if(zoneid==zone and (level==nil or zonelevel==level)) then
			local length=MobMap_Mask(data/mobmap_poweroftwo[15],mobmap_poweroftwo[16]);
			local position=MobMap_Mask(data/mobmap_poweroftwo[31],mobmap_poweroftwo[20]);
			return position, length;
		end
	end
	return nil;
end

function MobMap_GetItemPositions(pickuptype, itemid, zoneid, zonelevel)
	local position, length = MobMap_GetPickupItemPointer(pickuptype, itemid, zoneid, zonelevel);
	
	if(position==nil) then
		return nil; 
	end
	
	local i;
	local coords={};
	local xo,yo;
	for i=0, length-1, 1 do
		local xc,yc=MobMap_GetItemCoordFromDB(pickuptype, position+i)
		if(i%2==0) then
			xo=xc;
			yo=yc;
		else
			table.insert(coords, {x1=xo, x2=xc, y=yo});
		end
	end
	return coords;
end

function MobMap_GetItemCoordFromDB(pickuptype, position)
	local itemposdata=MobMap_GetPickupData(pickuptype);
	if(itemposdata==nil) then
		return nil;
	end
	local bucket=floor(position/4)+1;
	local data=itemposdata[bucket];
	if(data==nil) then
		return nil;
	end
	local x;
	local y=0;
	x=floor(data/(mobmap_shiftconst[(position%4)*2])+0.5);
	if(position%2==0) then y=floor(data/(mobmap_shiftconst[(position%4)*2+1])+0.5); end
	x=x%256;
	y=y%256;
	return x,y;
end

-- UI stuff

function MobMapPickupTypeFilter_OnLoad()
	UIDropDownMenu_Initialize(MobMapPickupListTypeFilter, MobMap_PickupListTypeFilter_Initialize);
	UIDropDownMenu_SetWidth(MobMapPickupListTypeFilter, 180);
end

function MobMap_PickupListTypeFilter_Initialize()
	local i;
	for i=1,table.getn(MOBMAP_PICKUP_TYPES),1 do
		local info={};
		info.text=MOBMAP_PICKUP_TYPES[i];
		info.func=MobMap_PickupListTypeFilter_OnClick;
		UIDropDownMenu_AddButton(info);
	end
end

mobmap_pickupitemlist={};
mobmap_pickupzonelist={};

function MobMap_PickupListTypeFilter_OnClick(self)
	UIDropDownMenu_SetSelectedID(MobMapPickupListTypeFilter, self:GetID());
	MobMap_RefreshPickupItemList();
end

function MobMap_RefreshPickupItemList()
	local selectedType=UIDropDownMenu_GetSelectedID(MobMapPickupListTypeFilter);
	if(selectedType~=MOBMAP_PICKUP_TYPE_QUESTITEMS and selectedType~=MOBMAP_PICKUP_TYPE_FISHING and selectedType~=MOBMAP_PICKUP_TYPE_MINING and selectedType~=MOBMAP_PICKUP_TYPE_HERBS) then return; end

	if(selectedType==MOBMAP_PICKUP_TYPE_QUESTITEMS) then MobMap_LoadDatabase(MOBMAP_PICKUP_QUEST_ITEM_DATABASE); end
	if(selectedType==MOBMAP_PICKUP_TYPE_FISHING) then MobMap_LoadDatabase(MOBMAP_PICKUP_FISHING_DATABASE); end
	if(selectedType==MOBMAP_PICKUP_TYPE_MINING) then MobMap_LoadDatabase(MOBMAP_PICKUP_MINING_DATABASE); end
	if(selectedType==MOBMAP_PICKUP_TYPE_HERBS) then MobMap_LoadDatabase(MOBMAP_PICKUP_HERBS_DATABASE); end

	local namefilter=MobMapPickupListNameFilter:GetText();
	if(namefilter=="") then namefilter=nil; end

	mobmap_pickupitemlist=MobMap_GetPickupItemList(selectedType, namefilter);
	MobMap_UpdatePickupItemList();
end

function MobMap_UpdatePickupItemList()
	local maxitemcount=14+math.floor((mobmap_window_height-430)/18);
	local itemcount=table.getn(mobmap_pickupitemlist);
	local offset=FauxScrollFrame_GetOffset(MobMapPickupItemListScrollFrame);

	MobMapPickupListFrameItemHighlightFrame:Hide();
	for i=1,36,1 do
		local itemindex=i+offset;
		if(itemindex>itemcount or i>maxitemcount) then
			MobMap_UpdatePickupItemNameEntry(i, nil);
		else
			MobMap_UpdatePickupItemNameEntry(i, mobmap_pickupitemlist[itemindex]);
		end
	end

	FauxScrollFrame_Update(MobMapPickupItemListScrollFrame, itemcount, maxitemcount, 22);
end

function MobMap_ShowSelectedPickupItem()
	if(mobmap_pickupitemlist==nil or MobMapPickupListFrame.selecteditem==nil) then return; end
	local i;
	for i=1,table.getn(mobmap_pickupitemlist),1 do
		if(mobmap_pickupitemlist[i]==MobMapPickupListFrame.selecteditem) then
			local offset=i-1;
			if(offset+14>table.getn(mobmap_pickupitemlist)) then
				if(offset-13<0) then
					offset=0;
				else
					offset=offset-13;
				end
			end
			FauxScrollFrame_SetOffset(MobMapPickupItemListScrollFrame, offset);
			MobMap_UpdatePickupItemList();
			return;
		end
	end
end

function MobMap_UpdatePickupItemNameEntry(pos, ihid)
	local frame=getglobal("MobMapPickupItem"..pos);
	local frame_button=getglobal("MobMapPickupItem"..pos.."ItemName");
	local frame_text=getglobal("MobMapPickupItem"..pos.."ItemNameText");
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
			if(ihid==MobMapPickupListFrame.selecteditem) then
				MobMapPickupListFrameItemHighlightFrame:Show();
				MobMapPickupListFrameItemHighlightFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 2);
				MobMapPickupListFrameItemHighlightFrame:SetAlpha(0.5);
				MobMapPickupItemHighlight:SetVertexColor(1.0, 1.0, 1.0);
			end
		end
	end
end

function MobMapPickupItemButton_ProcessClick(button)
	local frame=getglobal(button);
	local selectedType=UIDropDownMenu_GetSelectedID(MobMapPickupListTypeFilter);
	MobMapPickupListFrame.selecteditem=frame.ihid;
	MobMapPickupListFrame.selecteditemname=MobMap_GetItemNameByIHID(frame.ihid);
	local itemid, quality = MobMap_GetItemDataByIHID(frame.ihid);
	MobMapPickupListFrame.selecteditemid=itemid;
	MobMapPickupListFrame.selecteditemquality=quality;
	MobMapPickupListFrame.selectedzone=nil;
	local isDrop;
	mobmap_pickupzonelist, isDrop = MobMap_GetPickupItemZoneList(selectedType, frame.ihid);
	MobMapPickupListFrameItemHighlightFrame:Show();
	MobMapPickupListFrameItemHighlightFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 2);
	MobMapPickupListFrameItemHighlightFrame:SetAlpha(0.5);
	MobMapPickupListFrameZoneHighlightFrame:Hide();
	MobMap_UpdatePickupZoneList();
	if(MobMapPickupListFrameShowAllCheckButton:GetChecked()) then
		MobMap_UpdatePickupListAllZoneDisplay();
	else
		if(table.getn(mobmap_pickupzonelist)==1) then
			MobMapPickupListZoneButton_ProcessClick("MobMapPickupListZone1");
			if(mobmap_questsearch) then HideUIPanel(MobMapFrame); end
		elseif(mobmap_questsearch) then
			MobMap_UpdatePickupListAllZoneDisplay();
			MobMapPickupListFrame.selectedzone=nil;
		end
	end
	if(isDrop==true) then
		MobMapPickupListFrameMoreButton:Show();
	else
		MobMapPickupListFrameMoreButton:Hide();
	end
	mobmap_questsearch=false;
end

function MobMap_UpdatePickupZoneList()
	local maxzonecount=14+math.floor((mobmap_window_height-430)/18);
	local zonecount=table.getn(mobmap_pickupzonelist);
	local offset=FauxScrollFrame_GetOffset(MobMapPickupZoneListScrollFrame);

	MobMapPickupListFrameZoneHighlightFrame:Hide();
	for i=1,36,1 do
		local zoneindex=i+offset;
		if(zoneindex>zonecount or i>maxzonecount) then
			MobMap_UpdatePickupZoneEntry(i, nil);
		else
			MobMap_UpdatePickupZoneEntry(i, mobmap_pickupzonelist[zoneindex]);
		end
	end

	FauxScrollFrame_Update(MobMapPickupZoneListScrollFrame, zonecount, maxzonecount, 22);
end

function MobMap_UpdatePickupZoneEntry(pos, entrydata)
	local frame=getglobal("MobMapPickupListZone"..pos);
	local frame_text=getglobal("MobMapPickupListZone"..pos.."Text");

	if(entrydata==nil) then
		frame:Hide();
	else
		if(entrydata.level>0) then
			frame_text:SetText(MobMap_GetZoneName(entrydata.id).." ("..entrydata.level..")");
		else
			frame_text:SetText(MobMap_GetZoneName(entrydata.id));
		end
		frame.id=entrydata.id;
		frame.level=entrydata.level;
		frame.zonename=MobMap_GetZoneName(entrydata.id);
		frame:Show();
		if(entrydata==MobMapPickupListFrame.selectedzone) then
			MobMapPickupListFrameZoneHighlightFrame:Show();
			MobMapPickupListFrameZoneHighlightFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 2);
			MobMapPickupListFrameZoneHighlightFrame:SetAlpha(0.5);
			MobMapPickupZoneHighlight:SetVertexColor(1.0, 1.0, 1.0);
		end
	end
end

function MobMapPickupListZoneButton_ProcessClick(button)
	local selectedType=UIDropDownMenu_GetSelectedID(MobMapPickupListTypeFilter);
	local frame=getglobal(button);
	MobMapPickupListFrameZoneHighlightFrame:Show();
	MobMapPickupListFrameZoneHighlightFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0);
	MobMapPickupListFrameZoneHighlightFrame:SetAlpha(0.5);
	MobMapPickupZoneHighlight:SetVertexColor(1.0, 1.0, 1.0);
	MobMapPickupListFrame.selectedzone=frame.id;
	mobmap_multidisplay=nil;
	mobmap_currentlyshown={zonename=frame.zonename, zoneid=frame.id, zonelevel=frame.level, itemtype=selectedType, itemname=MobMapPickupListFrame.selecteditemname, ihid=MobMapPickupListFrame.selecteditem, itemid=MobMapPickupListFrame.selecteditemid, itemquality=MobMapPickupListFrame.selecteditemquality};
	mobmap_enabled=true;
	MobMapCheckButton:SetChecked(true);
	MobMap_SwitchMapAndDisplay();
end

function MobMap_UpdatePickupListAllZoneDisplay()
	local selectedType=UIDropDownMenu_GetSelectedID(MobMapPickupListTypeFilter);
	mobmap_currentlist={};
	mobmap_multidisplay={};
	mobmap_currentlyshown=nil;
	MobMapPickupListFrameZoneHighlightFrame:Hide();
	for k,v in pairs(mobmap_pickupzonelist) do
		if(mobmap_multidisplay[1]==nil) then
			mobmap_multidisplay[1]={itemtype=selectedType, itemname=MobMapPickupListFrame.selecteditemname, ihid=MobMapPickupListFrame.selecteditem, itemid=MobMapPickupListFrame.selecteditemid, itemquality=MobMapPickupListFrame.selecteditemquality, zones={}};
		end
		local zonename=MobMap_GetZoneName(v.id);
		table.insert(mobmap_multidisplay[1].zones,{zoneid=v.id, zonelevel=v.level, zonename=zonename});
	end
	if(table.getn(mobmap_multidisplay)==0) then 
		mobmap_multidisplay=nil; 
	else
		MobMap_UpdatePositions();
		MobMap_SwitchMapAndDisplay();
	end

	local i;
	for i=1,14,1 do
		local frame=getglobal("MobMapPickupListZone"..i);
		frame:Disable();
		frame:SetAlpha(0.5);
	end
end

function MobMap_HidePickupListAllZoneDisplay()
	mobmap_currentlyshown=nil;
	mobmap_multidisplay=nil;
	MobMap_SwitchMapAndDisplay();
	MobMapPickupListFrameZoneHighlightFrame:Hide();
	local i;
	for i=1,14,1 do
		local frame=getglobal("MobMapPickupListZone"..i);
		frame:Enable();
		frame:SetAlpha(1.0);
	end
end

function MobMap_LoadAllPickupDatabases()
	MobMap_LoadDatabase(MOBMAP_PICKUP_QUEST_ITEM_DATABASE);
	MobMap_LoadDatabase(MOBMAP_PICKUP_FISHING_DATABASE);
	MobMap_LoadDatabase(MOBMAP_PICKUP_MINING_DATABASE);
	MobMap_LoadDatabase(MOBMAP_PICKUP_HERBS_DATABASE);
	return 4;
end

function MobMap_IsInQuestPickupDatabase(itemname)
	MobMap_LoadDatabase(MOBMAP_PICKUP_QUEST_ITEM_DATABASE);

	local list=MobMap_GetPickupItemList(MOBMAP_PICKUP_TYPE_QUESTITEMS, "\""..itemname.."\"");
	if(table.getn(list)>0) then
		return true;
	else
		return false;
	end
end

function MobMap_IsInAnyPickupDatabase(itemname)
	local dbCount=MobMap_LoadAllPickupDatabases();

	local i;
	for i=1,dbCount,1 do
		local list=MobMap_GetPickupItemList(i, "\""..itemname.."\"");
		if(table.getn(list)>0) then
			return true;
		end
	end
	return false;
end

function MobMap_DoQuestPickupDatabaseSearch(itemname)
	MobMap_LoadDatabase(MOBMAP_PICKUP_QUEST_ITEM_DATABASE);

	return MobMap_DoPickupDatabaseSearch(MOBMAP_PICKUP_TYPE_QUESTITEMS, itemname);
end

function MobMap_ShowQuestItemPickupSpotsByID(ihid)
	if(ihid==nil) then return; end
	MobMap_ShowPanel("MobMapPickupListFrame");
	UIDropDownMenu_SetSelectedID(MobMapPickupListTypeFilter, MOBMAP_PICKUP_TYPE_QUESTITEMS);
	MobMapPickupListNameFilter:SetText("id: "..ihid);
	MobMap_RefreshPickupItemList();
	if(table.getn(mobmap_pickupitemlist)==1) then
		MobMapPickupItemButton_ProcessClick("MobMapPickupItem1");
	end
end

function MobMap_DoPickupDatabaseSearch(database, itemname)
	MobMap_ShowPanel("MobMapPickupListFrame");
	UIDropDownMenu_SetSelectedID(MobMapPickupListTypeFilter, database);
	MobMapPickupListNameFilter:SetText("\""..itemname.."\"");
	MobMap_RefreshPickupItemList();
	if(table.getn(mobmap_pickupitemlist)==1) then
		if(mobmap_questsearch) then 
			mobmap_questsearch=false;
			HideUIPanel(MobMapFrame);
		end
		MobMapPickupItemButton_ProcessClick("MobMapPickupItem1");
	elseif(table.getn(mobmap_pickupitemlist)>1) then
		if(not MobMapFrame:IsVisible()) then ShowUIPanel(MobMapFrame); end
		if(MobMapPickupListFrame~=nil and not MobMapPickupListFrame:IsVisible()) then MobMap_ShowPanel("MobMapPickupListFrame"); end
	else
		return false;
	end
	return true;
end

function MobMap_DoAnyPickupDatabaseSearch(itemname)
	if(MobMap_DoQuestPickupDatabaseSearch(itemname)==false) then
		local dbCount=MobMap_LoadAllPickupDatabases();
		local ihid=MobMap_GetIHIDByItemName(itemname);
		if(ihid==nil) then return; end

		local i;
		for i=1,dbCount,1 do
			local list=MobMap_GetPickupItemList(i, nil);
			for k,v in pairs(list) do
				if(v==ihid) then
					MobMap_DoPickupDatabaseSearch(i, itemname);
					return;
				end
			end
		end
	end
end