--<| Console Variables |>------------------------------------------------------------------------------------------------------------

--SetCVar("uiscale", 0.85); -- UI Scale (Range from 0.65 to 1.15, Unscaled 1)
SetCVar("farclip", 1600); -- View Distance (Range from 185 to 1250, Maximum 1600)
SetCVar("spellEffectLevel", 20); -- The visual intensity effect of spell graphics (Range from 1 to 1000, Default 10)
SetCVar("violenceLevel", 5); -- Violence level in combat - control blood level and combat effects (Range from 0 to 5, Default 2)

--<| Frames SetBackdrop |>---------------------------------------------------------------------------------------------------------

FrameBackdrop = {
  bgFile = "Interface\\CHATFRAME\\CHATFRAMEBACKGROUND",
  edgeFile = nil,
  tile = false, tileSize = 0, edgeSize = 0,
  insets = {left = 0, right = 0, top = 0, bottom = 0}
};

BarBackdrop = {
  bgFile = "Interface\\Addons\\NewAge\\Media\\Textures\\Minimalist",
  edgeFile = nil,
  tile = false, tileSize = 0, edgeSize = 0,
  insets = {left = 0, right = 0, top = 0, bottom = 0}
}; --bgFile = "Interface\\TargetingFrame\\UI-StatusBar"

--<| Player Container |>-------------------------------------------------------------------------------------------------------------

PlayerContainer = CreateFrame("Button", nil, UIParent, "SecureUnitButtonTemplate");
PlayerContainer:SetFrameStrata("BACKGROUND");
PlayerContainer:SetPoint("TOPLEFT", 21, -50); -- Default = -24, TitanPanel = -50
PlayerContainer:SetWidth(220);
PlayerContainer:SetHeight(48);
PlayerContainer:SetToplevel(true);
PlayerContainer:SetScale(1);
PlayerContainer:SetAttribute("unit", "player");
PlayerContainer:RegisterForClicks("LeftButtonUp", "RightButtonUp");
PlayerContainer:SetBackdrop(FrameBackdrop);
PlayerContainer:SetBackdropColor(0, 0, 0, .25);

PlayerContainerMenu = function()
  ToggleDropDownMenu(1, nil, PlayerFrameDropDown, PlayerContainer, 92, -3);
end
SecureUnitButton_OnLoad(PlayerContainer, "player", PlayerContainerMenu);

PlayerContainer:RegisterEvent("PLAYER_ENTERING_WORLD");
PlayerContainer:RegisterEvent("PARTY_MEMBERS_CHANGED");
PlayerContainer:RegisterEvent("PARTY_LEADER_CHANGED");
PlayerContainer:RegisterEvent("PARTY_LOOT_METHOD_CHANGED");
PlayerContainer:RegisterEvent("RAID_ROSTER_UPDATE");
PlayerContainer:RegisterEvent("READY_CHECK");
PlayerContainer:RegisterEvent("READY_CHECK_CONFIRM");
PlayerContainer:RegisterEvent("READY_CHECK_FINISHED");
PlayerContainer:RegisterEvent("PLAYER_FLAGS_CHANGED");
PlayerContainer:RegisterEvent("PLAYER_ROLES_ASSIGNED");

--<| Target Container |>-------------------------------------------------------------------------------------------------------------

TargetContainer = CreateFrame("Button", nil, UIParent, "SecureUnitButtonTemplate");
TargetContainer:SetFrameStrata("BACKGROUND");
TargetContainer:SetPoint("TOPLEFT", 272, -50);
TargetContainer:SetWidth(220);
TargetContainer:SetHeight(48);
TargetContainer:SetToplevel(true);
TargetContainer:SetScale(1);
TargetContainer:RegisterForClicks("RightButtonUp");
TargetContainer:SetBackdrop(FrameBackdrop);
TargetContainer:SetBackdropColor(0, 0, 0, .25);
TargetContainer:Hide();

TargetContainerMenu = function()
  ToggleDropDownMenu(1, nil, TargetFrameDropDown, TargetContainer, 92, -3);
end
SecureUnitButton_OnLoad(TargetContainer, "target", TargetContainerMenu);

TargetContainer:RegisterEvent("PLAYER_TARGET_CHANGED");
TargetContainer:RegisterEvent("PLAYER_REGEN_DISABLED");
TargetContainer:RegisterEvent("PLAYER_REGEN_ENABLED");

--<| Hide Frames |>-----------------------------------------------------------------------------------------------------------------

PlayerFrame:SetScript("OnEvent", nil);
PlayerFrame:Hide();
WatchFrame:Show();

if (PlayerFrame:IsShown()) then
  PlayerContainer:Hide();
