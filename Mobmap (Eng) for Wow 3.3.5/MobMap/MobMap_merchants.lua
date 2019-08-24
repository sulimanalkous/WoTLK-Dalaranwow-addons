-- merchant database functions

function MobMap_GetMerchantList(namefilter, subtitlefilter, zoneid, itemid)
	local merchantid;
	subtitlefilter=MobMap_PatternEscape(subtitlefilter);
	namefilter=MobMap_PatternEscape(namefilter);
	local merchantlist={};

	for merchantid=1,MobMap_GetMerchantCount(),1 do
		local match=true;

		local npcid=MobMap_GetMerchantNPCID(merchantid);
		if(npcid~=nil) then
			local merchantname, merchantsubtitle = MobMap_GetMobNameAndSubtitle(MobMap_GetMobFullName(npcid));
			if(merchantname==nil) then merchantname=""; end
			if(merchantsubtitle==nil) then merchantsubtitle=""; end

			if(namefilter~=nil) then
				if(string.find(string.lower(merchantname),".-"..string.lower(namefilter)..".-")==nil) then match=false; end
			end

			if(match==true and subtitlefilter~=nil) then
				if(string.find(string.lower(merchantsubtitle),".-"..string.lower(subtitlefilter)..".-")==nil) then match=false; end
			end

			if(match==true and zoneid~=nil) then
				local mobzone=MobMap_GetMobZone(npcid);
				if(not mobzone or mobzone.id~=zoneid) then match=false; end
			end

			if(match==true and itemid~=nil) then
				local _, itemcount, isExtended, items = MobMap_GetDetailsForMerchant(merchantid);
				local item;
				local found=false;
				for item=1,itemcount,1 do
					if(items[item].itemid==tonumber(itemid)) then found=true; break; end
				end
				if(found==false) then match=false; end
			end

			if(match==true) then table.insert(merchantlist, merchantid); end
		end
	end

	return merchantlist;
end

function MobMap_GetDetailsForMerchant(merchantid)
	local data=mobmap_merchants[merchantid];
	if(data==nil) then return nil; end

	local npcid=MobMap_Mask(data,mobmap_poweroftwo[16]);
	local itemstartpos=MobMap_Mask(data/mobmap_poweroftwo[16],mobmap_poweroftwo[20]);
	local itemcount=MobMap_Mask(data/mobmap_poweroftwo[36],mobmap_poweroftwo[10]);
	local isExtended=MobMap_Mask(data/mobmap_poweroftwo[46],mobmap_poweroftwo[1]);
	if(isExtended==0) then
		isExtended=false;
	else
		isExtended=true;
	end
	local tokencount=MobMap_Mask(data/mobmap_poweroftwo[47],mobmap_poweroftwo[3]);

	local item;
	local items={};
	local bucketsPerItem=1;
	if(isExtended==true) then bucketsPerItem=2; end
	if(tokencount>0) then bucketsPerItem=3; end
	if(tokencount>2) then bucketsPerItem=4; end
	if(tokencount>4) then bucketsPerItem=5; end
	for item=0,itemcount-1,1 do
		local currentitem={};
		local data1=mobmap_merchantitemdata[itemstartpos+1+bucketsPerItem*item];
		currentitem.itemid=MobMap_Mask(data1,mobmap_poweroftwo[17]);
		currentitem.quantity=MobMap_Mask(data1/mobmap_poweroftwo[17],mobmap_poweroftwo[8]);
		currentitem.limited=MobMap_Mask(data1/mobmap_poweroftwo[25],mobmap_poweroftwo[1]);
		if(currentitem.limited~=0) then
			currentitem.limited=false;
		else
			currentitem.limited=true;
		end
		currentitem.price=MobMap_Mask(data1/mobmap_poweroftwo[26],mobmap_poweroftwo[26]);

		if(isExtended==true) then
			local data2=mobmap_merchantitemdata[itemstartpos+1+bucketsPerItem*item+1];
			currentitem.honorprice=MobMap_Mask(data2,mobmap_poweroftwo[24]);
			currentitem.arenaprice=MobMap_Mask(data2/mobmap_poweroftwo[24],mobmap_poweroftwo[24]);

			currentitem.tokens={};
			local token;
			for token=0,tokencount-1,1 do
				local currenttoken={};
				local data3=mobmap_merchantitemdata[itemstartpos+1+bucketsPerItem*item+2+math.floor(token/2)];
				currenttoken.tokenid=MobMap_Mask(data3/mobmap_poweroftwo[(token%2)*25],mobmap_poweroftwo[10]);
				currenttoken.count=MobMap_Mask(data3/mobmap_poweroftwo[(token%2)*25+10],mobmap_poweroftwo[15]);
				if(currenttoken.count>0) then table.insert(currentitem.tokens,currenttoken); end
			end
		end
		table.insert(items,currentitem);
	end

	return npcid, itemcount, isExtended, items;
