-- ForteXorcist v1.965.3 by Xus 05-10-2010 for 3.3.5 & 4.0.1
-- Module started by Lurosara

-- TODO:
-- Forte_Timer:
--   Feral: Feral Charge Effect (Possibly too painful to implement in a reasonable manner.)

if FW.CLASS == "DRUID" then
	local FW = FW;
	local FWL = FW.L;
	local DR = FW:ClassModule("Druid");
	
	local CA = FW.Modules.Casting;
	local ST = FW.Modules.Timer;
	local CD = FW.Modules.Cooldown;
	--
	-- Spell Timer
	--
	-- Note that the Cyclone timer is always going to be inaccurate past the first cast
	
	-- Register ID renames first!
	FW:RegisterCustomName(50334,FWL.BERSERK_FERAL);
	FW:RegisterSet("Thunderheart Regalia",31043,31035,31040,31046,31049,34572,34446,34555);
	FW:RegisterSet("Nordrassil Raiment",30216,30217,30219,30220,30220);	
	
	if ST then
		--
		-- Spells
		-- istype: ST.DEFAULT ST.SHARED ST.UNIQUE ST.PET ST.CHARM ST.COOLDOWN ST.HEAL ST.BUFF
		-- spell, hastarget, duration, isdot, istype, reducedinpvp, texture, maxstacks
		
		-- id/name, ticks total
		ST:RegisterDrain(16914,	10); -- Hurricane

		-- Balance Spells
		ST:RegisterSpell(33786,	1,006,0,ST.UNIQUE,06); -- Cyclone
		ST:RegisterSpell(19975,	1,027,0,ST.UNIQUE,12); -- Entangling Roots
			ST:RegisterSpellModRank(19975, 1, -15);
			ST:RegisterSpellModRank(19975, 2, -12);
			ST:RegisterSpellModRank(19975, 3, -9);
			ST:RegisterSpellModRank(19975, 4, -6);
			ST:RegisterSpellModRank(19975, 5, -3);
		ST:RegisterSpell(770,	1,040,0,ST.DEFAULT); -- Faerie Fire
		ST:RegisterSpell(33831,	0,030,0,ST.PET); -- Force of Nature
		ST:RegisterSpell(2637,	1,040,0,ST.UNIQUE,12); -- Hibernate
			ST:RegisterSpellModRank(2637, 1, -20);
			ST:RegisterSpellModRank(2637, 2, -10);
		ST:RegisterSpell(5570,	1,012,1,ST.DEFAULT); -- Insect Swarm
			ST:RegisterTickSpeed(5570, 2); -- set tick speed to 2 instead of 3
			ST:RegisterSpellModTlnt(5570,57865,1,2); -- Nature's Splendor
		ST:RegisterSpell(8921,	1,012,1,ST.DEFAULT); -- Moonfire
			ST:RegisterSpellModSetB(8921,"Thunderheart Regalia", 2, 3);
			ST:RegisterSpellModTlnt(8921,57865,1,3); -- Nature's Splendor
		
		-- Feral Spells
		ST:RegisterSpell(5211,	1,004,0,ST.UNIQUE); -- Bash
			ST:RegisterSpellModTlnt(5211,16940,1,0.5); -- 16940 = Brutal Impact
			ST:RegisterSpellModTlnt(5211,16940,2,1);
		ST:RegisterSpell(99,	1,030,0,ST.UNIQUE); -- Demoralizing Roar
		ST:RegisterSpell(5209,	1,006,0,ST.UNIQUE); -- Challenging Roar
		ST:RegisterSpell(16857,	1,040,0,ST.DEFAULT); -- Faerie Fire (Feral)
		ST:RegisterSpell(6795,	1,003,0,ST.UNIQUE); -- Growl
		ST:RegisterSpell(33878,	1,012,0,ST.SHARED); -- Mangle - Bear
		ST:RegisterSpell(33876,	1,012,0,ST.SHARED); -- Mangle - Cat
		ST:RegisterSpell(9005,	1,003,0,ST.DEFAULT); -- Pounce
			ST:RegisterSpellModTlnt(9005,16940,1,0.5);
			ST:RegisterSpellModTlnt(9005,16940,2,1);
		ST:RegisterSpellAdd(9005, 9007); -- 9007 = Pounce Bleed
		ST:RegisterSpell(9007,	1,018,1,ST.DEFAULT); -- Pounce Bleed
		ST:RegisterSpell(1822,	1,009,1,ST.DEFAULT); -- Rake
		ST:RegisterSpell(1079,	1,012,1,ST.DEFAULT); -- Rip
			ST:RegisterTickSpeed(1079, 2); -- set tick speed to 2 instead of 3
			ST:RegisterSpellModGlph(1079,54860,1,4); -- glyph of rip
			
		ST:RegisterSpell(22570,	1,001,0,ST.UNIQUE); -- Maim
			ST:RegisterSpellModComb(22570,1,1);--like the other spellmods,
			ST:RegisterSpellModComb(22570,2,2);--this is added for each
			ST:RegisterSpellModComb(22570,3,3);--of the number of combopoints
			ST:RegisterSpellModComb(22570,4,4);
			ST:RegisterSpellModComb(22570,5,5);
		-- Shred, Maul, and Mangle -> Infected Wounds
		ST:RegisterSpellRename(5221,58179); -- Shred to Infected Wounds
		ST:RegisterSpellRename(6807,58179); -- Maul to Infected Wounds
		ST:RegisterSpellAdd(33878,58179); -- add to mangle bear
		ST:RegisterSpellAdd(33876,58179); -- add to mangle cat
		ST:RegisterSpell(58179, 1, 012,0,ST.DEFAULT,nil,nil,2); -- Infected Wounds
			ST:RegisterSpellModTlnt(58179,48485,0,-12); -- only if you have this talent...
		ST:RegisterSpell(48568, 1, 015,1,ST.DEFAULT,nil,nil,5); -- Lacerate
		
		-- Resto Spells
		ST:RegisterSpell(29166,	1,010,0,ST.BUFF); -- Innervate
		ST:RegisterSpell(2893,	1,008,0,ST.BUFF); -- Abolish Poison
		ST:RegisterSpell(33763,	1,007,0,ST.HEAL,nil,nil,3); -- Lifebloom
			ST:RegisterTickSpeed(33763, 1); -- set tick speed to 1 instead of 3
			ST:RegisterSpellModTlnt(33763,57865,1,2);-- Nature's Splendor
			ST:RegisterSpellModGlph(33763,54826,1,1); -- glyph of lifebloom
		ST:RegisterSpell(8936,	1,021,0,ST.HEAL); -- Regrowth
			ST:RegisterSpellModSetB(8936, "Nordrassil Raiment", 2, 6);
			ST:RegisterSpellModTlnt(8936,    57865,1,6); -- Nature's Splendor
		ST:RegisterSpell(774,	1,015,0,ST.HEAL); -- Rejuvenation
			ST:RegisterSpellModTlnt(774,	57865,1,3);-- Nature's Splendor
			ST:RegisterHastedGlyph(774,71014); -- set to hasted hot, requires Glyph of Rapid Rejuvenation
			
		ST:RegisterSpell(48496,	1,015,0,ST.HEAL); -- Living Seed
		ST:RegisterSpell(48438,	1,007,0,ST.HEAL); -- Wild Growth
			ST:RegisterTickSpeed(48438, 1); -- set tick speed to 1 instead of 3
		--
		-- Buffs
		-- buffname,hidden cd
		ST:RegisterBuff(48517); -- eclipse (solar)
		ST:RegisterBuff(48518); -- eclipse (lunar)
		ST:RegisterBuff(52610); -- savage roar

		-- Balance Buffs
		ST:RegisterBuff(22812); -- Barkskin
		ST:RegisterBuff(53312); -- Nature's Grasp
		ST:RegisterBuff(61346); -- Nature's Grace

		-- Feral Buffs
		ST:RegisterBuff(61684); -- Dash
		ST:RegisterBuff(59828); -- Enrage
		ST:RegisterBuff(22845); -- Frenzied Regeneration
		ST:RegisterBuff(50213); -- Tiger's Fury
		ST:RegisterBuff(37316); -- Nurture 2 piece Feral T5
		ST:RegisterBuff(50334); -- Berserk

		-- Resto Buffs
		ST:RegisterBuff(16870); -- Clearcasting
		ST:RegisterBuff(45283); -- Natural Perfection

		-- Feral Procs/Trinkets
		ST:RegisterBuff(67354); -- Evasion, Idol of Mutilation
		ST:RegisterBuff(67355); -- Agile, Idol of Mutilation
		ST:RegisterBuff(67360); -- Blessing of the Moon Goddess, Idol of Lunar Fury
		ST:RegisterBuff(67358); -- Rejuvenating, Idol of Flaring Growth
		ST:RegisterBuff(60569); -- Relentless Survival, Relentless Gladiator's Idol of Steadfastness
		ST:RegisterBuff(60553); -- Relentless Aggression, Relentless Gladiator's Idol of Resolve
		ST:RegisterBuff(71177); -- Vicious, Idol of the Lunar Eclipse
		ST:RegisterBuff(71175); -- Agile, Idol of the Crying Moon
		ST:RegisterBuff(71184); -- Soothing, Idol of the Black Willow
		
		ST:RegisterBuff(69369,1); -- Predator's Swiftness
		
		ST:RegisterCasterBuffs();
		ST:RegisterMeleeBuffs();
		
		local clearcasting = FW:SpellName(12536);
		ST:RegisterOnBuffGain(function(buff)
			if buff == clearcasting then
				FW:PlaySound("TimerClearcastingSound");
			end
		end);
	end
	--
	-- Cooldown Timer
	--
	if CD then
		-- Note: One day, this will correctly track Clearcasting/Nature's Gasp/Nature's Grace.
		
		-- Balance buffs
		CD:RegisterCooldownBuff(22812); -- barkskin
		CD:RegisterCooldownBuff(53307); -- thorns

		-- Resto buffs
		CD:RegisterCooldownBuff(21849); -- Gift of the Wild
		CD:RegisterCooldownBuff(1126); -- Mark of the Wild
		CD:RegisterCooldownBuff(16864); -- Omen of Clarity
		
		CD:RegisterHiddenCooldown(nil,48517,30); -- Eclipse (Solar)
		CD:RegisterHiddenCooldown(nil,48518,30); -- Eclipse (Lunar)
		
		-- other idols
		--CD:RegisterHiddenCooldown(47668,67354,45); -- Idol of Mutilation, Evasion
		--CD:RegisterHiddenCooldown(47670,67360,05); -- Idol of Lunar Fury, Blessing of the Moon Goddess
		--CD:RegisterHiddenCooldown(47671,67358,05); -- Idol of Flaring Growth, Rejuvenating
  
		-- Powerups
		CD:RegisterCasterPowerupCooldowns();
		CD:RegisterMeleePowerupCooldowns();
	end
	if ST then
	FW:SetMainCategory(FWL.SOUND,FW.ICON.SOUND,12,"SOUND");
		FW:SetSubCategory(FWL.SPELL_TIMER,FW.ICON.DEFAULT,2);
			FW:RegisterOption(FW.SND,2,FW.NON,FWL.CLEARCASTING,"","TimerClearcastingSound");
	end
	
end
