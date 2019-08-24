local Vehicle = HideBlizzard:NewModule("Vehicle")

local db
local defaults = {
	profile = {
		["vehiclemenubar"] = nil,
		["vehicleseat"] = nil,
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
		Vehicle:UpdateView()
	end
end

local options = nil
local function moduleOptions()
	if not options then
		options = {
			type = "group",
			name = "Vehicle",
			arg = "Vehicle",
			get = get,
			set = set,
			args = {
				enabled = {
					type = "toggle",
					order = 1,
					name = "|cff00ff66Enable Vehicle|r",
					descStyle = "inline",
					desc = "Vehicle module hides vehicle related frames",
					width = "full",
					get = function() return HideBlizzard:GetModuleEnabled("Vehicle") end,
					set = function(info, value) HideBlizzard:SetModuleEnabled("Vehicle", value) end,
				},
				vehiclemenubar = {
					type = "toggle",
					order = 2,
					name = "Vehicle Menu Bar",
					desc = "Hides the vehicle menu bar",
--					width = "full",
					disabled = function() return not Vehicle:IsEnabled() end,
				},
				vehicleseat = {
					type = "toggle",
					order = 3,
					name = "Vehicle Seat",
					desc = "Hides the vehicle seat under the minimap",
--					width = "full",
					disabled = function() return not Vehicle:IsEnabled() end,
				},
				reset = {
					type = "execute",
					order = 4,
					name = "reset module",
					desc = "use this if you're having trouble",
					width = "full",
					confirm = true,
					func = function() HideBlizzard:ModuleReset("Vehicle") end,
				},
			},
		}
	end
	return options
end

function Vehicle:OnInitialize()
	self:SetEnabledState(HideBlizzard:GetModuleEnabled("Vehicle"))
	self.db = HideBlizzard.db:RegisterNamespace("Vehicle", defaults)
	db = self.db.profile

	HideBlizzard:RegisterModuleOptions("Vehicle", moduleOptions, "Vehicle")
end

function Vehicle:OnEnable()
	self:UpdateView()
end

function Vehicle:OnDisable()
	self:UpdateView()
end

function Vehicle:UpdateView()
	db = self.db.profile

	if db.vehiclemenubar == true then
		VehicleMenuBar:Hide()
		VehicleMenuBar:UnregisterAllEvents()
		VehicleMenuBar.Show = function() end
	else
		if UnitInVehicle("player") then
			VehicleMenuBar.Show = nil
			VehicleMenuBar:Show()
		end
		VehicleMenuBar:RegisterEvent("UNIT_ENTERING_VEHICLE")
		VehicleMenuBar:RegisterEvent("UNIT_ENTERED_VEHICLE")
		VehicleMenuBar:RegisterEvent("UNIT_EXITED_VEHICLE")
		VehicleMenuBar:RegisterEvent("UNIT_DISPLAYPOWER")
		VehicleMenuBar:RegisterEvent("VEHICLE_ANGLE_UPDATE")
		VehicleMenuBar:RegisterEvent("VEHICLE_PASSENGERS_CHANGED")
		VehicleMenuBar:RegisterEvent("PLAYER_GAINS_VEHICLE_DATA")
		VehicleMenuBar:RegisterEvent("PLAYER_LOSES_VEHICLE_DATA")
		VehicleMenuBar:RegisterEvent("PLAYER_ENTERING_WORLD")
	end

	if db.vehicleseat == true then
		VehicleSeatIndicator:Hide()
		VehicleSeatIndicator:UnregisterAllEvents()
		VehicleSeatIndicator.Show = function() end
	else
		if UnitInVehicle("player") then
			VehicleSeatIndicator.Show = nil
			VehicleSeatIndicator:Show()
		end
		VehicleSeatIndicator:RegisterEvent("UNIT_ENTERING_VEHICLE")
		VehicleSeatIndicator:RegisterEvent("UNIT_ENTERED_VEHICLE")
		VehicleSeatIndicator:RegisterEvent("UNIT_EXITED_VEHICLE")
		VehicleSeatIndicator:RegisterEvent("UNIT_DISPLAYPOWER")
		VehicleSeatIndicator:RegisterEvent("VEHICLE_ANGLE_UPDATE")
		VehicleSeatIndicator:RegisterEvent("VEHICLE_PASSENGERS_CHANGED")
		VehicleSeatIndicator:RegisterEvent("PLAYER_GAINS_VEHICLE_DATA")
		VehicleSeatIndicator:RegisterEvent("PLAYER_LOSES_VEHICLE_DATA")
		VehicleSeatIndicator:RegisterEvent("PLAYER_ENTERING_WORLD")
	end
end
