-- position database functions

function MobMap_GetMobPositions(mobid, zoneid, zonelevel)
	if(mobmap_mobs[mobid]==nil) then return nil; end
	local mobpointer=MobMap_GetMobPointer(mobid);
	local minlevel, maxlevel, zonecount = MobMap_GetMobDetails(mobpointer);
	local i;
	for i=1, zonecount, 1 do
		local zonecode, level, length, pointer = MobMap_GetPointerToPositionData(mobpointer+i);
		if(zonecode==zoneid and level==zonelevel) then
			return MobMap_GetCoordPairsFromDB(pointer,length,mobmap_data);
		end
	end
	return nil;
end

function MobMap_GetCoordPairsFromDB(position, length, coordDB)
	local i;
	local coords={};
	local xo,yo;
	for i=0, length-1, 1 do
		local xc,yc=MobMap_GetCoordFromDB(position+i, coordDB)
		if(i%2==0) then
			xo=xc;
			yo=yc;
		else
			table.insert(coords, {x1=xo, x2=xc, y=yo});
		end
	end
	return coords;
end

function MobMap_GetCoordFromDB(position, coordDB)
	if(coordDB==nil) then coordDB=mobmap_data; end
	local bucket=floor(position/4)+1;
	local data=coordDB[bucket];
	if(data==nil) then return nil; end
	local x;
	local y=0;
	x=floor(data/(mobmap_shiftconst[(position%4)*2])+0.5);
	if(position%2==0) then y=floor(data/(mobmap_shiftconst[(position%4)*2+1])+0.5); end
	x=x%256;
	y=y%256;
	return x,y;
end

-- quest event database functions

function MobMap_GetQuestEventPositions(pointer, length)
	return MobMap_GetCoordPairsFromDB(pointer, length, mobmap_questeventdata);
end

function MobMap_GetQuestEventPositionsByEventID(eventid, zoneid, zonelevel)
	local length, pointer=MobMap_GetQuestEventZoneDetails(eventid, zoneid, zonelevel);
	if(length and pointer) then
		return MobMap_GetQuestEventPositions(pointer, length);
	end
	return nil;
end

-- user interface functions

mobmap_mobid_currentlyshown = nil;

function MobMap_UpdateMobMapFrame()
	local offset=FauxScrollFrame_GetOffset(MobMapMobSearchFrameMobListScrollFrame);
	local mobcount=table.getn(mobmap_currentlist);
	local maxmobcount=16+math.floor((mobmap_window_height-448)/18);
	MobMapMobSearchFrameMobHighlightFrame:Hide();
	for i=1,36,1 do
		local mobindex=i+offset;
		local frame=getglobal("MobMapMob"..i);
		if(mobmap_currentlist[mobindex]~=nil and i<maxmobcount) then
			frame:Show();
			frame:SetText(mobmap_currentlist[mobindex].name);
			frame.subtitle=mobmap_currentlist[mobindex].sub;
			frame.mobid=mobmap_currentlist[mobindex].mobid;
			frame:Enable();
			if(mobmap_mobid_currentlyshown==frame.mobid) then
				MobMapMobSearchFrameMobHighlightFrame:Show();
				MobMapMobSearchFrameMobHighlightFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0);
				MobMapMobSearchFrameMobHighlightFrame:SetAlpha(0.5);
				MobMapHighlight:SetVertexColor(1.0, 1.0, 1.0);
			end
		else
			frame:Hide();
		end
	end
	if(mobmap_currentlist[1]==nil and string.sub(MobMapMobSearchFrameSearchBox:GetText(),1,3)~="id:") then
		MobMapMob1:SetText(MOBMAP_NO_MOBS_FOUND);
		MobMapMob1:Disable();
		MobMapMob1:Show();
		MobMap_UpdateZoneList();
	end

	FauxScrollFrame_Update(MobMapMobSearchFrameMobListScrollFrame, mobcount+1, maxmobcount, 22);
end

