-- recipe/tradeskill database functions

mobmap_recipe_list_sorting = 0;

function MobMap_GetProfessionList()
	local professions={};
	local profession,data;
	if(mobmap_tradeskilllist) then
		for profession,data in pairs(mobmap_tradeskilllist) do
			table.insert(professions,profession);
		end
	end
	return professions;
end

function MobMap_GetRecipeList(professionfilter, namefilter, minlevel, maxlevel, orderByLevel)
	local recipes={};
	namefilter=MobMap_PatternEscape(namefilter);
	local match=true;
	local profession, professionData
	for profession, professionData in pairs(mobmap_tradeskilllist) do
		if(profession==professionfilter) then
			local offset=professionData["offset"];
			local recipeID, recipeSubID, recipeName;
			for recipeSubID=1, table.getn(professionData["skills"]), 1 do
				recipeID=recipeSubID+offset;
				recipeName=professionData["skills"][recipeSubID];
				recipeLevel=MobMap_GetRecipeLevel(recipeID);

				local match=true;
				if(namefilter~=nil) then
					if(string.find(string.lower(recipeName),".-"..string.lower(namefilter)..".-")==nil) then match=false; end
				end				
				if(match==true and minlevel~=nil) then
					if(recipeLevel<minlevel) then match=false; end
				end
				if(match==true and maxlevel~=nil) then
					if(recipeLevel>maxlevel) then match=false; end
				end

				if(match==true) then
					table.insert(recipes, recipeID);
				end
			end
		end
	end

	if(orderByLevel==true) then
		table.sort(recipes,MobMap_SortRecipesByLevelComparator);
	end
	
	return recipes;
end

function MobMap_SortRecipesByLevelComparator(r1, r2)
	local l1=MobMap_GetRecipeLevel(r1);
	local l2=MobMap_GetRecipeLevel(r2);
	if(l1<l2) then
		return true;
	else
		return false;
	end
end

function MobMap_GetRecipeDetails(recipeID)
	local data1=mobmap_tradeskilldata[(recipeID-1)*2+1];
	local data2=mobmap_tradeskilldata[(recipeID-1)*2+2];

	local productID=MobMap_Mask(data1,mobmap_poweroftwo[17]);
	local isEnchant=MobMap_Mask(data1/mobmap_poweroftwo[17],mobmap_poweroftwo[1]);
	if(isEnchant==1) then
		isEnchant=true;
	else
		isEnchant=false;
	end
	local minCount=MobMap_Mask(data1/mobmap_poweroftwo[18],mobmap_poweroftwo[9]);
	local maxCount=minCount+MobMap_Mask(data1/mobmap_poweroftwo[27],mobmap_poweroftwo[7]);
	local minLevel=MobMap_Mask(data1/mobmap_poweroftwo[34],mobmap_poweroftwo[10]);
	local recipeEnchantID=MobMap_Mask(data1/mobmap_poweroftwo[44],mobmap_poweroftwo[8]);
	local reagentPointer=MobMap_Mask(data2,mobmap_poweroftwo[17]);
	local reagentCount=MobMap_Mask(data2/mobmap_poweroftwo[17],mobmap_poweroftwo[5]);
	local recipeItem=MobMap_Mask(data2/mobmap_poweroftwo[22],mobmap_poweroftwo[17]);
	local sourceType=MobMap_Mask(data2/mobmap_poweroftwo[39],mobmap_poweroftwo[2]);
	recipeEnchantID=recipeEnchantID+MobMap_Mask(data2/mobmap_poweroftwo[41],mobmap_poweroftwo[11])*256;
	
	local reagent;
	local reagents={};
	for reagent=1,reagentCount,1 do
		local currentReagent={};
		local currentReagentPointer=reagentPointer+reagent-1;
		local data3=mobmap_tradeskillreagentdata[floor(currentReagentPointer/2)+1];
		currentReagent["itemid"]=MobMap_Mask(data3/mobmap_poweroftwo[26*(currentReagentPointer%2)],mobmap_poweroftwo[17]);
		currentReagent["dropinfo"]=MobMap_Mask(data3/mobmap_poweroftwo[26*(currentReagentPointer%2)+17],mobmap_poweroftwo[1]);
		if(currentReagent["dropinfo"]==1) then 
			currentReagent["dropinfo"]=true;
		else 
			currentReagent["dropinfo"]=false;
		end
		currentReagent["buyable"]=MobMap_Mask(data3/mobmap_poweroftwo[26*(currentReagentPointer%2)+18],mobmap_poweroftwo[1]);
		if(currentReagent["buyable"]==1) then
			currentReagent["buyable"]=true;
		else
			currentReagent["buyable"]=false;
		end
		currentReagent["count"]=MobMap_Mask(data3/mobmap_poweroftwo[26*(currentReagentPointer%2)+19],mobmap_poweroftwo[7]);
		table.insert(reagents,currentReagent);
	end

	return productID, isEnchant, minCount, maxCount, minLevel, reagents, recipeItem, sourceType, recipeEnchantID;
