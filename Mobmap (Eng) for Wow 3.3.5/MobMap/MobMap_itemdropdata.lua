-- item drop data database functions

function MobMap_GetDropItemNameList(itemnamefilter)
	local i;
	local list={};
	local exactmatch=false;
	if(itemnamefilter) then
		if(string.sub(itemnamefilter,1,1)=="\"" and string.sub(itemnamefilter,-1)=="\"") then
			exactmatch=true;
			itemnamefilter=string.sub(itemnamefilter,2,string.len(itemnamefilter)-1);
		else
			exactmatch=false;
		end
	end

	local idtofind=nil;
	if(string.sub(itemnamefilter,1,3)=="id:") then
		 idtofind=tonumber(string.sub(itemnamefilter,4));
	end
	for i=1,table.getn(mobmap_itemdropdataindex),1 do
		local data=mobmap_itemdropdataindex[i];
		local k;
		for k=0,1,1 do
			local currentIHID=MobMap_Mask(data/mobmap_poweroftwo[k*25],mobmap_poweroftwo[16]);
			if(idtofind) then
				if(currentIHID==idtofind) then
					table.insert(list, currentIHID);
				end
			else
				local currentName=MobMap_GetItemNameByIHID(currentIHID);
				if(currentName and ((exactmatch==false and string.find(string.lower(currentName),".-"..string.lower(itemnamefilter)..".-")~=nil) or (exactmatch==true and string.lower(currentName)==string.lower(itemnamefilter)))) then
					table.insert(list, currentIHID);
				end
			end
		end
	end
	return list;
end

function MobMap_GetDropChances(IHID)
	local i;
	local position=0;
	for i=1,table.getn(mobmap_itemdropdataindex),1 do
		local data=mobmap_itemdropdataindex[i];
		local k;
		for k=0,1,1 do
			local currentIHID=MobMap_Mask(data/mobmap_poweroftwo[k*25],mobmap_poweroftwo[16]);
			local length=MobMap_Mask(data/mobmap_poweroftwo[k*25+16],mobmap_poweroftwo[8]);
			local isPickup=MobMap_Mask(data/mobmap_poweroftwo[k*25+24],mobmap_poweroftwo[1]);
			if(isPickup==0) then isPickup=false; else isPickup=true; end
			if(currentIHID==IHID) then
				return MobMap_GetRealDropChances(position,length), isPickup;
			end
			position=position+length;
		end
	end
	return {};
end

function MobMap_GetRealDropChances(position, length)
	local p;
	local result={};
	for p=position,position+length-1,1 do
		local data=mobmap_itemdropdata[floor(p/2)+1];
		local m=MobMap_Mask(data/mobmap_poweroftwo[(p%2)*26],mobmap_poweroftwo[16]);
		local c=MobMap_Mask(data/mobmap_poweroftwo[(p%2)*26+16],mobmap_poweroftwo[8]);
		local h=MobMap_Mask(data/mobmap_poweroftwo[(p%2)*26+24],mobmap_poweroftwo[1]);
		local r=MobMap_Mask(data/mobmap_poweroftwo[(p%2)*26+25],mobmap_poweroftwo[1]);
		c=c/2;
		if(h==0) then h=false; else h=true; end
		if(r==0) then r=false; else r=true; end
		table.insert(result,{mobid=m, chance=c, heroiconly=h, bigraidonly=r});
	end
	return result;
end

function MobMap_GetMobLootTable(mobid)
	local position=0;
	local result={};
	for i=1,table.getn(mobmap_itemdropdataindex),1 do
		local data=mobmap_itemdropdataindex[i];
		local k;
		for k=0,1,1 do
			local currentIHID=MobMap_Mask(data/mobmap_poweroftwo[k*25],mobmap_poweroftwo[16]);
			local length=MobMap_Mask(data/mobmap_poweroftwo[k*25+16],mobmap_poweroftwo[8]);
			for p=position,position+length-1,1 do
				local data=mobmap_itemdropdata[floor(p/2)+1];
				local m=MobMap_Mask(data/mobmap_poweroftwo[(p%2)*26],mobmap_poweroftwo[16]);
				if(m==mobid) then
					local c=MobMap_Mask(data/mobmap_poweroftwo[(p%2)*26+16],mobmap_poweroftwo[8]);
					local h=MobMap_Mask(data/mobmap_poweroftwo[(p%2)*26+24],mobmap_poweroftwo[1]);
					local r=MobMap_Mask(data/mobmap_poweroftwo[(p%2)*26+25],mobmap_poweroftwo[1]);
					c=c/2;
					if(h==0) then h=false; else h=true; end
					if(r==0) then r=false; else r=true; end
					local itemid, quality, isDangerous = MobMap_GetItemDataByIHID(currentIHID);
					local itemname=MobMap_GetItemNameByIHID(currentIHID);
					table.insert(result,{ihid=currentIHID, chance=c, heroiconly=h, bigraidonly=r, itemid=itemid, itemname=itemname, quality=quality, isdangerous=isDangerous});
				end
			end

			position=position+length;			
		end
	end
	MobMap_SortMobLootTable(result);
	return result;