function MobMap_UpdateFilter(text, subtitle, zone)
	local maxmobcount=15+math.floor((mobmap_window_height-430)/18);
	mobmap_currentlist = {};
	local filtertext;
	local exactmatch;
	if(string.sub(text,1,1)=="\"" and string.sub(text,-1)=="\"") then
		exactmatch=true;
		filtertext=string.sub(text,2,string.len(text)-1);
	else
		filtertext=text;
		exactmatch=false;
	end
	local zoneid=-1;
	if(zone~="") then zoneid=MobMap_GetZoneID(zone); end
	if(string.sub(text,1,3)=="id:" and string.find(text, ",")) then
		mobmap_currentlyshown=nil;
		mobmap_currentlist={};
		mobmap_multidisplay={};
		text=string.sub(text,4);
		for w in string.gmatch(text, "%d*") do
			if(tonumber(w)~=nil) then
				table.insert(mobmap_multidisplay,{id=tonumber(w)});
			end
		end
		if(table.getn(mobmap_multidisplay)==0) then 
			mobmap_multidisplay=nil; 
		else
			MobMap_UpdatePositions();
			MobMap_SwitchMapAndDisplay();
		end
	else
		local idmatch=nil;
		if(string.sub(text,1,3)=="id:") then
			idmatch=tonumber(string.sub(text, 4));
		end
		if(mobmap_multidisplay~=nil) then
			mobmap_multidisplay=nil;
			MobMap_HideAllDots();
		end
		if(exactmatch==false) then
			filtertext=MobMap_PatternEscape(filtertext);
			subtitle=MobMap_PatternEscape(subtitle);
		end
		--if(exactmatch==true and subtitle=="") then
		--	local mobid=MobMap_GetIDForMobName(filtertext);
		--	if(mobid) then
		--		if(zoneid==-1 or MobMap_CheckIfMobIsInZone(mobid, zoneid)==true) then
		--			local part1,part2=MobMap_GetMobNameAndSubtitle(MobMap_GetMobFullName(mobid));
		--			table.insert(mobmap_currentlist,{name=part1, sub=part2, mobid=mobid});
		--		end
		--	end
		--else
		if(idmatch and idmatch>0 and idmatch<=MobMap_GetMobCount()) then		
			local part1,part2=MobMap_GetMobNameAndSubtitle(mobmap_mobs[idmatch]);
			table.insert(mobmap_currentlist,{name=part1, sub=part2, mobid=idmatch});
		else
			for k,v in pairs(mobmap_mobs) do
				local part1,part2=MobMap_GetMobNameAndSubtitle(v);
				if((exactmatch==false and string.find(string.lower(part1),".-"..string.lower(filtertext)..".-")~=nil) or (exactmatch==true and string.lower(part1)==string.lower(filtertext))) then
					if((part2==nil and subtitle=="") or (part2~=nil and string.find(string.lower(part2),".-"..string.lower(subtitle)..".-")~=nil)) then
						if(zoneid==-1 or MobMap_CheckIfMobIsInZone(k, zoneid)==true) then
							table.insert(mobmap_currentlist,{name=part1, sub=part2, mobid=k})
						end
					end
				end
			end
		end
		--end
	end
	MobMap_UnsetMob();
	MobMap_UpdateMobMapFrame();
	if(table.getn(mobmap_currentlist)==1) then
		MobMapButton_ProcessClick("MobMapMob1");
	else
		mobmap_zonelist={};
		MobMap_UpdateZoneList();
	end
end

function MobMapButton_OnClick(self)
	MobMapButton_ProcessClick(self:GetName());
end

