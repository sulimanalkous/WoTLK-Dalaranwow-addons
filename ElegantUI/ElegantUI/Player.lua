FrameInitialize(PF);

QueueFrame = CreateFrame("Frame", nil, PF);
QueueFrame:SetPoint("TOPLEFT", -3, 21);
QueueFrame:SetSize(24, 23);
local QueueIcon = QueueFrame:CreateTexture();
QueueFrame.Texture = QueueIcon;
QueueIcon:SetAllPoints();
QueueIcon:SetTexture("Interface\\LFGFrame\\LFG-Eye");
QueueIcon:SetTexCoord(0.125, 0.25, 0.25, 0.5);
local txtQueue = QueueFrame:CreateFontString(nil, "BACKGROUND", "GameFontNormal");
txtQueue:SetPoint("LEFT", 24, 1);
QueueFrame:SetScript("OnUpdate", function(self, elapsed)
  local eye = LFG_EYE_TEXTURES[self.queueType or "default"];
  AnimateTexCoords(QueueIcon, eye.width, eye.height, eye.iconSize, eye.iconSize, eye.frames, elapsed, eye.delay);
  local mode, submode = GetLFGMode();
  if (mode == "queued") then
    local hasData, _, _, _, _, _, _, _, _, _, _, _, tankWait, healerWait, dpsWait, myWait, queuedTime, _ = GetLFGQueueStats();
    if hasData then
      txtQueue:SetText("Queued: " .. SecondsToTime(GetTime() - tankWait));
    else
      txtQueue:SetText("Queue: < 1 Minute");
    end
  end
end);

local f = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate");
f:SetPoint("TOP", 0, -48);
f:SetSize(84, 17);
f:SetBackdrop(FrameBackdrop);
f:SetBackdropColor(0, 0, 0, .75);
f:SetAttribute("_onstate-status", [[
 if newstate == "1" then
    self:Show(); --self:SetBackdropColor(.05, .45, .3, .25);
 elseif newstate == "2" then
    self:Show(); --self:SetBackdropColor(.05, .3, .45, .25);
 else
    self:Hide(); --self:SetBackdropColor(0, 0, 0, .25);
 end
]]);
RegisterStateDriver(f, "status", "[swimming] 2; [mounted] 1; 0");

PF:SetScript("OnEvent", function(self, event, ...)
  local arg1, arg2, arg3, arg4, arg5 = ...;

  if (arg1 == "player") then
    if (event == "UNIT_PORTRAIT_UPDATE") then self:Update_Model();
    elseif (event == "UNIT_HEALTH") then self:Update_Health();
    elseif (event == "UNIT_MANA" or event == "UNIT_RAGE" or event == "UNIT_FOCUS" or event == "UNIT_ENERGY") then self:Update_Power();
    elseif (event == "UNIT_RUNIC_POWER") then RuneFrame:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 86, 0); --DeathKnight Rune power bar
    elseif (event == "UNIT_LEVEL") then self:Update_Level();
    elseif (event == "UNIT_FACTION") then self:Update_Faction();
    elseif (event == "UNIT_THREAT_SITUATION_UPDATE") then self:Update_Status("In_Combat");
    elseif (event == "PLAYER_FLAGS_CHANGED") then
      if IsResting() then self:Update_Status("Resting");
      else self:Update_Status("");
      end
    end
  end

  if (event == "PLAYER_ENTERING_WORLD") then
    local mode, submode = GetLFGMode();
    if (mode == "queued") then QueueFrame:Show(); else QueueFrame:Hide(); end

    local _, _, _, _, yOfs = PlayerFrame:GetPoint();
    self:SetPoint("TOPLEFT", 16, yOfs - 16);
    self:Frame_Update();
  elseif (event == "PLAYER_REGEN_ENABLED") then self:Update_Status("");
  elseif (event == "SPELL_UPDATE_USABLE") then
    if IsSwimming() then self:Update_Status("Swimming");
    elseif IsMounted() then
      if UnitOnTaxi("player") then self:Update_Status("Riding_Taxi");
      elseif IsFlying() then self:Update_Status("Flying");
      else self:Update_Status("Mounted");
      end
    else self:Update_Status("");
    end
  elseif (event == "MIRROR_TIMER_START") then self:Update_Status("Breath");
  elseif (event == "PARTY_MEMBERS_CHANGED" or event == "PARTY_LEADER_CHANGED" or event == "RAID_ROSTER_UPDATE") then
    self:Update_Leader();
  elseif (event == "PARTY_LOOT_METHOD_CHANGED") then self:Update_Loot();
  elseif (event == "PLAYER_ROLES_ASSIGNED") then self:Update_Role();
  elseif (event == "CHAT_MSG_SYSTEM") then
    if (arg1 == ERR_LFG_JOINED_QUEUE) then QueueFrame:Show(); end
    if (arg1 == ERR_LFG_LEFT_QUEUE or arg1 == ERR_LFG_PROPOSAL_DECLINED_SELF) then QueueFrame:Hide(); end
  end

--MirrorTimer2:HookScript("OnUpdate", PF:Update_Status("Breath"));

  if (UnitExists("pet") and (event == "PLAYER_ENTERING_WORLD" or event == "UNIT_PET")) then
    self:UnregisterEvent("UNIT_PET");
    if (PTF) then
      PTF:Frame_Update();
    else
      Pet_Load(); PTF:Frame_Update();
    end
  end

end);

local timer = 0;
PF:SetScript("OnUpdate", function(self, elap)
  timer = timer + elap;
  if (timer >= 0.15) then
    self:Update_Speed(); timer = 0;
  end
end);