end

function MobMap_GetRecipeProduct(recipeID)
	local data1=mobmap_tradeskilldata[(recipeID-1)*2+1];
	local data2=mobmap_tradeskilldata[(recipeID-1)*2+2];

	local productID=MobMap_Mask(data1,mobmap_poweroftwo[17]);
	local isEnchant=MobMap_Mask(data1/mobmap_poweroftwo[17],mobmap_poweroftwo[1]);
	if(isEnchant==1) then
		isEnchant=true;
	else
		isEnchant=false;
	end
	local minLevel=MobMap_Mask(data1/mobmap_poweroftwo[34],mobmap_poweroftwo[10]);

	return productID, isEnchant, minLevel;
end

function MobMap_GetRecipeLevel(recipeID)
	local data1=mobmap_tradeskilldata[(recipeID-1)*2+1];
	local minLevel=MobMap_Mask(data1/mobmap_poweroftwo[34],mobmap_poweroftwo[10]);

	return minLevel;
end

function MobMap_GetRecipeName(recipeID, professionName)
	local profession, data;
	for profession, data in pairs(mobmap_tradeskilllist) do
		if(professionName==nil or profession==professionName) then
			local offset=data["offset"];
			local recipeSubID;
			for recipeSubID=1, table.getn(data["skills"]), 1 do
				if(recipeSubID+offset==recipeID) then
					return data["skills"][recipeSubID];
				end
			end
		end
	end
	return nil;
end

function MobMap_GetMappedReagentItemID(reagentid)
	if(mobmap_tradeskillreagentmappings[reagentid]~=nil) then
		return mobmap_tradeskillreagentmappings[reagentid];
	else
		return reagentid;
	end	
end

-- user interface functions

function MobMap_RecipeListSortingOptions_OnShow()
	if(mobmap_recipe_list_sorting==1) then
		MobMapRecipeListSortByName:SetChecked(true);
		MobMapRecipeListSortByLevel:SetChecked(false);
	else
		MobMapRecipeListSortByName:SetChecked(false);
		MobMapRecipeListSortByLevel:SetChecked(true);
	end
end

function MobMap_RecipeListProfessionFilter_OnLoad(self)
	UIDropDownMenu_Initialize(self, MobMap_RecipeListProfessionFilter_Initialize);
	UIDropDownMenu_SetWidth(self, 180);
	UIDropDownMenu_SetSelectedID(self, 1);
end

function MobMap_RecipeListProfessionFilter_Initialize()
	local professions=MobMap_GetProfessionList();
	local i;
	for i=1,table.getn(professions),1 do
		local info={};
		info.text=professions[i];
		info.func=MobMap_RecipeListProfessionFilter_OnClick;
		UIDropDownMenu_AddButton(info);
	end
end

function MobMap_RecipeListProfessionFilter_OnClick(self)
	UIDropDownMenu_SetSelectedID(MobMapRecipeListProfessionFilter, self:GetID());
	MobMap_RefreshRecipeList();
end

mobmap_recipelistframe_oldtext1="";
mobmap_recipelistframe_timeout=0;

function MobMap_RecipeListFrame_OnShow()
	mobmap_recipelistframe_oldtext1=MobMapRecipeListNameFilter:GetText();
	mobmap_recipelistframe_timeout=-1;
end