function MobMapButton_ProcessClick(button)
	local frame=getglobal(button);
	MobMapMobSearchFrameMobHighlightFrame:Show();
	MobMapMobSearchFrameMobHighlightFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0);
	MobMapMobSearchFrameMobHighlightFrame:SetAlpha(0.5);
	MobMapHighlight:SetVertexColor(1.0, 1.0, 1.0);
	MobMapMobSearchFrameSelectionDetails:Show();
	MobMapMobSearchFrameSelectionDetailsName:SetText(frame:GetText());
	if(frame.subtitle~=nil) then
		MobMapMobSearchFrameSelectionDetailsSubtitle:SetText(frame.subtitle);
		MobMapMobSearchFrameSelectionDetails.mobfullname=frame:GetText().."|"..frame.subtitle;
		MobMapMobSearchFrameSelectionDetails.mobid=frame.mobid;
	else
		MobMapMobSearchFrameSelectionDetailsSubtitle:SetText("");
		MobMapMobSearchFrameSelectionDetails.mobfullname=frame:GetText();
		MobMapMobSearchFrameSelectionDetails.mobid=frame.mobid;
	end
	mobmap_mobid_currentlyshown=frame.mobid;
	local pointer=MobMap_GetMobPointer(frame.mobid);
	if(pointer==nil) then return; end
	local minlevel, maxlevel, zonecount = MobMap_GetMobDetails(pointer);
	if(minlevel~=maxlevel) then
		MobMapMobSearchFrameSelectionDetailsLevel:SetText(MOBMAP_LEVEL..minlevel.." - "..maxlevel);
	else
		if(minlevel==0) then
			MobMapMobSearchFrameSelectionDetailsLevel:SetText(MOBMAP_BOSS_LEVEL);
		else
			MobMapMobSearchFrameSelectionDetailsLevel:SetText(MOBMAP_LEVEL..minlevel);
		end
	end
	mobmap_zonelist={};
	local zonelist=MobMap_GetMobZones(pointer);
	for k,v in pairs(zonelist) do
		local zonename=MobMap_GetZoneName(v.id);
		table.insert(mobmap_zonelist,{name=zonename, id=v.id, level=v.level});
	end
	MobMap_UnsetZone();
	MobMap_UpdateZoneList();
end

function MobMap_UpdateZoneList()
	local maxzonecount=13+math.floor((mobmap_window_height-430)/18);
	local zones=table.getn(mobmap_zonelist);
	local offset=FauxScrollFrame_GetOffset(MobMapMobSearchFrameZoneListScrollFrame);

	for i=1,35,1 do
		local zoneindex=i+offset;
		local frame=getglobal("MobMapZone"..i);
		if(zoneindex>zones or i>maxzonecount) then
			frame:Hide();
		else
			if(mobmap_zonelist[zoneindex].level>0) then
				frame:SetText(mobmap_zonelist[zoneindex].name.." ("..mobmap_zonelist[zoneindex].level..")");
			else
				frame:SetText(mobmap_zonelist[zoneindex].name);
			end
			frame.id=mobmap_zonelist[zoneindex].id;
			frame.level=mobmap_zonelist[zoneindex].level;
			frame.zonename=mobmap_zonelist[zoneindex].name;
			frame:Show();
		end
	end

	FauxScrollFrame_Update(MobMapMobSearchFrameZoneListScrollFrame, zones, maxzonecount, 22);

	if(zones==1) then
		if(mobmap_questsearch) then 
			mobmap_questsearch=false;
			HideUIPanel(MobMapFrame);
		end
		MobMapZoneButton_ProcessClick("MobMapZone1");
	elseif(zones>1) then
		if(mobmap_questsearch) then
			local currentZone=GetRealZoneText();
			for i=1,35,1 do
				if(i<=zones and getglobal("MobMapZone"..i).zonename==currentZone) then
					MobMapZoneButton_ProcessClick("MobMapZone"..i);
					mobmap_questsearch=false;
					return;
				end
			end
			MobMapZoneButton_ProcessClick("MobMapZone1");
			mobmap_questsearch=false;
			return;
		end
		if(not MobMapFrame:IsVisible()) then ShowUIPanel(MobMapFrame); end
		if(MobMapMobSearchFrame~=nil and not MobMapMobSearchFrame:IsVisible()) then MobMap_ShowPanel("MobMapMobSearchFrame"); end
	end	
end

function MobMapZoneButton_OnClick(self)
	MobMapZoneButton_ProcessClick(self:GetName());
end

function MobMapZoneButton_ProcessClick(button)
	local frame=getglobal(button);
	MobMapZoneHighlightFrame:Show();
	MobMapZoneHighlightFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0);
	MobMapZoneHighlightFrame:SetAlpha(0.5);
	MobMapZoneHighlight:SetVertexColor(1.0, 1.0, 1.0);
	mobmap_multidisplay=nil;
	mobmap_currentlyshown={zonename=frame.zonename, zoneid=frame.id, zonelevel=frame.level, mobname=MobMapMobSearchFrameSelectionDetailsName:GetText(), mobfullname=MobMapMobSearchFrameSelectionDetails.mobfullname, mobid=MobMapMobSearchFrameSelectionDetails.mobid};
	mobmap_enabled=true;
	MobMapCheckButton:SetChecked(true);
	MobMap_SwitchMapAndDisplay();
