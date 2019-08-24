mobmap_questtracker_status = { width=300, height=360, visible=true, locked=false, collapsed={}, showdistance=true, showadditionaltargets=true, hidefinishedobjectives=false, hidefinishedquests=false, sortbydistance=true, backcolor={r=1.0, g=1.0, b=1.0, a=0.0}, exactpositioning=true };

mobmap_queststatus = {};

function MobMap_QuestTracker_ResizeFrame(self)
	local x,y = GetCursorPosition();
	x=x/UIParent:GetEffectiveScale();
	y=y/UIParent:GetEffectiveScale();
	if(self.oldx and self.oldy) then
		local xdist=x-self.oldx;
		local ydist=y-self.oldy;
		mobmap_questtracker_status.width=MobMapQuestTrackerFrame:GetWidth()-xdist;
		mobmap_questtracker_status.height=MobMapQuestTrackerFrame:GetHeight()-ydist;
		if(mobmap_questtracker_status.width<60) then mobmap_questtracker_status.width=60; end
		if(mobmap_questtracker_status.height<60) then mobmap_questtracker_status.height=60; end
		MobMapQuestTrackerFrame:SetWidth(mobmap_questtracker_status.width);
		MobMapQuestTrackerFrame:SetHeight(mobmap_questtracker_status.height);
	end
	self.oldx=x;
	self.oldy=y;
	MobMap_QuestTracker_UpdateQuests();
	MobMap_QuestTracker_ScrollBarUpdateVisibility();
end

function MobMap_QuestTracker_Reanchor()
	local x=MobMapQuestTrackerFrame:GetRight();
	local y=MobMapQuestTrackerFrame:GetTop();
	MobMapQuestTrackerFrame:SetPoint("TOPRIGHT", "UIParent", "TOPRIGHT", -(UIParent:GetWidth()-x), -(UIParent:GetHeight()-y));	
end

function MobMap_QuestTracker_Toggle()
	mobmap_questtracker_status.visible=not mobmap_questtracker_status.visible;
	MobMap_QuestTracker_Setup();
end

function MobMap_QuestTracker_Setup()
	--migration
	if(mobmap_questtracker_status.showdistance==nil) then mobmap_questtracker_status.showdistance=true; end
	if(mobmap_questtracker_status.showadditionaltargets==nil) then mobmap_questtracker_status.showadditionaltargets=true; end
	if(mobmap_questtracker_status.hidefinishedobjectives==nil) then mobmap_questtracker_status.hidefinishedobjectives=false; end
	if(mobmap_questtracker_status.hidefinishedquests==nil) then mobmap_questtracker_status.hidefinishedquests=false; end
	if(mobmap_questtracker_status.width<60) then mobmap_questtracker_status.width=60; end
	if(mobmap_questtracker_status.height<60) then mobmap_questtracker_status.height=60; end
	if(mobmap_questtracker_status.sortbydistance==nil) then mobmap_questtracker_status.sortbydistance=true; end
	if(mobmap_questtracker_status.backcolor==nil) then mobmap_questtracker_status.backcolor={r=1.0, g=1.0, b=1.0, a=0.0}; end
	if(mobmap_questtracker_status.exactpositioning==nil) then mobmap_questtracker_status.exactpositioning=true; end

	if(mobmap_use_questtracker) then
		MobMapQuestTrackerFrameBackground:SetTexture(mobmap_questtracker_status.backcolor.r, mobmap_questtracker_status.backcolor.g, mobmap_questtracker_status.backcolor.b, mobmap_questtracker_status.backcolor.a);
		MobMapQuestTrackerFrame:Show();
		MobMap_QuestTracker_Reanchor();
		if(mobmap_questtracker_status.visible) then
			MobMapQuestTrackerFrame:SetWidth(mobmap_questtracker_status.width);
			MobMapQuestTrackerFrame:SetHeight(mobmap_questtracker_status.height);
			MobMapQuestTrackerFrameScrollFrame:SetWidth(MobMapQuestTrackerFrame:GetWidth());
			MobMapQuestTrackerFrameScrollFrame:SetHeight(MobMapQuestTrackerFrame:GetHeight());
			if(not mobmap_questtracker_status.locked) then
				MobMapQuestTrackerFrameResizeButton:Show();
			else
				MobMapQuestTrackerFrameResizeButton:Hide();
			end
			MobMapQuestTrackerFrameToggleButtonTexture:SetTexCoord(0, 1.0, 0.8125, 0.1875);
			MobMapQuestTrackerFrameToggleButtonHighlight:SetTexCoord(0, 1.0, 0.8125, 0.1875);
			MobMapQuestTrackerFrameScrollFrame:Show();
			MobMap_QuestTracker_ScrollBarUpdateVisibility();
		else
			MobMapQuestTrackerFrame:SetWidth(MobMapQuestTrackerFrameToggleButton:GetWidth());
			MobMapQuestTrackerFrame:SetHeight(MobMapQuestTrackerFrameToggleButton:GetHeight());
			MobMapQuestTrackerFrameScrollFrame:SetWidth(MobMapQuestTrackerFrame:GetWidth());
			MobMapQuestTrackerFrameScrollFrame:SetHeight(MobMapQuestTrackerFrame:GetHeight());
			MobMapQuestTrackerFrameResizeButton:Hide();
			MobMapQuestTrackerFrameToggleButtonTexture:SetTexCoord(0, 1.0, 0.1875, 0.8125);
			MobMapQuestTrackerFrameToggleButtonHighlight:SetTexCoord(0, 1.0, 0.1875, 0.8125);
			MobMapQuestTrackerFrameScrollFrame:Hide();
		end
		hooksecurefunc("WorldMapQuestShowObjectives_Toggle", MobMap_QuestTracker_FullUpdate);
		MobMap_QuestTracker_FullUpdate();
	else
		MobMap_QuestTracker_FullUpdate();
		MobMapQuestTrackerFrame:Hide();
	end
