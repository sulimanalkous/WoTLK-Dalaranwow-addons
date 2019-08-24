-- ForteXorcist v1.965.3 by Xus 05-10-2010 for 3.3.5 & 4.0.1
-- Forte Mage Module attempt by Amros of Gilneas

if FW.CLASS == "MAGE" then
	local FW = FW;
	local FWL = FW.L;
	local MG = FW:ClassModule("Mage");
	
	local CA = FW.Modules.Casting;
	local ST = FW.Modules.Timer;
	local CD = FW.Modules.Cooldown;
	
	if ST then

		-- istype: ST.DEFAULT ST.SHARED ST.UNIQUE ST.PET ST.CHARM ST.COOLDOWN ST.HEAL ST.BUFF
		--spell, hastarget, duration, isdot, istype, reducedinpvp, texture, stack
	
		ST:RegisterSpell(118,1,050,0,ST.UNIQUE,010); -- Polymorph
			ST:RegisterSpellModRank(118,	1, -30);
			ST:RegisterSpellModRank(118,	2, -20);
			ST:RegisterSpellModRank(118,	3, -10);
		ST:RegisterSpell(44457,1,012,1,ST.DEFAULT); -- living bomb
		ST:RegisterSpell(11119,1,004,1,ST.DEFAULT); -- ignite
			ST:RegisterTickSpeed(11119, 1); -- set tick speed to 1 instead of 3
		ST:RegisterSpell(11069,1,000,0,ST.DEFAULT); -- fireball
			ST:RegisterTickSpeed(11069, 2); -- set tick speed to 2 instead of 3	
			
		ST:RegisterSpell(31589,1,000,0,ST.UNIQUE); -- slow
		ST:RegisterSpell(120,0,008,0,ST.UNIQUE); -- cone of cold
		ST:RegisterSpell(122,0,008,0,ST.UNIQUE); -- frost nova
		ST:RegisterSpell(44572,1,005,0,ST.UNIQUE); -- deep freeze
		
		ST:RegisterSpell(11071,1,005,0,ST.DEFAULT); -- frostbite
		
		ST:RegisterSpell(55342,0,030,0,ST.UNIQUE); -- Mirror Image
		ST:RegisterSpell(12484,1,000,0,ST.DEFAULT); -- Chilled
		
		ST:RegisterSpell(604,1,600,0,ST.BUFF); -- Dampen Magic
		ST:RegisterSpell(1008,1,600,0,ST.BUFF); -- Amplify Magic
		
		ST:RegisterBuff(12536); -- Clearcasting
		ST:RegisterBuff(44445); -- Hot Streak
		ST:RegisterBuff(37445);	-- Mana Surge
		
		ST:RegisterBuff(12042); -- Arcane Power
		ST:RegisterBuff(1463); -- Mana Shield
		ST:RegisterBuff(543); -- Fire Ward
		ST:RegisterBuff(6143); -- Frost Ward
		ST:RegisterBuff(12472); -- Icy Veins
		ST:RegisterBuff(44401); -- Missile Barrage
		ST:RegisterBuff(57761); -- Fireball!
		ST:RegisterBuff(70753); -- Pushing the Limit
		
		ST:RegisterBuff(66); -- Invisibility
		ST:RegisterBuff(12051); -- Evocation
		ST:RegisterBuff(45438); -- Ice Block
		
		ST:RegisterBuff(6117); -- Mage Armor
		ST:RegisterBuff(30482); -- Molten Armor
		ST:RegisterBuff(168); -- Frost Armor
		ST:RegisterBuff(7302); -- Ice Armor
		
		ST:RegisterBuff(44543); -- Fingers of Frost
		
		-- self debuffs
		ST:RegisterSelfDebuff(36032); -- Arcane Blast

		--debuffs
		ST:RegisterDebuff(120); -- cone of cold
		ST:RegisterDebuff(122); -- frost nova

		ST:RegisterCasterBuffs();
		
		local poly = FW:SpellName(118);
		ST:RegisterOnTimerBreak(function(unit,mark,spell)
			if spell == poly then
				if mark~=0 then unit=FW.RaidIcons[mark]..unit;end
				CA:CastShow("PolymorphBreak",unit);
			end
		end);
		ST:RegisterOnTimerFade(function(unit,mark,spell,t)
			if spell == poly then
				if t <= ST:GetFadeTime("PolymorphFade") then
					if mark~=0 then unit=FW.RaidIcons[mark]..unit;end
					CA:CastShow("PolymorphFade",unit);
					return 1;
				end
			end
		end);
		
		-- Old shaman code Code to track totems, also used for the water elemental!
		local SH_CurrentTotem = {"","","",""};
		local function SH_TotemUpdate(event,index)
			local _, name, startTime, duration, icon = GetTotemInfo(index);
			if SH_CurrentTotem[index] ~= "" then
				local i = ST.ST:find(SH_CurrentTotem[index],8);
				if i then
					if name ~= "" then
						ST.ST:remove(i);
					else
						if ST.ST[i][1]-GetTime()<0.75 then
							ST:Fade(i,2);
						else
							ST:Fade(i,3);
						end
					end
				end
			end
			if name ~= "" then
				ST.ST:insert(startTime+duration,0,duration,name,0,ST.PET,icon,name,2,0,"none",0,ST.PRIOR_NONE,0,1,0,0,ST:GetFilterType(name,ST.PET),0,startTime+duration,duration,1.0,0);
			end
			SH_CurrentTotem[index] = name;
		end
		FW:RegisterToEvent("PLAYER_TOTEM_UPDATE", SH_TotemUpdate);
		
		local clearcasting = FW:SpellName(12536);
		ST:RegisterOnBuffGain(function(buff)
			if buff == clearcasting then
				FW:PlaySound("TimerClearcastingSound");
			end
		end);
		
	end
	if CD then
		CD:RegisterCasterPowerupCooldowns();
	end

	FW:SetMainCategory(FWL.RAID_MESSAGES,FW.ICON.MESSAGE,10,"RAIDMESSAGES");
		FW:SetSubCategory(FW.NIL,FW.NIL,1);
			FW:RegisterOption(FW.INF,2,FW.NON,FWL.RAID_MESSAGES_HINT1);
			FW:RegisterOption(FW.INF,2,FW.NON,FWL.RAID_MESSAGES_HINT2);
			FW:RegisterOption(FW.CHK,2,FW.NON,FWL.SHOW_IN_RAID,		FWL.SHOW_IN_RAID_TT,    "OutputRaid");
			FW:RegisterOption(FW.MSG,2,FW.NON,FWL.SHOW_IN_CHANNEL,	FWL.SHOW_IN_CHANNEL_TT,	"Output");

	if ST then

		FW:SetSubCategory(FWL.BREAK_FADE,FW.ICON.SPECIFIC,2);
			FW:RegisterOption(FW.INF,2,FW.NON,FWL.BREAK_FADE_HINT1);
			FW:RegisterOption(FW.MS2,2,FW.NON,FWL.POLYMORPH_BREAK,		"",    "PolymorphBreak");
			FW:RegisterOption(FW.MS2,2,FW.NON,FWL.POLYMORPH_FADE,		"",    "PolymorphFade");

	FW:SetMainCategory(FWL.SOUND,FW.ICON.SOUND,12,"SOUND");
		FW:SetSubCategory(FWL.SPELL_TIMER,FW.ICON.DEFAULT,2);
			FW:RegisterOption(FW.SND,2,FW.NON,FWL.CLEARCASTING,"","TimerClearcastingSound");
	end
	
	FW.Default.OutputRaid = true;
	FW.Default.Output = true;
	FW.Default.OutputMsg = "MyProMageChannel";

	FW.Default.PolymorphBreak = 0;	FW.Default.PolymorphBreakMsg = ">> Polymorph on %s Broke Early! <<";
	FW.Default.PolymorphFade = 0;	FW.Default.PolymorphFadeMsg = ">> Polymorph on %s Fading in 3 seconds! <<";

end