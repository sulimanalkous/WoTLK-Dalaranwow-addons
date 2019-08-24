function Pet_Load()
  PTF = CreateFrame("Button", nil, PF, "SecureUnitButtonTemplate");
  PTF:SetPoint("TOPLEFT", 0, -134);
  PTF:SetFrameStrata("LOW");
  PTF:SetSize(220, 48);
  PTF:SetToplevel(true);
  PTF:SetScale(0.65);
  PTF.unit = "pet";
  PTF:RegisterForClicks("LeftButtonUp", "RightButtonUp");
  PTF:SetBackdrop(FrameBackdrop);
  PTF:SetBackdropColor(0, 0, 0, .25);

  PTFMenu = function()
    ToggleDropDownMenu(1, nil, PetFrameDropDown, PTF, 58, -3);
  end
  SecureUnitButton_OnLoad(PTF, "pet", PTFMenu);

  FrameInitialize(PTF);

  PTF:RegisterEvent("PET_RENAMEABLE");
  PTF:RegisterEvent("UNIT_NAME_UPDATE");
  PTF:RegisterEvent("UNIT_PORTRAIT_UPDATE");
  PTF:RegisterEvent("UNIT_HEALTH");
  PTF:RegisterEvent("UNIT_" .. select(2, UnitPowerType("pet")));
  PTF:RegisterEvent("UNIT_LEVEL");
  PTF:RegisterEvent("UNIT_HAPPINESS");
  PTF:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE");

  PTF:SetScript("OnEvent", function(self, event, ...)
    local arg1 = ...;

    if (arg1 == "pet") then
      if (event == "PET_RENAMEABLE" or event == "UNIT_NAME_UPDATE") then self:Update_Name();
      elseif (event == "UNIT_PORTRAIT_UPDATE") then self:Update_Model();
      elseif (event == "UNIT_HEALTH") then self:Update_Health();
      elseif (event == "UNIT_" .. select(2, UnitPowerType("pet"))) then self:Update_Power();
      elseif (event == "UNIT_LEVEL") then self:Update_Level();
      elseif (event == "UNIT_HAPPINESS") then
        if (not UnitIsDead("pet") or UnitAffectingCombat("pet")) then return; end
        local happiness, damagePercentage = GetPetHappiness();
        local mood = ({"Upset", "Concern", "Happy"})[happiness];
        if mood then self:Update_Status(mood);
        else self:Update_Status("");
        end
      elseif (event == "UNIT_THREAT_SITUATION_UPDATE") then self:Update_Status("In_Combat");
      end
    end

    local  bX = 17; local bY = 0;
    for i=1, 40 do
      local B, _, icon, _, _, dur, x, _, _ = UnitBuff("pet", i);
      if B then
        B = CreateFrame("Frame", nil, self.StatusFrame); B:SetPoint("RIGHT", bX, bY); B:SetSize(16, 16);
        local BIcon = B:CreateTexture(); BIcon:SetAllPoints(); BIcon:SetTexture(icon);
        B.Texture = BIcon;
      end
      bX = bX + 17;
      if (i == 8) then
        bX = 17; bY = -17;
      end
    end

    local  dX = 17; local dY = 0;
    for i=1, 40 do
      local D, _, icon, _, _, dur, x, _, _ = UnitDebuff("pet", i);
      if D then
        D = CreateFrame("Frame", nil, self.StatusFrame); D:SetPoint("RIGHT", dX, dY); D:SetSize(16, 16);
        local DIcon = D:CreateTexture(); DIcon:SetAllPoints(); DIcon:SetTexture(icon);
        D.Texture = DIcon;
      end
      dX = dX + 17;
      if (i == 8) then
        dX = 17; dY = -17;
      end
    end

  end);

  local timer = 0;
  PTF:SetScript("OnUpdate", function(self, elap)
    timer = timer + elap;
    if (timer >= 0.15) then
      self:Update_Speed(); timer = 0;
    end
  end);

end