end

function MobMap_QuestTracker_ShowBackground()
	if(mobmap_questtracker_status.backcolor.a<0.1) then
		MobMapQuestTrackerFrameBackground:SetTexture(mobmap_questtracker_status.backcolor.r, mobmap_questtracker_status.backcolor.g, mobmap_questtracker_status.backcolor.b, mobmap_questtracker_status.backcolor.a+0.1);
	end
end

function MobMap_QuestTracker_HideBackground()
	if(mobmap_questtracker_status.backcolor.a<0.1) then
		MobMapQuestTrackerFrameBackground:SetTexture(mobmap_questtracker_status.backcolor.r, mobmap_questtracker_status.backcolor.g, mobmap_questtracker_status.backcolor.b, mobmap_questtracker_status.backcolor.a);
	end
end

function MobMap_QuestTracker_ScrollBarOnVerticalScroll(self, offset)
	local scrollbar = getglobal(self:GetName().."ScrollBar");
	scrollbar:SetValue(offset);
	local min;
	local max;
	min, max = scrollbar:GetMinMaxValues();
	if(offset==0) then
		getglobal(scrollbar:GetName().."ScrollUpButton"):Disable();
	else
		getglobal(scrollbar:GetName().."ScrollUpButton"):Enable();
	end
	if ((scrollbar:GetValue() - max) == 0) then
		getglobal(scrollbar:GetName().."ScrollDownButton"):Disable();
	else
		getglobal(scrollbar:GetName().."ScrollDownButton"):Enable();
	end
end

function MobMap_QuestTracker_ScrollBarUpdateVisibility()
	if(MobMapQuestTrackerFrameScrollFrameScrollBarScrollDownButton:IsEnabled()~=0 or MobMapQuestTrackerFrameScrollFrameScrollBarScrollUpButton:IsEnabled()~=0) then
		MobMapQuestTrackerFrameScrollFrameScrollBar:Show();
		MobMapQuestTrackerFrame.scrollbar=true;
	else
		MobMapQuestTrackerFrameScrollFrameScrollBar:Hide();
		MobMapQuestTrackerFrame.scrollbar=false;
	end
end

function MobMap_QuestTracker_FullUpdate()	
	if(not mobmap_questtracker_status.visible or not mobmap_use_questtracker) then 
		MobMap_QuestTracker_ClearAllLines();
		return;
	end
	if(not MobMap_LoadDatabase(MOBMAP_MOBNAME_DATABASE)) then return false; end;
	if(not MobMap_LoadDatabase(MOBMAP_QUEST_DATABASE)) then return false; end;
	if(not MobMap_LoadDatabase(MOBMAP_POSITION_DATABASE)) then return false; end;
	MobMap_QuestTracker_RefreshQuestStatusFromLog();
	MobMap_QuestTracker_EnrichQuestStatus();
	MobMap_QuestTracker_UpdateQuests();
	MobMap_QuestTracker_ScrollBarUpdateVisibility();
end

mobmap_questtracker_lines={};
mobmap_questtracker_posdata_loop_count=0;

