function FrameInitialize(self)
  local unit = self.unit;
  --print(unit .. " frame is loaded");
  RegisterUnitWatch(self); --[[ http://wow.gamepedia.com/Macro_conditionals ]]--

  function self:Frame_Update()
    self:Update_Name();
    self:Update_Model();
    self:Update_ModelColor();
    self:Update_Health();
    self:Update_Power();
    self:Update_Level();
    if (unit == "pet") then return end --[[ Pet not need the rest of frames ]]--
    self:Update_Faction();
    self:Update_Leader();
    self:Update_Loot();
    self:Update_Role();
  end

  local txtName = self:CreateFontString(nil, "BACKGROUND", "GameFontNormal");
  txtName:SetPoint("TOPLEFT", 70, -1.75);
  txtName:SetSize(114, 13);
  txtName:SetJustifyV("TOP");
  txtName:SetJustifyH("LEFT");
  function self:Update_Name()
    txtName:SetText(UnitName(unit));
    if UnitExists(unit) then
      local Class = select(1, UnitClass(unit));
      if Class then
        local ClassColor = RAID_CLASS_COLORS[select(2, UnitClass(unit))];
        txtName:SetTextColor(ClassColor.r, ClassColor.g, ClassColor.b);
      end
    else
      --[[ Try to avoide changing pet color or target color ]]--
    end
  end

  self.ModelFrame = CreateFrame("PlayerModel", nil, self);
  self.ModelFrame:SetPoint("TOPLEFT", 20, 0);
  self.ModelFrame:SetSize(48, 48);
  local ModelColor = self.ModelFrame:CreateTexture();
  self.ModelFrame.Texture = ModelColor;
  ModelColor:SetAllPoints();
  function self:Update_Model()
    --self.ModelFrame:RefreshUnit();
    self.ModelFrame:SetUnit(unit); --[[ To display uncached models use SetDisplayInfo() on a playermodel type model ]]--
    self.ModelFrame:SetModelScale(1.5);
    self.ModelFrame:SetPosition(0, 0, -1.5); --[[ Some times not working ]]--
  end
  function self:Update_ModelColor()
    if UnitAffectingCombat(unit) then
      ModelColor:SetTexture("Interface\\FullScreenTextures\\LowHealth");
    elseif (unit == "player" and IsResting()) then
      ModelColor:SetTexture(.45, .3, .05, .25);
    else
      ModelColor:SetTexture(0, 0, 0, .25);
    end
  end

  self.HealthFrame = CreateFrame("Frame", nil, self);
  self.HealthFrame:SetPoint("TOPRIGHT", -1, -16);
  self.HealthFrame:SetSize(150, 17);
  self.HealthFrame:SetBackdrop(FrameBackdrop);
  self.HealthFrame:SetBackdropColor(0, .5, .25, .25);
  local HealthBarFrame = CreateFrame("Frame", nil, self.HealthFrame);
  HealthBarFrame:SetPoint("TOPLEFT", 0, 0);
  HealthBarFrame:SetHeight(17);
  HealthBarFrame:SetBackdrop(BarBackdrop);
  local HealthTextFrame = CreateFrame("Frame", nil, self.HealthFrame);
  local txtHealth = HealthTextFrame:CreateFontString(nil, "BACKGROUND", "GameFontHighlight");
  local txtHealthPercent = HealthTextFrame:CreateFontString(nil, "BACKGROUND", "GameFontHighlight");
  txtHealth:SetPoint("LEFT", self.HealthFrame, "LEFT", 1, 1);
  txtHealthPercent:SetPoint("RIGHT", self.HealthFrame, "RIGHT", -1, 1);
  function self:Update_Health()

    if (UnitInParty(unit) and UnitIsConnected(unit) == nil) then
      HealthBarFrame:SetBackdropColor(.35, .35, .35, 1); HealthBarFrame:SetWidth(150 - 0.1);
      txtHealth:SetText(""); txtHealthPercent:SetText("");
      return;
    elseif (not UnitPlayerControlled(unit) and UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) and not UnitIsTappedByAllThreatList(unit)) then
      HealthBarFrame:SetBackdropColor(.75, .75, .75, 1);
    elseif (UnitIsDeadOrGhost(unit)) then
      self:Update_Status("Dead");
    elseif (UnitHealth(unit) / UnitHealthMax(unit) < .34) then
      HealthBarFrame:SetBackdropColor(1, 0, 0, 1);
      if (unit == "player" and not UnitIsDeadOrGhost(unit)) then
        PlaySound("igCreatureAggroSelect"); --[[ Try to alert when player health is low ]]--
      end
    elseif (UnitHealth(unit) / UnitHealthMax(unit) < .5) then
      HealthBarFrame:SetBackdropColor(1, .88, .25, 1);
    else
      HealthBarFrame:SetBackdropColor(0, .75, .25, 1);
    end

    HealthBarFrame:SetWidth((UnitHealth(unit) / UnitHealthMax(unit)) * 150 - 0.1);
    txtHealth:SetText(UnitHealth(unit));
    txtHealthPercent:SetText(format("%.0f%%", (UnitHealth(unit) / UnitHealthMax(unit)) * 100));
  end

  self.PowerFrame = CreateFrame("Frame", nil, self);
  self.PowerFrame:SetPoint("TOPRIGHT", -1, -34);
  self.PowerFrame:SetSize(150, 13);
  self.PowerFrame:SetBackdrop(FrameBackdrop);
  self.PowerFrame:SetBackdropColor(0, .25, .5, .25);
  local PowerBarFrame = CreateFrame("Frame", nil, self.PowerFrame);
  PowerBarFrame:SetPoint("TOPLEFT", 0, 0);
  PowerBarFrame:SetHeight(13);
  PowerBarFrame:SetBackdrop(BarBackdrop);
  PowerBarFrame:SetBackdropColor(0, .25, .75, 1);
  local PowerTextFrame = CreateFrame("Frame", nil, self.PowerFrame);
  local txtPower = PowerTextFrame:CreateFontString(nil, "BACKGROUND", "GameFontHighlight");
  local txtPowerPercent = PowerTextFrame:CreateFontString(nil, "BACKGROUND", "GameFontHighlight");
  txtPower:SetPoint("LEFT", self.PowerFrame, "LEFT", 1, 0.5);
  txtPowerPercent:SetPoint("RIGHT", self.PowerFrame, "RIGHT", -1, 0.5);
  function self:Update_Power()
    if (UnitIsConnected(unit) == nil) then
      PowerBarFrame:SetBackdropColor(.35, .35, .35, 1); PowerBarFrame:SetWidth(150 - 0.1);
      txtPower:SetText(""); txtPowerPercent:SetText("");
    elseif (UnitPowerMax(unit) == 0) then
      PowerBarFrame:SetWidth(0.1);
      txtPower:SetText("None"); txtPowerPercent:SetText("");
    else
      PowerBarFrame:SetBackdropColor(0, .25, .75, 1);
      PowerBarFrame:SetWidth((UnitPower(unit) / UnitPowerMax(unit)) * 150 - 0.1);
      txtPower:SetText(UnitPower(unit)); --[[ Problem when enter to game the pet bar is not shown ]]--
      txtPowerPercent:SetText(format("%.0f%%", (UnitPower(unit) / UnitPowerMax(unit)) * 100));
    end
  end

  local LevelFrame = CreateFrame("Frame", nil, self);
  LevelFrame:SetPoint("TOPLEFT", 0, -26);
  LevelFrame:SetSize(22, 22);
  local LevelIcon = LevelFrame:CreateTexture();
  LevelFrame.Texture = LevelIcon;
  LevelIcon:SetAllPoints();
  LevelIcon:SetTexture("Interface\\TARGETINGFRAME\\UI-TargetingFrame-Skull");
  local txtLevel = self:CreateFontString(nil, "BACKGROUND", "GameFontNormal");
  txtLevel:SetPoint("TOPLEFT", 1, -34);
  txtLevel:SetWidth(18);
  function self:Update_Level()
    if (UnitLevel(unit) < 0) and (not UnitIsCorpse(unit)) then
      txtLevel:Hide(); LevelIcon:Show();
    else
      if (UnitCanAttack("player", unit)) then
        local color = GetQuestDifficultyColor(UnitLevel(unit));
        txtLevel:SetVertexColor(color.r, color.g, color.b);
      else txtLevel:SetVertexColor(1.0, 0.82, 0);
      end
      LevelIcon:Hide(); txtLevel:Show();
      txtLevel:SetText(UnitLevel(unit));
    end
  end

  local txtSpeed = self:CreateFontString(nil, "BACKGROUND", "GameFontHighlight");
  txtSpeed:SetPoint("TOPRIGHT", -2, -1.75);
  function self:Update_Speed()
    txtSpeed:SetText(format("%d%%", (GetUnitSpeed(unit) / 7) * 100)); --[[ Problem speed still use OnUpdate ]]--
  end

  self.StatusFrame = CreateFrame("Frame", nil, self);
  self.StatusFrame:SetPoint("TOPLEFT", 0, -48);
  self.StatusFrame:SetSize(84, 17);
  self.StatusFrame:SetBackdrop(FrameBackdrop);
  self.StatusFrame:SetBackdropColor(0, 0, 0, .25);
  local StatusBarFrame = CreateFrame("Frame", nil, self.StatusFrame);
  StatusBarFrame:SetPoint("TOPLEFT", 0, 0);
  StatusBarFrame:SetHeight(17);
  StatusBarFrame:SetBackdrop(BarBackdrop);
  StatusBarFrame:SetBackdropColor(0, 0, 0, 0);
  local StatusTextFrame = CreateFrame("Frame", nil, self.StatusFrame);
  local txtStatus = StatusTextFrame:CreateFontString(nil, "BACKGROUND", "GameFontNormal");
  txtStatus:SetPoint("CENTER", self.StatusFrame, "CENTER", -2, 1);
  function self:Update_Status(statusName)
    local StatusColor = {};
    StatusColor["Default"] = {r=0, g=0, b=0, a=.25};
    StatusColor[""] = StatusColor["Default"];
    StatusColor["Dead"] = {r=0, g=0, b=0, a=.75};
    StatusColor["Offline"] = {r=.2, g=.2, b=.2, a=.75};
    StatusColor["Resting"] = {r=.45, g=.3, b=.05, a=.25};
    StatusColor["Swimming"] = {r=.05, g=.3, b=.45, a=.25};
    StatusColor["Breath"] = StatusColor["Swimming"];
    StatusColor["Mounted"] = {r=.05, g=.45, b=.3, a=.25};
    StatusColor["Riding_Taxi"] = StatusColor["Mounted"];
    StatusColor["Flying"] = StatusColor["Mounted"];
    StatusColor["In_Combat"] = {r=.35, g=0, b=0, a=.25};
    StatusColor["Upset"] = {r=.35, g=0, b=0, a=.25};
    StatusColor["Concern"] = {r=.45, g=.3, b=.05, a=.25};
    StatusColor["Happy"] = {r=.05, g=.45, b=.3, a=.25};

    local statusMessage = statusName:gsub("%_", " ");
    local color = StatusColor[statusName];

    if (UnitAffectingCombat(unit) or UnitThreatSituation(unit)) then
      local isTanking, Status, threatPercent, rawThreatPercent, threatValue = UnitDetailedThreatSituation(unit, "target");
      if (unit == "target") then
        isTanking, Status, threatPercent, rawThreatPercent, threatValue = UnitDetailedThreatSituation("player", unit);
      end
      local r, g, b = GetThreatStatusColor(Status); color = {r=r, g=g, b=b, a=.25};
      if (unit == "player") then --[[ Do nothing ]]--
      elseif isTanking then statusMessage = "HIGH " .. format("%.0f%%", threatPercent);
      elseif Status then statusMessage = "LOW " .. format("%.0f%%", threatPercent);
      end
    elseif (statusName == "Breath") then
      print("Player is "..GetMirrorTimerProgress("BREATH"));
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
    end

    self.StatusFrame:SetBackdropColor(color.r, color.g, color.b, color.a);
    txtStatus:SetText(statusMessage);
    self:Update_ModelColor(); --[[ Problem with pet happiness, Change to self:ModelFrame and watch pet model ]]--
  end

  if (unit == "pet") then return; end --[[ Pet not need the rest of frames ]]--

  self.FactionFrame = CreateFrame("Frame", nil, self);
  self.FactionFrame:SetPoint("TOPLEFT", -1, -2);
  self.FactionFrame:SetSize(22, 22);
  local FactionIcon = self.FactionFrame:CreateTexture();
  self.FactionFrame.Texture = FactionIcon;
  FactionIcon:SetAllPoints();
  function self:Update_Faction()
    if UnitFactionGroup(unit) then
      FactionIcon:SetTexture("Interface\\FriendsFrame\\PlusManz-" .. UnitFactionGroup(unit));
      self.FactionFrame:Show();
    else
      self.FactionFrame:Hide();
    end
  end

  self.LeaderFrame = CreateFrame("Frame", nil, self);
  self.LeaderFrame:SetPoint("TOPLEFT", 2, 18);
  self.LeaderFrame:SetSize(16, 16);
  local LeaderIcon = self.LeaderFrame:CreateTexture();
  self.LeaderFrame.Texture = LeaderIcon;
  LeaderIcon:SetAllPoints();
  LeaderIcon:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon");
  local txtLeader = self.LeaderFrame:CreateFontString(nil, "BACKGROUND", "GameFontNormal");
  txtLeader:SetPoint("LEFT", 18, 1);
  txtLeader:SetText("Leader");

  self.GuideFrame = CreateFrame("Frame", nil, self);
  self.GuideFrame:SetPoint("TOPLEFT", 2, 18);
  self.GuideFrame:SetSize(16, 16);
  local GuideIcon = self.GuideFrame:CreateTexture();
  self.GuideFrame.Texture = GuideIcon;
  GuideIcon:SetAllPoints();
  GuideIcon:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES");
  GuideIcon:SetTexCoord(0, 0.296875, 0.015625, 0.3125);
  local txtGuide = self.GuideFrame:CreateFontString(nil, "BACKGROUND", "GameFontNormal");
  txtGuide:SetPoint("LEFT", 18, 1);
  txtGuide:SetText("Guide");

  function self:Update_Leader()
    if (UnitIsPartyLeader(unit) and (UnitInParty(unit) or UnitInRaid(unit))) then
      if HasLFGRestrictions() then
        self.LeaderFrame:Hide(); self.GuideFrame:Show();
      else
        self.GuideFrame:Hide(); self.LeaderFrame:Show();
      end
    else
      self.LeaderFrame:Hide(); self.GuideFrame:Hide();
    end
  end

  self.LootFrame = CreateFrame("Frame", nil, self);
  self.LootFrame:SetPoint("TOPLEFT", 70, 18);
  self.LootFrame:SetSize(16, 16);
  local LootIcon = self.LootFrame:CreateTexture();
  self.LootFrame.Texture = LootIcon;
  LootIcon:SetAllPoints();
  LootIcon:SetTexture("Interface\\GroupFrame\\UI-Group-MasterLooter");
  local txtLoot = LootFrame:CreateFontString(nil, "BACKGROUND", "GameFontNormal");
  txtLoot:SetPoint("LEFT", 18, 1);
  txtLoot:SetText("Loot");
  function self:Update_Loot()
    local _, lootMaster = GetLootMethod();
    if (lootMaster == 0 and ((GetNumPartyMembers() > 0) or (GetNumRaidMembers() > 0))) then
      self.LootFrame:Show();
    else
      self.LootFrame:Hide();
    end
  end

  self.RoleFrame = CreateFrame("Frame", nil, self);
  self.RoleFrame:SetPoint("TOPLEFT", 70, 18);
  self.RoleFrame:SetSize(16, 16);
  local RoleIcon = self.RoleFrame:CreateTexture();
  self.RoleFrame.Texture = RoleIcon;
  RoleIcon:SetAllPoints();
  RoleIcon:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES");
  local txtRole = self.RoleFrame:CreateFontString(nil, "BACKGROUND", "GameFontNormal");
  txtRole:SetPoint("LEFT", 18, 1);
  function self:Update_Role()
    local isTank, isHealer, isDPS = UnitGroupRolesAssigned(unit);
    self.RoleFrame:Show();
    if isTank then
      RoleIcon:SetTexCoord(0, 19/64, 22/64, 41/64); txtRole:SetText("Tank");
    elseif isHealer then
      RoleIcon:SetTexCoord(20/64, 39/64, 1/64, 20/64); txtRole:SetText("Healer");
    elseif isDPS then
      RoleIcon:SetTexCoord(20/64, 39/64, 22/64, 41/64); txtRole:SetText("Damage");
    else
      self.RoleFrame:Hide();
    end
  end

end

--PlaySound("igCreatureAggroSelect");
--PlayMusic("Sound\\Music\\GlueScreenMusic\\wow_main_theme.mp3");
--PlayMusic("Interface\\AddOns\\ElegantUI\\Media\\Music\\wow_main_theme.mp3");

