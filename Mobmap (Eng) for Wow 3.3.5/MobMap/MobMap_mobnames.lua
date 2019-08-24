-- mob name database

function MobMap_GetMobNameAndSubtitle(fulltitle)
	if(fulltitle==nil) then return nil; end
	local part1,part2;
	_,_,part1,part2=string.find(fulltitle,"(.*)|(.*)");
	if(part1==nil) then
		part1=fulltitle;
		part2=nil;
	else
		part1=part1;
		part2=part2;
	end
	return part1, part2;
end

mobmap_inverse_mobs=nil;
mobmap_last_mobname_search={name=nil, id=nil};

function MobMap_GetIDForMobName(name)
	if(mobmap_optimize_response_times==true) then
		if(mobmap_inverse_mobs==nil) then
			mobmap_inverse_mobs={};
			local k,v;
			for k,v in pairs(mobmap_mobs) do
				local part1,part2=MobMap_GetMobNameAndSubtitle(v);
				mobmap_inverse_mobs[part1]=k;
			end
		end
		return mobmap_inverse_mobs[name];
	else
		if(name==mobmap_last_mobname_search.name) then
			return mobmap_last_mobname_search.id;
		else
			local k,v;
			for k,v in pairs(mobmap_mobs) do
				local part1,part2=MobMap_GetMobNameAndSubtitle(v);
				if(part1==name) then
					mobmap_last_mobname_search.name=name;
					mobmap_last_mobname_search.id=k;
					return k;
				end;
			end
		end
	end
end

function MobMap_GetMobFullName(mobid)
	return mobmap_mobs[mobid];	
end

function MobMap_GetMobName(mobid)
	local part1,part2=MobMap_GetMobNameAndSubtitle(mobmap_mobs[mobid]);	
	return part1,part2;
end

function MobMap_GetPointerToPositionData(position)
	local data=mobmap_mobdetails[position];
	if(data==nil) then return nil; end
	local zonecode, zonelevel, length, pointer;
	zonecode=MobMap_Mask(data,mobmap_poweroftwo[8]);
	zonelevel=MobMap_Mask(data/mobmap_poweroftwo[8],mobmap_poweroftwo[7]);
	length=MobMap_Mask(data/mobmap_poweroftwo[15],mobmap_poweroftwo[16]);
	pointer=MobMap_Mask(data/mobmap_poweroftwo[31],mobmap_poweroftwo[20]);
	return zonecode, zonelevel, length, pointer;
end

function MobMap_GetMobZone(mobid)
	local zonelist=MobMap_GetMobZonesByMobID(mobid);
	if(zonelist==nil) then return nil; end
	if(table.getn(zonelist)==0) then
		return nil;
	end
	return zonelist[1];	
end

function MobMap_GetMobDetails(position)
	local data=mobmap_mobdetails[position];
	if(data==nil) then return nil; end
	local minlevel, maxlevel, zonecount;
	minlevel=MobMap_Mask(data,mobmap_poweroftwo[8]);
	maxlevel=MobMap_Mask(data/mobmap_poweroftwo[8],mobmap_poweroftwo[8]);
	zonecount=MobMap_Mask(data/mobmap_poweroftwo[16],mobmap_poweroftwo[8]);
	return minlevel, maxlevel, zonecount;
end

function MobMap_GetMobPointer(mobid)
	local data=mobmap_mobpointers[floor((mobid-1)/3)+1];
	if(data==nil) then return; end
	local pointer=MobMap_Mask(data/mobmap_poweroftwo[16*((mobid-1)%3)],mobmap_poweroftwo[16]);
	return pointer;
end

function MobMap_GetMobZones(pointer)
	local minlevel, maxlevel, zonecount = MobMap_GetMobDetails(pointer);
	local zones = {};
	for i=1, zonecount, 1 do
		local zonecode, zonelevel = MobMap_GetPointerToPositionData(pointer+i);
		table.insert(zones, {id=zonecode, level=zonelevel});
	end
	return zones;
end

function MobMap_GetMobZonesByMobID(mobid)
	if(mobmap_mobs[mobid]==nil) then return nil; end
	return MobMap_GetMobZones(MobMap_GetMobPointer(mobid));	
end