function MobMap_QuestTracker_UpdateQuests(localx, localy, localzonename, onlydistances)
	if(localx==nil) then
		localx, localy, localzonename = MobMap_GetPlayerCoordinates(true);
	end
	if(mobmap_questtracker_status.showdistance or mobmap_questtracker_status.sortbydistance) then
		if(mobmap_questtracker_status.exactpositioning) then
			if(not onlydistances or mobmap_questtracker_posdata_loop_count<=0) then
				MobMap_QuestTracker_EnrichQuestPosData(localx, localy, localzonename);
				mobmap_questtracker_posdata_loop_count=5;
			else
				mobmap_questtracker_posdata_loop_count=mobmap_questtracker_posdata_loop_count-1;
			end
		end
		MobMap_QuestTracker_EnrichQuestDistances(localx, localy, localzonename);
	end	
	if(mobmap_questtracker_status.sortbydistance) then
		if(MobMap_QuestTracker_SortQuestsByDistance(not onlydistances)==true) then
			onlydistances=false; -- force full update if sorting has changed
		end
	else
		MobMap_QuestTracker_PushCurrentZoneToTop();
	end
	if(not onlydistances) then
		MobMap_QuestTracker_ClearAllLines();
	end
	if(not mobmap_questtracker_status.visible) then return; end
	local groupLineNum=0;
	local questLineNum=0;
	local targetLineNum=0;
	local lastLine=nil;
	linetotalcount=100;
	local linecount=0;

	local i,header,k,quest,num,target;

	local scrollbarspace=22;
	local linestoexpect=0;
	local queststohide={};
	local headerstohide={};
	local questsfullycompleted={};
	for i,header in pairs(mobmap_queststatus) do
		local linesforcategory=1;		
		for k,quest in pairs(header.quests) do
			local notCompleted=false;
			if(not mobmap_questtracker_status.hidefinishedquests) then showQuest=true; end
			local linesforquest=1;
			for num,target in pairs(quest.targets) do
				if(not mobmap_questtracker_status.hidefinishedobjectives or not target.done) then
					linesforquest=linesforquest+1;
					if(not target.done and target.type~="MobMap") then notCompleted=true; end
				end
			end
			if(not mobmap_questtracker_status.hidefinishedquests or notCompleted) then
				linesforcategory=linesforcategory+linesforquest;
			else
				queststohide[quest]=true;
			end
			if(not notCompleted) then
				questsfullycompleted[quest]=true;
			end
		end
		if(linesforcategory>1) then
			if(not header.collapsed) then
				linestoexpect=linestoexpect+linesforcategory;
			else
				linestoexpect=linestoexpect+1;
			end
		else
			headerstohide[header]=true;
		end			
	end
	
	for i,header in pairs(mobmap_queststatus) do
		if(not headerstohide[header]) then
			local groupline;
			groupLineNum=groupLineNum+1;
			groupline=getglobal("MobMapQuestTrackerFrameGroupLine"..groupLineNum);
			if(not groupline) then
				groupline=CreateFrame("Frame", "MobMapQuestTrackerFrameGroupLine"..groupLineNum, MobMapQuestTrackerFrameScrollFrameScrollChildFrame, "MobMapQuestTrackerFrameGroupLineTemplate");
				groupline.titlebutton=getglobal(groupline:GetName().."TitleButton");
				groupline.expandbutton=getglobal(groupline:GetName().."ExpandButton");
				groupline.collapsebutton=getglobal(groupline:GetName().."CollapseButton");
			end
			if(not onlydistances) then
				groupline:SetWidth(MobMapQuestTrackerFrame:GetWidth());

				groupline.titlebutton:SetText(header.title);
				groupline.titlebutton:SetWidth(groupline:GetWidth()-groupline.expandbutton:GetWidth()-scrollbarspace);
				groupline.titlebutton:SetNormalFontObject(QuestDifficultyColors["header"].font);

				groupline:ClearAllPoints();
				if(not lastLine) then
					groupline:SetPoint("TOPLEFT", MobMapQuestTrackerFrameScrollFrameScrollChildFrame, "TOPLEFT", 0, 0);
				else
					groupline:SetPoint("TOPLEFT", lastLine, "BOTTOMLEFT", 0, 0);
				end
				groupline:Show();
			end
			table.insert(mobmap_questtracker_lines, groupline);
			lastLine=groupline;
			linecount=linecount+1;

			if(not header.collapsed) then
				if(groupline) then
					groupline.expandbutton:Hide();
					groupline.collapsebutton:Show();
				end
				for k,quest in pairs(header.quests) do
					if(not queststohide[quest]) then
						local questline;
						questLineNum=questLineNum+1;
						questline=getglobal("MobMapQuestTrackerFrameQuestLine"..questLineNum);
						if(not questline) then
							questline=CreateFrame("Frame", "MobMapQuestTrackerFrameQuestLine"..questLineNum, MobMapQuestTrackerFrameScrollFrameScrollChildFrame, "MobMapQuestTrackerFrameQuestLineTemplate");
							questline.titlebutton=getglobal(questline:GetName().."TitleButton");
							questline.infobutton=getglobal(questline:GetName().."InfoButton");
							questline.blizzinfobutton=getglobal(questline:GetName().."BlizzInfoButton");
							questline.itembutton=getglobal(questline:GetName().."ItemButton");
						end
						if(not onlydistances) then
							questline:SetWidth(MobMapQuestTrackerFrame:GetWidth());

							local displayedTitle=quest.title;
							local groupIndicator="";
							if(quest.groupsize and quest.groupsize>1) then
								displayedTitle=displayedTitle.." ("..quest.groupsize..")";								
								groupIndicator="g";
							else
								if(quest.tag==RAID) then
									groupIndicator="r";
								elseif(quest.tag==PVP) then
									groupIndicator="p";
								elseif(quest.tag==GROUP) then
									groupIndicator="g";
								end
							end
							if(quest.daily) then
								groupIndicator=groupIndicator.."d";
							end
	
							if(table.getn(quest.partyMembers)>0) then
								displayedTitle="("..table.getn(quest.partyMembers)..") "..displayedTitle;
							end

							if(quest.level) then
								displayedTitle="["..quest.level..groupIndicator.."] "..displayedTitle
							end

							local itemButtonWidth=0;
							if(quest.item and quest.qlindex and GetQuestLogSpecialItemCooldown(quest.qlindex)~=nil) then
								questline.itembutton:SetID(quest.qlindex);
								SetItemButtonTexture(questline.itembutton, quest.item.texture);
								SetItemButtonCount(questline.itembutton, quest.item.charges);
								WatchFrameItem_UpdateCooldown(questline.itembutton);
								questline.itembutton.rangeTimer = -1;
								questline.itembutton:Show();
								itemButtonWidth=16;
							else
								questline.itembutton:Hide();
							end

							questline.titlebutton:SetText(displayedTitle);
							questline.titlebutton:SetWidth(questline:GetWidth()-questline.infobutton:GetWidth()-16-scrollbarspace-itemButtonWidth);
							if(questsfullycompleted[quest]) then
								questline.titlebutton:SetNormalFontObject(MobMapFinishedQuestFont);
							else
								questline.titlebutton:SetNormalFontObject(GetQuestDifficultyColor(quest.level).font);
							end
							local fontObj=questline.titlebutton:GetFontString();
							fontObj:SetWidth(questline.titlebutton:GetWidth());
							fontObj:SetNonSpaceWrap(true);

							questline.blizzid=quest.blizzid;
							questline.shorttext=quest.shorttext;
							questline.title=quest.title;
							questline.partyMembers=quest.partyMembers;
							questline.questLink=quest.link;
							questline.index=quest.index;

							if(GetCVarBool("questPOI") and quest.poizone~=nil) then
								questline.blizzinfobutton:Show();
								questline.infobutton:ClearAllPoints();
								questline.infobutton:SetPoint("LEFT", questline, "LEFT", 4, 0);
							else
								questline.blizzinfobutton:Hide();
								questline.infobutton:ClearAllPoints();
								questline.infobutton:SetPoint("LEFT", questline, "LEFT", 16, 0);
							end

							questline:ClearAllPoints();
							if(not lastLine) then
								questline:SetPoint("TOPLEFT", MobMapQuestTrackerFrameScrollFrameScrollChildFrame, "TOPLEFT", 0, 0);
							else
								questline:SetPoint("TOPLEFT", lastLine, "BOTTOMLEFT", 0, 0);
							end
							questline:Show();
							table.insert(mobmap_questtracker_lines, questline);
							lastLine=questline;
						end
						linecount=linecount+1;

						for num,target in pairs(quest.targets) do
							local targetline;
							if(not mobmap_questtracker_status.hidefinishedobjectives or not target.done) then
								targetLineNum=targetLineNum+1;
								targetline=getglobal("MobMapQuestTrackerFrameTargetLine"..targetLineNum);
								if(not targetline) then
									targetline=CreateFrame("Frame", "MobMapQuestTrackerFrameTargetLine"..targetLineNum, MobMapQuestTrackerFrameScrollFrameScrollChildFrame, "MobMapQuestTrackerFrameTargetLineTemplate");
									targetline.text=getglobal(targetline:GetName().."Text");
									targetline.distance=getglobal(targetline:GetName().."Distance");
									targetline.check=getglobal(targetline:GetName().."Check");
									targetline.infobutton=getglobal(targetline:GetName().."InfoButton");
								end
								if(not onlydistances) then
									targetline:SetWidth(MobMapQuestTrackerFrame:GetWidth());
								end

								targetline.blizzid=quest.blizzid;

								local distanceFieldWidth=0;
								if(mobmap_questtracker_status.showdistance and target.distance and not target.done) then
									local distance;
									if(target.distance<3) then
										targetline.distance:SetText(MOBMAP_QUESTTRACKER_DISTANCE_HERE);
										targetline.distance:SetTextColor(0.0, 0.8, 1.0, 1.0);
									else
										distance=math.floor(target.distance+0.5);
										targetline.distance:SetText(distance..MOBMAP_QUEST_TRACKER_DISTANCE_UNIT);
										if(distance<500) then
											targetline.distance:SetTextColor(0.25, 0.75, 0.25, 1.0);
										elseif(distance<1500) then
											targetline.distance:SetTextColor(0.94, 0.78, 0.05, 1.0);
										else
											targetline.distance:SetTextColor(0.83, 0.13, 0.18, 1.0);
										end
									end
									targetline.distance:Show();									
									targetline.distance:SetWidth(200);
									distanceFieldWidth=targetline.distance:GetStringWidth();
									targetline.distance:SetWidth(distanceFieldWidth+4);
									targetline.distance:SetPoint("RIGHT", targetline.distance:GetParent(), "RIGHT", -scrollbarspace, 0);									
								else
									targetline.distance:Hide();
								end

								if(not onlydistances) then
									targetline.text:SetText(target.text);
									targetline.text:SetWidth(targetline:GetWidth()-targetline.infobutton:GetWidth()-distanceFieldWidth-32-scrollbarspace);
									targetline.text:SetHeight(targetline.text:GetStringHeight()+6);
									targetline:SetHeight(targetline.text:GetHeight());

									if(target.done) then
										targetline.check:Show();
										targetline.infobutton:Hide();
										targetline.text:SetTextColor(0.7,0.7,0.7,1.0);
									else
										targetline.check:Hide();
										targetline.infobutton:Show();
										targetline.text:SetTextColor(1.0,1.0,1.0,1.0);
									end

									targetline.data=target;

									targetline:ClearAllPoints();
									if(not lastLine) then
										targetline:SetPoint("TOPLEFT", MobMapQuestTrackerFrameScrollFrameScrollChildFrame, "TOPLEFT", 0, 0);
									else
										targetline:SetPoint("TOPLEFT", lastLine, "BOTTOMLEFT", 0, 0);
									end
									targetline:Show();
								end
								table.insert(mobmap_questtracker_lines, targetline);
								lastLine=targetline;
								linecount=linecount+1;
							end
						end
					end
				end
			else
				if(groupline) then
					groupline.expandbutton:Show();
					groupline.collapsebutton:Hide();
				end
			end
		end
	end

	MobMapQuestTrackerFrameScrollFrame:SetWidth(MobMapQuestTrackerFrame:GetWidth()-22);
	MobMapQuestTrackerFrameScrollFrame:SetHeight(MobMapQuestTrackerFrame:GetHeight());