end

function MobMap_GetMerchantNPCID(merchantid)
	local data=mobmap_merchants[merchantid];
	if(data==nil) then return nil; end

	local npcid=MobMap_Mask(data,mobmap_poweroftwo[16]);
	return npcid;
end

function MobMap_IsInMerchantDatabase(itemname)
	local ihidlist=MobMap_GetItemNameList("\""..itemname.."\"");
	if(table.getn(ihidlist)>0) then
		local itemid = MobMap_GetItemDataByIHID(ihidlist[0]);
		list=MobMap_GetMerchantList(nil, nil, nil, itemid);
		if(table.getn(list)>0) then
			return true;
		end
	end
	return false;
end

-- user interface functions

mobmap_mlzf_notextchanged=0;
mobmap_mlzf_textlen=0;
mobmap_mlzf_marklen=0;

function MobMap_MerchantListZoneFilter_OnTextChanged()
	if(mobmap_mlzf_notextchanged==1 or mobmap_mlzf_textlen==string.len(MobMapMerchantListZoneFilter:GetText())+1 or mobmap_mlzf_textlen==string.len(MobMapMerchantListZoneFilter:GetText())+mobmap_mlzf_marklen) then
		mobmap_mlzf_notextchanged=0;
		mobmap_mlzf_textlen=string.len(MobMapMerchantListZoneFilter:GetText());
	else
		local text=MobMapMerchantListZoneFilter:GetText();
		local match=nil;
		if(text~="") then
			local i;
			for i=1, 255, 1 do
				if(mobmap_zones[i]~=nil and string.find(string.lower(mobmap_zones[i]),"^"..string.lower(text)..".-")~=nil) then
					match=mobmap_zones[i];
					break;
				end
			end
		end
		if(match~=nil) then
			local textlen=string.len(text);
			mobmap_mlzf_notextchanged=1;
			mobmap_mlzf_textlen=string.len(match);
			MobMapMerchantListZoneFilter:SetText(match);
			if(string.len(match)>textlen) then MobMapMerchantListZoneFilter:HighlightText(textlen,string.len(match)); end
			mobmap_mlzf_marklen=string.len(match)-textlen;
		end
	end
end

mobmap_merchantlist=nil;

function MobMap_RefreshMerchantList()
	local namefilter=MobMapMerchantListNameFilter:GetText();
	if(namefilter=="") then namefilter=nil; end

	local subtitlefilter=MobMapMerchantListSubtitleFilter:GetText();
	if(subtitlefilter=="") then subtitlefilter=nil; end

	local zoneid=MobMap_GetZoneID(MobMapMerchantListZoneFilter:GetText());
	if(zoneid==0 or MobMapMerchantListZoneFilter:GetText()=="") then zoneid=nil; end

	local itemid=MobMapMerchantListItemFilter.itemid;

	mobmap_merchantlist=MobMap_GetMerchantList(namefilter, subtitlefilter, zoneid, itemid);
	FauxScrollFrame_SetOffset(MobMapMerchantListScrollFrame, 0);
	MobMap_UpdateMerchantList();
end

function MobMap_UpdateMerchantList()
	local maxmerchantcount=5+math.floor((mobmap_window_height-430)/40);
	local merchantcount=table.getn(mobmap_merchantlist);
	local offset=FauxScrollFrame_GetOffset(MobMapMerchantListScrollFrame);

	for i=1,15,1 do
		local merchantindex=i+offset;
		local frame=getglobal("MobMapMerchant"..i);
		if(merchantindex>merchantcount or i>maxmerchantcount) then
			MobMap_UpdateMerchantEntry(i, nil);
		else
			MobMap_UpdateMerchantEntry(i, mobmap_merchantlist[merchantindex]);
		end
	end

	FauxScrollFrame_Update(MobMapMerchantListScrollFrame, merchantcount, maxmerchantcount, 22);
end

