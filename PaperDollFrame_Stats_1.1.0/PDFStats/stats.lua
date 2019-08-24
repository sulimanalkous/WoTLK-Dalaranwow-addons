-- table of available stats
PDFStats.statsDB = {
	{	-- base stats
		label = PLAYERSTAT_BASE_STATS,
		value = "base",
		stats = {
			{value = "str", label = SPELL_STAT1_NAME, func = 1},
			{value = "agi", label = SPELL_STAT2_NAME, func = 2},
			{value = "sta", label = SPELL_STAT3_NAME, func = 3},
			{value = "int", label = SPELL_STAT4_NAME, func = 4},
			{value = "spi", label = SPELL_STAT5_NAME, func = 5},
		},
	},
	{	-- melee stats
		label = PLAYERSTAT_MELEE_COMBAT,
		value = "melee",
		stats = {
			{value = "dmg",		label = DAMAGE,					func = "Damage",	onEnter = "DamageFrame"},	-- melee damage
			{value = "spd",		label = ATTACK_SPEED,			func = "AttackSpeed"},		-- melee attack speed
			{value = "pwr",		label = ATTACK_POWER_TOOLTIP,	func = "AttackPower"},		-- melee attack power
			{value = "crit",	label = MELEE_CRIT_CHANCE,		func = "MeleeCritChance"},	-- melee crit chance
			{value = "exp",		label = STAT_EXPERTISE,			func = "Expertise"},		-- expertise
			{value = "skill",	label = COMBAT_RATING_NAME1,	func = "AttackBothHands"},	-- melee weapon skill
		},
		ratings = {
			{value = "crHit",	label = COMBAT_RATING_NAME6,	func = CR_HIT_MELEE},								-- melee hit rating
			{value = "hit",		label = COMBAT_RATING_NAME6,	func = CR_HIT_MELEE,	effective = true},			-- melee hit %
			{value = "crCrit",	label = COMBAT_RATING_NAME9,	func = CR_CRIT_MELEE},								-- melee crit rating
			{value = "crHaste",	label = COMBAT_RATING_NAME18,	func = CR_HASTE_MELEE},								-- melee haste rating
			{value = "haste",	label = SPELL_HASTE_ABBR,		func = CR_HASTE_MELEE,	effective = true},			-- melee haste %
			{value = "crExp",	label = COMBAT_RATING_NAME24,	func = CR_EXPERTISE},								-- expertise rating
			{value = "crArP",	label = COMBAT_RATING_NAME25,	func = CR_ARMOR_PENETRATION},						-- armor penetration rating
			{value = "arP",		label = COMBAT_RATING_NAME25,	func = CR_ARMOR_PENETRATION,	effective = true},	-- armor penetration %
		},
	},
	{	-- ranged stats
		label = PLAYERSTAT_RANGED_COMBAT,
		value = "ranged",
		stats = {
			{value = "raDmg",	label = DAMAGE,					func = "RangedDamage", onEnter = "RangedDamageFrame"},	-- ranged damage
			{value = "raSpd",	label = ATTACK_SPEED,			func = "RangedAttackSpeed"},							-- ranged attack speed
			{value = "raPwr",	label = ATTACK_POWER_TOOLTIP,	func = "RangedAttackPower"},							-- ranged attack power
			{value = "raCrit",	label = RANGED_CRIT_CHANCE,		func = "RangedCritChance"},								-- ranged crit chance
			{value = "raSkill",	label = COMBAT_RATING_NAME1,	func = "RangedAttack"},									-- ranged weapon skill
		},
		ratings = {
			{value = "crRaHit",		label = COMBAT_RATING_NAME7,	func = CR_HIT_RANGED},								-- ranged hit rating
			{value = "crRaHit",		label = COMBAT_RATING_NAME7,	func = CR_HIT_RANGED,	effective = true},			-- ranged hit %
			{value = "crRaCrit",	label = COMBAT_RATING_NAME10,	func = CR_CRIT_RANGED},								-- ranged crit rating
			{value = "crRaHaste",	label = COMBAT_RATING_NAME19,	func = CR_HASTE_RANGED},							-- ranged haste rating
			{value = "raHaste",		label = SPELL_HASTE_ABBR,		func = CR_HASTE_RANGED,	effective = true},			-- ranged haste %
			{value = "crArP",		label = COMBAT_RATING_NAME25,	func = CR_ARMOR_PENETRATION},						-- armor penetration rating
			{value = "arP",			label = COMBAT_RATING_NAME25,	func = CR_ARMOR_PENETRATION,	effective = true},	-- armor penetration %
		},
	},
	{	-- spell stats
		label = PLAYERSTAT_SPELL_COMBAT,
		value = "spell",
		stats = {
			{value = "spPwr",	label = BONUS_DAMAGE,		func = "SpellBonusDamage",	onEnter = "SpellBonusDamage"},	-- spell power
			{value = "hPwr",	label = BONUS_HEALING,		func = "SpellBonusHealing"},								-- healing power
			{value = "spCrit",	label = SPELL_CRIT_CHANCE,	func = "SpellCritChance",	onEnter = "SpellCritChance"},	-- spell crit chance
			{value = "spPen",	label = SPELL_PENETRATION,	func = "SpellPenetration"},									-- spell penetration
			{value = "regen",	label = MANA_REGEN,			func = "ManaRegen"},										-- mana regen
			{value = "regenCa",	label = MANA_REGEN_CASTING,	func = "ManaRegenCasting"},									-- mana regen while casting
		},
		ratings = {
			{value = "crSpHit",		label = COMBAT_RATING_NAME8,	func = CR_HIT_SPELL},						-- spell hit rating
			{value = "spHit",		label = COMBAT_RATING_NAME8,	func = CR_HIT_SPELL,	effective = true},	-- spell hit %
			{value = "crSpCrit",	label = COMBAT_RATING_NAME11,	func = CR_CRIT_SPELL},						-- spell crit rating
			{value = "crSpHaste",	label = SPELL_HASTE,			func = "SpellHaste"},						-- spell haste rating
			{value = "spHaste",		label = SPELL_HASTE_ABBR,		func = CR_HASTE_SPELL,	effective = true},	-- effective spell haste
		},
	},
	{	-- defensive stats
		label = PLAYERSTAT_DEFENSES,
		value = "defenses",
		stats = {
			{value = "armor",		label = ARMOR,				func = "Armor"},		-- armor
			{value = "def",			label = DEFENSE,			func = "Defense"},		-- defense
			{value = "avoid",		label = AVOIDANCE,			func = "Avoidance",		onEnter = "Avoidance"},		-- avoidance (dodge + parry + miss-from-defense)
			{value = "avoidBlk",	label = AVOIDANCEBLK,		func = "AvoidanceBlk",	onEnter = "AvoidanceBlk"},	-- avoidance w/ block
			{value = "dodge",		label = STAT_DODGE,			func = "Dodge"},		-- dodge chance
			{value = "parry",		label = STAT_PARRY,			func = "Parry"},		-- parry chance
			{value = "block",		label = STAT_BLOCK,			func = "Block"},		-- block chance
			{value = "blkVal",		label = BLOCK_VALUE,		func = "BlockValue"},	-- block value
			{value = "res",			label = STAT_RESILIENCE,	func = "Resilience"},	-- resilience
		},
		ratings = {
			{value = "crDef",	label = COMBAT_RATING_NAME2, func = CR_DEFENSE_SKILL},	-- defense rating
			{value = "crDodge",	label = COMBAT_RATING_NAME3, func = CR_DODGE},			-- dodge rating
			{value = "crParry",	label = COMBAT_RATING_NAME4, func = CR_PARRY},			-- parry rating
			{value = "crBlock",	label = COMBAT_RATING_NAME5, func = CR_BLOCK},			-- block rating
		},
	},
}