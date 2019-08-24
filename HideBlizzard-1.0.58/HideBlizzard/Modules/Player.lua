local Player = HideBlizzard:NewModule("Player")
local class = UnitClass("player")

local db
local defaults = {
	profile = {
		["armoredman"] = nil,
		["aura"] = nil,
		["druidmanabar"] = nil,
		["playercastbar"] = nil,
		["playerunitframe"] = nil,
		["runeframe"] = nil,
		["totemframe"] = nil,
	},
}

local get, set
do
	function get(info)
		local key = info[#info]
		return db[key]
	end

	function set(info, value)
		local key = info[#info]
		db[key] = value
		Player:UpdateView()
	end
end

local options = nil
local function moduleOptions()
	if not options then
		options = {
			type = "group",
			name = "Player",
			arg = "Player",
			get = get,
			set = set,
			args = {
				enabled = {
					type = "toggle",
					order = 1,
					name = "|cff00ff66Enable Player|r",
					descStyle = "inline",
					desc = "Player module hides player related frames",
					width = "full",
					get = function() return HideBlizzard:GetModuleEnabled("Player") end,
					set = function(info, value) HideBlizzard:SetModuleEnabled("Player", value) end,
				},
				armoredman = {
					type = "toggle",
					order = 2,
					name = "Armored Man",
					desc = "Hides the armored man under the minimap",
--					width = "full",
					disabled = function() return not Player:IsEnabled() end,
				},
				aura = {
					type = "toggle",
					order = 3,
					name = "Aura",
					desc = "Hides the buff and debuff frame",
--					width = "full",
					disabled = function() return not Player:IsEnabled() end,
				},
				druidmanabar = {
					type = "toggle",
					order = 4,
					name = "Druid Mana Bar",
					desc = "Hides the druid mana bar when you shapeshift",
--					width = "full",
					disabled = function() return not Player:IsEnabled() end,
				},
				playercastbar = {
					type = "toggle",
					order = 5,
					name = "Player Cast Bar",
					desc = "Hides the player cast bar",
--					width = "full",
					disabled = function() return not Player:IsEnabled() end,
				},
				playerunitframe = {
					type = "toggle",
					order = 6,
					name = "Player Unit Frame",
					desc = "Hides the player unit frame",
--					width = "full",
					disabled = function() return not Player:IsEnabled() end,
				},
				runeframe = {
					type = "toggle",
					order = 7,
					name = "Rune Frame",
					desc = "Hides the rune frame",
--					width = "full",
					disabled = function() return not Player:IsEnabled() end,
				},
				totemframe = {
					type = "toggle",
					order = 8,
					name = "Totem Frame",
					desc = "Hides the totem frame",
--					width = "full",
					disabled = function() return not Player:IsEnabled() end,
				},
				reset = {
					type = "execute",
					order = 9,
					name = "reset module",
					desc = "use this if you're having trouble",
					width = "full",
					confirm = true,
					func = function() HideBlizzard:ModuleReset("Player") end,
				},
			},
		}
	end
	return options
end

function Player:OnInitialize()
	self:SetEnabledState(HideBlizzard:GetModuleEnabled("Player"))
	self.db = HideBlizzard.db:RegisterNamespace("Player", defaults)
	db = self.db.profile

	HideBlizzard:RegisterModuleOptions("Player", moduleOptions, "Player")
end

function Player:OnEnable()
	self:UpdateView()
end

function Player:OnDisable()
	self:UpdateView()
end

function Player:UpdateView()
	db = self.db.profile

	if db.armoredman == true then
		DurabilityFrame:Hide() 
		DurabilityFrame.Show = function() end
		DurabilityFrame:UnregisterAllEvents()
	else
		DurabilityFrame.Show = nil
		DurabilityFrame:RegisterEvent("UNIT_INVENTORY_CHANGED")
		DurabilityFrame:RegisterEvent("UPDATE_INVENTORY_ALERTS")
	end

	if db.aura == true then
		BuffFrame:UnregisterAllEvents()
		BuffFrame:Hide()
		TemporaryEnchantFrame:Hide()
	else
		BuffFrame:Show()
		BuffFrame:RegisterEvent("UNIT_AURA")
		BuffFrame:RegisterEvent("PLAYER_AURAS_CHANGED")
		TemporaryEnchantFrame:Show()
		BuffFrame_Update()
	end
--[[ cata
PlayerFrameAlternateManaBar:RegisterEvent("UNIT_POWER")
PlayerFrameAlternateManaBar:RegisterEvent("UNIT_MAXPOWER")
PlayerFrameAlternateManaBar:RegisterEvent("PLAYER_ENTERING_WORLD")
PlayerFrameAlternateManaBar:RegisterEvent("UNIT_DISPLAYPOWER")
]]
	if db.druidmanabar == true then
		for shapeshiftIndex=1, GetNumShapeshiftForms() do
			local active = GetShapeshiftFormInfo(shapeshiftIndex)
			if active then
				PlayerFrameAlternateManaBar:Hide()
				PlayerFrameAlternateManaBar:UnregisterAllEvents()
				PlayerFrameAlternateManaBar.Show = function() end
			else
				PlayerFrameAlternateManaBar:Hide()
				PlayerFrameAlternateManaBar:UnregisterAllEvents()
				PlayerFrameAlternateManaBar.Show = function() end
			end
		end
	else
		for shapeshiftIndex=1, GetNumShapeshiftForms() do
			local active = GetShapeshiftFormInfo(shapeshiftIndex)
			if active then
				PlayerFrameAlternateManaBar.Show = nil
				PlayerFrameAlternateManaBar:Show()
				PlayerFrameAlternateManaBar:RegisterEvent("PLAYER_ENTERING_WORLD")
				PlayerFrameAlternateManaBar:RegisterEvent("UNIT_DISPLAYPOWER")
				PlayerFrameAlternateManaBar:RegisterEvent("UNIT_MAXMANA")
				PlayerFrameAlternateManaBar:RegisterEvent("UNIT_MANA")
				AlternatePowerBar_UpdateValue(PlayerFrameAlternateManaBar)
				AlternatePowerBar_UpdateMaxValues(PlayerFrameAlternateManaBar)
				AlternatePowerBar_UpdatePowerType(PlayerFrameAlternateManaBar)
			else
				PlayerFrameAlternateManaBar:Hide()
				PlayerFrameAlternateManaBar.Show = function() end
			end
		end
	end

	if db.playercastbar == true then
		CastingBarFrame:UnregisterAllEvents()
	else
		CastingBarFrame:RegisterEvent("UNIT_SPELLCAST_START")
		CastingBarFrame:RegisterEvent("UNIT_SPELLCAST_STOP")
		CastingBarFrame:RegisterEvent("UNIT_SPELLCAST_FAILED")
		CastingBarFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
		CastingBarFrame:RegisterEvent("UNIT_SPELLCAST_DELAYED")
		CastingBarFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
		CastingBarFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
		CastingBarFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	end

	if db.playerunitframe == true then
		PlayerFrame:Hide()
		PlayerFrame:UnregisterAllEvents()
		PlayerFrame.Show = function() end
		PlayerFrame:RegisterEvent('UNIT_ENTERING_VEHICLE')
		PlayerFrame:RegisterEvent('UNIT_ENTERED_VEHICLE')
		PlayerFrame:RegisterEvent('UNIT_EXITING_VEHICLE')
		PlayerFrame:RegisterEvent('UNIT_EXITED_VEHICLE')
		PlayerFrameHealthBar:UnregisterAllEvents()
		PlayerFrameManaBar:UnregisterAllEvents()
	else
		PlayerFrame.Show = nil
		PlayerFrame:Show()
		PlayerFrame:RegisterEvent("UNIT_LEVEL")
		PlayerFrame:RegisterEvent("UNIT_COMBAT")
		PlayerFrame:RegisterEvent("UNIT_FACTION")
		PlayerFrame:RegisterEvent("UNIT_MAXMANA")
		PlayerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
		PlayerFrame:RegisterEvent("PLAYER_ENTER_COMBAT")
		PlayerFrame:RegisterEvent("PLAYER_LEAVE_COMBAT")
		PlayerFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
		PlayerFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
		PlayerFrame:RegisterEvent("PLAYER_UPDATE_RESTING")
		PlayerFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
		PlayerFrame:RegisterEvent("PARTY_LEADER_CHANGED")
		PlayerFrame:RegisterEvent("PARTY_LOOT_METHOD_CHANGED")
		PlayerFrame:RegisterEvent("VOICE_START")
		PlayerFrame:RegisterEvent("VOICE_STOP")
		PlayerFrame:RegisterEvent("RAID_ROSTER_UPDATE")
		PlayerFrame:RegisterEvent("READY_CHECK")
		PlayerFrame:RegisterEvent("READY_CHECK_CONFIRM")
		PlayerFrame:RegisterEvent("READY_CHECK_FINISHED")
		PlayerFrame:RegisterEvent("UNIT_ENTERED_VEHICLE")
		PlayerFrame:RegisterEvent("UNIT_ENTERING_VEHICLE")
		PlayerFrame:RegisterEvent("UNIT_EXITING_VEHICLE")
		PlayerFrame:RegisterEvent("UNIT_EXITED_VEHICLE")
		PlayerFrame:RegisterEvent("PLAYER_FLAGS_CHANGED")
		PlayerFrame:RegisterEvent("PLAYER_ROLES_ASSIGNED")
		PlayerFrame:RegisterEvent("PLAYTIME_CHANGED")
		PlayerFrameHealthBar:RegisterEvent("UNIT_HEALTH")
		PlayerFrameHealthBar:RegisterEvent("UNIT_MAXHEALTH")
		PlayerFrameManaBar:RegisterEvent("UNIT_MANA")
		PlayerFrameManaBar:RegisterEvent("UNIT_RAGE")
		PlayerFrameManaBar:RegisterEvent("UNIT_FOCUS")
		PlayerFrameManaBar:RegisterEvent("UNIT_ENERGY")
		PlayerFrameManaBar:RegisterEvent("UNIT_RUNIC_POWER")
		PlayerFrameManaBar:RegisterEvent("UNIT_HAPPINESS")
		PlayerFrameManaBar:RegisterEvent("UNIT_MAXMANA")
		PlayerFrameManaBar:RegisterEvent("UNIT_MAXRAGE")
		PlayerFrameManaBar:RegisterEvent("UNIT_MAXFOCUS")
		PlayerFrameManaBar:RegisterEvent("UNIT_MAXENERGY")
		PlayerFrameManaBar:RegisterEvent("UNIT_MAXRUNIC_POWER")
		PlayerFrameManaBar:RegisterEvent("UNIT_MAXHAPPINESS")
		PlayerFrameManaBar:RegisterEvent("UNIT_RUNIC_POWER")
		PlayerFrameManaBar:RegisterEvent("UNIT_DISPLAYPOWER")
	end

	if db.runeframe == true then
		if (class == "DEATHKNIGHT") then
			RuneFrame:Hide()
			RuneFrame:UnregisterAllEvents()
		end
	else
		if (class == "DEATHKNIGHT") then
			RuneFrame:Show()
			RuneFrame:RegisterEvent("RUNE_POWER_UPDATE")
			RuneFrame:RegisterEvent("RUNE_TYPE_UPDATE")
			RuneFrame:RegisterEvent("UNIT_RUNIC_POWER")
			RuneFrame:RegisterEvent("UNIT_MAXRUNIC_POWER")
			RuneFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
		end
	end

	local function hasPet()
		local name, _,tier, column, _, _, _, meetsPrereq = GetTalentInfo(3, 20)
		if type(name) == "string" then
			if (meetsPrereq and name == "Master of Ghouls") then 
				return true
			else
				return false
			end
		end
	end
	-- shaman: hide
	-- deathknight: if no pet-show; hide both
	if db.totemframe == true then
		if (class == "SHAMAN") then
			for i =1, MAX_TOTEMS do
				local totem = _G["TotemFrameTotem"..i]
				totem:Hide()
				totem:UnregisterAllEvents()
			end
		elseif (class == "DEATHKNIGHT") then
			if not hasPet then
				for i =1, MAX_TOTEMS do
					local totem = _G["TotemFrameTotem"..i]
					totem:RegisterEvent("PLAYER_TOTEM_UPDATE")
					totem:RegisterEvent("PLAYER_ENTERING_WORLD")
					totem:RegisterForClicks("RightButtonUp")
				end
			else
				for i =1, MAX_TOTEMS do
					local totem = _G["TotemFrameTotem"..i]
					totem:Hide()
					totem:UnregisterAllEvents()
				end
			end
		end
	else
		-- shaman: show
		-- deathknight: if no pet-show; show sham..hide dk
		if (class == "SHAMAN") then
			for i =1, MAX_TOTEMS do
				local totem = _G["TotemFrameTotem"..i]
				totem:RegisterEvent("PLAYER_TOTEM_UPDATE")
				totem:RegisterEvent("PLAYER_ENTERING_WORLD")
				totem:RegisterForClicks("RightButtonUp")
			end
		elseif (class == "DEATHKNIGHT") then
			if not hasPet then
				for i =1, MAX_TOTEMS do
					local totem = _G["TotemFrameTotem"..i]
					totem:RegisterEvent("PLAYER_TOTEM_UPDATE")
					totem:RegisterEvent("PLAYER_ENTERING_WORLD")
					totem:RegisterForClicks("RightButtonUp")
				end
			else
				for i =1, MAX_TOTEMS do
					local totem = _G["TotemFrameTotem"..i]
					totem:RegisterEvent("PLAYER_TOTEM_UPDATE")
					totem:RegisterEvent("PLAYER_ENTERING_WORLD")
					totem:RegisterForClicks("RightButtonUp")
				end
			end
		end
	end
end
