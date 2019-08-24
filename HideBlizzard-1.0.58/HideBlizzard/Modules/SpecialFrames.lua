local SpecialFrames = HideBlizzard:NewModule("SpecialFrames", "AceHook-3.0")

local db
local defaults = {
	profile = {
		["achievement"] = nil,
		["dungeon"] = nil,
		["minimap"] = nil,
		["party"] = nil,
		["tooltip"] = nil,
		["zonetext"] = nil,
		["sysmessage"] = nil,
		["infomessage"] = nil,
		["errormessage"] = nil,
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
		SpecialFrames:UpdateView()
	end
end

local options = nil
local function moduleOptions()
	if not options then
		options = {
			type = "group",
			name = "SpecialFrames",
			arg = "SpecialFrames",
			get = get,
			set = set,
			args = {
				enabled = {
					type = "toggle",
					order = 1,
					name = "|cff00ff66Enable SpecialFrames|r",
					descStyle = "inline",
					desc = "SpecialFrames module hides frames not linked to the other modules",
					width = "full",
					get = function() return HideBlizzard:GetModuleEnabled("SpecialFrames") end,
					set = function(info, value) HideBlizzard:SetModuleEnabled("SpecialFrames", value) end,
				},
				alerts = {
					order = 2,
					type = "group",
					name = "Alert Frames",
					args = {
						achievement = {
							order = 1,
							type = "toggle",
							name = "Achievement Frame",
							desc = "Hides the achievement alert frame",
		--					width = "full",
							disabled = function() return not SpecialFrames:IsEnabled() end,
						},
						dungeon = {
							order = 2,
							type = "toggle",
							name = "Dungeon Frame",
							desc = "Hides the dungeon completion alert frame",
		--					width = "full",
							disabled = function() return not SpecialFrames:IsEnabled() end,
						},
					},
				},
				minimap = {
					order = 3,
					type = "toggle",
					name = "Minimap",
					desc = "Hides the minimap",
--					width = "full",
					disabled = function() return not SpecialFrames:IsEnabled() end,
				},
				party = {
					order = 4,
					type = "toggle",
					name = "Party",
					desc = "Hides the party frames",
--					width = "full",
					disabled = function() return not SpecialFrames:IsEnabled() end,
				},
				tooltip = {
					order = 5,
					type = "toggle",
					name = "Tooltip",
					desc = "Hides the tooltip frame",
--					width = "full",
					disabled = function() return not SpecialFrames:IsEnabled() end,
				},
				zonetext = {
					order = 6,
					type = "toggle",
					name = "Zone Text",
					desc = "Hides the zone and subzone text in the middle of the screen",
--					width = "full",
					disabled = function() return not SpecialFrames:IsEnabled() end,
				},
				messages = {
					order = 7,
					type = "group",
					name = "Messages",
					args = {
						sysmessage = {
							type = "toggle",
							order = 1,
							name = "System Message",
							desc = "Hides all the system message(yellow) text at the top of the screen",
--							width = "full",
							disabled = function() return not SpecialFrames:IsEnabled() end,
						},
						infomessage = {
							type = "toggle",
							order = 2,
							name = "Info Message",
							desc = "Hides all the notification(yellow) text at the top of the screen",
--							width = "full",
							disabled = function() return not SpecialFrames:IsEnabled() end,
						},
						errormessage = {
							type = "toggle",
							order = 3,
							name = "Error Message",
							desc = "Hides all the error(red) text at the top of the screen",
--							width = "full",
							disabled = function() return not SpecialFrames:IsEnabled() end,
						},
					},
				},
				reset = {
					type = "execute",
					order = 8,
					name = "reset module",
					desc = "use this if you're having trouble",
					width = "full",
					confirm = true,
					func = function() HideBlizzard:ModuleReset("SpecialFrames") end,
				},
			},
		}
	end
	return options
end

function SpecialFrames:OnInitialize()
	self:SetEnabledState(HideBlizzard:GetModuleEnabled("SpecialFrames"))
	self.db = HideBlizzard.db:RegisterNamespace("SpecialFrames", defaults)
	db = self.db.profile

	HideBlizzard:RegisterModuleOptions("SpecialFrames", moduleOptions, "SpecialFrames")
end

function SpecialFrames:OnEnable()
	self:UpdateView()
end

function SpecialFrames:OnDisable()
	self:UpdateView()
end

local function hook(tooltip)
	local tooltips = {GameTooltip, ItemRefTooltip, ShoppingTooltip1, ShoppingTooltip2, ShoppingTooltip3, WorldMapTooltip}
	for i=1, #tooltips do
		tooltips[i]:Hide()
	end
end

local function unhook(tooltip)
	local tooltips = {GameTooltip, ItemRefTooltip, ShoppingTooltip1, ShoppingTooltip2, ShoppingTooltip3, WorldMapTooltip}
	for i=1, #tooltips do
		tooltips[i]:Show()
	end
end

function SpecialFrames:UpdateView()
	db = self.db.profile

	if db.achievement == true then
		for i =1, MAX_ACHIEVEMENT_ALERTS do
			local af = _G["AchievementAlertFrame"..i]
			AlertFrame:UnregisterAllEvents()
			AlertFrame.Show = function() end
		end
	else
		for i =1, MAX_ACHIEVEMENT_ALERTS do
			local af = _G["AchievementAlertFrame"..i]
			AlertFrame.Show = nil
			AlertFrame:RegisterEvent("ACHIEVEMENT_EARNED")
		end
	end
	if db.dungeon == true then
		DungeonCompletionAlertFrame1:Hide()
		DungeonCompletionAlertFrame1:UnregisterAllEvents()
		DungeonCompletionAlertFrame1.Show = function() end
	else
		DungeonCompletionAlertFrame1.Show = nil
		DungeonCompletionAlertFrame1:RegisterEvent("LFG_COMPLETION_REWARD")
	end

	if db.minimap == true then
		MinimapCluster:Hide()
		MinimapCluster.Show = function() end
	else
		MinimapCluster.Show = nil
		MinimapCluster:Show()
	end

	if db.party == true then
		for i = 1, MAX_PARTY_MEMBERS do
			local party = _G["PartyMemberFrame"..i]
			party:Hide()
			party:UnregisterAllEvents()
			party.Show = function() end
		end
		UIParent:UnregisterEvent("RAID_ROSTER_UPDATE")
	else
		for i = 1, MAX_PARTY_MEMBERS do
			local party = _G["PartyMemberFrame"..i]
			if (GetPartyMember(i)) then
				party.Show = nil
				party:Show()
				party:RegisterEvent("PLAYER_ENTERING_WORLD")
				party:RegisterEvent("PARTY_MEMBERS_CHANGED")
				party:RegisterEvent("PARTY_LEADER_CHANGED")
				party:RegisterEvent("PARTY_LOOT_METHOD_CHANGED")
				party:RegisterEvent("MUTELIST_UPDATE")
				party:RegisterEvent("IGNORELIST_UPDATE")
				party:RegisterEvent("UNIT_FACTION")
				party:RegisterEvent("UNIT_AURA")
				party:RegisterEvent("UNIT_PET")
				party:RegisterEvent("VOICE_START")
				party:RegisterEvent("VOICE_STOP")
				party:RegisterEvent("VARIABLES_LOADED")
				party:RegisterEvent("VOICE_STATUS_UPDATE")
				party:RegisterEvent("READY_CHECK")
				party:RegisterEvent("READY_CHECK_CONFIRM")
				party:RegisterEvent("READY_CHECK_FINISHED")
				party:RegisterEvent("UNIT_ENTERED_VEHICLE")
				party:RegisterEvent("UNIT_EXITED_VEHICLE")
				party:RegisterEvent("UNIT_HEALTH")
				UnitFrame_OnEvent("PARTY_MEMBERS_CHANGED")
			end
		end
		UIParent:RegisterEvent("RAID_ROSTER_UPDATE")
	end

	if db.tooltip == true then
		self:SecureHook("GameTooltip_SetDefaultAnchor", hook)
	else
		self:Unhook("GameTooltip_SetDefaultAnchor", unhook)
	end

	if db.sysmessage == true then
		UIErrorsFrame:UnregisterEvent("SYSMSG")
	else
		UIErrorsFrame:RegisterEvent("SYSMSG")
	end
	if db.infomessage == true then
		UIErrorsFrame:UnregisterEvent("UI_INFO_MESSAGE")
	else
		UIErrorsFrame:RegisterEvent("UI_INFO_MESSAGE")
	end
	if db.errormessage == true then
		UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")
	else
		UIErrorsFrame:RegisterEvent("UI_ERROR_MESSAGE")
	end

	if db.zonetext == true then
		ZoneTextFrame:UnregisterAllEvents()
		ZoneTextFrame:Hide()
		SubZoneTextFrame:UnregisterAllEvents()
		SubZoneTextFrame:Hide()
	else
		ZoneTextFrame:RegisterEvent("ZONE_CHANGED")
		ZoneTextFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
		ZoneTextFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
		SubZoneTextFrame:RegisterEvent("ZONE_CHANGED")
		SubZoneTextFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
		SubZoneTextFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	end
end
