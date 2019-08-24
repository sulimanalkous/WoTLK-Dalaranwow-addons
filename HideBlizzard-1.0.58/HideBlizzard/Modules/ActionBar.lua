local ActionBar = HideBlizzard:NewModule("ActionBar")

local db
local defaults = {
	profile = {
		["gryphons"] = nil,
		["mainmenubar"] = nil,
		["repbar"] = nil,
		["stancebar"] = nil,
		["xpbar"] = nil,
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
		ActionBar:UpdateView()
	end
end

local options = nil
local function moduleOptions()
	if not options then
		options = {
			type = "group",
			name = "ActionBar",
			arg = "ActionBar",
			get = get,
			set = set,
			args = {
				enabled = {
					type = "toggle",
					order = 1,
					name = "|cff00ff66Enable ActionBar|r",
					descStyle = "inline",
					desc = "ActionBar module hides frames connected to the main action bar at the bottom of the screen",
					width = "full",
					get = function() return HideBlizzard:GetModuleEnabled("ActionBar") end,
					set = function(info, value) HideBlizzard:SetModuleEnabled("ActionBar", value) end,
				},
				gryphons = {
					type = "toggle",
					order = 2,
					name = "Gryphons",
					desc = "Hides the art on the ends of the main action bar",
--					width = "full",
					disabled = function() return not ActionBar:IsEnabled() or db.mainmenubar end,
				},
				mainmenubar = {
					type = "toggle",
					order = 3,
					name = "Main Menu Bar",
					desc = "Hides the main action bar and the frames connected to it",
--					width = "full",
					disabled = function() return not ActionBar:IsEnabled() end,
				},
				repbar = {
					type = "toggle",
					order = 4,
					name = "Rep Bar",
					desc = "Hides the reputation bar",
--					width = "full",
					disabled = function() return not ActionBar:IsEnabled() or db.mainmenubar end,
				},
				stancebar = {
					type = "toggle",
					order = 5,
					name = "Stance Bar",
					desc = "Hides the stance/shapeshift bar",
--					width = "full",
					disabled = function() return not ActionBar:IsEnabled() or db.mainmenubar end,
				},
				xpbar = {
					type = "toggle",
					order = 6,
					name = "XP Bar",
					desc = "Hides the experience bar",
--					width = "full",
					disabled = function() return not ActionBar:IsEnabled() or db.mainmenubar end,
				},
				reset = {
					type = "execute",
					order = 7,
					name = "reset module",
					desc = "use this if you're having trouble",
					width = "full",
					confirm = true,
					func = function() HideBlizzard:ModuleReset("ActionBar") end,
				},
			},
		}
	end
	return options
end

function ActionBar:OnInitialize()
	self:SetEnabledState(HideBlizzard:GetModuleEnabled("ActionBar"))
	self.db = HideBlizzard.db:RegisterNamespace("ActionBar", defaults)
	db = self.db.profile

	HideBlizzard:RegisterModuleOptions("ActionBar", moduleOptions, "ActionBar")
end

function ActionBar:OnEnable()
	self:UpdateView()
end

function ActionBar:OnDisable()
	self:UpdateView()
end

function ActionBar:UpdateView()
	db = self.db.profile

	if db.gryphons == true then
		MainMenuBarLeftEndCap:Hide()
		MainMenuBarRightEndCap:Hide()
	else
		MainMenuBarLeftEndCap:Show()
		MainMenuBarRightEndCap:Show()
	end

	if db.mainmenubar == true then
		MainMenuBar:Hide()
		MainMenuBar:UnregisterAllEvents()
		MainMenuBar.Show = function() end
	else
		MainMenuBar.Show = nil
		MainMenuBar:Show()
		MainMenuBar:RegisterEvent("PLAYER_ENTERING_WORLD")
		MainMenuBar:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
		MainMenuBar:RegisterEvent("ADDON_LOADED")
		MainMenuBar:RegisterEvent("BAG_UPDATE")
		MainMenuBar:RegisterEvent("UNIT_ENTERING_VEHICLE")
		MainMenuBar:RegisterEvent("UNIT_ENTERED_VEHICLE")
		MainMenuBar:RegisterEvent("UNIT_EXITING_VEHICLE")
		MainMenuBar:RegisterEvent("UNIT_EXITED_VEHICLE")
	end

	if db.repbar == true then
		for factionIndex = 1, GetNumFactions() do
			local isWatched = GetFactionInfo(factionIndex)
			if isWatched then
				ReputationWatchBar:Hide()
				ReputationWatchBar.Show = function() end
				ReputationWatchBar_Update()
			else
				ReputationWatchBar:Hide()
				ReputationWatchBar.Show = function() end
				ReputationWatchBar_Update()
			end
		end
	else
		for factionIndex = 1, GetNumFactions() do
			local isWatched = GetFactionInfo(factionIndex)
			if isWatched then
				ReputationWatchBar.Show = nil
				ReputationWatchBar:Show()
				ReputationWatchBar_Update()
			else
				ReputationWatchBar:Hide()
				ReputationWatchBar.Show = function() end
				ReputationWatchBar_Update()
			end
		end
	end

	if db.stancebar == true then
		if GetNumShapeshiftForms() ~= 0 then
			ShapeshiftBarFrame:Hide()
			ShapeshiftBarFrame.Show = function() end
		end
	else
		if GetNumShapeshiftForms() ~= 0 then
			ShapeshiftBarFrame.Show = nil
			ShapeshiftBarFrame:Show()
		end
	end

	if db.xpbar == true then
		MainMenuExpBar:Hide()
		MainMenuExpBar.Show = function() end
		MainMenuExpBar_Update()
	else
		MainMenuExpBar.Show = nil
		MainMenuExpBar:Show()
		MainMenuExpBar_Update()
	end
end
