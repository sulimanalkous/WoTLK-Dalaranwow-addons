-- item name helper database functions

function MobMap_GetItemNameList(itemnamefilter)
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
	if(string.sub(itemnamefilter,1,3)=="id:") then
		local idtofind=tonumber(string.sub(text,4));
		if(idtofind>0 and idtofind<MobMap_GetItemNameHelperItemCount()) then
			table.insert(list, idtofind);
		end
	else
		for i=1,MobMap_GetItemNameHelperItemCount(),1 do
			local name=MobMap_GetItemNameByIHID(i);
			local match=true;
			if(name and itemnamefilter) then
				if((exactmatch==false and string.find(string.lower(name),".-"..string.lower(itemnamefilter)..".-")==nil) or (exactmatch==true and string.lower(name)~=string.lower(itemnamefilter))) then match=false; end
			end
			if(match==true) then
				table.insert(list, i);
			end
		end
	end
	return list;
end

function MobMap_GetItemNameByIHID(ihid)
	if(ihid==nil) then return nil; end
	return mobmap_itemnamehelperlist[ihid];
end

function MobMap_GetItemDataByIHID(ihid)
	if(ihid==nil) then return nil; end
	local data=mobmap_itemnamehelperdata[floor((ihid-1)/2)+1];
	if(data==nil) then return nil; end
	local itemid=MobMap_Mask(data/mobmap_poweroftwo[25*((ihid-1)%2)],mobmap_poweroftwo[17]);
	local quality=MobMap_Mask(data/mobmap_poweroftwo[25*((ihid-1)%2)+17],mobmap_poweroftwo[7]);
	local dangerous=MobMap_Mask(data/mobmap_poweroftwo[25*((ihid-1)%2)+24],mobmap_poweroftwo[1]);
	if(dangerous==0) then
		dangerous=false;
	else
		dangerous=true;
	end
	return itemid, quality, dangerous;
end

function MobMap_IsItemDangerous(ihid)
	if(ihid==nil) then return false; end
	local data=mobmap_itemnamehelperdata[floor((ihid-1)/2)+1];
	local dangerous=MobMap_Mask(data/mobmap_poweroftwo[25*((ihid-1)%2)+24],mobmap_poweroftwo[1]);
	if(dangerous==0) then 
		return false;
	else
		return true;
	end
end

mobmap_inverse_itemnamehelperlist_byitemid=nil;

function MobMap_GetIHIDByItemID(searchid)
	if(mobmap_optimize_response_times==true) then
		if(mobmap_inverse_itemnamehelperlist_byitemid==nil) then
			mobmap_inverse_itemnamehelperlist_byitemid={};
			for i=1,MobMap_GetItemNameHelperItemCount(),1 do
				local itemid=MobMap_GetItemDataByIHID(i);
				mobmap_inverse_itemnamehelperlist_byitemid[itemid]=i;
			end
		end
		return mobmap_inverse_itemnamehelperlist_byitemid[searchid];
	else
		for i=1,MobMap_GetItemNameHelperItemCount(),1 do
			local itemid=MobMap_GetItemDataByIHID(i);
			if(itemid==searchid) then
				return i;
			end
		end
		return nil;
	end
end

mobmap_inverse_itemnamehelperlist=nil;

function MobMap_GetIHIDByItemName(itemname)
	if(mobmap_optimize_response_times==true) then
		if(mobmap_inverse_itemnamehelperlist==nil) then
			mobmap_inverse_itemnamehelperlist={};
			for i=1,MobMap_GetItemNameHelperItemCount(),1 do
				mobmap_inverse_itemnamehelperlist[mobmap_itemnamehelperlist[i]]=i;
			end
		end
		return mobmap_inverse_itemnamehelperlist[itemname];
	else
		for i=1,MobMap_GetItemNameHelperItemCount(),1 do
			if(mobmap_itemnamehelperlist[i]==itemname) then
				return i;
			end
		end
		return nil;
	end
end

function MobMap_GetItemNameByItemID(searchid)
	return MobMap_GetItemNameByIHID(MobMap_GetIHIDByItemID(searchid));
end

function MobMap_GetItemNameHelperItemCount()
	return table.getn(mobmap_itemnamehelperlist);
end

-- UI stuff

function MobMap_SetupDangerousItemTooltip(tooltip)
	tooltip:ClearLines();
	tooltip:AddLine(MOBMAP_DANGEROUS_ITEM_TOOLTIP_LINES[1],1.0,0.0,0.0);	
	tooltip:AddLine(MOBMAP_DANGEROUS_ITEM_TOOLTIP_LINES[2]);
	tooltip:AddLine(MOBMAP_DANGEROUS_ITEM_TOOLTIP_LINES[3]);
end

function MobMap_DisplayItemTooltip(tooltip, itemid, ihid)
	if(ihid==nil) then ihid=MobMap_GetIHIDByItemID(itemid); end
	if(itemid~=nil) then
		if(IsShiftKeyDown() or GetItemInfo(itemid)~=nil or (mobmap_request_item_details==true and MobMap_IsItemDangerous(ihid)==false)) then
			tooltip:SetHyperlink(MobMap_ConstructItemString(itemid));
		else
			if(MobMap_CreateItemTooltip) then
				if(MobMap_CreateItemTooltip(tooltip, itemid)==false) then
					MobMap_SetupDangerousItemTooltip(tooltip);
				end
			else
				MobMap_SetupDangerousItemTooltip(tooltip);
			end
		end
		tooltip:SetFrameLevel(5000);
		tooltip:Show();
	end
end