end

function MobMap_SortMobLootTable(tbl)
	table.sort(tbl, MobMap_SortMobLootTable_Comp);
end

function MobMap_SortMobLootTable_Comp(e, f)
	if(e.quality>f.quality) then
		return true;
	elseif(e.quality<f.quality) then
		return false;
	else
		if(e.bigraidonly==true and f.bigraidonly==false) then
			return false;
		elseif(e.bigraidonly==false and f.bigraidonly==true) then
			return true;
		else
			if(e.heroiconly==true and f.heroiconly==false) then
				return false;
			elseif(e.heroiconly==false and f.heroiconly==true) then
				return true;
			else
				if(e.itemname<f.itemname) then
					return true;
				elseif(e.itemname>f.itemname) then
					return false;
				else
					if(e.itemid<f.itemid) then
						return true;
					else
						return false;
					end
				end
			end
		end
	end			
end

function MobMap_GetCrateName(crateid)
	return mobmap_itemsourcecrates[crateid];
end

-- user interface functions

mobmap_drop_list_sorting=0;

function MobMap_DropListFrame_OnShow()
	local mobmap_old_questsearch=mobmap_questsearch;
	mobmap_questsearch=false;
	if(mobmap_dropitemnamelist==nil) then
		MobMap_RefreshDropItemNameList();
	else
		MobMap_ShowSelectedItem();
	end
	MobMap_RefreshDropChanceList();
	mobmap_questsearch=mobmap_old_questsearch;
end

function MobMap_DropListByBosses_OnShow()
	MobMap_UpdateBossNameList();
end

function MobMap_DropListSortingOptions_Update()
	if(mobmap_drop_list_sorting==0) then
		MobMapDropListSortByItems:SetChecked(true);
		MobMapDropListSortByBosses:SetChecked(false);
		MobMapDropListByItem:Show();
		MobMapDropListByBosses:Hide();
	else
		MobMapDropListSortByItems:SetChecked(false);
		MobMapDropListSortByBosses:SetChecked(true);
		MobMapDropListByItem:Hide();
		MobMapDropListByBosses:Show();
	end
end

function MobMap_UpdateBossNameList()
	local maxbosscount=16+math.floor((mobmap_window_height-430)/18);
	for i=1,38,1 do
		MobMap_UpdateBossName(i, nil);
	end
	local offset=FauxScrollFrame_GetOffset(MobMapDropListBossScrollFrame);

	local bosscount=0;
	local k,v,l;
	for k,v in pairs(mobmap_instancelist) do
		bosscount=bosscount+1;
		local pos=bosscount-offset;
		if(v.isExpanded==nil) then
			v.isExpanded=false;
		end
		if(pos>=1 and pos<=maxbosscount) then
			MobMap_UpdateBossName(pos, v.name, nil, k, v.isExpanded);
		end
		if(v.isExpanded==true) then
			for l=1,table.getn(v),1 do
				bosscount=bosscount+1;
				pos=bosscount-offset;
				if(pos>=1 and pos<=maxbosscount) then
					if(v[l]>65000) then
						MobMap_UpdateBossName(pos, MobMap_GetCrateName(v[l]-65000), v[l]);
					else
						MobMap_UpdateBossName(pos, MobMap_GetMobName(v[l]), v[l]);
					end
				end
			end
		end
	end

	FauxScrollFrame_Update(MobMapDropListBossScrollFrame, bosscount, maxbosscount, 22);
end

