HideBlizzard = LibStub("AceAddon-3.0"):NewAddon("HideBlizzard", "AceConsole-3.0", "AceEvent-3.0")
HideBlizzard:SetEnabledState(true)
HideBlizzard:SetDefaultModuleState(false)
HideBlizzard:SetDefaultModuleLibraries("AceEvent-3.0")

local _VERSION = GetAddOnMetadata("HideBlizzard", "Version") or 0

local db
local defaults = {
	profile = {
		modules = {
			["ActionBar"] = nil,
			["Buttons"] = nil,
			["Pet"] = nil,
			["Player"] = nil,
			["SpecialFrames"] = nil,
			["Target"] = nil,
			["Vehicle"] = nil,
		},
	},
}

function HideBlizzard:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("HideBlizzardDB", defaults)
	self.db.RegisterCallback(self, "OnProfileChanged", "UpdateView")
	self.db.RegisterCallback(self, "OnProfileCopied", "UpdateView")
	self.db.RegisterCallback(self, "OnProfileReset", "UpdateView")
	db = self.db.profile

	self:Init()
	self:RegisterOptions()
	self:RegisterChatCommand("hb", function()
		InterfaceOptionsFrame_OpenToCategory(HideBlizzard.optionFrame.Profiles)
		InterfaceOptionsFrame_OpenToCategory(HideBlizzard.optionFrame.HideBlizzard)
		InterfaceOptionsFrame:Raise()
		collectgarbage()
	end)
end

function HideBlizzard:OnEnable()
	self:RegisterEvent("PLAYER_REGEN_DISABLED", function()
		if InCombatLockdown() then
			if InterfaceOptionsFrame:IsVisible() then
				self:Print("|cff40bbffHideBlizzard|r is closing the options window since you are currently in combat.")
				InterfaceOptionsFrame:Hide()
				GameMenu:Hide()
			end
		end
	end)
end

function HideBlizzard:OnDisable()
--	self:UnregisterAllEvents()
end

function HideBlizzard:Init()
	local waitFrame = CreateFrame("Frame")
	local lastUpdate = 0
	waitFrame:SetScript("OnUpdate", function(self, elapsed)
		lastUpdate = lastUpdate + elapsed
		if (lastUpdate > 3) then
			if not db.Version then
				db.Version = _VERSION
				HideBlizzard:Print("Welcome! Type /hb to configure.")
			elseif db.Version ~= _VERSION then
				db.Version = _VERSION
				HideBlizzard:Print(string.format("Updated to version |cff00ff66%s|r. See changelog for recent changes.", db.Version))
			end
			lastUpdate = 0
			waitFrame:SetScript("OnUpdate", nil)
			lastUpdate = nil
			waitFrame = nil
			collectgarbage()
		end
	end)
end

-- |cff40bbffHideBlizzard|r
function HideBlizzard:GlobalReset()
	wipe(HideBlizzardDB)
	self:Print("Database has been reset! Will take effect when you next login.")
end

function HideBlizzard:ModuleReset(module)
	if type(module) ~= "string" then return end

	if GetModuleEnabled(module) then
		HideBlizzard:DisableModule(module)
		wipe(HideBlizzardDB.namespaces[module])
		self:Print(string.format("%s settings reset! Will take effect when you next login.", module))
	end
end

-- @Mapster func
function HideBlizzard:GetModuleEnabled(module)
	return self.db.profile.modules[module]
end

-- @Mapster func
function HideBlizzard:SetModuleEnabled(module, value)
	local old = HideBlizzard.db.profile.modules[module]
	HideBlizzard.db.profile.modules[module] = value
	if old ~= value then
		if value then
			HideBlizzard:EnableModule(module)
		else
			HideBlizzard:DisableModule(module)
		end
	end
end

-- @Mapster func
function HideBlizzard:UpdateView()
	for k,v in self:IterateModules() do
		if self:GetModuleEnabled(k) and not v:IsEnabled() then
			self:EnableModule(k)
		elseif not self:GetModuleEnabled(k) and v:IsEnabled() then
			self:DisableModule(k)
		end
		if type(v.UpdateView) == "function" then
			v:UpdateView()
		end
	end
end
