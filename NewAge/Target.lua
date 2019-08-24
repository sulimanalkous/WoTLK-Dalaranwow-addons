local LeaderFrame = CreateFrame("Frame", nil, TargetContainer);
local RoleFrame = CreateFrame("Frame", nil, TargetContainer);
local FactionFrame = CreateFrame("Frame", nil, TargetContainer);
local ModelFrame = CreateFrame("TabardModel", nil, TargetContainer);
local HealthFrame = CreateFrame("Frame", nil, TargetContainer);
local HealthBarFrame = CreateFrame("Frame", nil, HealthFrame);
local HealthTextFrame = CreateFrame("Frame", nil, HealthFrame);
local PowerFrame = CreateFrame("Frame", nil, TargetContainer);
local PowerBarFrame = CreateFrame("Frame", nil, PowerFrame);
local PowerTextFrame = CreateFrame("Frame", nil, PowerFrame);
local StatusFrame = CreateFrame("Frame", nil, TargetContainer);

local Class = select(1, UnitClass("target"));
local ClassColor = RAID_CLASS_COLORS[select(2, UnitClass("target"))];
local LeaderIcon = LeaderFrame:CreateTexture();
local RoleIcon = RoleFrame:CreateTexture();
local isTank, isHealer, isDamage = UnitGroupRolesAssigned("target");
local FactionIcon = FactionFrame:CreateTexture();
local ModelColor = ModelFrame:CreateTexture();
local txtLeader = LeaderFrame:CreateFontString(nil, "BACKGROUND", "GameFontNormal");
local txtRole = RoleFrame:CreateFontString(nil, "BACKGROUND", "GameFontNormal");
local txtLevel = TargetContainer:CreateFontString(nil, "BACKGROUND", "GameFontNormal");
local txtName = TargetContainer:CreateFontString(nil, "BACKGROUND", "GameFontNormalSmall");
local txtSpeed = TargetContainer:CreateFontString(nil, "BACKGROUND", "GameFontHighlight");
local txtHealth = HealthTextFrame:CreateFontString(nil, "BACKGROUND", "GameFontHighlight");
local txtHealthPercent = HealthTextFrame:CreateFontString(nil, "BACKGROUND", "GameFontHighlight");
local txtPower = PowerTextFrame:CreateFontString(nil, "BACKGROUND", "GameFontHighlight");
local txtPowerPercent = PowerTextFrame:CreateFontString(nil, "BACKGROUND", "GameFontHighlight");
local txtStatus = StatusFrame:CreateFontString(nil, "BACKGROUND", "GameFontNormal");

LeaderFrame:SetPoint("TOPLEFT", 2, 18);
LeaderFrame:SetWidth(16);
LeaderFrame:SetHeight(16);
LeaderFrame.Texture = LeaderIcon;
LeaderIcon:SetAllPoints();
LeaderIcon:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES");
LeaderIcon:SetTexCoord(0, 0.296875, 0.015625, 0.3125);

RoleFrame:SetPoint("TOPLEFT", 70, 18);
RoleFrame:SetWidth(16);
RoleFrame:SetHeight(16);
RoleFrame.Texture = RoleIcon;
RoleIcon:SetAllPoints();
RoleIcon:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES");

FactionFrame:SetPoint("TOPLEFT", -1, -2);
FactionFrame:SetWidth(22);
FactionFrame:SetHeight(22);
FactionFrame.Texture = FactionIcon;
FactionIcon:SetAllPoints();


ModelFrame:SetPoint("TOPLEFT", 20, 0);
ModelFrame:SetWidth(48);
ModelFrame:SetHeight(48);
--ModelFrame:SetUnit("target");
ModelFrame:SetPosition(200, 0, 0);
ModelFrame.Texture = ModelColor;
ModelColor:SetAllPoints();
ModelColor:SetTexture(0, 0, 0, .25);

HealthFrame:SetPoint("TOPRIGHT", -1, -16);
HealthFrame:SetWidth(150);
HealthFrame:SetHeight(17);
HealthFrame:SetBackdrop(FrameBackdrop);
HealthFrame:SetBackdropColor(0, .5, .25, .25);

HealthBarFrame:SetPoint("TOPLEFT", 0, 0);
HealthBarFrame:SetHeight(17);
HealthBarFrame:SetBackdrop(BarBackdrop);

PowerFrame:SetPoint("TOPRIGHT", -1, -34);
PowerFrame:SetWidth(150);
PowerFrame:SetHeight(13);
PowerFrame:SetBackdrop(FrameBackdrop);
PowerFrame:SetBackdropColor(0, .25, .5, .25);

PowerBarFrame:SetPoint("TOPLEFT", 0, 0);
PowerBarFrame:SetHeight(13);
PowerBarFrame:SetBackdrop(BarBackdrop);
PowerBarFrame:SetBackdropColor(0, .25, .75, 1);

StatusFrame:SetPoint("TOPLEFT", 0, -48);
StatusFrame:SetWidth(88);
StatusFrame:SetHeight(17);
StatusFrame:SetBackdrop(FrameBackdrop);
StatusFrame:SetBackdropColor(0, 0, 0, .25);