function MobMap_RecipeListFrame_OnUpdate()
	if(MobMapRecipeListNameFilter:GetText()~=mobmap_recipelistframe_oldtext1) then
		mobmap_recipelistframe_oldtext1=MobMapRecipeListNameFilter:GetText();
		mobmap_recipelistframe_timeout=0.5;
	end
	if(mobmap_recipelistframe_timeout==-1) then return; end
	if(mobmap_recipelistframe_timeout<0) then
		MobMap_RefreshRecipeList();
		mobmap_recipelistframe_timeout=-1;
	else
		mobmap_recipelistframe_timeout=mobmap_recipelistframe_timeout-arg1;
	end
end

mobmap_recipelist=nil;

function MobMap_RefreshRecipeList()
	local profession=UIDropDownMenu_GetText(MobMapRecipeListProfessionFilter);
	local namefilter=MobMapRecipeListNameFilter:GetText();
	local sortByLevel;
	if(mobmap_recipe_list_sorting==1) then
		sortByLevel=false;
	else
		sortByLevel=true;
	end
	mobmap_recipelist=MobMap_GetRecipeList(profession, namefilter, nil, nil, sortByLevel);
	MobMap_UpdateRecipeList();
end

function MobMap_UpdateRecipeList()
	local maxrecipecount=14+math.floor((mobmap_window_height-430)/18);
	local recipecount=table.getn(mobmap_recipelist);
	local offset=FauxScrollFrame_GetOffset(MobMapRecipeListScrollFrame);

	for i=1,36,1 do
		local recipeindex=i+offset;
		if(recipeindex>recipecount or i>maxrecipecount) then
			MobMap_UpdateRecipeEntry(i, nil);
		else
			MobMap_UpdateRecipeEntry(i, mobmap_recipelist[recipeindex]);
		end
	end

	FauxScrollFrame_Update(MobMapRecipeListScrollFrame, recipecount, maxrecipecount, 22);
end

function MobMap_UpdateRecipeEntry(index, entry)
	local frame=getglobal("MobMapRecipe"..index);
	local frame_button=getglobal("MobMapRecipe"..index.."RecipeName");
	local frame_level=getglobal("MobMapRecipe"..index.."RecipeLevel");
	local profession=UIDropDownMenu_GetText(MobMapRecipeListProfessionFilter);
	local recipeName=MobMap_GetRecipeName(entry);
	if(entry==nil) then
		frame:Hide();
		frame.recipeid=nil;
	else
		local productID, isEnchant, minLevel = MobMap_GetRecipeProduct(entry);
		frame:Show();
		frame.recipeid=entry;
		frame.productid=productID;
		frame.isenchant=isEnchant;
		frame.minlevel=minLevel;
		frame_button:SetText(recipeName);
		if((minLevel%5==0 or minLevel==1) and (profession~="Gifte" and profession~="Poisons")) then
			frame_level:SetText(minLevel);
		else
			frame_level:SetText("");
		end
	end
end

mobmap_recipedetailframe_timeout=0;

function MobMap_RecipeDetailFrame_OnUpdate()
	if(mobmap_recipedetailframe_timeout<0) then
		MobMap_UpdateRecipeDetails();
		mobmap_recipedetailframe_timeout=0.5;
	else
		mobmap_recipedetailframe_timeout=mobmap_recipedetailframe_timeout-arg1;
	end
end