function MobMap_UpdateMerchantEntry(entry, merchantid)
	local frame=getglobal("MobMapMerchant"..entry);
	
	if(merchantid==nil) then
		frame:Hide();
	else
		frame.merchantid=merchantid;
		local frame_name=getglobal("MobMapMerchant"..entry.."MerchantName");
		local frame_subtitle=getglobal("MobMapMerchant"..entry.."MerchantSubtitle");
		local frame_zone=getglobal("MobMapMerchant"..entry.."MerchantZone");

		local npcid=MobMap_GetMerchantNPCID(merchantid);
		local name, subtitle = MobMap_GetMobNameAndSubtitle(MobMap_GetMobFullName(npcid));

		frame_name:SetText(name);
		if(subtitle~=nil) then
			frame_subtitle:SetText(subtitle);
		else
			frame_subtitle:SetText("");
		end

		local zone=MobMap_GetMobZone(npcid);
		if(zone~=nil) then
			frame_zone:SetText(MobMap_GetZoneName(zone.id));
		else
			frame_zone:SetText("???");
		end

		frame:Show();
	end	
end

mobmap_merchantdetailframe_timeout=0;

function MobMap_MerchantDetailFrame_OnUpdate()
	if(mobmap_merchantdetailframe_timeout<0) then
		MobMap_UpdateMerchantItemDisplay();
		mobmap_merchantdetailframe_timeout=0.5;
	else
		mobmap_merchantdetailframe_timeout=mobmap_merchantdetailframe_timeout-arg1;
	end
end

function MobMap_DisplayMerchantDetails(merchantid)
	local npcid, itemcount, isExtended, items = MobMap_GetDetailsForMerchant(merchantid);
	local name, subtitle = MobMap_GetMobNameAndSubtitle(MobMap_GetMobFullName(npcid));

	MobMapMerchantListMerchantDetailFrame.page=1;
	MobMapMerchantListMerchantDetailFrame.itemcount=itemcount;
	MobMapMerchantListMerchantDetailFrame.itemdata=items;
	MobMapMerchantListMerchantDetailFrame.isExtended=isExtended;
	MobMapMerchantListMerchantDetailFrameMerchantName:SetText(name);
	MobMapMerchantListMerchantDetailFrameMerchantName.npcid=npcid;
	if(subtitle~=nil) then
		MobMapMerchantListMerchantDetailFrameMerchantSubtitle:SetText(subtitle);
	else
		MobMapMerchantListMerchantDetailFrameMerchantSubtitle:SetText("");
	end

	MobMapMerchantListMerchantDetailFrame:Show();
	MobMap_UpdateMerchantItemDisplay();
end