txtLeader:SetPoint("LEFT", 18, 1);
txtLeader:SetText("Leader");
txtRole:SetPoint("LEFT", 18, 1);
txtLevel:SetPoint("TOPLEFT", 1, -34);
txtLevel:SetWidth(18);
txtName:SetPoint("TOPLEFT", 70, -2);
--txtName:SetTextColor(ClassColor.r, ClassColor.g, ClassColor.b, 1);
--txtName:SetWidth(114);
--txtName:SetHeight(13);
txtSpeed:SetPoint("TOPRIGHT", -2, -1.75);
txtHealth:SetPoint("LEFT", HealthFrame, "LEFT", 1, 1);
txtPower:SetPoint("LEFT", PowerFrame, "LEFT", 1, 0.5);
txtHealthPercent:SetPoint("RIGHT", HealthFrame, "RIGHT", -1, 1);
txtPowerPercent:SetPoint("RIGHT", PowerFrame, "RIGHT", -1, 0.5);
txtStatus:SetPoint("CENTER", 0, 1);

local DeltaTime = 0;
local WaitTime = .5;

function TargetContainer_OnEvent(self, event, ...)
  if (event == "PLAYER_REGEN_DISABLED") then RegisterStateDriver(TargetContainer, "visibility", "[combat, exists] show; hide") end
  if (event == "PLAYER_REGEN_ENABLED") then UnregisterStateDriver(TargetContainer, "visibility") end
  if (event == "PLAYER_TARGET_CHANGED") then
    RegisterStateDriver(TargetContainer, "visibility", "[exists] show; hide");
    if UnitExists("target") then ModelFrame:SetUnit("target") end
  end

  DEFAULT_CHAT_FRAME:AddMessage("Target: " .. event .. " fired.");
end

function TargetContainer_Update(self, elapsed)
  if (WaitTime >= .5) then
    WaitTime = .1;
  end

  DeltaTime = DeltaTime + elapsed;
  if (DeltaTime >= WaitTime) then
    DeltaTime = 0;

    if (IsPartyLeader()) then
      LeaderFrame:Show();
    else
      LeaderFrame:Hide();
    end

    if (isTank) then
      RoleIcon:Show(); RoleIcon:SetTexCoord(0, 19/64, 22/64, 41/64); txtRole:SetText("Tank");
    elseif (isHealer) then
      RoleIcon:Show(); RoleIcon:SetTexCoord(20/64, 39/64, 1/64, 20/64); txtRole:SetText("Healer");
    elseif (isDamage) then
      RoleIcon:Show(); RoleIcon:SetTexCoord(20/64, 39/64, 22/64, 41/64); txtRole:SetText("Damage");
    else
      RoleIcon:Hide();
    end

    if (UnitFactionGroup("target")) == "Alliance" or (UnitFactionGroup("target")) == "Horde" then
      FactionIcon:SetTexture("Interface\\FriendsFrame\\PlusManz-" .. UnitFactionGroup("target"));
    end

    if (UnitIsDeadOrGhost("target")) then
      StatusFrame:SetBackdropColor(0, 0, 0, .35); txtStatus:SetText("Dead");
    elseif (UnitAffectingCombat("target")) then
      StatusFrame:SetBackdropColor(.35, 0, 0, .25); txtStatus:SetText("In Combat");
    else
      StatusFrame:SetBackdropColor(0, 0, 0, .25); txtStatus:SetText("");
    end
















    txtName:SetText(UnitName("target"));
    txtLevel:SetText(UnitLevel("target"));
    txtSpeed:SetText(format("%d%%",(GetUnitSpeed("target") / 7) * 100));
    txtHealth:SetText(UnitHealth("target"));
    txtHealthPercent:SetText(format("%.0f%%", (UnitHealth("target") / UnitHealthMax("target")) * 100));
    if (UnitPowerMax("target") == 0) then
      txtPower:SetText("None");
      txtPowerPercent:SetText("");
    else
      txtPower:SetText(UnitPower("target"));
      txtPowerPercent:SetText(format("%.0f%%", (UnitPower("target") / UnitPowerMax("target")) * 100));
    end

    if (UnitHealth("target") / UnitHealthMax("target") < .34) then
      HealthBarFrame:SetBackdropColor(1, 0, 0, 1);
    elseif (UnitHealth("target") / UnitHealthMax("target") < .5) then
      HealthBarFrame:SetBackdropColor(1, .88, .25, 1);
    else
      HealthBarFrame:SetBackdropColor(0, .75, .25, 1);
    end




    HealthBarFrame:SetWidth((UnitHealth("target") / UnitHealthMax("target")) * 150 - 0.1);
    PowerBarFrame:SetWidth((UnitPower("target") / UnitPowerMax("target")) * 150 - 0.1);
  end
end

function TargetContainer_OnHide (self)
  PlaySound("INTERFACESOUND_LOSTTARGETUNIT");
  CloseDropDownMenus();
end

TargetContainer:SetScript("OnEvent", TargetContainer_OnEvent);
TargetContainer:SetScript("OnUpdate", TargetContainer_Update);
TargetContainer:SetScript("OnHide", TargetContainer_OnHide);
