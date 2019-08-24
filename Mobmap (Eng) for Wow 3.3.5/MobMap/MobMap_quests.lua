-- quest database functions

function MobMap_GetQuestList(namefilter, minlevel, maxlevel, zoneid, noHordeOnly, noAllianceOnly, minmoney, npcfilter, groupfilter, rewardid, onlyundone)
	local quests={};
	local questid;
	namefilter=MobMap_PatternEscape(namefilter);
	local match=true;
	for questid=1, MobMap_GetQuestCount(), 1 do
		match=true;
		local questname=MobMap_GetQuestName(questid);

		if(namefilter~=nil) then
			if(string.find(string.lower(questname),".-"..string.lower(namefilter)..".-")==nil) then match=false; end
		end

		local level, zone, prequest, postquest, isHorde, isAlliance, money, npc, sourcepointer, grouptype, always, choice, endnpc = MobMap_GetDetailsForQuest(questid);

		if(match==true and minlevel~=nil) then
			if(level<minlevel) then match=false; end
		end

		if(match==true and maxlevel~=nil) then
			if(level>maxlevel) then match=false; end
		end
		if(match==true and zoneid~=nil) then
			if(zone~=zoneid) then match=false; end
		end
		if(match==true and noHordeOnly~=nil and noHordeOnly~=false) then
			if(isHorde==true and isAlliance==false) then match=false; end
		end
		if(match==true and noAllianceOnly~=nil and noAllianceOnly~=false) then
			if(isAlliance==true and isHorde==false) then match=false; end
		end
		if(match==true and minmoney~=nil) then
			if(money<minmoney) then match=false; end
		end
		if(match==true and npcfilter~=nil) then
			if(npc==0 or string.find(string.lower(MobMap_GetMobName(npc)),".-"..string.lower(npcfilter)..".-")==nil) then match=false; end
		end
		if(match==true and groupfilter~=nil) then
			if(grouptype~=groupfilter) then match=false; end
		end
		if(match==true and rewardid~=nil) then
			local k,v;
			local found=false;
			for k,v in pairs(choice) do
				if(v==tonumber(rewardid)) then found=true; break; end
			end
			if(found==false) then
				for k,v in pairs(always) do
					if(v==tonumber(rewardid)) then found=true; break; end
				end
			end
			if(found==false) then match=false; end
		end
		if(match==true and onlyundone) then
			if(MobMap_IsQuestCompleted(MobMap_GetBlizzIDByQuestID(questid))) then match=false; end
		end

		if(match==true) then
			table.insert(quests, questid);
		end
	end
	
	return quests;
end

function MobMap_GetDetailsForQuest(questid)
	local data1=mobmap_questdata[(questid-1)*3+1];
	local data2=mobmap_questdata[(questid-1)*3+2];
	local data3=mobmap_questdata[(questid-1)*3+3];
	if(data1==nil or data2==nil or data3==nil) then return nil; end
	local level=MobMap_Mask(data1,mobmap_poweroftwo[8]);
	local zoneid=MobMap_Mask(data1/mobmap_poweroftwo[8],mobmap_poweroftwo[8]);
	local prequest=MobMap_Mask(data1/mobmap_poweroftwo[16],mobmap_poweroftwo[16]);
	local postquest=MobMap_Mask(data1/mobmap_poweroftwo[32],mobmap_poweroftwo[16]);
	local isHorde=MobMap_Mask(data1/mobmap_poweroftwo[48],mobmap_poweroftwo[1]);
	if(isHorde==1) then isHorde=true; else isHorde=false; end
	local isAlliance=MobMap_Mask(data1/mobmap_poweroftwo[49],mobmap_poweroftwo[1]);
	if(isAlliance==1) then isAlliance=true; else isAlliance=false; end
	local money=MobMap_Mask(data2,mobmap_poweroftwo[24]);
	local npcid=MobMap_Mask(data2/mobmap_poweroftwo[24],mobmap_poweroftwo[16]);
	local grouptype=MobMap_Mask(data2/mobmap_poweroftwo[40],mobmap_poweroftwo[4]);
	local endnpcid=MobMap_Mask(data2/mobmap_poweroftwo[44],mobmap_poweroftwo[6]);
	local rewardpointer=MobMap_Mask(data3,mobmap_poweroftwo[20]);
	local rewardcount=MobMap_Mask(data3/mobmap_poweroftwo[20],mobmap_poweroftwo[4]);
	local sourcepointer=MobMap_Mask(data3/mobmap_poweroftwo[24],mobmap_poweroftwo[16]);
	endnpcid=endnpcid+MobMap_Mask(data3/mobmap_poweroftwo[40],mobmap_poweroftwo[10])*mobmap_poweroftwo[6];


	local always={};
	local choice={};
	if(rewardcount>0) then
		local i;
		for i=1, rewardcount, 1 do
			local rewarddata=mobmap_questrewarddata[floor((rewardpointer+i-2)/3)+1];
			local rewardid=MobMap_Mask(rewarddata/mobmap_poweroftwo[((rewardpointer+i-2)%3)*17],mobmap_poweroftwo[16]);
			local isChoice=MobMap_Mask(rewarddata/mobmap_poweroftwo[((rewardpointer+i-2)%3)*17+16],mobmap_poweroftwo[1]);
			if(isChoice~=0) then
				table.insert(choice,rewardid);
			else
				table.insert(always,rewardid);
			end
		end
	end

	return level, zoneid, prequest, postquest, isHorde, isAlliance, money, npcid, sourcepointer, grouptype, always, choice, endnpcid;
end

function MobMap_GetQuestTargets(blizzid)
	local data=mobmap_questblizzidindex[blizzid];
	if(data==nil) then return {}; end
	local targetoffset=MobMap_Mask(data/mobmap_poweroftwo[20],mobmap_poweroftwo[20]);
	local targetcount=MobMap_Mask(data/mobmap_poweroftwo[40],mobmap_poweroftwo[4]);

	local i;
	local results={};
	for i=1, targetcount, 1 do
		local data=mobmap_questtargets[targetoffset+i];
		local objtype=MobMap_Mask(data,mobmap_poweroftwo[4]);
		local id=MobMap_Mask(data/mobmap_poweroftwo[4],mobmap_poweroftwo[16]);
		local xpos=MobMap_Mask(data/mobmap_poweroftwo[20],mobmap_poweroftwo[9])/5;
		local ypos=MobMap_Mask(data/mobmap_poweroftwo[29],mobmap_poweroftwo[9])/5;
		local zone=MobMap_Mask(data/mobmap_poweroftwo[38],mobmap_poweroftwo[9]);
		local zonelevel=MobMap_Mask(data/mobmap_poweroftwo[47],mobmap_poweroftwo[4]);
		local isExact=(MobMap_Mask(data/mobmap_poweroftwo[51],mobmap_poweroftwo[1])==1);
		table.insert(results, {type=objtype, id=id, x=xpos, y=ypos, zoneid=zone, zonelevel=zonelevel, exact=isExact});
	end
	
	return results;