function MobMap_ShowRecipeDetails(recipeid)
	if(recipeid==nil) then
		MobMapRecipeDetailsFrame.recipeid=nil;
	else
		local productID, isEnchant, minCount, maxCount, minLevel, reagents, recipeItem, sourceType, recipeEnchantID = MobMap_GetRecipeDetails(recipeid);
		local recipeName=MobMap_GetRecipeName(recipeid);

		MobMapRecipeDetailsFrame.recipeid=recipeid;
		MobMapRecipeDetailsFrame.recipename=recipeName;
		MobMapRecipeDetailsFrame.productid=productID;
		MobMapRecipeDetailsFrame.isenchant=isEnchant;
		MobMapRecipeDetailsFrame.mincount=minCount;
		MobMapRecipeDetailsFrame.maxcount=maxCount;
		MobMapRecipeDetailsFrame.minlevel=minLevel;
		MobMapRecipeDetailsFrame.reagents=reagents;
		MobMapRecipeDetailsFrame.recipeitem=recipeItem;
		MobMapRecipeDetailsFrame.sourcetype=sourceType;
		if(recipeItem~=0) then
			local ihid=MobMap_GetIHIDByItemID(recipeItem);
			MobMapRecipeDetailsFrame.ihid=ihid;
			local recipeitemname=MobMap_GetItemNameByIHID(ihid);
			MobMapRecipeDetailsFrame.recipeitemname=recipeitemname;
			local _, recipeitemquality=MobMap_GetItemDataByIHID(ihid);
			MobMapRecipeDetailsFrame.recipeitemquality=recipeitemquality;
		else
			MobMapRecipeDetailsFrame.ihid=nil;
			MobMapRecipeDetailsFrame.recipeitemname=nil;
			MobMapRecipeDetailsFrame.recipeitemquality=nil;
		end
		if(isEnchant==true) then
			local enchantLink=MobMap_ConstructEnchantLink(productID, recipeName);
			if(mobmap_request_item_details==true) then
				MobMapScanTooltip:SetHyperlink(enchantLink);
			end
		else
			local itemString=MobMap_ConstructItemString(productID);
			if(mobmap_request_item_details==true) then
				MobMapScanTooltip:SetHyperlink(itemString);
			end
		end
		local reagent;
		for reagent=1,table.getn(reagents),1 do
			local itemString=MobMap_ConstructItemString(reagents[reagent].itemid);
			if(mobmap_request_item_details==true) then
				MobMapScanTooltip:SetHyperlink(itemString);
			end
		end
		MobMap_UpdateRecipeDetails();

		if(IsShiftKeyDown() and recipeEnchantID and recipeEnchantID>0) then
			ChatEdit_InsertLink(MobMap_ConstructEnchantLink(recipeEnchantID, recipeName));
		end
	end
end