end

function MobMap_ShowMobByID(mobid)
	if(mobid==nil) then return; end
	MobMap_DisplayDebugMessage("MobMap_ShowMobByID("..mobid..")");
	MobMap_ShowPanel("MobMapMobSearchFrame");
	MobMapMobSearchFrameSearchBox:SetText("id: "..mobid.."");
	MobMapMobSearchFrameSubtitleSearchBox:SetText("");
	MobMapMobSearchFrameZoneSearchBox:SetText("");
	mobmap_mobsearchframe_oldtext1=MobMapMobSearchFrameSearchBox:GetText();
	mobmap_mobsearchframe_oldtext2=MobMapMobSearchFrameSubtitleSearchBox:GetText();
	mobmap_mobsearchframe_oldtext3=MobMapMobSearchFrameZoneSearchBox:GetText();
	MobMap_UpdateFilter(MobMapMobSearchFrameSearchBox:GetText(),MobMapMobSearchFrameSubtitleSearchBox:GetText(),MobMapMobSearchFrameZoneSearchBox:GetText());
end

function MobMap_ShowMobByName(mobname)
	if(mobname==nil) then return; end
	MobMap_DisplayDebugMessage("MobMap_ShowMobByName("..mobname..")");
	MobMap_ShowPanel("MobMapMobSearchFrame");
	MobMapMobSearchFrameSearchBox:SetText("\""..mobname.."\"");
	MobMapMobSearchFrameSubtitleSearchBox:SetText("");
	MobMapMobSearchFrameZoneSearchBox:SetText("");
	mobmap_mobsearchframe_oldtext1=MobMapMobSearchFrameSearchBox:GetText();
	mobmap_mobsearchframe_oldtext2=MobMapMobSearchFrameSubtitleSearchBox:GetText();
	mobmap_mobsearchframe_oldtext3=MobMapMobSearchFrameZoneSearchBox:GetText();
	MobMap_UpdateFilter(MobMapMobSearchFrameSearchBox:GetText(),MobMapMobSearchFrameSubtitleSearchBox:GetText(),MobMapMobSearchFrameZoneSearchBox:GetText());
end

function MobMap_ShowMultipleMobs(idlist,caption,preferredzone,preferredzonelevel)
	local searchtext="id:";
	for i=1,table.getn(idlist),1 do
		searchtext=searchtext..idlist[i];
		if(i<table.getn(idlist)) then
			searchtext=searchtext..",";
		end
	end
	mobmap_multidisplay_preferredzone=nil;
	if(preferredzone and preferredzonelevel) then
		local zoneid=MobMap_GetZoneID(preferredzone);
		if(zoneid) then
			mobmap_multidisplay_preferredzone={id=zoneid, level=preferredzonelevel};
		end
	end
	mobmap_multidisplay_caption=caption;
	MobMapMobSearchFrameSearchBox:SetText(searchtext);
	MobMapMobSearchFrameSubtitleSearchBox:SetText("");
	MobMapMobSearchFrameZoneSearchBox:SetText("");
	mobmap_mobsearchframe_oldtext1=MobMapMobSearchFrameSearchBox:GetText();
	mobmap_mobsearchframe_oldtext2=MobMapMobSearchFrameSubtitleSearchBox:GetText();
	mobmap_mobsearchframe_oldtext3=MobMapMobSearchFrameZoneSearchBox:GetText();
	MobMap_UpdateFilter(MobMapMobSearchFrameSearchBox:GetText(),MobMapMobSearchFrameSubtitleSearchBox:GetText(),MobMapMobSearchFrameZoneSearchBox:GetText());
end

-- MobMapMobSearchFrame event handlers

mobmap_mobsearchframe_oldtext1="";
mobmap_mobsearchframe_oldtext2="";
mobmap_mobsearchframe_oldtext3="";
mobmap_mobsearchframe_timeout=0;