function MobMap_UpdateMerchantItemDisplay()
	local itemsperpage=8+math.floor((mobmap_window_height-430)/50)*2;
	local pageoffset=MobMapMerchantListMerchantDetailFrame.page-1;
	local isExtended=MobMapMerchantListMerchantDetailFrame.isExtended;
	local itemcount=MobMapMerchantListMerchantDetailFrame.itemcount;
	local itemdata=MobMapMerchantListMerchantDetailFrame.itemdata;

	local itemnum;
	for itemnum=1,24,1 do
		local item=itemnum+pageoffset*itemsperpage;
		local frame=getglobal("MobMapMerchantItem"..itemnum);
		if(item>itemcount or itemnum>itemsperpage) then
			frame:Hide();
		else
			local itemid=itemdata[item].itemid;
			local itemString=MobMap_ConstructItemString(itemid);
			local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(itemString);
			local frame_name=getglobal("MobMapMerchantItem"..itemnum.."Name");
			local frame_item=getglobal("MobMapMerchantItem"..itemnum.."ItemButton");
			local frame_itemstock=getglobal("MobMapMerchantItem"..itemnum.."ItemButtonStock");
			local frame_money=getglobal("MobMapMerchantItem"..itemnum.."MoneyFrame");
			local frame_altcurrency=getglobal("MobMapMerchantItem"..itemnum.."AltCurrencyFrame");
			if(itemName==nil) then
				frame_name:SetText("???");
				frame_name:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
				if(mobmap_request_item_details==true) then
					MobMapScanTooltip:SetHyperlink(itemString);
				else
					MobMap_LoadDatabase(MOBMAP_ITEMNAME_HELPER_DATABASE);
					local ihid=MobMap_GetIHIDByItemID(itemid);
					if(ihid~=nil) then
						frame_name:SetText(MobMap_GetItemNameByIHID(ihid));
						local _, quality=MobMap_GetItemDataByIHID(ihid);
						local r, g, b = GetItemQualityColor(quality);
						frame_name:SetTextColor(r,g,b);
					end
				end
				frame_itemstock:Hide();
				SetItemButtonTexture(frame_item, "Interface\\Icons\\INV_Misc_QuestionMark.blp");
				frame.itemstring=nil;
				frame.itemlink=nil;
			else
				frame_name:SetText(itemName);
				local r, g, b = GetItemQualityColor(itemRarity);
				frame_name:SetTextColor(r,g,b);
				SetItemButtonCount(frame_item, itemdata[item].quantity);
				if(itemdata[item].limited==true) then
					frame_itemstock:Hide();
				else
					frame_itemstock:Show();
					frame_itemstock:SetText("L");
				end
				SetItemButtonTexture(frame_item, itemTexture);
				frame.itemstring=itemString;
				frame.itemlink=itemLink;
				frame.itemid=itemid;
			end
			MoneyFrame_Update(frame_money:GetName(), itemdata[item].price);
			frame_money:Show();
			local pointsbutton=getglobal(frame_altcurrency:GetName().."Points");
			frame_altcurrency:Hide();
			pointsbutton:Hide();
			local showAltCurrency=false;
			if(itemdata[item].honorprice~=nil and itemdata[item].honorprice~=0) then
				local factionGroup=UnitFactionGroup("player");
				local pointsTexture;
				if(factionGroup) then
					pointsTexture="Interface\\TargetingFrame\\UI-PVP-"..factionGroup;
				end
				pointsbutton.pointType=HONOR_POINTS;
				AltCurrencyFrame_Update(pointsbutton:GetName(), pointsTexture, itemdata[item].honorprice);
				frame_altcurrency:Show();
				pointsbutton:Show();
				showAltCurrency=true;
			end
			if(itemdata[item].arenaprice~=nil and itemdata[item].arenaprice~=0) then
				pointsbutton.pointType=ARENA_POINTS;
				AltCurrencyFrame_Update(pointsbutton:GetName(), "Interface\\PVPFrame\\PVP-ArenaPoints-Icon", itemdata[item].arenaprice);
				frame_altcurrency:Show();
				pointsbutton:Show();
				showAltCurrency=true;
			end
			local token;
			for token=1,3,1 do
				getglobal(frame_altcurrency:GetName().."Item"..token):Hide();
			end
			if(itemdata[item].tokens~=nil and table.getn(itemdata[item].tokens)>0) then
				for token=1,table.getn(itemdata[item].tokens),1 do
					local tokenframe=getglobal(frame_altcurrency:GetName().."Item"..token);
					local tokenTexture=mobmap_merchanttokenicons[itemdata[item].tokens[token].tokenid];
					local tokenName=mobmap_merchanttokennames[itemdata[item].tokens[token].tokenid];
					tokenTexture=string.gsub(tokenTexture, "\\\\", "\\");
					AltCurrencyFrame_Update(tokenframe:GetName(), tokenTexture, itemdata[item].tokens[token].count);
					if(token>1) then
						tokenframe:SetPoint("LEFT", frame_altcurrency:GetName().."Item"..token-1, "RIGHT", 4, 0);
					elseif(token==1 and(itemdata[item].arenaprice==0 and itemdata[item].honorprice==0)) then
						tokenframe:SetPoint("LEFT", frame_altcurrency:GetName().."Points", "LEFT", 6, 0);	
					else
						tokenframe:SetPoint("LEFT", frame_altcurrency:GetName().."Points", "RIGHT", 4, 0);
					end
					tokenframe:Show();
					tokenframe.tokenname=tokenName;
				end
				frame_altcurrency:Show();
				showAltCurrency=true;
			end

			if(showAltCurrency) then
				if(itemdata[item].price==0) then
					frame_altcurrency:SetPoint("BOTTOMLEFT", frame_name:GetName().."Frame", "BOTTOMLEFT", -5, 31);
				else
					frame_altcurrency:SetPoint("LEFT", frame_money:GetName(), "RIGHT", -14, 0);
				end
			end
			frame:Show();
		end
	end
end

function MobMap_MerchantPrevPageButton_OnClick()
	local pageoffset=MobMapMerchantListMerchantDetailFrame.page-1;
	local itemcount=MobMapMerchantListMerchantDetailFrame.itemcount;
	if(pageoffset>0) then
		pageoffset=pageoffset-1;
	end
	MobMapMerchantListMerchantDetailFrame.page=pageoffset+1;
	MobMap_UpdateMerchantItemDisplay();
end

function MobMap_MerchantNextPageButton_OnClick()
	local itemsperpage=8+math.floor((mobmap_window_height-430)/50)*2;
	local pageoffset=MobMapMerchantListMerchantDetailFrame.page-1;
	local itemcount=MobMapMerchantListMerchantDetailFrame.itemcount;
	if(itemcount>(pageoffset+1)*itemsperpage) then
		pageoffset=pageoffset+1;
	end
	MobMapMerchantListMerchantDetailFrame.page=pageoffset+1;
	MobMap_UpdateMerchantItemDisplay();
