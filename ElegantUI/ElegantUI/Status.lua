  function self:Update_Status(statusName)
    local StatusColor = {};
    StatusColor["Default"] = {r=0, g=0, b=0, a=0.25};
    StatusColor["Dead"]	= {r=0, g=0, b=0, a=0.75};
    StatusColor["Offline"]	= {r=0.2, g=0.2, b=0.2, a=0.75};
    StatusColor["Falling"]	= {r=0.35, g=0.35, b=0, a=0.25};
    StatusColor["Resting"]	= {r=0.45, g=0.3, b=0.05, a=0.25};
    StatusColor["Swimming"]	= {r=0.05, g=0.3, b=0.45, a=0.25};
    StatusColor["Mounted"]	= {r=0.05, g=0.45, b=0.3, a=0.25};
    StatusColor["In_Combat"]	= {r=0.35, g=0, b=0, a=0.25};
    StatusColor["Depressed"]	= {r=0.35, g=0, b=0, a=0.25};
    StatusColor["Concern"]	= {r=0.45, g=0.3, b=0.05, a=0.25};
    StatusColor["Happy"]	= {r=0.05, g=0.45, b=0.3, a=0.25};
    StatusColor[""]	= StatusColor["Default"];
    StatusColor["Riding_Taxi"]	= StatusColor["Mounted"];
    StatusColor["Flying"]	= StatusColor["Mounted"];

    local statusMessage = statusName:gsub("%_", " ");

    if (unit == "pet") then

      local happiness, damagePercentage = GetPetHappiness();
      local mood = ({"Depressed", "Concern", "Happy"})[happiness];
      if mood then
        statusName = mood; statusMessage = statusName;
      else
        statusName = ""; statusMessage = statusName;
      end

    elseif (unit == "player") then

      if (statusName == "Resting" and not IsResting()) then
        statusName = ""; statusMessage = statusName;
      end

      local timer, _, timerMax, _, _, _ = GetMirrorTimerInfo(2);
      if (timer == "BREATH") then
        StatusBarFrame:SetWidth((GetMirrorTimerProgress(timer) / timerMax) * 84 - 0.1);
        statusMessage = format("Breath %.0f%%", (GetMirrorTimerProgress(timer) / timerMax) * 100 - 0.1);
        if (GetMirrorTimerProgress(timer) / timerMax < .26) then
          StatusBarFrame:SetBackdropColor(1, 0, 0, 1);
        else
          StatusBarFrame:SetBackdropColor(0, .25, .75, 1);
        end
      else
        StatusBarFrame:SetBackdropColor(0, 0, 0, 0);
      end

    else

      if (statusName == "In_Combat") then --[[ UnitAffectingCombat(unit) ]]--
        if (unit == "target" and UnitThreatSituation("player")) then
          local isTanking, Status, threatPercent, rawThreatPercent, threatValue = UnitDetailedThreatSituation("player", unit);
        else
          local isTanking, Status, threatPercent, rawThreatPercent, threatValue = UnitDetailedThreatSituation(unit, "target");
        end
        local r, g, b = GetThreatStatusColor(Status);
        StatusColor["In_Combat"]	= {r=r, g=g, b=b, a=0.25};
        if isTanking then
          statusMessage = "HIGH " .. format("%.0f%%", threatPercent);
        elseif Status then
          statusMessage = "LOW " .. format("%.0f%%", threatPercent);
        end
      end

    end

    local color = StatusColor[statusName];
    self.StatusFrame:SetBackdropColor(color.r, color.g, color.b, color.a);
    txtStatus:SetText(statusMessage);
    self:Update_ModelColor(); --[[ Problem with pet happiness, Change to self:ModelFrame and watch pet model ]]--
  end