end

function MobMap_GetBlizzIDByQuestID(questid)
	local data=mobmap_questidindex[questid];
	if(data==nil) then return 0; end
	local blizzid=MobMap_Mask(data,mobmap_poweroftwo[20]);
	return blizzid;
end

function MobMap_GetQuestIDByBlizzID(blizzid)
	local data=mobmap_questblizzidindex[blizzid];
	if(data==nil) then return 0; end
	local questid=MobMap_Mask(data,mobmap_poweroftwo[20]);
	return questid;
end

function MobMap_GetNPCForQuest(questid)
	if(questid>MobMap_GetQuestCount()) then return 0; end
	local data=mobmap_questdata[(questid-1)*3+2];
	local npcid=MobMap_Mask(data/mobmap_poweroftwo[24],mobmap_poweroftwo[16]);
	return npcid;
end

function MobMap_GetPreAndPostQuestForQuest(questid)
	if(questid>MobMap_GetQuestCount()) then return 0; end
	local data=mobmap_questdata[(questid-1)*3+1];
	local prequest=MobMap_Mask(data/mobmap_poweroftwo[16],mobmap_poweroftwo[16]);
	local postquest=MobMap_Mask(data/mobmap_poweroftwo[32],mobmap_poweroftwo[16]);
	return prequest, postquest;
end

function MobMap_GetPreQuestForQuest(questid)
	if(questid>MobMap_GetQuestCount()) then return 0; end
	local data=mobmap_questdata[(questid-1)*3+1];
	local prequest=MobMap_Mask(data/mobmap_poweroftwo[16],mobmap_poweroftwo[16]);
	return prequest;
end

function MobMap_GetPostQuestForQuest(questid)
	if(questid>MobMap_GetQuestCount()) then return 0; end
	local data=mobmap_questdata[(questid-1)*3+1];
	local postquest=MobMap_Mask(data/mobmap_poweroftwo[32],mobmap_poweroftwo[16]);
	return postquest;
end

function MobMap_GetQuestName(questid)
	return mobmap_questnames[questid];
end

mobmap_inverse_questnames=nil;