end

function MobMap_OpenRewardSelection()
	MobMap_SetSelectionFunc(MobMap_DoRewardSelection);
	MobMap_ShowItemNameSelectionFrame(MobMapQuestListRewardFilter.selecteditem);
end

function MobMap_MerchantItem_OnClick(self)
	if(IsControlKeyDown()) then
		if(self:GetParent().itemlink~=nil) then
			DressUpItemLink(self:GetParent().itemlink);
		end
	elseif(IsShiftKeyDown()) then
		if(self:GetParent().itemlink~=nil) then
			ChatEdit_InsertLink(self:GetParent().itemlink);
		end
	end
end

function MobMap_ClearMerchantFilter()
	MobMapMerchantListNameFilter:SetText("");
	MobMapMerchantListSubtitleFilter:SetText("");
	MobMapMerchantListZoneFilter:SetText("");
	MobMap_ClearMerchantItemSelection();
end

function MobMap_OpenMerchantItemSelection()
	MobMap_SetSelectionFunc(MobMap_DoMerchantItemSelection);
	MobMap_ShowItemNameSelectionFrame(MobMapMerchantListItemFilter.selecteditem);
end

function MobMap_ClearMerchantItemSelection()
	MobMapMerchantListItemFilter:SetText(MOBMAP_MERCHANT_ITEM_FILTER_TEXT);
	MobMapMerchantListItemFilter.itemid=nil;
	MobMapMerchantListItemFilter.itemname=nil;
	MobMapMerchantListItemFilter.selecteditem=nil;
	MobMap_RefreshMerchantList();
end

function MobMap_DoMerchantItemSelection(itemihid)
	MobMapMerchantListItemFilter.selecteditem=itemihid;
	MobMapMerchantListItemFilter.itemname=MobMap_GetItemNameByIHID(itemihid);
	local itemid, quality = MobMap_GetItemDataByIHID(itemihid);
	MobMapMerchantListItemFilter.itemid=itemid;
	local r, g, b = GetItemQualityColor(quality);
	local hexcolor=MobMap_RGBToHex(r,g,b);
	MobMapMerchantListItemFilter:SetText(MOBMAP_MERCHANT_ITEM_FILTER_PRETEXT.." |cFF"..hexcolor.."["..MobMapMerchantListItemFilter.itemname.."]|r");
	MobMap_RefreshMerchantList();
end

function MobMap_DoMerchantItemSearch(itemihid)
	if(itemihid==nil) then return; end
	MobMap_ShowPanel("MobMapMerchantListFrame");
	MobMap_ClearMerchantFilter();
	MobMap_DoMerchantItemSelection(itemihid);
end

-- MobMapMerchantListFrame event handlers

mobmap_merchantlistframe_oldtext1="";
mobmap_merchantlistframe_oldtext2="";
mobmap_merchantlistframe_oldtext3="";
mobmap_merchantlistframe_timeout=0;

function MobMap_MerchantListFrame_OnShow()
	mobmap_merchantlistframe_oldtext1=MobMapMerchantListNameFilter:GetText();
	mobmap_merchantlistframe_oldtext2=MobMapMerchantListSubtitleFilter:GetText();
	mobmap_merchantlistframe_oldtext3=MobMapMerchantListZoneFilter:GetText();
	mobmap_merchantlistframe_timeout=-1;
end

function MobMap_MerchantListFrame_OnUpdate()
	if(MobMapMerchantListNameFilter:GetText()~=mobmap_merchantlistframe_oldtext1 or MobMapMerchantListSubtitleFilter:GetText()~=mobmap_merchantlistframe_oldtext2 or MobMapMerchantListZoneFilter:GetText()~=mobmap_merchantlistframe_oldtext3) then
		mobmap_merchantlistframe_oldtext1=MobMapMerchantListNameFilter:GetText();
		mobmap_merchantlistframe_oldtext2=MobMapMerchantListSubtitleFilter:GetText();
		mobmap_merchantlistframe_oldtext3=MobMapMerchantListZoneFilter:GetText();
		mobmap_merchantlistframe_timeout=0.5;
	end
	if(mobmap_merchantlistframe_timeout==-1) then return; end
	if(mobmap_merchantlistframe_timeout<0) then
		MobMap_RefreshMerchantList();
		mobmap_merchantlistframe_timeout=-1;
	else
		mobmap_merchantlistframe_timeout=mobmap_merchantlistframe_timeout-arg1;
	end
end