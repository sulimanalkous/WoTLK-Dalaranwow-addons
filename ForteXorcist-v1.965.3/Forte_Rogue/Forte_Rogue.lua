-- ForteXorcist v1.965.3 by Xus 05-10-2010 for 3.3.5 & 4.0.1

if FW.CLASS == "ROGUE" then
	local FW = FW;
	local FWL = FW.L;
	local PR = FW:ClassModule("Rogue");
	
	local CA = FW.Modules.Casting;
	local ST = FW.Modules.Timer;
	local CD = FW.Modules.Cooldown;
	
	if ST then
		-- istype: ST.DEFAULT	ST.SHARED ST.UNIQUE	ST.PET ST.POWERUP ST.CHARM ST.DEBUFF ST.DRAIN ST.HEAL ST.BUFF
		--spell, hastarget, duration, isdot, istype, reducedinpvp, texture, stack
		
		-- Abilities
		ST:RegisterSpell(  408, 1, 000,0,ST.UNIQUE); -- Kidney Shot
		ST:RegisterSpell( 2094, 1, 000,0,ST.UNIQUE); -- Blind
		ST:RegisterSpell( 6770, 1, 000,0,ST.UNIQUE); -- Sap
		ST:RegisterSpell(18425, 1, 000,0,ST.UNIQUE); -- Kick silence
		ST:RegisterSpell(32748, 1, 000,0,ST.UNIQUE); -- Deadly Throw interrupt
		ST:RegisterSpell( 1330, 1, 000,0,ST.UNIQUE); -- Garrote silence	
		ST:RegisterSpell( 1833, 1, 000,0,ST.UNIQUE); -- Cheap Shot
		ST:RegisterSpell( 1776, 1, 000,0,ST.UNIQUE); -- Gouge
		ST:RegisterSpell(51722, 1, 000,0,ST.UNIQUE); -- Dismantle
		ST:RegisterSpell(30981, 1, 000,0,ST.UNIQUE); -- Crippling Poison
		ST:RegisterSpell( 5760, 1, 000,0,ST.UNIQUE); -- Mind-numbing Poison
		ST:RegisterSpell(13218, 1, 000,0,ST.UNIQUE); -- Wound Poison		
		
		ST:RegisterSpell(  703, 1, 000,1,ST.DEFAULT); -- Garrote
		ST:RegisterSpell( 1943, 1, 000,1,ST.DEFAULT); -- Rupture
			ST:RegisterTickSpeed(1943, 2); -- set tick speed to 2 instead of 3	

		--ST:RegisterSpell(57993, 1, 000,0,ST.DEFAULT); -- Envenom
		
		-- Poisons
		ST:RegisterSpell(2818, 1,000,1,ST.DEFAULT);  -- Deadly Poison I
			ST:RegisterSpecialRefresh(2818);
		ST:RegisterSpell(2824, 1,000,1,ST.DEFAULT);  -- Deadly Poison II
			ST:RegisterSpecialRefresh(2824);
		ST:RegisterSpell(11353, 1,000,1,ST.DEFAULT); -- Deadly Poison III
			ST:RegisterSpecialRefresh(11353);
		ST:RegisterSpell(11354, 1,000,1,ST.DEFAULT); -- Deadly Poison IV
			ST:RegisterSpecialRefresh(11354);
		ST:RegisterSpell(25349, 1,000,1,ST.DEFAULT); -- Deadly Poison V
			ST:RegisterSpecialRefresh(25349);
		ST:RegisterSpell(26968, 1,000,1,ST.DEFAULT); -- Deadly Poison VI
			ST:RegisterSpecialRefresh(26968);
		ST:RegisterSpell(27187, 1,000,1,ST.DEFAULT); -- Deadly Poison VII
			ST:RegisterSpecialRefresh(27187);
		ST:RegisterSpell(57969, 1,000,1,ST.DEFAULT); -- Deadly Poison VIII
			ST:RegisterSpecialRefresh(57969);
		ST:RegisterSpell(57970, 1,000,1,ST.DEFAULT); -- Deadly Poison IX
			ST:RegisterSpecialRefresh(57970);
		
		-- Self buffs
		ST:RegisterBuff(13750); -- Adrenaline Rush
		ST:RegisterBuff(13877); -- Blade Flurry
		ST:RegisterBuff(14177); -- Cold Blood
		ST:RegisterBuff(5277); -- Evasion
		ST:RegisterBuff(2983); -- Sprint
		ST:RegisterBuff(31224); -- Cloak of Shadows
		ST:RegisterBuff(1856); -- Vanish
		ST:RegisterBuff(1966); -- Feint
		ST:RegisterBuff(51662); -- Hunger for Blood
		ST:RegisterBuff(57934); -- Tricks of the Trade
		ST:RegisterBuff(5171); -- Slice and Dice
		ST:RegisterBuff(32645); -- Envenom
		
		ST:RegisterMeleeBuffs();			
	end
	if CD then
		CD:RegisterMeleePowerupCooldowns();
	end
end
