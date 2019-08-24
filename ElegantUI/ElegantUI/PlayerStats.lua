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

-- Ranged Damage per Second
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

local BaseState = CreateFrame("Frame", nil, StatsFrame);
BaseState:SetPoint("TOPLEFT", StatsFrame, "TOPLEFT", 6, -17);
BaseState:SetSize(144, 13);
fontstring = BaseState:CreateFontString(nil, "BACKGROUND", "GameFontHighlightSmall");
fontstring:SetPoint("BOTTOM", BaseState, "TOP", 0, 1);
fontstring:SetText("Base State");

local Melee = CreateFrame("Frame", nil, StatsFrame);
Melee:SetPoint("TOPLEFT", StatsFrame, "TOPLEFT", 6, -93);
Melee:SetSize(144, 13);
fontstring = Melee:CreateFontString(nil, "BACKGROUND", "GameFontHighlightSmall");
fontstring:SetPoint("BOTTOM", Melee, "TOP", 0, 1);
fontstring:SetText("Melee");

local Ranged = CreateFrame("Frame", nil, StatsFrame);
Ranged:SetPoint("TOPLEFT", StatsFrame, "TOPLEFT", 6, -193);
Ranged:SetSize(144, 13);
fontstring = Ranged:CreateFontString(nil, "BACKGROUND", "GameFontHighlightSmall");
fontstring:SetPoint("BOTTOM", Ranged, "TOP", 0, 1);
fontstring:SetText("Ranged");

local Spell = CreateFrame("Frame", nil, StatsFrame);
Spell:SetPoint("TOPLEFT", StatsFrame, "TOPLEFT", 6, -281);
Spell:SetSize(144, 13);
fontstring = Spell:CreateFontString(nil, "BACKGROUND", "GameFontHighlightSmall");
fontstring:SetPoint("BOTTOM", Spell, "TOP", 0, 1);
fontstring:SetText("Spell");

local Defenses = CreateFrame("Frame", nil, StatsFrame);
Defenses:SetPoint("TOPLEFT", StatsFrame, "TOPLEFT", 6, -370);
Defenses:SetSize(144, 13);
fontstring = Defenses:CreateFontString(nil, "BACKGROUND", "GameFontHighlightSmall");
fontstring:SetPoint("BOTTOM", Defenses, "TOP", 0, 1);
fontstring:SetText("Defenses");

local STR = CreateFrame("Frame", "ContentStat1", BaseState, "StatFrameTemplate");
STR:SetPoint("TOPLEFT", BaseState, "BOTTOMLEFT", 0, 13);
STR:SetSize(144, 13);

local AGI = CreateFrame("Frame", "ContentStat2", BaseState, "StatFrameTemplate");
AGI:SetPoint("TOPLEFT", STR, "BOTTOMLEFT", 0, 1);
AGI:SetSize(144, 13);

local STA = CreateFrame("Frame", "ContentStat3", BaseState, "StatFrameTemplate");
STA:SetPoint("TOPLEFT", AGI, "BOTTOMLEFT", 0, 1);
STA:SetSize(144, 13);

local INT = CreateFrame("Frame", "ContentStat4", BaseState, "StatFrameTemplate");
INT:SetPoint("TOPLEFT", STA, "BOTTOMLEFT", 0, 1);
INT:SetSize(144, 13);

local SPI = CreateFrame("Frame", "ContentStat5", BaseState, "StatFrameTemplate");
SPI:SetPoint("TOPLEFT", INT, "BOTTOMLEFT", 0, 1);
SPI:SetSize(144, 13);

local MD = CreateFrame("Frame", "ContentStatMeleeDamage", Melee, "StatFrameTemplate");
MD:SetPoint("TOPLEFT", Melee, "BOTTOMLEFT", 0, 13);
MD:SetSize(144, 13);

local MPS = CreateFrame("Frame", "ContentStatMeleeDPS", Melee, "StatFrameTemplate");
MPS:SetPoint("TOPLEFT", MD, "BOTTOMLEFT", 0, 1);
MPS:SetSize(144, 13);

local MP = CreateFrame("Frame", "ContentStatMeleePower", Melee, "StatFrameTemplate");
MP:SetPoint("TOPLEFT", MPS, "BOTTOMLEFT", 0, 1);
MP:SetSize(144, 13);

local MS = CreateFrame("Frame", "ContentStatMeleeSpeed", Melee, "StatFrameTemplate");
MS:SetPoint("TOPLEFT", MP, "BOTTOMLEFT", 0, 1);
MS:SetSize(144, 13);

local MH = CreateFrame("Frame", "ContentStatMeleeHit", Melee, "StatFrameTemplate");
MH:SetPoint("TOPLEFT", MS, "BOTTOMLEFT", 0, 1);
MH:SetSize(144, 13);

