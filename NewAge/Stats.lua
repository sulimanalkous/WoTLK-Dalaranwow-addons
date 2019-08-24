-- Print Resault
function NewPaperDollFrame_UpdateStats()
	PrintStats();
end

function PrintStats()
  -- Main Frame (Container)
  StatsContainer:SetParent(PaperDollFrame);
  StatsContainer:SetPoint("TOPLEFT", "PaperDollFrame",  "TOPRIGHT", -35, 12);
  StatsContainer:SetWidth(157);
  StatsContainer:SetHeight(474);
  StatsContainer:SetToplevel(true);
  StatsContainer:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = {left = 4, right = 4, top = 4, bottom = 4}
  });
  StatsContainer:SetBackdropColor(0.1, 0.1, 0.1, 0.65);
  StatsContainer:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);

	local str = ContentStat1;
	local agi = ContentStat2;
	local sta = ContentStat3;
	local int = ContentStat4;
	local spi = ContentStat5;

	local md = ContentStatMeleeDamage;
	local mps = ContentStatMeleeDPS;
	local mp = ContentStatMeleePower;
	local ms = ContentStatMeleeSpeed;
	local mh = ContentStatMeleeHit;
	local mc = ContentStatMeleeCrit;
	local me = ContentStatMeleeExpert;

	local rd = ContentStatRangeDamage;
	local rps = ContentStatRangeDPS;
	local rp = ContentStatRangePower;
	local rs = ContentStatRangeSpeed;
	local rh = ContentStatRangeHit;
	local rc = ContentStatRangeCrit;

	local sd = ContentStatSpellDamage;
	local she = ContentStatSpellHeal;
	local shi = ContentStatSpellHit;
	local sc = ContentStatSpellCrit;
	local sha = ContentStatSpellHaste;
	local sr = ContentStatSpellRegen;

	local armor = ContentStatArmor;
	local ar = ContentStatArmorReduction;
	local def = ContentStatDefense;
	local dodge = ContentStatDodge;
	local parry = ContentStatParry;
	local block = ContentStatBlock;
	local bv = ContentStatBlockValue;
	local res = ContentStatResil;

	PaperDollFrame_SetStat(str, 1);
	PaperDollFrame_SetStat(agi, 2);
	PaperDollFrame_SetStat(sta, 3);
	PaperDollFrame_SetStat(int, 4);
	PaperDollFrame_SetStat(spi, 5);

	PaperDollFrame_SetDamage(md);
	md:SetScript("OnEnter", CharacterDamageFrame_OnEnter);
	PaperDollFrame_SetMeleeDPS(mps);
	PaperDollFrame_SetAttackSpeed(ms);
	PaperDollFrame_SetAttackPower(mp);
	PaperDollFrame_SetRating(mh, CR_HIT_MELEE);
	PaperDollFrame_SetMeleeCritChance(mc);
	PaperDollFrame_SetExpertise(me);

	PaperDollFrame_SetRangedDamage(rd);
	rd:SetScript("OnEnter", CharacterRangedDamageFrame_OnEnter);
	PaperDollFrame_SetRangedDPS(rps);
	PaperDollFrame_SetRangedAttackPower(rp);
	PaperDollFrame_SetRangedAttackSpeed(rs);
	PaperDollFrame_SetRating(rh, CR_HIT_RANGED);
	PaperDollFrame_SetRangedCritChance(rc);

	PaperDollFrame_SetSpellBonusDamage(sd);
	sd:SetScript("OnEnter", CharacterSpellBonusDamage_OnEnter);
	PaperDollFrame_SetSpellBonusHealing(she);
	PaperDollFrame_SetRating(shi, CR_HIT_SPELL);
	PaperDollFrame_SetSpellCritChance(sc);
	sc:SetScript("OnEnter", CharacterSpellCritChance_OnEnter);
	PaperDollFrame_SetSpellHaste(sha);
	PaperDollFrame_SetManaRegen(sr);

	PaperDollFrame_SetArmor(armor);
	PaperDollFrame_SetArmorReduction(ar);
	PaperDollFrame_SetDefense(def);
	PaperDollFrame_SetDodge(dodge);
	PaperDollFrame_SetParry(parry);
	PaperDollFrame_SetBlock(block);
	PaperDollFrame_SetBlockValue(bv);
	PaperDollFrame_SetResilience(res);
end

local PDF_Display = true;

function PDF_OnClick()
	PDF_Display = not PDF_Display;
	if PDF_Display then
		StatsContainer:Show();
	else
		StatsContainer:Hide();
	end
end