end

function MobMap_QuestTracker_ClearAllLines()
	local k,v;
	for k,v in pairs(mobmap_questtracker_lines) do
		v:ClearAllPoints();
		v:Hide();
	end
	mobmap_questtracker_lines={};
end

function MobMap_QuestTracker_RefreshQuestStatusFromLog()
	mobmap_queststatus={};

	local selected=GetQuestLogSelection();
	local collapsed={};
	local i=1;
	local currentHeader=nil;
	local wasCollapsed;
	local realIndex=0;
	while(i<=GetNumQuestLogEntries()) do
		local questTitle, questLevel, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily = GetQuestLogTitle(i);
		if(questTitle) then			
			if(isHeader) then
				currentHeader={title=questTitle, quests={}, collapsed=false};
				table.insert(mobmap_queststatus, currentHeader);
				realIndex=realIndex+1;
				if(isCollapsed) then
					collapsed[questTitle]=true;
					currentHeader.collapsed=true;
					ExpandQuestHeader(i);
					wasCollapsed=true;
				else
					wasCollapsed=false;
				end
			else
				SelectQuestLogEntry(i);
				local questDescription, questObjectives = GetQuestLogQuestText();
				local id=MobMap_GetQuestIdFromQuestLog(i);
				local numPartyMembers=GetNumPartyMembers();
				local partyMembersOnQuest={};
				for j=1,numPartyMembers,1 do
					if(IsUnitOnQuest(i, "party"..j)) then
						local playerName=UnitName("party"..j);
						table.insert(partyMembersOnQuest, playerName);
					end
				end
				local questLink=GetQuestLink(i);				
				local specialLink, specialTexture, specialCharges = GetQuestLogSpecialItemInfo(i);
				local questItem=nil;
				if(specialLink) then
					questItem={link=specialLink, charges=specialCharges, texture=specialTexture};
				end
				local poizone=GetQuestWorldMapAreaID(id);
				if(poizone==0) then poizone=nil; end
				local currentQuest={index=i, title=questTitle, link=questLink, level=questLevel, tag=questTag, completed=isComplete, daily=isDaily, blizzid=id, targets={}, shorttext=questObjectives, level=questLevel, groupsize=suggestedGroup, tag=questTag, partyMembers=partyMembersOnQuest, item=questItem, poizone=poizone};
				if(not wasCollapsed) then
					realIndex=realIndex+1;
					currentQuest.qlindex=realIndex;
				else
					currentQuest.qlindex=nil;
				end
				table.insert(currentHeader.quests, currentQuest);
				local j=1;
				while(j<=GetNumQuestLeaderBoards(i)) do
					local lbdesc, lbtype, lbdone = GetQuestLogLeaderBoard(j, i);
					table.insert(currentQuest.targets, {index=j, text=lbdesc, type=lbtype, done=lbdone, quest=currentQuest, poizone=poizone});
					if(lbdone) then
						if(mobmap_autocreated and mobmap_autocreated.questid==currentQuest.blizzid and mobmap_autocreated.index==j) then
							MobMap_QuestTracker_RemoveAutoCreatedWaypoint();
						end
					end
					j=j+1;
				end
			end
		end
		i=i+1;
	end

	i=1;
	while(i<=GetNumQuestLogEntries()) do
		local questTitle, questLevel, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily = GetQuestLogTitle(i);
		if(questTitle) then
			if(isHeader) then
				if(collapsed[questTitle]) then
					CollapseQuestHeader(i);
				end
			end
		end
		i=i+1;
	end

	SelectQuestLogEntry(selected);

	for i,header in pairs(mobmap_queststatus) do	
		for k,quest in pairs(header.quests) do
			local notCompleted=false;
			for num,target in pairs(quest.targets) do
				if(not mobmap_questtracker_status.hidefinishedobjectives or not target.done) then
					if(not target.done and target.type~="MobMap") then notCompleted=true; end
				end
			end
			if(notCompleted==false) then
				quest.done=true;
			end
		end
	end
