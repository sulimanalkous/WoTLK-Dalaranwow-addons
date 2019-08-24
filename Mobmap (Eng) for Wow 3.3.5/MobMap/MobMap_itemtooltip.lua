-- item tooltip database functions

function MobMap_GetItemTooltip(itemid)
	local k,v,i;
	for k,v in pairs(mobmap_itemtooltipindex) do
		for i=0,2,1 do
			local item=MobMap_Mask(v/mobmap_poweroftwo[i*17],mobmap_poweroftwo[17]);
			if(item==itemid) then
				local data=HuffmanDecode(mobmap_itemtooltipdata[(k-1)*3+i+1], mobmap_itemtooltipdata_huffmantree, mobmap_itemtooltipdata_precodingtable);
				if(data) then
					local icon, tooltip=string.match(data, "^(.-)#(.-)$");
					if(icon and tooltip) then
						return tooltip, icon;
					else
						return data;
					end
				else
					return nil;
				end
			end
		end
	end
	return nil;
end

function MobMap_GetItemIcon(itemid)
	local tooltip, icon = MobMap_GetItemTooltip(itemid);
	return icon;
end

function MobMap_CreateItemTooltip(tooltip, itemid)
	tooltip:ClearLines();
	local data=MobMap_GetItemTooltip(itemid);
	if(data) then
		if(string.sub(data,-1)~="\n") then data=data.."\n"; end
		local wrap=false;
		for line in string.gmatch(data, "(.-)\n") do
			if(line=="") then line=" "; end
			local leftPart, rightPart = string.match(line,"^(.-)\t(.-)$");
			if(leftPart and rightPart) then
				tooltip:AddDoubleLine(leftPart, rightPart, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, false);
			else
				tooltip:AddLine(line, 1.0, 1.0, 1.0, wrap);
			end
			wrap=true;
		end
		tooltip:AddLine(" ");
		tooltip:AddLine(MOBMAP_DATABASE_TOOLTIP_SUFFIX, nil, nil, nil, wrap);
		tooltip:SetFrameLevel(5000);
		tooltip:Show();
		return true;
	else
		return false;
	end
end