function MobMap_UpdateBossName(pos, entry, bossid, instanceid, isExpanded)
	local frame=getglobal("MobMapDropListBoss"..pos);
	local framehighlight=getglobal("MobMapDropListBoss"..pos.."Highlight");
	local frametext=getglobal("MobMapDropListBoss"..pos.."Text");
	if(entry==nil) then
		frame:Hide();
	else
		frame:SetText(entry);
		frame.instanceid=instanceid;
		frame.bossid=bossid;
		if(isExpanded==true) then
			frame:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up");
			framehighlight:SetTexture("Interface\\Buttons\\UI-PlusButton-Hilight");
			frame:UnlockHighlight();
		elseif(isExpanded==false) then
			frame:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up");
			framehighlight:SetTexture("Interface\\Buttons\\UI-PlusButton-Hilight");
			frame:UnlockHighlight();
		else
			frame:SetNormalTexture("");
			framehighlight:SetTexture("");
		end		
		frame:Show();
	end
end

function MobMap_DropListBossNameEntry_OnClick(self)
	if(self.instanceid) then
		if(mobmap_instancelist[self.instanceid].isExpanded==true) then
			mobmap_instancelist[self.instanceid].isExpanded=false;
		else
			mobmap_instancelist[self.instanceid].isExpanded=true;
		end
	elseif(self.bossid) then
		MobMap_DisplayBossLootTable(self.bossid);
	end
	MobMap_UpdateBossNameList();
end

mobmap_bossloottable={};

function MobMap_DisplayBossLootTable(npcid)
	if(npcid<65000) then
		local title, subtitle=MobMap_GetMobNameAndSubtitle(MobMap_GetMobFullName(npcid));
		MobMapDropListByBossesName:SetText(title);
		if(subtitle) then
			MobMapDropListByBossesSubtitle:SetText(subtitle);
		else
			MobMapDropListByBossesSubtitle:SetText("");
		end
		local pointer=MobMap_GetMobPointer(npcid);
		if(pointer==nil) then return; end
		local minlevel, maxlevel = MobMap_GetMobDetails(pointer);
		if(minlevel~=maxlevel) then
			MobMapDropListByBossesLevel:SetText(MOBMAP_LEVEL..minlevel.." - "..maxlevel);
		else
			if(minlevel==0) then
				MobMapDropListByBossesLevel:SetText(MOBMAP_BOSS_LEVEL);
			else
				MobMapDropListByBossesLevel:SetText(MOBMAP_LEVEL..minlevel);
			end
		end
	else
		local title=MobMap_GetCrateName(npcid-65000);
		MobMapDropListByBossesName:SetText(title);
		MobMapDropListByBossesSubtitle:SetText("");
		MobMapDropListByBossesLevel:SetText("");
	end
	
	mobmap_bossloottable=MobMap_GetMobLootTable(npcid);
	MobMap_UpdateBossLootTable();
end

function MobMap_UpdateBossLootTable()
	local maxlootcount=5+math.floor((mobmap_window_height-430)/44);
	local itemcount=table.getn(mobmap_bossloottable);
	local offset=FauxScrollFrame_GetOffset(MobMapDropListBossLootTableScrollFrame);

	for i=1,14,1 do
		local itemindex=i+offset;
		if(itemindex>itemcount or i>maxlootcount) then
			MobMap_UpdateBossLootTableEntry(i, nil);
		else
			MobMap_UpdateBossLootTableEntry(i, mobmap_bossloottable[itemindex]);
		end
	end

	FauxScrollFrame_Update(MobMapDropListBossLootTableScrollFrame, itemcount, maxlootcount, 22);
end