local MC = CreateFrame("Frame", "ContentStatMeleeCrit", Melee, "StatFrameTemplate");
MC:SetPoint("TOPLEFT", MH, "BOTTOMLEFT", 0, 1);
MC:SetSize(144, 13);

local ME = CreateFrame("Frame", "ContentStatMeleeExpert", Melee, "StatFrameTemplate");
ME:SetPoint("TOPLEFT", MC, "BOTTOMLEFT", 0, 1);
ME:SetSize(144, 13);

local RD = CreateFrame("Frame", "ContentStatRangeDamage", Ranged, "StatFrameTemplate");
RD:SetPoint("TOPLEFT", Ranged, "BOTTOMLEFT", 0, 13);
RD:SetSize(144, 13);

local RPS = CreateFrame("Frame", "ContentStatRangeDPS", Ranged, "StatFrameTemplate");
RPS:SetPoint("TOPLEFT", RD, "BOTTOMLEFT", 0, 1);
RPS:SetSize(144, 13);

local RP = CreateFrame("Frame", "ContentStatRangePower", Ranged, "StatFrameTemplate");
RP:SetPoint("TOPLEFT", RPS, "BOTTOMLEFT", 0, 1);
RP:SetSize(144, 13);

local RS = CreateFrame("Frame", "ContentStatRangeSpeed", Ranged, "StatFrameTemplate");
RS:SetPoint("TOPLEFT", RP, "BOTTOMLEFT", 0, 1);
RS:SetSize(144, 13);

local RH = CreateFrame("Frame", "ContentStatRangeHit", Ranged, "StatFrameTemplate");
RH:SetPoint("TOPLEFT", RS, "BOTTOMLEFT", 0, 1);
RH:SetSize(144, 13);

local RC = CreateFrame("Frame", "ContentStatRangeCrit", Ranged, "StatFrameTemplate");
RC:SetPoint("TOPLEFT", RH, "BOTTOMLEFT", 0, 1);
RC:SetSize(144, 13);

local SD = CreateFrame("Frame", "ContentStatSpellDamage", Spell, "StatFrameTemplate");
SD:SetPoint("TOPLEFT", Spell, "BOTTOMLEFT", 0, 13);
SD:SetSize(144, 13);

local SHE = CreateFrame("Frame", "ContentStatSpellHeal", Spell, "StatFrameTemplate");
SHE:SetPoint("TOPLEFT", SD, "BOTTOMLEFT", 0, 1);
SHE:SetSize(144, 13);

local SHI = CreateFrame("Frame", "ContentStatSpellHit", Spell, "StatFrameTemplate");
SHI:SetPoint("TOPLEFT", SHE, "BOTTOMLEFT", 0, 1);
SHI:SetSize(144, 13);

local SC = CreateFrame("Frame", "ContentStatSpellCrit", Spell, "StatFrameTemplate");
SC:SetPoint("TOPLEFT", SHI, "BOTTOMLEFT", 0, 1);
SC:SetSize(144, 13);

local SHA = CreateFrame("Frame", "ContentStatSpellHaste", Spell, "StatFrameTemplate");
SHA:SetPoint("TOPLEFT", SC, "BOTTOMLEFT", 0, 1);
SHA:SetSize(144, 13);

local SR = CreateFrame("Frame", "ContentStatSpellRegen", Spell, "StatFrameTemplate");
SR:SetPoint("TOPLEFT", SHA, "BOTTOMLEFT", 0, 1);
SR:SetSize(144, 13);

local ARMR = CreateFrame("Frame", "ContentStatArmor", Defenses, "StatFrameTemplate");
ARMR:SetPoint("TOPLEFT", Defenses, "BOTTOMLEFT", 0, 13);
ARMR:SetSize(144, 13);

local AR = CreateFrame("Frame", "ContentStatArmorReduction", Defenses, "StatFrameTemplate");
AR:SetPoint("TOPLEFT", ARMR, "BOTTOMLEFT", 0, 1);
AR:SetSize(144, 13);

local DEF = CreateFrame("Frame", "ContentStatDefense", Defenses, "StatFrameTemplate");
DEF:SetPoint("TOPLEFT", AR, "BOTTOMLEFT", 0, 1);
DEF:SetSize(144, 13);

local DODGE = CreateFrame("Frame", "ContentStatDodge", Defenses, "StatFrameTemplate");
DODGE:SetPoint("TOPLEFT", DEF, "BOTTOMLEFT", 0, 1);
DODGE:SetSize(144, 13);