function MobMapMobSearchFrame_OnShow()
	mobmap_mobsearchframe_oldtext1=MobMapMobSearchFrameSearchBox:GetText();
	mobmap_mobsearchframe_oldtext2=MobMapMobSearchFrameSubtitleSearchBox:GetText();
	mobmap_mobsearchframe_timeout=-1;
end

function MobMapMobSearchFrame_OnUpdate()
	if(MobMapMobSearchFrameSearchBox:GetText()~=mobmap_mobsearchframe_oldtext1 or MobMapMobSearchFrameSubtitleSearchBox:GetText()~=mobmap_mobsearchframe_oldtext2 or MobMapMobSearchFrameZoneSearchBox:GetText()~=mobmap_mobsearchframe_oldtext3) then
		mobmap_mobsearchframe_oldtext1=MobMapMobSearchFrameSearchBox:GetText();
		mobmap_mobsearchframe_oldtext2=MobMapMobSearchFrameSubtitleSearchBox:GetText();
		mobmap_mobsearchframe_oldtext3=MobMapMobSearchFrameZoneSearchBox:GetText();
		mobmap_mobsearchframe_timeout=1.0;
	end
	if(mobmap_mobsearchframe_timeout==-1) then return; end
	if(mobmap_mobsearchframe_timeout<0) then
		MobMap_UpdateFilter(MobMapMobSearchFrameSearchBox:GetText(),MobMapMobSearchFrameSubtitleSearchBox:GetText(),MobMapMobSearchFrameZoneSearchBox:GetText());
		mobmap_mobsearchframe_timeout=-1;
	else
		mobmap_mobsearchframe_timeout=mobmap_mobsearchframe_timeout-arg1;
	end
end

mobmap_pzf_notextchanged=0;
mobmap_pzf_textlen=0;
mobmap_pzf_marklen=0;

function MobMap_PositionZoneFilter_OnTextChanged()
	if(mobmap_pzf_notextchanged==1 or mobmap_pzf_textlen==string.len(MobMapMobSearchFrameZoneSearchBox:GetText())+1 or mobmap_pzf_textlen==string.len(MobMapMobSearchFrameZoneSearchBox:GetText())+mobmap_pzf_marklen) then
		mobmap_pzf_notextchanged=0;
		mobmap_pzf_textlen=string.len(MobMapMobSearchFrameZoneSearchBox:GetText());
	else
		local text=MobMapMobSearchFrameZoneSearchBox:GetText();
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
			mobmap_pzf_notextchanged=1;
			mobmap_pzf_textlen=string.len(match);
			MobMapMobSearchFrameZoneSearchBox:SetText(match);
			if(string.len(match)>textlen) then MobMapMobSearchFrameZoneSearchBox:HighlightText(textlen,string.len(match)); end
			mobmap_pzf_marklen=string.len(match)-textlen;
		end
	end
end

-- quest event stuff

mobmap_questeventframe_oldtext="";
mobmap_questeventframe_timeout=0;

function MobMapQuestEventFrame_OnShow()
	mobmap_questeventframe_oldtext=MobMapQuestEventFrameSearchBox:GetText();
	mobmap_questeventframe_timeout=-1;
end

function MobMapQuestEventFrame_OnUpdate()
	if(MobMapQuestEventFrameSearchBox:GetText()~=mobmap_questeventframe_oldtext) then
		mobmap_questeventframe_oldtext=MobMapQuestEventFrameSearchBox:GetText();
		mobmap_questeventframe_timeout=1.0;
	end
	if(mobmap_questeventframe_timeout==-1) then return; end
	if(mobmap_questeventframe_timeout<0) then
		MobMap_UpdateQuestEventFilter(MobMapQuestEventFrameSearchBox:GetText());
		mobmap_questeventframe_timeout=-1;
	else
		mobmap_questeventframe_timeout=mobmap_questeventframe_timeout-arg1;
	end
end

function MobMap_GetQuestEventTextByID(id)
	return mobmap_questevents[id];
end

mobmap_questevent_currentlist = {};
mobmap_questevent_currentevent = nil;