function MobMap_UpdateBossLootTableEntry(pos, entry)
	local frame=getglobal("MobMapBossLootTableEntry"..pos);
	local frame_item=getglobal("MobMapBossLootTableEntry"..pos.."ItemButton");
	local frame_name=getglobal("MobMapBossLootTableEntry"..pos.."Name");
	local frame_chance=getglobal("MobMapBossLootTableEntry"..pos.."Chance");
	local frame_heroic=getglobal("MobMapBossLootTableEntry"..pos.."Heroic");
	local frame_bigraid=getglobal("MobMapBossLootTableEntry"..pos.."Bigraid");
	if(entry==nil) then
		frame:Hide();
	else
		frame_name:SetText(entry.itemname);
		local r, g, b = GetItemQualityColor(entry.quality);
		frame_name:SetTextColor(r,g,b);

		frame.itemid=entry.itemid;
		frame.ihid=entry.ihid;
		frame.isdangerous=entry.isdangerous;

		local itemString=MobMap_ConstructItemString(entry.itemid);
		local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(itemString);
		if(itemName==nil and entry.isdangerous==false) then
			MobMapScanTooltip:SetHyperlink(itemString);
			frame.itemlink=nil;
		else
			if(itemName==nil) then
				frame.itemlink=nil;
				local icon=MobMap_GetItemIcon(entry.itemid);
				if(icon) then
					SetItemButtonTexture(frame_item, "Interface\\Icons\\"..icon..".blp");
				else
					SetItemButtonTexture(frame_item, "Interface\\Icons\\INV_Misc_QuestionMark.blp");
				end
			else
				frame.itemlink=itemLink;
				SetItemButtonTexture(frame_item, itemTexture);
			end
		end
		if(entry.chance<=100) then
			frame_chance:SetText(string.format("%5.1f",entry.chance).."%");
		else
			frame_chance:SetText("???%");
		end
		if(entry.heroiconly==true) then
			frame_heroic:Show();
		else
			frame_heroic:Hide();
		end
		if(entry.bigraidonly==true) then
			frame_bigraid:Show();
		else
			frame_bigraid:Hide();
		end
		frame:Show();
	end
end

mobmap_bossloottable_timeout=0;

function MobMap_BossLootTable_OnUpdate()
	if(mobmap_bossloottable_timeout<0) then
		MobMap_UpdateBossLootTable();
		mobmap_bossloottable_timeout=0.5;
	else
		mobmap_bossloottable_timeout=mobmap_bossloottable_timeout-arg1;
	end
end

mobmap_dropitemnamelist=nil;

function MobMap_RefreshDropItemNameList()
	local filtertext=MobMapDropListItemNameFilter:GetText();
	mobmap_dropitemnamelist=MobMap_GetDropItemNameList(filtertext);
	FauxScrollFrame_SetOffset(MobMapDropListItemScrollFrame, 0);
	MobMap_UpdateDropItemNameList();
end

function MobMap_UpdateDropItemNameList()
	local maxitemcount=15+math.floor((mobmap_window_height-430)/18);
	local itemnamecount=table.getn(mobmap_dropitemnamelist);
	local offset=FauxScrollFrame_GetOffset(MobMapDropListItemScrollFrame);
	MobMapDropListFrameItemHighlightFrame:Hide();

	for i=1,37,1 do
		local itemindex=i+offset;
		if(itemindex>itemnamecount or i>maxitemcount) then
			MobMap_UpdateDropItemNameEntry(i, nil);
		else
			MobMap_UpdateDropItemNameEntry(i, mobmap_dropitemnamelist[itemindex]);
		end
	end

	FauxScrollFrame_Update(MobMapDropListItemScrollFrame, itemnamecount, maxitemcount, 22);
end

function MobMap_UpdateDropItemNameEntry(pos, ihid)
	local frame=getglobal("MobMapDropListItem"..pos);
	local frame_button=getglobal("MobMapDropListItem"..pos.."ItemName");
	local frame_text=getglobal("MobMapDropListItem"..pos.."ItemNameText");
	if(ihid==nil) then
		frame:Hide();
	else
		local itemname=MobMap_GetItemNameByIHID(ihid);
		local itemid, quality = MobMap_GetItemDataByIHID(ihid);
		if(itemname~=nil and itemid~=nil) then			
			MobMap_DisplayDebugMessage("MobMap_UpdateDropItemNameEntry("..itemname..")");
			local r, g, b = GetItemQualityColor(quality);
			frame_text:SetText(itemname);
			frame_text:SetTextColor(r,g,b);
			frame.itemid=itemid;
			frame.ihid=ihid;
			frame:Show();
			if(ihid==MobMapDropListFrame.selecteditem) then
				MobMapDropListFrameItemHighlightFrame:Show();
				MobMapDropListFrameItemHighlightFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 2);
				MobMapDropListFrameItemHighlightFrame:SetAlpha(0.5);
				MobMapDropItemHighlight:SetVertexColor(1.0, 1.0, 1.0);
			end
		end
	end
end