function MobMap_CheckIfMobIsInZone(mobid, zoneid, zonelevel)
	if(mobmap_mobs[mobid]==nil) then return nil; end
	local pointer=MobMap_GetMobPointer(mobid);
	local minlevel, maxlevel, zonecount=MobMap_GetMobDetails(pointer);
	for i=1, zonecount, 1 do
		local zonecode, level = MobMap_GetPointerToPositionData(pointer+i);
		if(zonecode==zoneid and (zonelevel==nil or level==zonelevel)) then return true; end
	end
	return false;
end

-- quest event database functions

function MobMap_GetQuestEventPointer(eventid)
	local data=mobmap_questeventpointers[floor((eventid-1)/3)+1];
	if(data==nil) then return; end
	local pointer=MobMap_Mask(data/mobmap_poweroftwo[16*((eventid-1)%3)],mobmap_poweroftwo[16]);
	if(pointer2==0) then return nil; end
	return pointer;
end

function MobMap_GetQuestEventDetails(position)
	local data=mobmap_questeventdetails[position];
	local zoneid=MobMap_Mask(data,mobmap_poweroftwo[8]);
	local zonelevel=MobMap_Mask(data/mobmap_poweroftwo[8],mobmap_poweroftwo[7]);
	local count=MobMap_Mask(data/mobmap_poweroftwo[15],mobmap_poweroftwo[16]);
	local pointer=MobMap_Mask(data/mobmap_poweroftwo[31],mobmap_poweroftwo[21]);
	return zoneid, zonelevel, count, pointer;
end

function MobMap_GetQuestEventZones(eventid)
	local zones={};
	local pointer=MobMap_GetQuestEventPointer(eventid);
	local pointer2=MobMap_GetQuestEventPointer(eventid+1);
	local zonecount=pointer2-pointer;
	for i=1, zonecount, 1 do
		local zoneid, zonelevel, count, zonepointer = MobMap_GetQuestEventDetails(pointer+i-1);
		local zonedata={id = zoneid, level = zonelevel, length = count, pointer = zonepointer, name = MobMap_GetZoneName(zoneid)};
		table.insert(zones, zonedata);
	end
	return zones;
end

function MobMap_GetQuestEventZoneDetails(eventid, zoneid, zonelevel)
	local zones=MobMap_GetQuestEventZones(eventid);
	for k,v in pairs(zones) do
		if(v.id==zoneid and v.level==zonelevel) then
			return v.length, v.pointer;
		end
	end
	return nil;
end

mobmap_inverse_questevents = nil;

function MobMap_GetQuestEventIDs(eventtext)
	if(mobmap_optimize_response_times==true) then
		if(mobmap_inverse_questevents==nil) then
			mobmap_inverse_questevents={};
			local k,v;
			for k,v in pairs(mobmap_questevents) do
				v=string.lower(v);
				local subtable=mobmap_inverse_questevents[v];
				if(subtable==nil) then
					subtable={};
					mobmap_inverse_questevents[v]=subtable;
				end
				table.insert(subtable, k);
			end
		end
		return mobmap_inverse_questevents[eventtext];
	else
		local subtable={};
		for k,v in pairs(mobmap_questevents) do
			if(string.lower(v)==string.lower(eventtext)) then table.insert(subtable, k); end
		end
		if(#subtable>0) then
			return subtable;
		else
			return nil;
		end
	end
end

function MobMap_DoQuestEventSearch(query)
	MobMap_ShowPanel("MobMapQuestEventFrame");
	MobMapQuestEventFrameSearchBox:SetText("\""..query.."\"");
	mobmap_questeventframe_oldtext=MobMapQuestEventFrameSearchBox:GetText();
	MobMap_UpdateQuestEventFilter(MobMapQuestEventFrameSearchBox:GetText());
	if(table.getn(mobmap_questevent_currentlist)>0) then
		return true;
	else
		return false;
	end
end

function MobMap_DoQuestEventSearchByID(query)
	MobMap_ShowPanel("MobMapQuestEventFrame");
	MobMapQuestEventFrameSearchBox:SetText("id: "..query.."");
	mobmap_questeventframe_oldtext=MobMapQuestEventFrameSearchBox:GetText();
	MobMap_UpdateQuestEventFilter(MobMapQuestEventFrameSearchBox:GetText());
	if(table.getn(mobmap_questevent_currentlist)>0) then
		return true;
	else
		return false;
	end
end