function MobMap_UpdateQuestEventFilter(text)
	mobmap_questevent_currentlist = {};
	local filtertext;
	local exactmatch;
	if(string.sub(text,1,1)=="\"" and string.sub(text,-1)=="\"") then
		exactmatch=true;
		filtertext=string.sub(text,2,string.len(text)-1);
	else
		filtertext=text;
		exactmatch=false;
	end
	if(exactmatch==false) then
		filtertext=MobMap_PatternEscape(filtertext);
	end
	local idtofind=nil;
	if(string.sub(text,1,3)=="id:") then
		 idtofind=tonumber(string.sub(text,4));
	end
	if(idtofind and mobmap_questevents[idtofind]) then
		table.insert(mobmap_questevent_currentlist,{text=mobmap_questevents[idtofind], id=idtofind});
	else
		if(exactmatch==true) then
			local eventid=MobMap_GetQuestEventIDs(filtertext);
			if(eventid) then
				for k,v in pairs(eventid) do
					local eventtext=mobmap_questevents[v];
					table.insert(mobmap_questevent_currentlist,{text=eventtext, id=v});
				end
			end
		else
			for k,v in pairs(mobmap_questevents) do
				local eventtext=v;
				if(string.find(string.lower(eventtext),".-"..string.lower(filtertext)..".-")~=nil) then
					table.insert(mobmap_questevent_currentlist,{text=eventtext, id=k});
				end
			end
		end
	end
	--MobMap_UnsetMob();
	MobMap_UpdateQuestEventFrame();
	--if(table.getn(mobmap_questevent_currentlist)==1) then
	--	MobMapButton_ProcessClick("MobMapMob1");
	--else
	--	mobmap_zonelist={};
	--	MobMap_UpdateZoneList();
	--end
end

function MobMap_UpdateQuestEventFrame()
	local offset=FauxScrollFrame_GetOffset(MobMapQuestEventFrameEventListScrollFrame);
	local eventcount=table.getn(mobmap_questevent_currentlist);
	local maxeventcount=10+math.floor((mobmap_window_height-430)/18);
	MobMapQuestEventFrameEventHighlightFrame:Hide();
	for i=1,32,1 do
		local eventindex=i+offset;
		local frame=getglobal("MobMapQuestEventFrameEvent"..i);
		if(mobmap_questevent_currentlist[eventindex]~=nil and i<maxeventcount) then
			frame:Show();
			frame:SetText(mobmap_questevent_currentlist[eventindex].text);
			frame.id=mobmap_questevent_currentlist[eventindex].id;
			frame:Enable();
			if(mobmap_questevent_currentevent==frame.id) then
				MobMapQuestEventFrameEventHighlightFrame:Show();
				MobMapQuestEventFrameEventHighlightFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0);
				MobMapQuestEventFrameEventHighlightFrame:SetAlpha(0.5);
				MobMapQuestEventFrameEventHighlightFrameHighlight:SetVertexColor(1.0, 1.0, 1.0);
			end
		else
			frame:Hide();
		end
	end
	if(mobmap_questevent_currentlist[1]==nil) then
		MobMapQuestEventFrameEvent1:SetText(MOBMAP_NO_EVENTS_FOUND);
		MobMapQuestEventFrameEvent1:Disable();
		MobMapQuestEventFrameEvent1:Show();
		--MobMap_UpdateZoneList();
	end
	FauxScrollFrame_Update(MobMapQuestEventFrameEventListScrollFrame, eventcount+1, maxeventcount, 22);
	if(eventcount==1) then
		if(mobmap_questsearch) then 
			HideUIPanel(MobMapFrame); 
			mobmap_questsearch=false;
		end
		MobMapEventButton_ProcessClick(getglobal("MobMapQuestEventFrameEvent1"));
	else
		if(not MobMapFrame:IsVisible()) then ShowUIPanel(MobMapFrame); end
		if(MobMapQuestEventFrame~=nil and not MobMapQuestEventFrame:IsVisible()) then MobMap_ShowPanel("MobMapQuestEventFrame"); end
	end
end

mobmap_questeventzones_currentlist = {};
mobmap_questeventzones_currentevent = nil;

function MobMapEventButton_OnClick(self)
	MobMapEventButton_ProcessClick(self);
end