function MobMap_DropListSelectItem(self)
	local ihid=self:GetParent().ihid;
	if(IsControlKeyDown() or IsShiftKeyDown()) then
		local itemid=self:GetParent().itemid;
		local itemString=MobMap_ConstructItemString(itemid);
		local itemName, itemLink = GetItemInfo(itemString);
		if(itemLink) then
			if(IsControlKeyDown()) then
				DressUpItemLink(itemLink);
			elseif(IsShiftKeyDown()) then
				ChatEdit_InsertLink(itemLink);
			end
		else
			MobMap_DisplayMessage(MOBMAP_UNSAFE_ITEM_LINK_ERROR);
		end
		return;
	end
	MobMapDropListFrame.selecteditem=ihid;
	MobMapDropListFrame.selecteditemname=MobMap_GetItemNameByIHID(ihid);
	MobMapDropListFrameItemHighlightFrame:Show();
	MobMapDropListFrameItemHighlightFrame:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 2);
	MobMapDropListFrameItemHighlightFrame:SetAlpha(0.5);
	MobMapDropItemHighlight:SetVertexColor(1.0, 1.0, 1.0);
	MobMap_RefreshDropChanceList();
end

function MobMap_DropListSelectDropChance(self)
	MobMap_LoadDatabase(MOBMAP_POSITION_DATABASE);
	if(self.mobid==nil) then
		MobMap_ShowMobByName(self:GetText());
	else
		MobMap_ShowMobByID(self.mobid);
	end
end

function MobMap_ShowSelectedItem()
	if(mobmap_dropitemnamelist==nil or MobMapDropListFrame.selecteditem==nil) then return; end
	local maxitemcount=15+math.floor((mobmap_window_height-430)/18);
	local i;
	for i=1,table.getn(mobmap_dropitemnamelist),1 do
		if(mobmap_dropitemnamelist[i]==MobMapDropListFrame.selecteditem) then
			local offset=i-1;
			if(offset+maxitemcount>table.getn(mobmap_dropitemnamelist)) then
				if(offset-(maxitemcount-1)<0) then
					offset=0;
				else
					offset=offset-(maxitemcount-1);
				end
			end
			FauxScrollFrame_SetOffset(MobMapDropListItemScrollFrame, offset);
			MobMap_UpdateDropItemNameList();
			return;
		end
	end
end


mobmap_dropchancelist={};