end

function MobMap_QuestTracker_PushCurrentZoneToTop()
	local zonename=GetRealZoneText();

	local k,header;
	for k,header in pairs(mobmap_queststatus) do
		header.movedToTop=nil;
	end
	for k,header in pairs(mobmap_queststatus) do
		if(header.title==zonename) then
			header.movedToTop=true;
			local temp=table.remove(mobmap_queststatus, k);
			table.insert(mobmap_queststatus, 1, temp);
			return;
		end
	end
end

function MobMap_QuestTracker_EnrichQuestDistances(localx, localy, localzonename)
	for i,header in pairs(mobmap_queststatus) do
		local headerMinDistance=999999;
		for k,quest in pairs(header.quests) do
			local minDistance=999999;
			for num,target in pairs(quest.targets) do
				local distance=nil;
				if(not target.done and target.extinfo and (target.extinfo.x>0 or target.extinfo.y>0) and target.extinfo.zoneid>0) then
					if(target.extinfo.inside) then
						distance=0;
					else
						distance=MobMap_QuestTracker_CalcDistanceToCoord(localx, localy, localzonename, target.extinfo.x/100, target.extinfo.y/100, MobMap_GetZoneName(target.extinfo.zoneid));
					end
				end
				if((quest.done or target.type~="MobMap") and distance and distance<minDistance and (target.type~="MobMap" or mobmap_questtracker_status.showadditionaltargets)) then
					minDistance=distance;
				end
				target.distance=distance;
			end
			if(minDistance==999999) then minDistance=nil; end
			quest.distance=minDistance;
			if(minDistance and minDistance<headerMinDistance) then
				headerMinDistance=minDistance;
			end
		end
		if(headerMinDistance==999999) then headerMinDistance=nil; end
		header.distance=headerMinDistance;
	end
end