function MobMap_GetQuestIDsByName(questname, faction)
	local firstAlliance=(faction=="Alliance");
	local firstHorde=(faction=="Horde");
	local questTable;
	if(mobmap_optimize_response_times==true) then
		if(mobmap_inverse_questnames==nil) then
			mobmap_inverse_questnames={};
			local k,v;
			for k,v in pairs(mobmap_questnames) do
				if(mobmap_inverse_questnames[v]) then
					if(type(mobmap_inverse_questnames[v])~="table") then
						local newtable={};
						table.insert(newtable, mobmap_inverse_questnames[v]);
						mobmap_inverse_questnames[v]=newtable;
					end
					table.insert(mobmap_inverse_questnames[v],k);
				else
					mobmap_inverse_questnames[v]=k;
				end
			end
		end
		if(mobmap_inverse_questnames[questname]==nil) then
			return nil;
		else
			if(type(mobmap_inverse_questnames[questname])=="table") then
				questTable=mobmap_inverse_questnames[questname];
			else
				questTable={};
				table.insert(questTable,mobmap_inverse_questnames[questname]);
			end
		end
	else
		local k,v;
		questTable={};
		for k,v in pairs(mobmap_questnames) do
			if(v==questname) then
				table.insert(questTable, k);
			end
		end
	end
	if(#(questTable)==0) then return nil; end
	if(firstAlliance==false and firstHorde==false) then return questTable; end
	local i,k;
	local finalQuestTable={};
	for k=1, 2, 1 do
		for i=1, #(questTable), 1 do
			quest=questTable[i];
			local isHorde, isAlliance;
			_, _, _, _, isHorde, isAlliance = MobMap_GetDetailsForQuest(quest);
			if((firstAlliance==true and isAlliance==true) or (firstHorde==true and isHorde==true)) then
				if(k==1) then table.insert(finalQuestTable, quest); end
			else
				if(k==2) then table.insert(finalQuestTable, quest); end			
			end
		end
	end
	return finalQuestTable;
end

function MobMap_GetQuestObjective(questid)
	return HuffmanDecode(mobmap_questobjdata[questid], mobmap_questobjdata_huffmantree, mobmap_questobjdata_precodingtable);
end

function MobMap_GetQuestSourceName(sourcepointer)
	return mobmap_queststartitems[sourcepointer];
end

function MobMap_EvaluateQuestChains(quests)
	if(quests==nil) then return nil; end
	local result={};
	
	local key, questid, questsgiven, questsprocessed;
	
	questsgiven={};
	questsprocessed={};
	for key, questid in pairs(quests) do
		questsgiven[questid]=1;
	end

	for key, questid in pairs(quests) do
		if(questsprocessed[questid]~=1) then
			local prequest, postquest = MobMap_GetPreAndPostQuestForQuest(questid);
			local currentquest=questid;
			if(prequest~=0) then
				currentquest=MobMap_FindQuestChainStart(prequest);
				prequest, postquest = MobMap_GetPreAndPostQuestForQuest(currentquest);
			end
			repeat
				if(questsgiven[currentquest]==1) then
					table.insert(result,currentquest);
				else
					table.insert(result,currentquest+1000000);
				end
				questsprocessed[currentquest]=1;
				currentquest=MobMap_GetPostQuestForQuest(currentquest);
			until(currentquest==0 or currentquest>MobMap_GetQuestCount())
		end
	end

	return result;
end

function MobMap_FindQuestChainStart(questid)
	local prequest = MobMap_GetPreQuestForQuest(questid);
	if(prequest==0) then
		return questid;
	else
		return MobMap_FindQuestChainStart(prequest);
	end	
end

-- quest comment database functions

function MobMap_GetQuestCommentInfo(questid)
	if(mobmap_use_quest_comments==true) then
		if(MobMap_LoadDatabase(MOBMAP_QUEST_COMMENT_DATABASE, true, true)==false) then return nil; end
		local key, data;
		for key, data in pairs(mobmap_questcommentinfo) do
			local id=MobMap_Mask(data,mobmap_poweroftwo[16]);
			local offset=MobMap_Mask(data/mobmap_poweroftwo[16],mobmap_poweroftwo[16]);
			local count=MobMap_Mask(data/mobmap_poweroftwo[32],mobmap_poweroftwo[8]);
			if(id==questid) then return offset, count; end
		end
	end
	return nil;
end

function MobMap_GetQuestComments(questid)
	local offset, count = MobMap_GetQuestCommentInfo(questid);
	if(offset==nil) then return nil; end
	local i;
	local result={};
	for i=1, count, 1 do
		local data=HuffmanDecode(mobmap_questcommentdata[offset+i],mobmap_questcommentdata_huffmantree,mobmap_questcommentdata_precodingtable);
		if(data) then
			local playername, realmname, timestamp, content = string.match(data,"^(.-)|(.-)|(.-)|(.*)$");
			if(playername) then 
				table.insert(result, {player=playername, realm=realmname, time=timestamp, text=content});
			end
		end
	end
	return result;
end

-- user interface functions

mobmap_questlist={};

function MobMap_RefreshQuestList()
	local namefilter=MobMapQuestListNameFilter:GetText();
	if(namefilter=="") then namefilter=nil; end
	local npcfilter=MobMapQuestListNPCFilter:GetText();
	if(npcfilter=="") then npcfilter=nil; end
	local zonefilter=MobMapQuestListZoneFilter:GetText();
	local i;
	local zoneid=MobMap_GetZoneID(zonefilter);
	if(zoneid==0 or zonefilter=="") then zoneid=nil; end

	local typefilter=UIDropDownMenu_GetSelectedID(MobMapQuestListTypeFilter);
	if(typefilter==1) then 
		typefilter=nil; 
	else
		if(typefilter>1) then typefilter=typefilter-2; end
	end
	local minlevel=MobMapQuestListMinLevelFilter:GetText();
	local maxlevel=MobMapQuestListMaxLevelFilter:GetText();
	if(minlevel=="") then minlevel=nil; else minlevel=tonumber(minlevel); end
	if(maxlevel=="") then maxlevel=nil; else maxlevel=tonumber(maxlevel); end
	local noAllianceOnly=nil;
	local noHordeOnly=nil;
	if(MobMapQuestListAllianceFilter:GetChecked()) then
		noHordeOnly=true;
	end
	if(MobMapQuestListHordeFilter:GetChecked()) then
		noAllianceOnly=true;
	end
	if(noAllianceOnly==true and noHordeOnly==true) then noAllianceOnly=nil; noHordeOnly=nil; end
	local moneyfilter=MoneyInputFrame_GetCopper(MobMapQuestListMoneyFilter);
	if(moneyfilter==0) then moneyfilter=nil; end
	local rewardid=MobMapQuestListRewardFilter.itemid;

	local onlyundone=nil;
	if(MobMapQuestListDoneFilter:GetChecked()) then onlyundone=true; end

	mobmap_questlist=MobMap_GetQuestList(namefilter, minlevel, maxlevel, zoneid, noHordeOnly, noAllianceOnly, moneyfilter, npcfilter, typefilter, rewardid, onlyundone);
	mobmap_questlist=MobMap_EvaluateQuestChains(mobmap_questlist);
	FauxScrollFrame_SetOffset(MobMapQuestListScrollFrame, 0);
	MobMap_UpdateQuestList();
end

function MobMap_UpdateQuestList()
	local maxquestcount=7+math.floor((mobmap_window_height-430)/30.6);
	local questcount=#(mobmap_questlist);
	local offset=FauxScrollFrame_GetOffset(MobMapQuestListScrollFrame);

	for i=1,20,1 do
		local questindex=i+offset;
		local frame=getglobal("MobMapQuest"..i);
		if(questindex>questcount or i>maxquestcount) then
			MobMap_UpdateQuestEntry(i, nil);
		else
			MobMap_UpdateQuestEntry(i, mobmap_questlist[questindex]);
		end
	end

	FauxScrollFrame_Update(MobMapQuestListScrollFrame, questcount, maxquestcount, 22);
end

function MobMap_UpdateQuestEntry(frameid, questid)
	local frame=getglobal("MobMapQuest"..frameid);
	if(questid==nil) then
		frame:Hide();
	else
		if(questid>1000000) then
			frame.notinrs=true;
			frame:SetAlpha(0.5);
			questid=questid-1000000;
		else
			frame.notinrs=false;
			frame:SetAlpha(1.0);
		end
		frame.questid=questid;
		
		local level, zoneid, prequest, postquest, isHorde, isAlliance, money, npcid, sourcepointer, grouptype, always, choice, endnpcid = MobMap_GetDetailsForQuest(questid);
		local blizzid=MobMap_GetBlizzIDByQuestID(questid);

		local frame_done=getglobal("MobMapQuest"..frameid.."QuestDone");
		local frame_name=getglobal("MobMapQuest"..frameid.."QuestName");
		local frame_source=getglobal("MobMapQuest"..frameid.."QuestSource");
		local frame_zone=getglobal("MobMapQuest"..frameid.."QuestZone");
		local frame_type=getglobal("MobMapQuest"..frameid.."QuestType");
		local frame_level=getglobal("MobMapQuest"..frameid.."QuestLevel");
		local frame_horde=getglobal("MobMapQuest"..frameid.."FactionIconHorde");
		local frame_alliance=getglobal("MobMapQuest"..frameid.."FactionIconAlliance");

		frame_done:SetChecked(MobMap_IsQuestCompleted(blizzid));
		frame_done.questid=questid;

		local questcolor=GetQuestDifficultyColor(level);
		frame_name:SetText(MobMap_GetQuestName(questid));
		frame_name:SetTextColor(questcolor.r, questcolor.g, questcolor.b);
		if(prequest~=0) then
			frame_name:SetWidth(200);
			getglobal(frame_name:GetName().."Text"):SetWidth(200);
		else
			frame_name:SetWidth(220);
			getglobal(frame_name:GetName().."Text"):SetWidth(220);
		end

		if(npcid==0 and sourcepointer==0) then
			frame_source:SetText("???");
			frame_source:SetTextColor(1.0,1.0,1.0);
		else
			if(sourcepointer~=0) then
				frame_source:SetText("Item: "..MobMap_GetQuestSourceName(sourcepointer));
				frame_source:SetTextColor(1.0,1.0,1.0);
			else
				frame.npcid=npcid;
				frame_source:SetText(MobMap_GetMobName(npcid));
				frame_source:SetTextColor(1.0,0.82,0.0);
			end
		end

		frame_zone:SetText(MobMap_GetZoneName(zoneid));
		frame_type:SetText(MOBMAP_QUEST_TYPES[grouptype]);
		if(level==0) then
			frame_level:SetText("?");
		else
			frame_level:SetText(level);
		end

		if(isHorde==true) then
			frame_horde:Show();
		else
			frame_horde:Hide();
		end

		if(isAlliance==true) then
			frame_alliance:Show();
		else
			frame_alliance:Hide();
		end

		frame:Show();
	end
end

function MobMap_ClearQuestListFilters()
	MobMapQuestListNameFilter:SetText("");
	MobMapQuestListNPCFilter:SetText("");
	MobMapQuestListZoneFilter:SetText("");
	MobMapQuestListMinLevelFilter:SetText("");
	MobMapQuestListMaxLevelFilter:SetText("");
	MobMapQuestListAllianceFilter:SetChecked(false);
	MobMapQuestListHordeFilter:SetChecked(false);
	MoneyInputFrame_SetCopper(MobMapQuestListMoneyFilter, 0);
	MobMap_ClearRewardSelection();
end

function MobMap_ShowAllQuestGivers()
	MobMap_LoadDatabase(MOBMAP_POSITION_DATABASE);
	local questgiverlist={};
	local i,k;
	for i=1,#(mobmap_questlist),1 do
		local npcid=MobMap_GetNPCForQuest(mobmap_questlist[i]);
		if(npcid~=0) then
			local found=false;
			for k=1,#(questgiverlist),1 do
				if(questgiverlist[k]==npcid) then
					found=true;
					break;
				end
			end
			if(found==false) then
				table.insert(questgiverlist, npcid);
				if(#(questgiverlist)>=100) then
					break;
				end
			end
		end
	end
	if(#(questgiverlist)>=100) then
		MobMap_DisplayMessage(MOBMAP_QUEST_TOO_MANY_QUEST_GIVERS);
	end
	MobMap_ShowMultipleMobs(questgiverlist);
end

function MobMap_QuestListTypeFilter_OnLoad(self)
	UIDropDownMenu_Initialize(self, MobMap_QuestListTypeFilter_Initialize);
	UIDropDownMenu_SetWidth(self, 80);
	UIDropDownMenu_SetSelectedID(self, 1);
end

function MobMap_QuestListTypeFilter_Initialize()
	local i;
	local info={};
	info.text=MOBMAP_QUEST_TYPE_FILTER_ALL;
	info.func=MobMap_QuestListTypeFilter_OnClick;
	UIDropDownMenu_AddButton(info);
	for i=1, 8, 1 do
		MobMap_QuestListTypeFilter_SubInitialize(i);
	end
end

function MobMap_QuestListTypeFilter_SubInitialize(id)
	local info={};
	info.text=MOBMAP_QUEST_TYPES[id-1];
	info.func=MobMap_QuestListTypeFilter_OnClick;
	UIDropDownMenu_AddButton(info);
end

function MobMap_QuestListTypeFilter_OnClick(self)
	UIDropDownMenu_SetSelectedID(MobMapQuestListTypeFilter, self:GetID());
end

mobmap_qlzf_notextchanged=0;
mobmap_qlzf_textlen=0;
mobmap_qlzf_marklen=0;

function MobMap_QuestListZoneFilter_OnTextChanged()
	if(mobmap_qlzf_notextchanged==1 or mobmap_qlzf_textlen==string.len(MobMapQuestListZoneFilter:GetText())+1 or mobmap_qlzf_textlen==string.len(MobMapQuestListZoneFilter:GetText())+mobmap_qlzf_marklen) then
		mobmap_qlzf_notextchanged=0;
		mobmap_qlzf_textlen=string.len(MobMapQuestListZoneFilter:GetText());
	else
		local text=MobMapQuestListZoneFilter:GetText();
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
			mobmap_qlzf_notextchanged=1;
			mobmap_qlzf_textlen=string.len(match);
			MobMapQuestListZoneFilter:SetText(match);
			if(string.len(match)>textlen) then MobMapQuestListZoneFilter:HighlightText(textlen,string.len(match)); end
			mobmap_qlzf_marklen=string.len(match)-textlen;
		end
	end
end

function MobMap_OpenRewardSelection(self)
	MobMap_SetSelectionFunc(MobMap_DoRewardSelection);
	MobMap_ShowItemNameSelectionFrame(self.selecteditem);
end

function MobMap_ClearRewardSelection(self)
	self:SetText(MOBMAP_QUEST_REWARD_FILTER_TEXT);
	self.itemid=nil;
	self.itemname=nil;
	self.selecteditem=nil;
	MobMap_RefreshQuestList();
end

function MobMap_DoRewardSelection(itemihid)
	MobMapQuestListRewardFilter.selecteditem=itemihid;
	MobMapQuestListRewardFilter.itemname=MobMap_GetItemNameByIHID(itemihid);
	local itemid, quality = MobMap_GetItemDataByIHID(itemihid);
	MobMapQuestListRewardFilter.itemid=itemid;
	local r, g, b = GetItemQualityColor(quality);
	local hexcolor=MobMap_RGBToHex(r,g,b);
	MobMapQuestListRewardFilter:SetText(MOBMAP_QUEST_REWARD_FILTER_PRETEXT.." |cFF"..hexcolor.."["..MobMapQuestListRewardFilter.itemname.."]|r");
	MobMap_RefreshQuestList();
end

function MobMap_DoQuestRewardSearch(itemihid)
	MobMap_ShowPanel("MobMapQuestListFrame");
	MobMap_ClearQuestListFilters();
	MobMap_DoRewardSelection(itemihid);
end

function MobMap_ManuallySetQuestCompletion(self)
	local questid=self.questid;
	local newstate;
	if(self:GetChecked()) then
		newstate=true;
	else
		newstate=false;
	end

	if(questid) then
		repeat
			local _, _, prequest, postquest = MobMap_GetDetailsForQuest(questid);
			local blizzid = MobMap_GetBlizzIDByQuestID(questid);
			MobMap_SetQuestCompletionStatus(blizzid, newstate);
			questid=nil;
			if(newstate==true) then
				if(prequest) then
					questid=prequest;
				end
			else
				if(postquest) then
					questid=postquest;
				end
			end
		until(questid==nil);
	end
end

-- quest detail frame

mobmap_quest_details_idlist=nil;
mobmap_quest_details_idnum=0;

function MobMap_ShowQuestDetailsByTitle(title, objective)
	questids=MobMap_GetQuestIDsByName(title, UnitFactionGroup("player"));
	if(questids==nil) then
		return false;
	else
		local idtoshow=1;
		if(objective) then
			local k, v;
			local maxsimilarity=-1;
			for k, v in pairs(questids) do
				local otherobjective=MobMap_GetQuestObjective(questids[k]);
				if(otherobjective) then
					local similarity=MobMap_GetQuestTextSimilarity(objective, otherobjective);
					if(similarity>maxsimilarity) then
						maxsimilarity=similarity;
						idtoshow=k;
					end
				end
			end
		end
		mobmap_quest_details_idlist=questids;
		mobmap_quest_details_id=idtoshow;
		MobMap_ShowQuestDetails(questids[idtoshow]);
		return true;
	end
end

function MobMap_ShowQuestDetailsByBlizzID(blizzid)
	local questid=MobMap_GetQuestIDByBlizzID(blizzid);
	if(questid==nil) then return false; end
	MobMap_ShowQuestDetails(questid);
	return true;
end

function MobMap_GetQuestTextSimilarity(text1, text2)
	if(text1==nil or text2==nil) then return 0; end
	local w1=MobMap_SplitTextIntoWords(MobMap_RemoveQuestTextEnhancements(text1));
	local w2=MobMap_SplitTextIntoWords(MobMap_RemoveQuestTextEnhancements(text2));
	
	local minsize=1000000000;
	local maxsize=0;
	if(#(w1)<minsize) then minsize=#(w1); end
	if(#(w2)<minsize) then minsize=#(w2); end
	if(#(w1)>maxsize) then maxsize=#(w1); end
	if(#(w2)>maxsize) then maxsize=#(w2); end
	
	local similarity=0;
	local i;
	for i=1, minsize, 1 do
		if(w1[i]==w2[i]) then
			similarity=similarity+(1/maxsize);
		end
	end
	return similarity;
end

function MobMap_SplitTextIntoWords(text)
	local words={};
	for w in string.gmatch(text, "%S+") do
		table.insert(words, w);
	end
	return words;
end

function MobMap_RemoveQuestTextEnhancements(text)
	local before, link, entity, after;
	repeat
		before, link, entity, after = string.match(text,"^([^|]*)|([^|]*)|([^|]*)|(.*)$");
		if(before) then
			text=before..entity..after;
		end
	until(not before);
	return text;
end

function MobMap_NextQuestDetail()
	if(mobmap_quest_details_idlist~=nil) then
		mobmap_quest_details_idnum=mobmap_quest_details_idnum+1;
		if(mobmap_quest_details_idnum>#(mobmap_quest_details_idlist)) then
			mobmap_quest_details_idnum=1;
		end
		MobMap_ShowQuestDetails(mobmap_quest_details_idlist[mobmap_quest_details_idnum]);
	end
end

function MobMap_PrevQuestDetail()
	if(mobmap_quest_details_idlist~=nil) then
		mobmap_quest_details_idnum=mobmap_quest_details_idnum-1;
		if(mobmap_quest_details_idnum<1) then
			mobmap_quest_details_idnum=#(mobmap_quest_details_idlist);
		end
		MobMap_ShowQuestDetails(mobmap_quest_details_idlist[mobmap_quest_details_idnum]);
	end
end

function MobMap_ShowQuestDetails(questid)
	if(mobmap_quest_details_idlist~=nil and #(mobmap_quest_details_idlist)>1) then
		MobMapQuestDetailFrameNextButton:Show();
		MobMapQuestDetailFramePrevButton:Show();
		MobMapQuestDetailFrameTitleText:SetWidth(220);
		MobMapQuestDetailFrameTitle:SetWidth(220);
	else
		MobMapQuestDetailFrameNextButton:Hide();
		MobMapQuestDetailFramePrevButton:Hide();	
		MobMapQuestDetailFrameTitleText:SetWidth(260);
		MobMapQuestDetailFrameTitle:SetWidth(260);
	end
	if(questid==0) then return; end
	MobMapQuestDetailFrame:Hide();
	local level, zone, prequest, postquest, isHorde, isAlliance, money, npc, sourcepointer, grouptype, always, choice, endnpc = MobMap_GetDetailsForQuest(questid);
	if(level==nil) then return; end

	local title=MobMap_GetQuestName(questid);
	MobMapQuestDetailFrameTitleText:SetText(title);
	MobMapQuestDetailFrame.questtitle=title;
	MobMapQuestDetailFrameDetailsLevel:SetText(level);
	MobMapQuestDetailFrameDetailsType:SetText(MOBMAP_QUEST_TYPES_LONG[grouptype]);
	local factiontext="";
	if(isAlliance==true) then
		factiontext=MOBMAP_QUEST_FACTION_ALLIANCE;
	end
	if(isHorde==true) then
		if(factiontext~="") then factiontext=factiontext..", "; end
		factiontext=factiontext..MOBMAP_QUEST_FACTION_HORDE;
	end

	MobMapQuestDetailFrameDetailsFaction:SetText(factiontext);
	MobMapQuestDetailFrameDetailsPrequest:SetText("");
	MobMapQuestDetailFrameDetailsPrequest:Disable();
	local questname;
	if(prequest~=0) then
		questname=MobMap_GetQuestName(prequest);
		if(questname) then
			MobMapQuestDetailFrameDetailsPrequest.questid=prequest;
			MobMapQuestDetailFrameDetailsPrequest:SetText(questname);
			MobMapQuestDetailFrameDetailsPrequest:Enable();
		end
	end

	MobMapQuestDetailFrameDetailsPostquest:SetText("");
	MobMapQuestDetailFrameDetailsPostquest:Disable();
	if(postquest~=0) then
		questname=MobMap_GetQuestName(postquest);
		if(questname) then
			MobMapQuestDetailFrameDetailsPostquest.questid=postquest;
			MobMapQuestDetailFrameDetailsPostquest:SetText(questname);
			MobMapQuestDetailFrameDetailsPostquest:Enable();
		end
	end

	MobMapQuestDetailFrameDetailsSource:Disable();
	if(sourcepointer~=0) then
		MobMapQuestDetailFrameDetailsSource:SetText("Item: "..MobMap_GetQuestSourceName(sourcepointer));
	else
		if(npc==0) then
			MobMapQuestDetailFrameDetailsSource:SetText("???");
		else
			MobMapQuestDetailFrameDetailsSource.npcid=npc;
			MobMapQuestDetailFrameDetailsSource:SetText(MobMap_GetMobName(npc));
			MobMapQuestDetailFrameDetailsSource:Enable();
		end
	end

	MobMapQuestDetailFrameDetailsEnd:Disable();
	if(endnpc==0) then
		MobMapQuestDetailFrameDetailsEnd:SetText("???");
	else
		MobMapQuestDetailFrameDetailsEnd.npcid=endnpc;
		MobMapQuestDetailFrameDetailsEnd:SetText(MobMap_GetMobName(endnpc));
		MobMapQuestDetailFrameDetailsEnd:Enable();
	end

	MobMapQuestDetailFrameDetailsZone:SetText(MobMap_GetZoneName(zone));
	local objective=MobMap_GetQuestObjective(questid);
	MobMapQuestDetailFrame.questobjective=objective;
	MobMap_DisplayEnrichedText(objective, "Objective", MobMapQuestDetailFrameObjective);

	MoneyFrame_Update("MobMapQuestDetailFrameRewardsMoney", money);

	local i;
	for i=1,6,1 do
		getglobal("MobMapQuestDetailFrameRewardsChoosable"..i):Hide();
		getglobal("MobMapQuestDetailFrameRewardsChoosable"..i).itemid=nil;
	end
	for i=1,4,1 do
		getglobal("MobMapQuestDetailFrameRewardsAlways"..i):Hide();
		getglobal("MobMapQuestDetailFrameRewardsAlways"..i).itemid=nil;
	end

	local index, id;
	for index, id in pairs(choice) do
		local itemString=MobMap_ConstructItemString(id);
		local itemFrame=getglobal("MobMapQuestDetailFrameRewardsChoosable"..index);
		itemFrame.itemid=id;
		local itemName=GetItemInfo(itemString);
		if(itemName~=nil) then
			MobMap_ShowQuestReward(index, "Choosable", id);
		else
			if(mobmap_request_item_details==true) then
				MobMapScanTooltip:SetHyperlink(itemString);
			end
		end
	end

	for index, id in pairs(always) do
		local itemString=MobMap_ConstructItemString(id);
		local itemFrame=getglobal("MobMapQuestDetailFrameRewardsAlways"..index);
		itemFrame.itemid=id;
		local itemName=GetItemInfo(itemString);
		if(itemName~=nil) then
			MobMap_ShowQuestReward(index, "Always", id);
		else
			if(mobmap_request_item_details==true) then
				MobMapScanTooltip:SetHyperlink(itemString);
			end
		end
	end

	MobMapQuestCommentFrame:Hide();

	if(mobmap_use_quest_comments==true) then
		MobMapQuestDetailFrame:SetHeight(600);
		MobMapQuestDetailFrameBackground:SetHeight(576);
		MobMapQuestDetailFrameComments:Show();
		MobMapQuestDetailFrameComments.data=MobMap_GetQuestComments(questid);
		local count=0;
		if(MobMapQuestDetailFrameComments.data) then count=#(MobMapQuestDetailFrameComments.data); end
		if(count>0) then
			count="|cFF00FF00"..count.."|r";
			MobMapQuestDetailFrameCommentsDisplayButton:Enable();
			if(mobmap_autoshow_comments==true) then
				MobMap_ShowQuestComments(MobMapQuestDetailFrameComments.data);
			end
		else
			count="|cFFFF0000"..count.."|r";
			MobMapQuestDetailFrameCommentsDisplayButton:Disable();
		end
		MobMapQuestDetailFrameCommentsCount:SetText(MOBMAP_QUEST_COMMENT_COUNT..count);
	else
		MobMapQuestDetailFrame:SetHeight(580);
		MobMapQuestDetailFrameBackground:SetHeight(556);
		MobMapQuestDetailFrameComments:Hide();
	end
	
	MobMapQuestDetailFrame:Show();
end

function MobMap_ShowQuestReward(index, rewardtype, itemid)
	local itemString=MobMap_ConstructItemString(itemid);
	local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(itemString);
	local itemFrame=getglobal("MobMapQuestDetailFrameRewards"..rewardtype..index);
	local itemFrameName=getglobal("MobMapQuestDetailFrameRewards"..rewardtype..index.."Name");
	local itemFrameTexture=getglobal("MobMapQuestDetailFrameRewards"..rewardtype..index.."IconTexture");
	if(itemName~=nil) then
		itemFrameName:SetText(itemName);
		local r, g, b = GetItemQualityColor(itemRarity);
		itemFrameName:SetTextColor(r,g,b);
		itemFrameTexture:SetTexture(itemTexture);
		itemFrame.itemstring=itemString;
		itemFrame.itemlink=itemLink;
		itemFrame:Show();
	else
		if(mobmap_request_item_details==true) then
			itemFrameName:SetText("???");
		else
			MobMap_LoadDatabase(MOBMAP_ITEMNAME_HELPER_DATABASE);
			local ihid=MobMap_GetIHIDByItemID(itemid);
			if(ihid~=nil) then
				itemFrameName:SetText(MobMap_GetItemNameByIHID(ihid));
				local _, quality=MobMap_GetItemDataByIHID(ihid);
				local r, g, b = GetItemQualityColor(quality);
				itemFrameName:SetTextColor(r,g,b);
			end
		end
		itemFrame.itemstring=nil;
		itemFrame.itemlink=nil;
		itemFrameTexture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark.blp");
		itemFrame:Show();
	end
end

local mobmap_questdetailframe_updatetimer = 0;

function MobMap_QuestDetailFrame_OnUpdate()
	if(mobmap_questdetailframe_updatetimer<=0) then
		local i;
		for i=1,6,1 do
			getglobal("MobMapQuestDetailFrameRewardsChoosable"..i):Hide();
		end
		for i=1,4,1 do
			getglobal("MobMapQuestDetailFrameRewardsAlways"..i):Hide();
		end

		local index;
		for index=1,6,1 do
			local itemFrame=getglobal("MobMapQuestDetailFrameRewardsChoosable"..index);
			if(itemFrame.itemid~=nil) then
				MobMap_ShowQuestReward(index, "Choosable", itemFrame.itemid);
			end
		end
		for index=1,4,1 do
			local itemFrame=getglobal("MobMapQuestDetailFrameRewardsAlways"..index);
			if(itemFrame.itemid~=nil) then
				MobMap_ShowQuestReward(index, "Always", itemFrame.itemid);
			end
		end
		mobmap_questdetailframe_updatetimer=0.5;
	else
		mobmap_questdetailframe_updatetimer=mobmap_questdetailframe_updatetimer-arg1;
	end
end

function MobMap_QuestItem_OnClick(self)
	if(IsControlKeyDown()) then
		if(self.itemlink~=nil) then
			DressUpItemLink(self.itemlink);
		end
	elseif(IsShiftKeyDown()) then
		if(self.itemlink~=nil) then
			ChatEdit_InsertLink(self.itemlink);
		end
	end
end

function MobMap_DisplayEnrichedText(text, key, target)
	local i;
	local frame=nil;
	local space=target;
	
	i=1;
	repeat
		frame=getglobal("MobMapEnrichedText_"..key.."_Word"..i);
		if(frame) then 
			frame:Hide(); 
			frame:ClearAllPoints();
		end
		i=i+1;
	until(frame==nil);
	i=1;
	repeat
		frame=getglobal("MobMapEnrichedText_"..key.."_Link"..i);
		if(frame) then 
			frame:ClearAllPoints();
			frame:Hide();
		end
		i=i+1;
	until(frame==nil);

	local parts={};
	local partcount=1;
	local inLink=false;
	for w in string.gmatch(text, "%S+") do
    		if(inLink==false) then
			parts[partcount]=w;
			if(string.find(w,"^|")~=nil) then
				inLink=true;
				if(string.find(w,"|.?$")~=nil) then
					inLink=false;
					partcount=partcount+1;
				end
			else
			    	partcount=partcount+1;
			end
		else
			parts[partcount]=parts[partcount].." "..w;
			if(string.find(w,"|.?$")~=nil) then
				inLink=false;
				partcount=partcount+1;
			end
		end
	end

	local k, token;
	local nextlink=1;
	local nextword=1;
	local xpos=0;
	local ypos=0;
	local lineheight=14;
	for k, token in pairs(parts) do
		if(string.find(token,"|")~=nil) then
			local link, entity, after = string.match(token,"^|(.*)|(.*)|(.*)");
			if(link~=nil and entity~=nil) then
				local linktype=nil;
				local linkdata=nil;
				if(string.match(link,"^(%d+)$")) then
					linkdata=tonumber(link);
					linktype="mobid";
				elseif(string.match(link,"^(%d+)/(%d+)$")) then
					local x,y=string.match(link,"^(%d+)/(%d+)$");
					linkdata={x=tonumber(x),y=tonumber(y)};
					linktype="coord";
				end
				if(linkdata and linktype) then
					frame=getglobal("MobMapEnrichedText_"..key.."_Link"..nextlink);
					if(frame==nil) then
						frame=CreateFrame("Button","MobMapEnrichedText_"..key.."_Link"..nextlink,space,"MobMapQuestObjectiveLinkFrameTemplate");
					end
					local textobject=getglobal(frame:GetName().."Text");
					if(after==nil) then entity=entity.." "; end
					frame:SetText(entity);
					textobject:SetWidth(1000);
					local textwidth=textobject:GetStringWidth();
					textobject:SetWidth(textwidth+6);
					textobject:SetHeight(lineheight);
					frame:SetWidth(textwidth+6);
					frame:SetHeight(lineheight);
					if(xpos+textwidth>space:GetWidth()) then
						ypos=ypos-lineheight;
						xpos=0;
					end
					frame:ClearAllPoints();
					frame:SetPoint("TOPLEFT",space,"TOPLEFT",xpos,ypos);
					xpos=xpos+textwidth-2;
					frame:Show();
					frame.linktype=linktype;
					frame.data=linkdata;
					nextlink=nextlink+1;
				end
			end
			token=after;
		end
		if(token~=nil) then
			if(token=="\\n") then
				ypos=ypos-lineheight;
				xpos=0;
			else
				frame=getglobal("MobMapEnrichedText_"..key.."_Word"..nextword);
				if(frame==nil) then
					frame=CreateFrame("Frame","MobMapEnrichedText_"..key.."_Word"..nextword,space,"MobMapQuestObjectiveWordFrameTemplate");
				end
				local textobject=getglobal(frame:GetName().."Text");
				textobject:SetText(token.." ");
				textobject:SetWidth(1000);
				local textwidth=textobject:GetStringWidth();
				textobject:SetWidth(textwidth+1);
				textobject:SetHeight(lineheight);
				frame:SetWidth(textwidth+1);
				frame:SetHeight(lineheight);
				if(xpos+textwidth>space:GetWidth()) then
					ypos=ypos-lineheight;
					xpos=0;
				end
				frame:ClearAllPoints();
				frame:SetPoint("TOPLEFT",space,"TOPLEFT",xpos,ypos);
				xpos=xpos+textwidth;
				frame:Show();
				nextword=nextword+1;
			end
		end
	end
	if(xpos>0) then
		return -ypos+lineheight;
	else
		return -ypos;
	end
end

function MobMap_ProcessEnrichmentLink(linktype, data)
	if(linktype=="mobid") then
		if(not MobMapFrame:IsVisible()) then
			mobmap_questsearch=true;
		end
		MobMap_ShowPanel("MobMapMobSearchFrame");
		MobMap_ShowMobByID(data);
	elseif(linktype=="coord") then
		MobMap_ShowSinglePositionOnMap(data.x, data.y, "Questkommentar-Koordinate");
	end
end

-- quest comment frame

function MobMap_ShowQuestComments(data, commentoffset, pagenum)
	MobMapQuestCommentFrameTitleText:SetText(MOBMAP_QUEST_COMMENT_TITLE_PREFIX.."\""..MobMapQuestDetailFrameTitleText:GetText().."\"");
	
	MobMap_HideAllQuestCommentFrames();

	if(commentoffset==nil) then commentoffset=0; end
	if(pagenum==nil) then pagenum=1; end
	local count=1;
	local yoffset=60;
	local yspace=10;
	local i=0;
	for i=1+commentoffset, #(data), 1 do
		local newoffset=MobMap_CreateQuestCommentFrame(data[i], count, yoffset);
		if(newoffset<0) then
			break;
		else
			yoffset=yoffset+newoffset+yspace;
			count=count+1;
		end
	end
	local lastcomment=commentoffset+count-1;

	if(lastcomment<#(data) or commentoffset>0) then
		MobMapQuestCommentFramePageText:SetText("Seite "..pagenum);
		if(lastcomment<#(data)) then
			MobMapQuestCommentFramePageNextButton:Enable();
		else
			MobMapQuestCommentFramePageNextButton:Disable();
		end
		if(commentoffset>0) then
			MobMapQuestCommentFramePagePrevButton:Enable();
		else
			MobMapQuestCommentFramePagePrevButton:Disable();
		end
		MobMapQuestCommentFramePage.pagenum=pagenum;
		if(MobMapQuestCommentFramePage.offset==nil) then MobMapQuestCommentFramePage.offset={}; end
		MobMapQuestCommentFramePage.offset[pagenum]=commentoffset;
		MobMapQuestCommentFramePage.offset[pagenum+1]=lastcomment;
		MobMapQuestCommentFramePage:Show();
	else
		MobMapQuestCommentFramePage.offset=nil;
		MobMapQuestCommentFramePage:Hide();
	end

	MobMapQuestCommentFrame:Show();
end

function MobMap_ShowQuestCommentEditor(questtitle, questobjective)
	MobMapQuestCommentEditorFrameTitleSubText:SetText("\""..questtitle.."\"");
	MobMapQuestCommentEditorFrame.questtitle=questtitle;
	MobMapQuestCommentEditorFrame.questobjective=questobjective;

	local commenttext=MobMap_GetSavedQuestComment(questtitle, questobjective);
	if(commenttext) then 
		MobMapQuestCommentEditorFrameEditboxBorderEditBox:SetText(commenttext);
		MobMap_DisplayMessage(MOBMAP_QUEST_COMMENT_EDITOR_ALREADYFOUND);
	else
		MobMapQuestCommentEditorFrameEditboxBorderEditBox:SetText("");
	end

	MobMapQuestCommentEditorFrameIdentificationYes:SetChecked(mobmap_quest_comment_identification);
	MobMapQuestCommentEditorFrameIdentificationNo:SetChecked(not mobmap_quest_comment_identification);

	MobMapQuestCommentEditorFrame:Show();
end

function MobMap_HideAllQuestCommentFrames()
	local i=1;
	repeat
		frame=getglobal("MobMapQuestCommentFrameInstance"..i);
		if(frame) then 
			frame:Hide(); 
			frame:ClearAllPoints();
		end
		i=i+1;
	until(frame==nil);
end

function MobMap_CreateQuestCommentFrame(comment, count, yoffset)
	local xoffset=20;
	local maxysize=570;
	local space=MobMapQuestCommentFrame;
	frame=getglobal("MobMapQuestCommentFrameInstance"..count);
	if(frame==nil) then
		frame=CreateFrame("Frame","MobMapQuestCommentFrameInstance"..count,space,"MobMapQuestCommentFrameTemplate");
	end

	local title=getglobal("MobMapQuestCommentFrameInstance"..count.."Title");
	local source="Anonymous";
	if(comment.player~="" and comment.realm~="") then
		source=comment.player..MOBMAP_QUEST_COMMENT_EDITOR_AUTHOR_1..comment.realm;
	end
	local datestring;
	if(GetLocale()=="deDE") then
		datestring=date("%d.%m.%y", comment.time);
	else
		datestring=date("%m/%d/%y", comment.time);
	end
	title:SetText(source..MOBMAP_QUEST_COMMENT_EDITOR_AUTHOR_2..datestring..":");
	local textspace=getglobal("MobMapQuestCommentFrameInstance"..count.."Space");
	local textheight=MobMap_DisplayEnrichedText(comment.text, "Comment"..count, textspace);
	textspace:SetHeight(textheight);
	frame:SetHeight(textheight+20);

	if(yoffset+frame:GetHeight()<maxysize) then
		frame:ClearAllPoints();
		frame:SetPoint("TOPLEFT",space,"TOPLEFT",xoffset,-yoffset);
		frame:Show();
		return frame:GetHeight();
	else
		frame:Hide();
		return -1;
	end
end

function MobMap_GetSavedQuestComment(title, objective)
	local newid=-1;
	for k,v in pairs(mobmap_comments) do
		if(v.title==title and v.objective==objective) then
			return v.text;
		end
	end
	return nil;
end

function MobMap_SaveQuestComment(title, objective, text, identify)
	local oldid=nil;
	for k,v in pairs(mobmap_comments) do
		if(v.title==title and v.objective==objective) then
			oldid=k;
			break;
		end
	end

	local comment={};
	comment.title=title;
	comment.objective=objective;
	comment.text=text;
	if(identify) then
		local playername=UnitName("player");
		local realmname=GetRealmName();
		comment.author=playername.."|"..realmname;
	end

	if(oldid) then
		if(text and text~="") then
			mobmap_comments[oldid]=comment;
			MobMap_DisplayMessage(MOBMAP_QUEST_COMMENT_EDITOR_CONFIRMATION);
		else
			MobMap_DisplayMessage(MOBMAP_QUEST_COMMENT_EDITOR_DELETED);
			mobmap_comments[oldid]=nil;
		end
	else
		if(text and text~="") then
			mobmap_comments[tostring(time())]=comment;
			MobMap_DisplayMessage(MOBMAP_QUEST_COMMENT_EDITOR_CONFIRMATION);
		end
	end
	MobMapQuestCommentEditorFrame:Hide();
end

function MobMap_AddCurrentPositionToComment()
	local x, y = MobMap_GetPlayerCoordinates();
	if(x>=0 or y>=0) then
		MobMapQuestCommentEditorFrameEditboxBorderEditBox:Insert(math.floor(x+0.5)..","..math.floor(y+0.5));
	end
end