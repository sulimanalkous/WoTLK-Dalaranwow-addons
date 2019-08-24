local Buttons = HideBlizzard:NewModule("Buttons")

local db
local defaults = {
	profile = {
		["chatbuttons"] = nil,
		["battleground"] = nil,
		["calendar"] = nil,
		["lfg"] = nil,
		["mail"] = nil,
		["tracking"] = nil,
		["voice"] = nil,
		["world"] = nil,
		["zoom"] = nil,
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
		Buttons:UpdateView()
	end
end

local options = nil
local function moduleOptions()
	if not options then
		options = {
			type = "group",
			name = "Buttons",
			arg = "Buttons",
			get = get,
			set = set,
			args = {
				enabled = {
					type = "toggle",
					order = 1,
					name = "|cff00ff66Enable Buttons|r",
					descStyle = "inline",
					desc = "Buttons module hides buttons connected to the chat and minimap frame",
					width = "full",
					get = function() return HideBlizzard:GetModuleEnabled("Buttons") end,
					set = function(info, value) HideBlizzard:SetModuleEnabled("Buttons", value) end,
				},
				chatbuttons = {
					type = "toggle",
					order = 2,
					name = "Chat Buttons",
					desc = "Hides the chat arrows on the chat frame",
--					width = "full",
					disabled = function() return not Buttons:IsEnabled() end,
				},
				battleground = {
					type = "toggle",
					order = 3,
					name = "Battleground",
					desc = "Hides the battleground queue button",
--					width = "full",
					disabled = function() return not Buttons:IsEnabled() end,
				},
				calendar = {
					type = "toggle",
					order = 4,
					name = "Calendar",
					desc = "Hides the calendar button",
--					width = "full",
					disabled = function() return not Buttons:IsEnabled() end,
				},
				lfg = {
					type = "toggle",
					order = 5,
					name = "Looking For Group (LFG)",
					desc = "Hides the looking for group (lfg) button",
--					width = "full",
					disabled = function() return not Buttons:IsEnabled() end,
				},
				mail = {
					type = "toggle",
					order = 6,
					name = "Mail",
					desc = "Hides the mail button",
--					width = "full",
					disabled = function() return not Buttons:IsEnabled() end,
				},
				tracking = {
					type = "toggle",
					order = 7,
					name = "Tracking",
					desc = "Hides the tracking button",
--					width = "full",
					disabled = function() return not Buttons:IsEnabled() end,
				},
				voice = {
					type = "toggle",
					order = 8,
					name = "Voice",
					desc = "Hides the voice button",
--					width = "full",
					disabled = function() return not Buttons:IsEnabled() end,
				},
				world = {
					type = "toggle",
					order = 9,
					name = "World Map",
					desc = "Hides the world map button",
--					width = "full",
					disabled = function() return not Buttons:IsEnabled() end,
				},
				zoom = {
					type = "toggle",
					order = 10,
					name = "Zoom",
					desc = "Hides both the zoom buttons",
--					width = "full",
					disabled = function() return not Buttons:IsEnabled() end,
				},
				reset = {
					type = "execute",
					order = 11,
					name = "reset module",
					desc = "use this if you're having trouble",
					width = "full",
					confirm = true,
					func = function() HideBlizzard:ModuleReset("Buttons") end,
				},
			},
		}
	end
	return options
end

function Buttons:OnInitialize()
	self:SetEnabledState(HideBlizzard:GetModuleEnabled("Buttons"))
	self.db = HideBlizzard.db:RegisterNamespace("Buttons", defaults)
	db = self.db.profile

	HideBlizzard:RegisterModuleOptions("Buttons", moduleOptions, "Buttons")
end

function Buttons:OnEnable()
	self:UpdateView()
end

function Buttons:OnDisable()
	self:UpdateView()
end

function Buttons:UpdateView()
	db = self.db.profile

	if db.chatbuttons == true then
		FriendsMicroButton:Hide()
		ChatFrameMenuButton:Hide()
		for i =1, NUM_CHAT_WINDOWS do
			local up = _G["ChatFrame"..i.."ButtonFrame".."UpButton"]
			up:Hide()
			local down = _G["ChatFrame"..i.."ButtonFrame".."DownButton"]
			down:Hide()
			local bottom = _G["ChatFrame"..i.."ButtonFrame".."BottomButton"]
			bottom:Hide()

			_G["ChatFrame"..i.."ButtonFrame"]:Hide()
		end
	else -- todo: UPDATE CHAT
		FriendsMicroButton:Show()
		ChatFrameMenuButton:Show()
		for i =1, NUM_CHAT_WINDOWS do
			local up = _G["ChatFrame"..i.."ButtonFrame".."UpButton"]
			up:Show()
			local down = _G["ChatFrame"..i.."ButtonFrame".."DownButton"]
			down:Show()
			local bottom = _G["ChatFrame"..i.."ButtonFrame".."BottomButton"]
			bottom:Show()

			_G["ChatFrame"..i.."ButtonFrame"]:Show()
		end
	end

	if db.battleground == true then
		MiniMapBattlefieldFrame:Hide()
		MiniMapBattlefieldFrame:UnregisterAllEvents()
	else
		BattlefieldFrame_UpdateStatus()
	end

	if db.calendar == true then
		GameTimeFrame:Hide()
	else
		GameTimeFrame:Show()
	end

	if db.lfg == true then
		if GetLFGMode() then
			MiniMapLFGFrame:Hide()
		end
	else
		if GetLFGMode() then
			MiniMapLFGFrame:Show()
		end
	end

	if db.mail == true then
		if HasNewMail() then
			MiniMapMailFrame:Hide()
		end
	else
		if HasNewMail() then
			MiniMapMailFrame:Show()
		end
	end

	if db.tracking == true then
		MiniMapTracking:Hide()
		MiniMapTrackingButton:Hide()
	else
		MiniMapTracking:Show()
		MiniMapTrackingButton:Show()
	end

	if db.voice == true then
		MiniMapVoiceChatFrame:Hide()
		MiniMapVoiceChatFrame:UnregisterAllEvents()
	else
		MiniMapVoiceChat_Update()
	end

	if db.world == true then
		MiniMapWorldMapButton:Hide() 
	else
		MiniMapWorldMapButton:Show()
	end

	if db.zoom == true then
		MinimapZoomIn:Hide()
		MinimapZoomOut:Hide()
	else
		MinimapZoomIn:Show()
		MinimapZoomOut:Show()
	end
end