function MobMapEventButton_ProcessClick(frame)
	MobMapQuestEventFrameEventHighlightFrame:Show();
	MobMapQuestEventFrameEventHighlightFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0);
	MobMapQuestEventFrameEventHighlightFrame:SetAlpha(0.5);
	MobMapQuestEventFrameEventHighlightFrameHighlight:SetVertexColor(1.0, 1.0, 1.0);
	local eventid=frame.id;
	mobmap_questevent_currentevent=eventid;
	mobmap_questeventzones_currentevent=frame:GetText();
	local zones=MobMap_GetQuestEventZones(eventid);
	mobmap_questeventzones_currentlist=zones;
	MobMap_UpdateQuestEventZoneFrame();
end

function MobMap_UpdateQuestEventZoneFrame()
	local offset=FauxScrollFrame_GetOffset(MobMapQuestEventFrameEventZoneListScrollFrame);
	local zonecount=table.getn(mobmap_questeventzones_currentlist);
	MobMapQuestEventFrameEventZoneHighlightFrame:Hide();
	for i=1,4,1 do
		local zoneindex=i+offset;
		local frame=getglobal("MobMapQuestEventFrameEventZone"..i);
		if(mobmap_questeventzones_currentlist[zoneindex]~=nil) then
			frame:Show();
			if(mobmap_questeventzones_currentlist[zoneindex].level>0) then
				frame:SetText(mobmap_questeventzones_currentlist[zoneindex].name.." ("..mobmap_questeventzones_currentlist[zoneindex].level..")");
			else
				frame:SetText(mobmap_questeventzones_currentlist[zoneindex].name);
			end
			frame.id=mobmap_questeventzones_currentlist[zoneindex].id;
			frame.level=mobmap_questeventzones_currentlist[zoneindex].level;
			frame.length=mobmap_questeventzones_currentlist[zoneindex].length;
			frame.pointer=mobmap_questeventzones_currentlist[zoneindex].pointer;
			frame.name=mobmap_questeventzones_currentlist[zoneindex].name;
			frame:Enable();
		else
			frame:Hide();
		end
	end
	FauxScrollFrame_Update(MobMapQuestEventFrameEventZoneListScrollFrame, zonecount+1, 4, 22);
	if(zonecount==1) then
		if(mobmap_questsearch) then 
			mobmap_questsearch=false;
			HideUIPanel(MobMapFrame); 
		end
		MobMapEventZoneButton_ProcessClick(getglobal("MobMapQuestEventFrameEventZone1"));
	elseif(zonecount>1) then
		if(mobmap_questsearch) then
			local currentZone=GetRealZoneText();
			for i=1,4,1 do
				if(i<=zonecount and getglobal("MobMapQuestEventFrameEventZone"..i).name==currentZone) then
					MobMapEventZoneButton_ProcessClick("MobMapQuestEventFrameEventZone"..i);
					mobmap_questsearch=false;
					return;
				end
			end
			MobMapEventZoneButton_ProcessClick("MobMapQuestEventFrameEventZone1");
			mobmap_questsearch=false;
			return;
		end
		if(not MobMapFrame:IsVisible()) then ShowUIPanel(MobMapFrame); end
		if(MobMapQuestEventFrame~=nil and not MobMapQuestEventFrame:IsVisible()) then MobMap_ShowPanel("MobMapQuestEventFrame"); end
	end
	mobmap_questsearch=false;
end

function MobMapEventZoneButton_OnClick(self)
	MobMapEventZoneButton_ProcessClick(self);
end

function MobMapEventZoneButton_ProcessClick(frame)
	MobMapQuestEventFrameEventZoneHighlightFrame:Show();
	MobMapQuestEventFrameEventZoneHighlightFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0);
	MobMapQuestEventFrameEventZoneHighlightFrame:SetAlpha(0.5);
	MobMapQuestEventFrameEventZoneHighlightFrameHighlight:SetVertexColor(1.0, 1.0, 1.0);
	mobmap_multidisplay=nil;
	MobMap_ShowMultiplePositionsOnMap(MobMap_GetQuestEventPositions(frame.pointer, frame.length), mobmap_questeventzones_currentevent, frame.name, frame.level);

	--mobmap_currentlyshown={zonename=self:GetText(), zoneid=self.id, mobname=MobMapMobSearchFrameSelectionDetailsName:GetText(), mobfullname=MobMapMobSearchFrameSelectionDetails.mobfullname, mobid=MobMapMobSearchFrameSelectionDetails.mobid};
end