local PARRY = CreateFrame("Frame", "ContentStatParry", Defenses, "StatFrameTemplate");
PARRY:SetPoint("TOPLEFT", DODGE, "BOTTOMLEFT", 0, 1);
PARRY:SetSize(144, 13);

local BLOCK = CreateFrame("Frame", "ContentStatBlock", Defenses, "StatFrameTemplate");
BLOCK:SetPoint("TOPLEFT", PARRY, "BOTTOMLEFT", 0, 1);
BLOCK:SetSize(144, 13);

local BV = CreateFrame("Frame", "ContentStatBlockValue", Defenses, "StatFrameTemplate");
BV:SetPoint("TOPLEFT", BLOCK, "BOTTOMLEFT", 0, 1);
BV:SetSize(144, 13);

local RES = CreateFrame("Frame", "ContentStatResil", Defenses, "StatFrameTemplate");
RES:SetPoint("TOPLEFT", BV, "BOTTOMLEFT", 0, 1);
RES:SetSize(144, 13);

function PrintStats()
	PaperDollFrame_SetStat(STR, 1);
	PaperDollFrame_SetStat(AGI, 2);
	PaperDollFrame_SetStat(STA, 3);
	PaperDollFrame_SetStat(INT, 4);
	PaperDollFrame_SetStat(SPI, 5);

	PaperDollFrame_SetDamage(MD);
	MD:SetScript("OnEnter", CharacterDamageFrame_OnEnter);
	PaperDollFrame_SetMeleeDPS(MPS);
	PaperDollFrame_SetAttackSpeed(MS);
	PaperDollFrame_SetAttackPower(MP);
	PaperDollFrame_SetRating(MH, CR_HIT_MELEE);
	PaperDollFrame_SetMeleeCritChance(MC);
	PaperDollFrame_SetExpertise(ME);

	PaperDollFrame_SetRangedDamage(RD);
	RD:SetScript("OnEnter", CharacterRangedDamageFrame_OnEnter);
	PaperDollFrame_SetRangedDPS(RPS);
	PaperDollFrame_SetRangedAttackPower(RP);
	PaperDollFrame_SetRangedAttackSpeed(RS);
	PaperDollFrame_SetRating(RH, CR_HIT_RANGED);
	PaperDollFrame_SetRangedCritChance(RC);

	PaperDollFrame_SetSpellBonusDamage(SD);
	SD:SetScript("OnEnter", CharacterSpellBonusDamage_OnEnter);
	PaperDollFrame_SetSpellBonusHealing(SHE);
	PaperDollFrame_SetRating(SHI, CR_HIT_SPELL);
	PaperDollFrame_SetSpellCritChance(SC);
	SC:SetScript("OnEnter", CharacterSpellCritChance_OnEnter);
	PaperDollFrame_SetSpellHaste(SHA);
	PaperDollFrame_SetManaRegen(SR);

	PaperDollFrame_SetArmor(ARMR);
	PaperDollFrame_SetArmorReduction(AR);
	PaperDollFrame_SetDefense(DEF);
	PaperDollFrame_SetDodge(DODGE);
	PaperDollFrame_SetParry(PARRY);
	PaperDollFrame_SetBlock(BLOCK);
	PaperDollFrame_SetBlockValue(BV);
	PaperDollFrame_SetResilience(RES);
end

StatsFrame:SetScript("OnLoad", function(self)
  Stats_OnLoad();
end);

StatsFrame:SetScript("OnShow", function(self)
  PrintStats();
end);

StatsFrame:SetScript("OnEvent", function(self, event, ...)
  local arg1 = ...;

  if (arg1 == "player" and (
    event == "UNIT_LEVEL" or
    event == "PLAYER_EQUIPMENT_CHANGED" or
    event == "PLAYER_DAMAGE_DONE_MODS" or
    event == "UNIT_STATS" or
    event == "UNIT_DAMAGE" or
    event == "UNIT_ATTACK" or
    event == "UNIT_ATTACK_POWER" or
    event == "UNIT_ATTACK_SPEED" or
    event == "UNIT_RANGEDDAMAGE" or
    event == "UNIT_RANGED_ATTACK_POWER" or
    event == "UNIT_RESISTANCES"
  )) then PaperDollFrame_UpdateStats = PrintStats;
	end
end);

StatsButton = CreateFrame("Button", nil, PaperDollFrame, "UIPanelButtonTemplate");
StatsButton:SetPoint("BOTTOMRIGHT", PaperDollFrame, -44, 85);
StatsButton:SetSize(47, 22);
StatsButton:SetText("Stats");

local StatsShown = true;

StatsButton:SetScript("OnClick", function(self)
	StatsShown = not StatsShown;
	if (StatsShown) then
		StatsFrame:Show();
	else
		StatsFrame:Hide();
	end
end);
