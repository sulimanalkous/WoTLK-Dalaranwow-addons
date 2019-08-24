FrameInitialize(TF);

TargetClassificationIcon = TF:CreateTexture();
TargetClassificationIcon:SetPoint("LEFT", -19, 8);
TargetClassificationIcon:SetSize(64, 64);
TargetClassificationIcon:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Gold-Dragon");
TargetClassificationIcon:SetTexCoord(0, 1, 0, .7); -- Left Right Top Bottom
TF.Texture = TargetClassificationIcon;
TargetClassificationIcon:Hide();

TF:SetScript("OnHide", function(self)
  PlaySound("INTERFACESOUND_LOSTTARGETUNIT");
  CloseDropDownMenus();
end);

TF:SetScript("OnEvent", function(self, event, ...)
  local arg1 = ...;

  if (arg1 == "target") then
    if (event == "UNIT_HEALTH") then self:Update_Health();
    elseif (event == "UNIT_" .. select(2, UnitPowerType("target"))) then self:Update_Power();
    elseif (event == "UNIT_THREAT_LIST_UPDATE") then self:Update_Status("In_Combat");
    end
  end

  if (event == "PLAYER_TARGET_CHANGED") then
    local Classification = UnitClassification("target");
    if (Classification == "worldboss" or Classification == "elite" or Classification == "rareelite" or Classification == "rare") then
      TargetClassificationIcon:Show();
    else
      TargetClassificationIcon:Hide();
    end

    hooksecurefunc("TargetFrame_UpdateBuffAnchor", function()
      local  bX = 17; local bY = 0;
      for i=1, MAX_TARGET_BUFFS do
        local B = _G["TargetFrameBuff"..i];
        if B then B:SetParent(TF.StatusFrame); B:SetSize(16, 16); B:ClearAllPoints(); B:SetPoint("RIGHT", bX, bY); end
        bX = bX + 17;
        if (i == 8) then bX = 17; bY = -17; end
      end
    end);

    hooksecurefunc("TargetFrame_UpdateDebuffAnchor", function()
      local  dX = 17; local dY = 0;
      for i=1, MAX_TARGET_DEBUFFS do
        local D = _G["TargetFrameDebuff"..i];
        if D then D:SetParent(TF.StatusFrame); D:SetSize(16, 16); D:ClearAllPoints(); D:SetPoint("RIGHT", dX, dY); end
        dX = dX + 17;
        if (i == 8) then dX = 17; dY = -17; end
      end
    end);

    self:Frame_Update();
  end

end);

local timer = 0;
TF:SetScript("OnUpdate", function(self, elap)
  timer = timer + elap;
  if (timer >= 0.15) then
    self:Update_Speed(); timer = 0;
  end
end);