function MobMap_QuestTracker_EnrichQuestPosData(localx, localy, localzonename)
	if(not (localx and localy and localzonename)) then return; end
	if(not MobMap_LoadDatabase(MOBMAP_DROP_DATABASE)) then return false; end;
	if(not MobMap_LoadDatabase(MOBMAP_PICKUP_DATABASE)) then return false; end;
	if(not MobMap_LoadDatabase(MOBMAP_PICKUP_QUEST_ITEM_DATABASE)) then return false; end;
	local roundedlocalx=math.floor(localx*100+0.5);
	local roundedlocaly=math.floor(localy*100+0.5);
	for i,header in pairs(mobmap_queststatus) do
		for k,quest in pairs(header.quests) do
			for l,target in pairs(quest.targets) do
				local extinfo=target.extinfo;
				if(extinfo and not extinfo.exact) then
					local positions=nil;
					local zonename=nil;
					if(extinfo.positions) then
						positions=extinfo.positions;
					else
						if(extinfo.type==1) then
							positions=MobMap_GetMobPositions(extinfo.id, extinfo.zoneid, extinfo.zonelevel);
						elseif(extinfo.type==2) then
							local droprates=MobMap_GetDropChances(extinfo.id);
							if(#droprates>0) then
								if(#droprates==1) then
									positions=MobMap_GetMobPositions(droprates[1].mobid, extinfo.zoneid, extinfo.zonelevel);
								else
									local nearestZone=nil;
									local nearestZoneDistance=0;
									local nearestMob=nil;
									for _, droprate in pairs(droprates) do										
										local zonelist=MobMap_GetMobZonesByMobID(droprate.mobid);
										if(zonelist) then
											for id, zone in pairs(zonelist) do
												local otherzonename=MobMap_GetZoneName(zone.id);
												if(localzonename==otherzonename) then
													distance=0;
												else
													distance=MobMap_QuestTracker_CalcDistanceToCoord(localx, localy, localzonename, 0.5, 0.5, otherzonename);
												end
												if(distance and (nearestZone==nil or distance<nearestZoneDistance) and (nearestZone==nil or zone.id~=nearestZone.id)) then
													nearestZoneDistance=distance;
													nearestZone=zone;
													nearestMob=droprate.mobid;
												end
											end
										end
									end
									if(nearestMob) then									
										positions=MobMap_GetMobPositions(nearestMob, nearestZone.id, nearestZone.level);
										extinfo.zoneid=nearestZone.id;
										extinfo.zonelevel=nearestZone.level;
									end
								end
							end
							if(positions==nil) then
								positions=MobMap_GetMobPositions(droprates[1].mobid, extinfo.zoneid, extinfo.zonelevel);
							end
						elseif(extinfo.type==3 or extinfo.type==4) then
							positions=MobMap_GetItemPositions(MOBMAP_PICKUP_TYPE_QUESTITEMS, extinfo.id, extinfo.zoneid, extinfo.zonelevel);
						elseif(extinfo.type==6) then
							positions=MobMap_GetQuestEventPositionsByEventID(extinfo.id, extinfo.zoneid, extinfo.zonelevel);
						elseif(extinfo.type==7) then
							positions=MobMap_GetMobPositions(extinfo.id, extinfo.zoneid, extinfo.zonelevel);
						elseif(extinfo.type==8) then
							positions=MobMap_GetQuestEventPositionsByEventID(extinfo.id, extinfo.zoneid, extinfo.zonelevel);
						end
						if(positions==nil) then positions={}; end
						extinfo.positions=positions;
					end
					if(positions and #positions>0) then
						local mindistance=999999;
						local minx=nil;
						local miny=nil;
						local inside=nil;
						for key,value in pairs(positions) do
							local x;
							for x=value.x1, value.x2, 1 do
								if(x==roundedlocalx and value.y==roundedlocaly) then
									inside=true;
									break;
								else
									local distance=MobMap_QuestTracker_CalcDistanceToCoord(localx, localy, localzonename, x/100, value.y/100, MobMap_GetZoneName(extinfo.zoneid));
									if(distance and distance<mindistance) then
										mindistance=distance;
										minx=x;
										miny=value.y;
									end
								end
							end							
						end
						extinfo.inside=inside;
						if(not inside) then
							if(mindistance<999999 and minx and miny) then
								extinfo.x=minx;
								extinfo.y=miny;
								if(mobmap_autocreated and mobmap_autocreated.questid==quest.blizzid and mobmap_autocreated.index==target.index) then
									local tomtomcrazyarrow=getglobal("TomTomCrazyArrow");
									if(not(tomtomcrazyarrow and tomtomcrazyarrow:IsVisible())) then
										mobmap_autocreated=nil;
										mobmap_autocreated_waypoint=nil;
									else
										MobMap_QuestTracker_UpdateAutoCreatedWaypoint(minx, miny);
									end
								end
							end
						else
							if(mobmap_autocreated and mobmap_autocreated.questid==quest.blizzid and mobmap_autocreated.index==target.index) then
								MobMap_QuestTracker_RemoveAutoCreatedWaypoint();
							end
						end
					end
				end
			end
		end
	end
end

function MobMap_QuestTracker_SortQuestsByDistance(force)
	local hasToReSort=false;
	if(force) then 
		hasToReSort=true;
	else
		local headerMaxDistance=0;
		for i,header in pairs(mobmap_queststatus) do
			local questMaxDistance=0;
			for k,quest in pairs(header.quests) do
				local targetMaxDistance=0;
				for num,target in pairs(quest.targets) do
					local distance=999999;
					if(not target.type=="MobMap") then
						if(target.distance) then distance=target.distance; end
						if(distance>=targetMaxDistance) then 
							targetMaxDistance=distance;
						else
							hasToReSort=true;
							break;
						end
					end
				end
				if(hasToReSort==true) then break; end
				local distance=999999;
				if(quest.distance) then distance=quest.distance; end
				if(distance>=questMaxDistance) then
					questMaxDistance=distance;
				else
					hasToReSort=true;
					break;
				end
			end
			if(hasToReSort==true) then break; end
			local distance=999999;
			if(not header.movedToTop) then
				if(header.distance) then distance=header.distance; end
				if(distance>=headerMaxDistance) then
					headerMaxDistance=distance;
				else
					hasToReSort=true;
					break;
				end
			end
		end
	end

	if(hasToReSort) then
		table.sort(mobmap_queststatus,MobMap_QuestTracker_SortDistanceComparator);
		for i,header in pairs(mobmap_queststatus) do
			table.sort(header.quests,MobMap_QuestTracker_SortDistanceComparator);
			for k,quest in pairs(header.quests) do
				table.sort(quest.targets,MobMap_QuestTracker_SortDistanceComparator);
			end
		end
		MobMap_QuestTracker_PushCurrentZoneToTop();
	end
	return hasToReSort;
end

function MobMap_QuestTracker_SortDistanceComparator(o1, o2)
	local distance1=o1.distance;
	local distance2=o2.distance;
	if(o1.type=="MobMap") then distance1=1000000; end
	if(o2.type=="MobMap") then distance2=1000000; end
	if(o1.type and o1.done) then distance1=1000010+o1.index; end
	if(o2.type and o2.done) then distance2=1000010+o2.index; end
	if(distance1==nil) then distance1=999999; end
	if(distance2==nil) then distance2=999999; end
	return (distance1<distance2);
end

function MobMap_QuestTracker_EnrichQuestStatus()
	local k,quests,quest,target;
	for k,quests in pairs(mobmap_queststatus) do
		for k,quest in pairs(quests.quests) do
			local targets=MobMap_GetQuestTargets(quest.blizzid);
			for k,target in pairs(targets) do
				if(target.type~=7 and target.type~=8) then
					if(k<=table.getn(quest.targets)) then
						quest.targets[k].extinfo=target;
						if(target.type==1 or target.type==2 or target.type==3 or target.type==4) then
							local found, _, count = string.find(quest.targets[k].text, "^.*: %d+/(%d+)$");
							target.count=tonumber(count);
						end
						if(not target.count) then target.count=0; end
					end
				else
					if(mobmap_questtracker_status.showadditionaltargets) then
						local name="";
						if(target.type==7) then
							name=MobMap_GetMobName(target.id);
						elseif(target.type==8) then
							local eventtext=MobMap_GetQuestEventTextByID(target.id);
							local found, _, objectname = string.find(eventtext, "^.+: (.*)$");
							if(not objectname) then objectname="???"; end
							name=objectname;
						end
						table.insert(quest.targets, {text=MOBMAP_QUEST_TARGETS_END_PART1..name..MOBMAP_QUEST_TARGETS_END_PART2, type="MobMap", done=nil, quest=quest, extinfo=target});
					end
				end
			end
		end
	end
end

function MobMap_QuestTracker_ExpandGroup(header)
	local i=1;
	while(i<=GetNumQuestLogEntries()) do
		local questTitle, questLevel, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily = GetQuestLogTitle(i);
		if(questTitle) then
			if(isHeader) then
				if(questTitle==header) then
					ExpandQuestHeader(i);
					break;
				end
			end
		end
		i=i+1;
	end
	MobMap_QuestTracker_FullUpdate();
end

function MobMap_QuestTracker_CollapseGroup(header)
	local i=1;
	while(i<=GetNumQuestLogEntries()) do
		local questTitle, questLevel, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily = GetQuestLogTitle(i);
		if(questTitle) then
			if(isHeader) then
				if(questTitle==header) then
					CollapseQuestHeader(i);
					break;
				end
			end
		end
		i=i+1;
	end
	MobMap_QuestTracker_FullUpdate();
end

mobmap_autocreated=nil;
mobmap_autocreated_waypoint=nil;

function MobMap_QuestTracker_ShowTargetInfo(self)
	local wp_x;
	local wp_y;
	local wp_zone;
	local wp_text;
	local map_was_shown=WorldMapFrame:IsVisible();
	mobmap_questsearch=true;
	if(self.data.extinfo) then
		wp_x=self.data.extinfo.x;
		wp_y=self.data.extinfo.y;
		wp_zone=MobMap_GetZoneName(self.data.extinfo.zoneid);
		if(self.data.extinfo.type==1) then
			if(not MobMap_LoadDatabase(MOBMAP_POSITION_DATABASE)) then return false; end;
			MobMap_ShowMobByID(self.data.extinfo.id);
			if(self.data.extinfo.count>1) then
				wp_text=MOBMAP_QUEST_TRACKER_OBJ_1..self.data.extinfo.count.." "..MobMap_GetMobName(self.data.extinfo.id);
			else
				wp_text=MOBMAP_QUEST_TRACKER_OBJ_1..MobMap_GetMobName(self.data.extinfo.id);
			end
		elseif(self.data.extinfo.type==7) then
			if(not MobMap_LoadDatabase(MOBMAP_POSITION_DATABASE)) then return false; end;
			MobMap_ShowMobByID(self.data.extinfo.id);
			wp_text=MOBMAP_QUEST_TRACKER_OBJ_7_1_a..self.data.quest.title..MOBMAP_QUEST_TRACKER_OBJ_7_1_b..MobMap_GetMobName(self.data.extinfo.id)..MOBMAP_QUEST_TRACKER_OBJ_7_1_c;
		elseif(self.data.extinfo.type==8) then
			if(not MobMap_LoadDatabase(MOBMAP_POSITION_DATABASE)) then return false; end;
			MobMap_DoQuestEventSearchByID(self.data.extinfo.id);
			local eventtext=MobMap_GetQuestEventTextByID(self.data.extinfo.id);
			local found, _, objectname = string.find(eventtext, "^.+: (.*)$");
			if(not objectname) then objectname="???"; end
			wp_text=MOBMAP_QUEST_TRACKER_OBJ_7_1_a..self.data.quest.title..MOBMAP_QUEST_TRACKER_OBJ_7_1_b..objectname..MOBMAP_QUEST_TRACKER_OBJ_7_1_c;
		elseif(self.data.extinfo.type==2) then
			if(not MobMap_LoadDatabase(MOBMAP_DROP_DATABASE)) then return false; end;
			MobMap_ShowItemDropRateByID(self.data.extinfo.id, self.data.extinfo.zoneid);
			if(mobmap_dropchancelist==nil or table.getn(mobmap_dropchancelist)==0) then
				wp_text=MOBMAP_QUEST_TRACKER_OBJ_2_a..self.data.extinfo.count.." "..MobMap_GetItemNameByIHID(self.data.extinfo.id);
			else
				local mobs="";
				local count=0;
				for k,v in pairs(mobmap_dropchancelist) do
					if(mobs~="") then mobs=mobs..", "; end
					if(count>3) then
						mobs=mobs.."...";
						break;
					end
					count=count+1;
					mobs=mobs..MobMap_GetMobName(v.mobid);
				end
				wp_text=MOBMAP_QUEST_TRACKER_OBJ_2_a..self.data.extinfo.count.." "..MobMap_GetItemNameByIHID(self.data.extinfo.id)..MOBMAP_QUEST_TRACKER_OBJ_2_b..mobs;
			end
		elseif(self.data.extinfo.type==3) then
			if(not MobMap_LoadDatabase(MOBMAP_PICKUP_DATABASE)) then return false; end;
			if(not MobMap_LoadDatabase(MOBMAP_PICKUP_QUEST_ITEM_DATABASE)) then return false; end;
			MobMap_ShowQuestItemPickupSpotsByID(self.data.extinfo.id);
			wp_text=MOBMAP_QUEST_TRACKER_OBJ_3..self.data.extinfo.count.." "..MobMap_GetItemNameByIHID(self.data.extinfo.id);
		elseif(self.data.extinfo.type==4) then
			if(not MobMap_LoadDatabase(MOBMAP_PICKUP_DATABASE)) then return false; end;
			if(not MobMap_LoadDatabase(MOBMAP_PICKUP_QUEST_ITEM_DATABASE)) then return false; end;
			MobMap_ShowQuestItemPickupSpotsByID(self.data.extinfo.id);
			wp_text=MOBMAP_QUEST_TRACKER_OBJ_3..self.data.extinfo.count.." "..MobMap_GetItemNameByIHID(self.data.extinfo.id)..MOBMAP_QUEST_TRACKER_OBJ_4;
		elseif(self.data.extinfo.type==6) then
			if(not MobMap_LoadDatabase(MOBMAP_POSITION_DATABASE)) then return false; end;
			MobMap_DoQuestEventSearchByID(self.data.extinfo.id);
			wp_text=MobMap_GetQuestEventTextByID(self.data.extinfo.id);
		else
			MobMap_ParseQuestObjective(self.data.text);
		end
	else
		MobMap_ParseQuestObjective(self.data.text);
	end
	MobMap_SelectQuestPOIOnMap(self.blizzid);
	if(mobmap_autocreate_waypoints and wp_x and wp_y and wp_zone and wp_text and not self.data.extinfo.inside) then
		MobMap_QuestTracker_CreateWaypoint(wp_x, wp_y, wp_zone, wp_text);
		mobmap_autocreated={index=self.data.index, questid=self.data.quest.blizzid, x=wp_x, y=wp_y, zonename=wp_zone, text=wp_text};
		if(not map_was_shown and mobmap_quicksearch_omit_map) then
			WorldMapFrame:Hide();
		end
	end
	mobmap_questsearch=false;
end

function MobMap_QuestTracker_CreateWaypoint(xcoord, ycoord, zonename, text)
	if(TomTom) then
		MobMap_QuestTracker_RemoveAutoCreatedWaypoint();
		local zoneindex=mobmap_zoneindex[zonename];
		if(zoneindex) then
			mobmap_autocreated_waypoint=TomTom:AddZWaypoint(zoneindex.c, zoneindex.z, xcoord, ycoord, text);
			TomTom:SetCrazyArrow(mobmap_autocreated_waypoint, TomTom.profile.arrow.arrival, text);
			return;
		end
	elseif(Cartographer_Waypoints and Cartographer:IsModuleActive(Cartographer_Waypoints)) then 
		local zoneindex=mobmap_zoneindex[zonename];
		if(zoneindex) then
			Cartographer_Waypoints:AddLHWaypoint(zoneindex.c, zoneindex.z, xcoord, ycoord, text);
			Cartographer_Waypoints:UpdateWaypoint();
		end
	end
end

function MobMap_QuestTracker_RemoveAutoCreatedWaypoint()
	if(mobmap_autocreated_waypoint) then
		TomTom:RemoveWaypoint(mobmap_autocreated_waypoint);
		mobmap_autocreated_waypoint=nil;
		mobmap_autocreated=nil;
	end
end

function MobMap_QuestTracker_UpdateAutoCreatedWaypoint(xcoord, ycoord)
	if(not (TomTom and mobmap_autocreated_waypoint and mobmap_autocreated and (mobmap_autocreated.x~=xcoord or mobmap_autocreated.y~=ycoord))) then return; end
	TomTom:RemoveWaypoint(mobmap_autocreated_waypoint);
	local zoneindex=mobmap_zoneindex[mobmap_autocreated.zonename];
	if(zoneindex) then
		mobmap_autocreated_waypoint=TomTom:AddZWaypoint(zoneindex.c, zoneindex.z, xcoord, ycoord, mobmap_autocreated.text);
		mobmap_autocreated.x=xcoord;
		mobmap_autocreated.y=ycoord;
		TomTom:SetCrazyArrow(mobmap_autocreated_waypoint, TomTom.profile.arrow.arrival, mobmap_autocreated.text);
	end
end

function MobMap_QuestTracker_ResetTrackerPos()
	MobMapQuestTrackerFrame:ClearAllPoints();
	MobMapQuestTrackerFrame:SetPoint("TOPRIGHT", "UIParent", "TOPRIGHT", -80, -220);
	mobmap_questtracker_status.width=300;
	mobmap_questtracker_status.height=360;
	MobMap_QuestTracker_FullUpdate();
end

function MobMap_QuestTracker_ShowQuestLogEntry(index)
	QuestLog_OpenToQuest(index);
end

function MobMap_QuestTracker_CalcDistanceToCoord(localx, localy, localzonename, x, y, zonename)
	local localzoneindex=mobmap_zoneindex[localzonename];
	local zoneindex=mobmap_zoneindex[zonename];
	if(localzoneindex and zoneindex) then
		return mobmap_astrolabe_library:ComputeDistance(localzoneindex.c, localzoneindex.z, localx, localy, zoneindex.c, zoneindex.z, x, y); 
	end
	return nil;
end

function MobMap_QuestTracker_ShowQuestObjectiveTooltip(self, blizzid)
	if(self.shorttext) then
		MobMapQuestTooltip:ClearAllPoints();
		MobMapQuestTooltip:SetOwner(self, "ANCHOR_CURSOR");
		MobMapQuestTooltip:ClearLines();
		MobMapQuestTooltip:AddLine(self.title, nil, nil, nil, nil, 1);
		MobMapQuestTooltip:AddLine(self.shorttext, 1.0, 1.0, 1.0, 1.0, 1);
		if(table.getn(self.partyMembers)>0) then
			for i=1,table.getn(self.partyMembers) do
				MobMapQuestTooltip:AddLine(LIGHTYELLOW_FONT_COLOR_CODE..self.partyMembers[i]..FONT_COLOR_CODE_CLOSE);
			end
		end
		MobMapQuestTooltip:Show();
	end
end