function MobMap_UpdateRecipeDetails()
	local recipeid=MobMapRecipeDetailsFrame.recipeid;

	if(recipeid==nil) then
		MobMapRecipeDetailsFrame:Hide()
	else
		local recipename=MobMapRecipeDetailsFrame.recipename;
		local productid=MobMapRecipeDetailsFrame.productid;
		local isenchant=MobMapRecipeDetailsFrame.isenchant;
		local mincount=MobMapRecipeDetailsFrame.mincount;
		local maxcount=MobMapRecipeDetailsFrame.maxcount;
		local minlevel=MobMapRecipeDetailsFrame.minlevel;
		local reagents=MobMapRecipeDetailsFrame.reagents;
		local recipeitem=MobMapRecipeDetailsFrame.recipeitem;
		local sourcetype=MobMapRecipeDetailsFrame.sourcetype;
		local recipeitemname=MobMapRecipeDetailsFrame.recipeitemname;
		local recipeitemquality=MobMapRecipeDetailsFrame.recipeitemquality;
		MobMapRecipeDetailsFrameRecipeName:SetText(recipename);
		if(isenchant==true) then
			local enchantLink=MobMap_ConstructEnchantLink(productid, recipename);
			MobMapRecipeDetailsFrameRecipeIcon:SetNormalTexture("Interface\\Icons\\Spell_Holy_GreaterHeal");
			MobMapRecipeDetailsFrameRecipeIcon.link=enchantLink;
		else
			local itemString=MobMap_ConstructItemString(productid);
			local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(itemString);
			if(itemName~=nil) then
				MobMapRecipeDetailsFrameRecipeIcon:SetNormalTexture(itemTexture);
				MobMapRecipeDetailsFrameRecipeIcon.link=itemLink;
			else
				MobMapRecipeDetailsFrameRecipeIcon:SetNormalTexture("Interface\\Icons\\INV_Misc_QuestionMark.blp");
				MobMapRecipeDetailsFrameRecipeIcon.link=nil;
			end
		end
		
		if(mincount==1 and maxcount==1) then
			MobMapRecipeDetailsFrameRecipeIconCount:SetText("");
		else
			if(mincount==maxcount) then
				MobMapRecipeDetailsFrameRecipeIconCount:SetText(mincount);
			else
				MobMapRecipeDetailsFrameRecipeIconCount:SetText(mincount.."-"..maxcount);
			end
		end

		local reagent;
		for reagent=1,8,1 do
			local reagentButton=getglobal("MobMapRecipeDetailsFrameReagent"..reagent);
			reagentButton:Hide();
		end
		for reagent=1,table.getn(reagents),1 do
			local itemString=MobMap_ConstructItemString(reagents[reagent].itemid);
			local reagentButton=getglobal("MobMapRecipeDetailsFrameReagent"..reagent);
			local reagentName=getglobal("MobMapRecipeDetailsFrameReagent"..reagent.."Name");
			local reagentCount=getglobal("MobMapRecipeDetailsFrameReagent"..reagent.."Count");
			local reagentDropButton=getglobal("MobMapRecipeDetailsFrameReagent"..reagent.."DropButton");
			local reagentMerchantButton=getglobal("MobMapRecipeDetailsFrameReagent"..reagent.."MerchantButton");
			local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(itemString);
			if(itemName~=nil) then
				SetItemButtonTexture(reagentButton, itemTexture);
				reagentName:SetText(itemName);
				reagentName:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
				reagentCount:SetText(reagents[reagent].count);
				reagentButton.link=itemLink;
				reagentButton:Show();
			else
				SetItemButtonTexture(reagentButton, "Interface\\Icons\\INV_Misc_QuestionMark.blp");
				reagentName:SetText("???");
				reagentName:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
				reagentCount:SetText("");
				reagentButton.link=nil;
				reagentButton:Show();
			end
			if(reagents[reagent].dropinfo==true) then
				reagentDropButton.itemid=MobMap_GetMappedReagentItemID(reagents[reagent].itemid);
				reagentDropButton:Show();
			else
				reagentDropButton.itemid=nil;
				reagentDropButton:Hide();
			end
			if(reagents[reagent].buyable==true) then
				reagentMerchantButton.itemid=MobMap_GetMappedReagentItemID(reagents[reagent].itemid);
				reagentMerchantButton:Show();
			else
				reagentMerchantButton.itemid=nil;
				reagentMerchantButton:Hide();
			end
		end

		if(recipeitem~=0 and recipeitem~=nil) then
			if(recipeitemname==nil) then
				MobMapRecipeDetailsFrameRecipeNameLabel:Hide();
				MobMapRecipeDetailsFrameRecipeSourceButton:Hide();
			else
				local r, g, b = GetItemQualityColor(recipeitemquality);
				local hexcolor=MobMap_RGBToHex(r,g,b);
				MobMapRecipeDetailsFrameRecipeNameLabel:SetText(MOBMAP_RECIPE_SOURCE_ITEM_TEXT.."|cFF"..hexcolor.."["..recipeitemname.."]|r");
				MobMapRecipeDetailsFrameRecipeNameLabel:Show();
				MobMapRecipeDetailsFrameRecipeSourceButton:Show();
				if(sourcetype==1) then
					MobMapRecipeDetailsFrameRecipeSourceButtonText:SetText(MOBMAP_RECIPE_SOURCE_TEXT..MOBMAP_RECIPE_SOURCE_MERCHANT);
				elseif(sourcetype==2) then
					MobMapRecipeDetailsFrameRecipeSourceButtonText:SetText(MOBMAP_RECIPE_SOURCE_TEXT..MOBMAP_RECIPE_SOURCE_QUEST);
				elseif(sourcetype==3) then
					MobMapRecipeDetailsFrameRecipeSourceButtonText:SetText(MOBMAP_RECIPE_SOURCE_TEXT..MOBMAP_RECIPE_SOURCE_QUEST..", "..MOBMAP_RECIPE_SOURCE_MERCHANT);
				else
					MobMapRecipeDetailsFrameRecipeSourceButton:Hide();
				end
			end
		else
			MobMapRecipeDetailsFrameRecipeNameLabel:Hide();
			MobMapRecipeDetailsFrameRecipeSourceButton:Hide();
		end

		MobMapRecipeDetailsFrame:Show();
	end
end

function MobMap_RecipeSourceButton_OnClick()
	local ihid=MobMapRecipeDetailsFrame.ihid;
	local sourcetype=MobMapRecipeDetailsFrame.sourcetype;
	if(ihid~=nil) then
		if(sourcetype==1 or sourcetype==3) then
			MobMap_LoadDatabase(MOBMAP_MERCHANT_DATABASE);
			MobMap_DoMerchantItemSearch(ihid);
		else
			MobMap_LoadDatabase(MOBMAP_QUEST_DATABASE);
			MobMap_DoQuestRewardSearch(ihid);
		end
	end
end