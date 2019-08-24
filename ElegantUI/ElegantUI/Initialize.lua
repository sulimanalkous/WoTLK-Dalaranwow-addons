--[[ Game (Override the default settings) ]]----------------------------------------------------------------------------------------

RegisterStateDriver(PlayerFrame, "visibility", "[exists] hide; hide");
RegisterStateDriver(PetFrame, "visibility", "[exists] hide; hide");
RegisterStateDriver(TargetFrame, "visibility", "[exists] hide; hide");
RegisterStateDriver(PartyMemberFrame1, "visibility", "[exists] hide; hide");
RegisterStateDriver(PartyMemberFrame2, "visibility", "[exists] hide; hide");
RegisterStateDriver(PartyMemberFrame3, "visibility", "[exists] hide; hide");
RegisterStateDriver(PartyMemberFrame4, "visibility", "[exists] hide; hide");
MultiBarRightButton1:SetPoint("TOPRIGHT", 0, 84);
MultiBarLeftButton1:SetPoint("TOPRIGHT", 0, 84);
--RegisterStateDriver(WatchFrame, "visibility", "[combat] hide; show");
CharacterAttributesFrame:Hide();
CharacterModelFrame:SetPoint("TOPLEFT", 66, -78);
CharacterModelFrame:SetHeight(320);

--[[ Frames SetBackdrop ]]---------------------------------------------------------------------------------------------------------
--Interface\\TargetingFrame\\UI-Classes-Circles

FrameBackdrop = {
  bgFile = "Interface\\CHATFRAME\\CHATFRAMEBACKGROUND",
  edgeFile = nil,
  tile = false, tileSize = 0, edgeSize = 0,
  insets = {left = 0, right = 0, top = 0, bottom = 0}
};

BorderBackdrop = {
  bgFile = "Interface\\CHATFRAME\\CHATFRAMEBACKGROUND",
  edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
  tile = true, tileSize = 16, edgeSize = 16,
  insets = {left = 4, right = 4, top = 4, bottom = 4}
};

BarBackdrop = {
  bgFile = "Interface\\Addons\\ElegantUI\\Media\\Textures\\Minimalist",
  edgeFile = nil,
  tile = false, tileSize = 0, edgeSize = 0,
  insets = {left = 0, right = 0, top = 0, bottom = 0}
}; -- bgFile = "Interface\\TargetingFrame\\UI-StatusBar"

--[[ Animation Eye textures ]]-------------------------------------------------------------------------------------------------------

LFG_EYE_TEXTURES = {};
LFG_EYE_TEXTURES["default"] = {file = "Interface\\LFGFrame\\LFG-Eye", width = 512, height = 256, frames = 29, iconSize = 64, delay = 0.1};
LFG_EYE_TEXTURES["raid"] = {file = "Interface\\LFGFrame\\LFR-Anim", width = 256, height = 256, frames = 16, iconSize = 64, delay = 0.05};
LFG_EYE_TEXTURES["unknown"] = {file = "Interface\\LFGFrame\\WaitAnim", width = 128, height = 128, frames = 4, iconSize = 64, delay = 0.25};

--[[ Player Container (PF = PlayerFrame) ]]-----------------------------------------------------------------------------------------

PF = CreateFrame("Button", nil, UIParent, "SecureUnitButtonTemplate");
PF:SetPoint("TOPLEFT", 16, -20);
PF:SetFrameStrata("BACKGROUND");
PF:SetSize(220, 48);
PF:SetToplevel(true);
PF:SetScale(1);
PF.unit = "player";
PF:RegisterForClicks("LeftButtonUp", "RightButtonUp");
PF:SetBackdrop(FrameBackdrop);
PF:SetBackdropColor(0, 0, 0, .25);

PFMenu = function()
  ToggleDropDownMenu(1, nil, PlayerFrameDropDown, PF, 88, -3);
end
SecureUnitButton_OnLoad(PF, "player", PFMenu);

PF:RegisterEvent("UNIT_PORTRAIT_UPDATE");
PF:RegisterEvent("UNIT_HEALTH");
    PF:RegisterEvent("UNIT_MANA");
    PF:RegisterEvent("UNIT_RAGE");
    PF:RegisterEvent("UNIT_FOCUS");
    PF:RegisterEvent("UNIT_ENERGY");
    PF:RegisterEvent("UNIT_RUNIC_POWER");