else
  TargetFrame:SetScript("OnEvent", nil);
  TargetFrame:Hide();
end

--<| Player Stats |>------------------------------------------------------------------------------------------------------------------

-- Hide Stats panels and Expand Player high
function Stats_OnLoad()
	CharacterAttributesFrame:Hide();
	CharacterModelFrame:SetPoint("TOPLEFT", 66, -78);
	CharacterModelFrame:SetHeight(320);
	PaperDollFrame_UpdateStats = NewPaperDollFrame_UpdateStats;
end

-- Melee Damage per Second
function PaperDollFrame_SetMeleeDPS(statFrame)
	local minDamage, maxDamage, minOffHandDamage, maxOffHandDamage, physicalBonusPos, physicalBonusNeg, percent = UnitDamage("player");
	local speed, offhandSpeed = UnitAttackSpeed("player");

	minDamage = (minDamage / percent) - physicalBonusPos - physicalBonusNeg;
	maxDamage = (maxDamage / percent) - physicalBonusPos - physicalBonusNeg;
	local baseDamage = (minDamage + maxDamage) * 0.5;
	local fullDamage = (baseDamage + physicalBonusPos + physicalBonusNeg) * percent;
	local text = format("%.2f", max(fullDamage,1) / speed);
	local tooltipText = format("Main Hand %.2f", max(fullDamage,1) / speed);

	-- Off Hand Damage
	if ( offhandSpeed ) then
		minOffHandDamage = (minOffHandDamage / percent) - physicalBonusPos - physicalBonusNeg;
		maxOffHandDamage = (maxOffHandDamage / percent) - physicalBonusPos - physicalBonusNeg;
		local offhandBaseDamage = (minOffHandDamage + maxOffHandDamage) * 0.5;
		local offhandFullDamage = (offhandBaseDamage + physicalBonusPos + physicalBonusNeg) * percent;
		text = text .." / ".. format("%.2f", max(offhandFullDamage,1) / offhandSpeed);
		tooltipText = tooltipText .. " / " .. format("Off Hand %.2f", max(offhandFullDamage,1) / offhandSpeed);
	end

	PaperDollFrame_SetLabelAndText(statFrame, "DPS", text);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. DAMAGE_PER_SECOND .. FONT_COLOR_CODE_CLOSE;
	statFrame.tooltip2 = tooltipText;
	statFrame:Show();
end

-- Rnaged Damage per Second
function PaperDollFrame_SetRangedDPS(statFrame)
	-- If no ranged attack then set to n/a
	local hasRelic = UnitHasRelicSlot("player");	
	local rangedTexture = GetInventoryItemTexture("player", 18);
	if ( rangedTexture and not hasRelic ) then
		PaperDollFrame.noRanged = nil;
	else
		PaperDollFrame.noRanged = 1;
		return;
	end

	local rangedAttackSpeed, minDamage, maxDamage, physicalBonusPos, physicalBonusNeg, percent = UnitRangedDamage("player");

	minDamage = (minDamage / percent) - physicalBonusPos - physicalBonusNeg;
	maxDamage = (maxDamage / percent) - physicalBonusPos - physicalBonusNeg;
	local baseDamage = (minDamage + maxDamage) * 0.5;
	local fullDamage = (baseDamage + physicalBonusPos + physicalBonusNeg) * percent;

	PaperDollFrame_SetLabelAndText(statFrame, "DPS", format("%.2f", max(fullDamage,1) / rangedAttackSpeed));
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. DAMAGE_PER_SECOND .. FONT_COLOR_CODE_CLOSE;
	statFrame.tooltip2 = format("Ranged %.2f", max(fullDamage,1) / rangedAttackSpeed);
	statFrame:Show();
end

-- Armor Reduction
function PaperDollFrame_SetArmorReduction(statFrame)
	local effectiveArmor = UnitArmor("player");
	local armorReduction = PaperDollFrame_GetArmorReduction(effectiveArmor, UnitLevel("player"));
	PaperDollFrame_SetLabelAndText(statFrame, "Armor Reduction", format("%.2f%%", armorReduction));
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. format("Armor Reduction") .. FONT_COLOR_CODE_CLOSE;
	statFrame.tooltip2 = format(DEFAULT_STATARMOR_TOOLTIP, armorReduction);	
	statFrame:Show();
end

-- Block Value
function PaperDollFrame_SetBlockValue(statFrame)
	local ShieldBlock = GetShieldBlock();
	PaperDollFrame_SetLabelAndText(statFrame, "Block Value", ShieldBlock);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. format("Block Value %d", ShieldBlock) .. FONT_COLOR_CODE_CLOSE;
	statFrame.tooltip2 = format("Your block stops %d damage", ShieldBlock);
	statFrame:Show();
end