function MobMap_RefreshDropChanceList()
	if(MobMapDropListFrame.selecteditem==nil) then
		mobmap_dropchancelist={};
	else
		local isPickup;
		mobmap_dropchancelist, isPickup = MobMap_GetDropChances(MobMapDropListFrame.selecteditem);
		if(isPickup==true) then
			MobMapDropListMoreButton:Show();
		else
			MobMapDropListMoreButton:Hide();
		end
	end
	FauxScrollFrame_SetOffset(MobMapDropListMobScrollFrame,0);
	MobMap_UpdateDropChanceList();
	if(mobmap_questsearch==true and #(mobmap_dropchancelist)>0) then
		MobMap_DisplayDebugMessage("autoselecting drop chance 1");
		HideUIPanel(MobMapFrame);
		if(mobmap_questsearch_preferredzone) then
			for i=1,21,1 do
				if(getglobal("MobMapDropRateEntry"..i).zoneid==mobmap_questsearch_preferredzone) then
					MobMap_DropListSelectDropChance(getglobal("MobMapDropRateEntry"..i.."MobName"));
					return;
				end
			end
			MobMap_DropListSelectDropChance(MobMapDropRateEntry1MobName);
		else
			MobMap_DropListSelectDropChance(MobMapDropRateEntry1MobName);
		end
	end
end

function MobMap_UpdateDropChanceList()
	local maxdropchancecount=9+math.floor((mobmap_window_height-430)/33);
	local dropchancecount=table.getn(mobmap_dropchancelist);
	local offset=FauxScrollFrame_GetOffset(MobMapDropListMobScrollFrame);
	MobMap_DisplayDebugMessage("MobMap_UpdateDropChanceList()");

	for i=1,21,1 do
		local dropindex=i+offset;
		if(dropindex>dropchancecount) then
			MobMap_UpdateDropChanceEntry(i, nil);
		else
			MobMap_UpdateDropChanceEntry(i, mobmap_dropchancelist[dropindex], i<=maxdropchancecount);
		end
	end

	FauxScrollFrame_Update(MobMapDropListMobScrollFrame, dropchancecount, maxdropchancecount, 22);
end

function MobMap_UpdateDropChanceEntry(pos, entry, visible)
	local frame=getglobal("MobMapDropRateEntry"..pos);
	local frame_mobname=getglobal("MobMapDropRateEntry"..pos.."MobName");
	local frame_chance=getglobal("MobMapDropRateEntry"..pos.."Chance");
	local frame_heroic=getglobal("MobMapDropRateEntry"..pos.."Heroic");
	local frame_zone=getglobal("MobMapDropRateEntry"..pos.."ZoneAndLevel");
	local frame_bigraid=getglobal("MobMapDropRateEntry"..pos.."Bigraid");
	if(entry==nil) then
		frame:Hide();
		frame.zoneid=nil;
	else
		if(entry.mobid<=65000) then
			frame_mobname:SetText(MobMap_GetMobName(entry.mobid));
			frame_mobname.mobid=entry.mobid;
		else
			frame_mobname:SetText(MobMap_GetCrateName(entry.mobid-65000));
			frame_mobname.mobid=nil;
		end
		if(entry.chance<100) then
			frame_chance:SetText(string.format("%5.1f",entry.chance).."%");
		else
			frame_chance:SetText("???%");
		end
		local zone=MobMap_GetMobZone(entry.mobid);
		local zonename="???";
		frame.zoneid=nil;
		if(zone~=nil) then
			zonename=MobMap_GetZoneName(zone.id);
			frame.zoneid=zone.id;
		end
		if(entry.mobid<=65000) then
			local minlevel, maxlevel = MobMap_GetMobDetails(MobMap_GetMobPointer(entry.mobid));
			local moblevelstring;
			if(minlevel==maxlevel) then
				if(minlevel==0) then
					moblevelstring=MOBMAP_BOSS_LEVEL;
				else
					moblevelstring=MOBMAP_LEVEL..minlevel;
				end
			else
				moblevelstring=MOBMAP_LEVEL..minlevel.." - "..maxlevel;
			end
			frame_zone:SetText(zonename..", "..moblevelstring);
		else
			frame_zone:SetText("");
		end
		if(entry.heroiconly==true) then
			frame_heroic:Show();
		else
			frame_heroic:Hide();
		end
		if(entry.bigraidonly==true) then
			frame_bigraid:Show();
		else
			frame_bigraid:Hide();
		end
		if(visible) then
			frame:Show();
		else
			frame:Hide();
		end
	end
end

function MobMap_IsInDropRateDatabase(itemname, minimumProbability)
	local list=MobMap_GetDropItemNameList("\""..itemname.."\"");
	if(table.getn(list)>0) then
		if(minimumProbability~=nil and table.getn(list)==1) then
			local chancelist=MobMap_GetDropChances(list[1]);
			local k,v;			
			for k,v in pairs(chancelist) do
				if(v.chance>=minimumProbability) then
					return true;
				end
			end
			return false;
		end
		return true;
	else
		return false;
	end
end

function MobMap_DoDropRateItemSearch(itemname)
	if(itemname==nil) then return; end
	MobMap_ShowPanel("MobMapDropListFrame");
	MobMap_DisplayDebugMessage("MobMap_DoDropRateItemSearch("..itemname..")");
	MobMapDropListItemNameFilter:SetText("\""..itemname.."\"");
	MobMap_RefreshDropItemNameList();
	if(#(mobmap_dropitemnamelist)==1) then
		MobMap_DropListSelectItem(MobMapDropListItem1ItemName);
	end
end

function MobMap_ShowItemDropRateByID(ihid, preferredZone)
	if(ihid==nil) then return; end
	MobMap_DisplayDebugMessage("MobMap_ShowItemDropRateByID("..ihid..")");
	MobMap_ShowPanel("MobMapDropListFrame");
	MobMapDropListItemNameFilter:SetText("id: "..ihid);
	MobMap_RefreshDropItemNameList();
	mobmap_questsearch_preferredzone=preferredZone;
	if(#(mobmap_dropitemnamelist)==1) then
		MobMap_DropListSelectItem(MobMapDropListItem1ItemName);
	end
	mobmap_questsearch_preferredzone=nil;
end

function MobMap_BossLootItem_OnClick(self)
	if(self:GetParent().itemlink) then
		if(IsControlKeyDown()) then
			DressUpItemLink(self:GetParent().itemlink);
		elseif(IsShiftKeyDown()) then
			ChatEdit_InsertLink(self:GetParent().itemlink);
		end
	else
		MobMap_DisplayMessage(MOBMAP_UNSAFE_ITEM_LINK_ERROR);
	end
end