PF:RegisterEvent("UNIT_LEVEL");
PF:RegisterEvent("UNIT_FACTION");
PF:RegisterEvent("PLAYER_ENTERING_WORLD"); -- Fired when reload UI: enter world or (enters/leaves an instance or battleground) or respawns from graveyard
PF:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE");
PF:RegisterEvent("PLAYER_REGEN_ENABLED");
PF:RegisterEvent("PLAYER_FLAGS_CHANGED");
PF:RegisterEvent("SPELL_UPDATE_USABLE");
PF:RegisterEvent("MIRROR_TIMER_START");
PF:RegisterEvent("PARTY_MEMBERS_CHANGED");
PF:RegisterEvent("PARTY_LEADER_CHANGED");
PF:RegisterEvent("RAID_ROSTER_UPDATE");
PF:RegisterEvent("PARTY_LOOT_METHOD_CHANGED");
PF:RegisterEvent("PLAYER_ROLES_ASSIGNED");
PF:RegisterEvent("CHAT_MSG_SYSTEM");
PF:RegisterEvent("UNIT_PET");

--[[ Target Container (TF = TargetFrame) ]]-----------------------------------------------------------------------------------------

TF = CreateFrame("Button", nil, PF, "SecureUnitButtonTemplate");
TF:SetPoint("LEFT", 252, 0); -- Start moving from left edge point of TF
TF:SetFrameStrata("MEDIUM");
TF:SetSize(220, 48);
TF:SetToplevel(true);
TF:SetScale(1);
TF.unit = "target";
TF:RegisterForClicks("RightButtonUp");
TF:SetBackdrop(FrameBackdrop);
TF:SetBackdropColor(0, 0, 0, .25);

TFMenu = function()
  ToggleDropDownMenu(1, nil, TargetFrameDropDown, TF, 88, -3);
end
SecureUnitButton_OnLoad(TF, "target", TFMenu);

TF:RegisterEvent("UNIT_HEALTH");
TF:RegisterEvent("UNIT_" .. select(2, UnitPowerType("target")));
TF:RegisterEvent("UNIT_THREAT_LIST_UPDATE");
TF:RegisterEvent("PLAYER_TARGET_CHANGED");

--[[ Party Container (PRF = PartyMemberFrame) ]]--------------------------------------------------------------------------------

PMF = CreateFrame("Frame", nil, PF);
PMF:SetPoint("TOPLEFT", -21, -228);
PMF:SetFrameStrata("MEDIUM");
PMF:SetSize(247, 393);
PMF:SetToplevel(true);
PMF:SetScale(0.75);
--PMF:SetBackdrop(FrameBackdrop);
--PMF:SetBackdropColor(0, 0, 0, .1);

--[[ Player Stats (Player PaperDollFrame ]]-----------------------------------------------------------------------------------------

StatsFrame = CreateFrame("Frame", nil, PaperDollFrame);
StatsFrame:SetPoint("TOPLEFT", PaperDollFrame, "TOPRIGHT", -35, 12);
StatsFrame:SetSize(157, 474);
StatsFrame:SetToplevel(true);
StatsFrame:SetBackdrop(BorderBackdrop);
StatsFrame:SetBackdropColor(0.1, 0.1, 0.1, .65);
StatsFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);

StatsFrame:RegisterEvent("UNIT_LEVEL");
StatsFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
StatsFrame:RegisterEvent("PLAYER_DAMAGE_DONE_MODS");
StatsFrame:RegisterEvent("UNIT_STATS");
StatsFrame:RegisterEvent("UNIT_DAMAGE");
StatsFrame:RegisterEvent("UNIT_ATTACK");
StatsFrame:RegisterEvent("UNIT_ATTACK_POWER");
StatsFrame:RegisterEvent("UNIT_ATTACK_SPEED");
StatsFrame:RegisterEvent("UNIT_RANGEDDAMAGE");
StatsFrame:RegisterEvent("UNIT_RANGED_ATTACK_POWER");
StatsFrame:RegisterEvent("UNIT_RESISTANCES");

--[[ Console Variables ]]------------------------------------------------------------------------------------------------------------

local gxFrame = CreateFrame("Frame");
gxFrame:RegisterEvent("CVAR_UPDATE");
gxFrame:SetScript("OnEvent", function()
  if (event == "CVAR_UPDATE") then 
    SetCVar("gxCursor", 1 - GetCVar("gxWindow")); -- Fix Mouse pointer is not visible in FULLSCREEN mode
    SetCVar("useUiScale", 1); -- UI Scale (Disable 0, Enable 1)
    SetCVar("uiscale", 0.85); -- UI Scale (Range from 0.65 to 1.15, Unscaled 1)
    --SetCVar("farclip", 1600); -- View Distance (Range from 185 to 1277, Maximum 1600)
    SetCVar("violenceLevel", 5); -- Violence level in combat - control blood level and combat effects (Range from 0 to 5, Default 2)
    SetCVar("spellEffectLevel", 20); -- The visual intensity effect of spell graphics (Range from 1 to 1000, Default 10)
    SetCVar("taintLog", 1); -- Save errors in "logs/taint" file (Disable 0, Enable basic 1, Enable full 2)
  end
end);

