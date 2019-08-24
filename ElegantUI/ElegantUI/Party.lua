local yOfs = -32;

for i=1, MAX_PARTY_MEMBERS, 1 do
  local frameName = _G["PMF"..i];
  local unit = "party"..i;

  frameName = CreateFrame("Button", nil, PMF, "SecureUnitButtonTemplate");
  frameName:SetPoint("TOPLEFT", PMF, "TOPLEFT", 13, yOfs);
  frameName:SetFrameStrata("MEDIUM");
  frameName:SetSize(220, 48);
  frameName:SetToplevel(true);
  frameName:SetScale(1);
  frameName.unit = unit;
  frameName:RegisterForClicks("LeftButtonUp", "RightButtonUp");
  frameName:SetBackdrop(FrameBackdrop);
  frameName:SetBackdropColor(0, 0, 0, .25);

	local showmenu = function()
		ToggleDropDownMenu(1, nil, _G["PartyMemberFrame"..i.."DropDown"], frameName, 67, -3);
	end
	SecureUnitButton_OnLoad(frameName, unit, showmenu);

  frameName:RegisterEvent("UNIT_PORTRAIT_UPDATE");
  frameName:RegisterEvent("UNIT_HEALTH");
  frameName:RegisterEvent("UNIT_" .. select(2, UnitPowerType(unit)));
  frameName:RegisterEvent("UNIT_FACTION");
  frameName:RegisterEvent("UNIT_LEVEL");
  frameName:RegisterEvent("PLAYER_ENTERING_WORLD");
  frameName:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE");
  frameName:RegisterEvent("PARTY_MEMBERS_CHANGED");
  frameName:RegisterEvent("PARTY_LEADER_CHANGED");
  frameName:RegisterEvent("RAID_ROSTER_UPDATE");
  frameName:RegisterEvent("PARTY_LOOT_METHOD_CHANGED");

  FrameInitialize(frameName);

  yOfs = yOfs - 94;

  frameName:SetScript("OnEvent", function(self, event, ...)
    local arg1 = ...;

    if UnitInParty(unit) then
      if (arg1 == unit) then
        if (event == "UNIT_PORTRAIT_UPDATE") then self:Update_Model();
        elseif (event == "UNIT_HEALTH") then self:Update_Health();
        elseif (event == "UNIT_" .. select(2, UnitPowerType(unit))) then self:Update_Power();
        elseif (event == "UNIT_LEVEL") then self:Update_Level();
        elseif (event == "UNIT_FACTION") then self:Update_Faction();
        elseif (event == "UNIT_THREAT_SITUATION_UPDATE") then self:Update_Status("In_Combat");
        end
      end
    end

    if (event == "PLAYER_ENTERING_WORLD" or event == "PARTY_MEMBERS_CHANGED") then
      self:Frame_Update();
      self:Show();
    elseif (event == "PARTY_MEMBERS_CHANGED" or event == "PARTY_LEADER_CHANGED" or event == "RAID_ROSTER_UPDATE") then
      self:Update_Leader();
    elseif (event == "PARTY_LOOT_METHOD_CHANGED") then self:Update_Loot();
    --elseif (event == "PLAYER_ROLES_ASSIGNED") then self:Update_Role();
    end

  end);

  local timer = 0;
  frameName:SetScript("OnUpdate", function(self, elap)
    timer = timer + elap;
    if (timer >= 0.15) then
      self:Update_Speed(); timer = 0;
    end
  end);

end

