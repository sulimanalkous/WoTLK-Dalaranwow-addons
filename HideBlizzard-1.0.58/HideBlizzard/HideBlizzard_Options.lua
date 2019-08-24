local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")

local get, set
do
	function get(info)
		local key = info[#info] 
		return HideBlizzard.db.profile[key]
	end

	function set(info, value)
		local key = info[#info]
		HideBlizzard.db.profile[key] = value
		HideBlizzard:UpdateView()
	end
end

local options, moduleOptions = nil, {}
local function generalOptions()
	if not options then
		options = {
			name = "HideBlizzard",
			type = "group",
			args = {
				HideBlizzardOptions = {
					order = 1,
					type = "group",
					name = "HideBlizzard",
					get = get,
					set = set,
					args = {
						changelog = {
							type = "description",
							order = 2,
							name = function() return
							[[|cffffff33 Version 1.0.58 - 8/16/10|r

    • various bugs fixed
    • more code cleanup
]]
							end,
							width = "full",
						},
						spacer = {
							type = "description",
							order = 3,
							name = "",
						},
						help = {
							type = "description",
							order = 4,
							name = function() return
							[[|cffffff33 Problems & Solutions (3)|r

1. After using Stancebar option the button textures are offset and look wierd.
    |cffff8000This can happen, if it does, simply reloadui.|r

2. After disabling the tooltip option, the tooltip box looks wierd.
    |cffff8000This can happen, if it does, simply reloadui.|r

3. I somehow broke HideBlizzard. What do I do?
    |cffff8000If this happens, press the 'Reset' button and see if that works. If not, then please report what you did.|r]]
							end,
							width = "full",
						},
						spacer = {
							type = "description",
							order = 5,
							name = "\n",
						},
						info = {
							type = "description",
							order = 7,
							name = function() return[[You can get support either at |cffffff33curse.com|r or |cffffff33wowinterface.com|r. Use one of these sites to post bug reports or feature requests.|r]]
							end,
							width = "full",
						},
						reset = {
							type = "execute",
							order = 8,
							name = "reset",
							desc = "reset settings to defaults",
							width = "full",
							confirm = true,
							func = function() HideBlizzard:GlobalReset() end,
						},
					},
				},
			},
		}
		for k, v in pairs(moduleOptions) do
			options.args[k] = type(v) == "function" and v() or v
		end
	end
	return options
end

local optionFrame = {}
function HideBlizzard:RegisterOptions()
	self.optionFrame = {}

	AceConfigRegistry:RegisterOptionsTable("HideBlizzard", generalOptions)
	self.optionFrame.HideBlizzard = AceConfigDialog:AddToBlizOptions("HideBlizzard", nil, nil, "HideBlizzardOptions")
	self:RegisterModuleOptions("Profiles", AceDBOptions:GetOptionsTable(self.db), "Profiles")
end

function HideBlizzard:RegisterModuleOptions(name, optionTbl, displayName)
	moduleOptions[name] = optionTbl
	self.optionFrame[name] = AceConfigDialog:AddToBlizOptions("HideBlizzard", displayName, "HideBlizzard", name)
end
