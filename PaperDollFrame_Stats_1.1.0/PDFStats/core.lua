local db
local statsDB

local defaultNumFrames = #PLAYERSTAT_DROPDOWN_OPTIONS
local MISS_CHANCE = "Miss Chance"
AVOIDANCE = "Avoidance"
AVOIDANCEBLK = "Avoidance w/ block"
BLOCK_VALUE = "Block value"
MANA_REGEN_CASTING = MANA_REGEN.." (casting)"

-- complete some "missing" global strings
COMBAT_RATING_NAME18 = SPELL_HASTE
COMBAT_RATING_NAME19 = SPELL_HASTE
COMBAT_RATING_NAME20 = SPELL_HASTE
COMBAT_RATING_NAME25 = SPELL_PENETRATION

CR_ARMOR_PENETRATION_TOOLTIP = CR_HIT_MELEE_TOOLTIP:match("\n\n(.+)")

BLOCK_VALUE_TOOLTIP = CR_BLOCK_TOOLTIP:match("\n(.+)")


local addon = CreateFrame("Frame", "PDFStats", UIParent)
addon:SetToplevel(true)
addon:SetWidth(256)
addon:SetHeight(224)
addon:SetPoint("CENTER")
addon:EnableMouse(true)
addon:SetMovable(true)
addon:Hide()
addon:SetScript("OnMouseDown", addon.StartMoving)
addon:SetScript("OnMouseUp", addon.StopMovingOrSizing)
addon:SetBackdrop({
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true, tileSize = 16, edgeSize = 16,
	insets = {left = 4, right = 4, top = 4, bottom = 4}
})
addon:SetBackdropColor(0, 0, 0, 0.8)
addon:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
addon:RegisterEvent("ADDON_LOADED")
addon:RegisterEvent("PLAYER_LOGIN")
addon:SetScript("OnEvent", function(self, event, ...)
	addon[event](self, ...)
end)


local frameList = CreateFrame("Frame", "PDFStatsFrameList", addon, "UIDropDownMenuTemplate")
frameList:SetPoint("TOPLEFT", -8, -8)


local closeButton = CreateFrame("Button", nil, addon, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", -2, -4)


local deleteButton = CreateFrame("Button", nil, addon, "UIPanelButtonTemplate")
deleteButton:SetWidth(80)
deleteButton:SetHeight(22)
deleteButton:SetPoint("RIGHT", closeButton, "LEFT", 0, -1)
deleteButton:SetText(DELETE)
deleteButton:Hide()
deleteButton:SetScript("OnClick", function()
	addon:RemoveCategory(UIDropDownMenu_GetText(frameList))
end)


local editBox = CreateFrame("EditBox", "PDFStatsEditBox", addon, "InputBoxTemplate")
editBox:SetAutoFocus(true)
editBox:SetFontObject(ChatFontSmall)
editBox:SetWidth(160)
editBox:SetHeight(20)
editBox:SetPoint("TOPLEFT", frameList, "BOTTOM", 4, 0)
editBox:SetText("Enter category name...")
editBox:Hide()
editBox:SetScript("OnEnterPressed", function(self)
	local text = self:GetText()
	if text:match("%S+") then
		if not addon:AddCategory(text) then
			self:SetText("Enter category name...")
			self:HighlightText()
			return
		end
		addon:SelectCategory(#db)
		UIDropDownMenu_SetText(frameList, text)
		self:Hide()
	else
		self:SetText("Enter category name...")
		self:HighlightText()
		addon:Print("Invalid category name.")
	end
end)
editBox:SetScript("OnEscapePressed", function(self)
	self:Hide()
	addon:SelectCategory(nil)
end)


function addon:InitializeDropDowns()
	local function newCategory()
		self:SelectCategory(nil)
		editBox:SetText("Enter category name...")
		editBox:Show()
	end
	
	local function onClick(self)
		addon:SelectCategory(self.value)
	end
	
	local info = {}
	
	UIDropDownMenu_Initialize(frameList, function(self)
		for i, v in ipairs(db) do
			wipe(info)
			info.text = v.name
			info.value = i
			info.func = onClick
			UIDropDownMenu_AddButton(info)
		end
		
		wipe(info)
		info.text = "Create new..."
		info.value = "new"
		info.func = newCategory
		UIDropDownMenu_AddButton(info)
	end)
	
	UIDropDownMenu_JustifyText(frameList, "LEFT")
	UIDropDownMenu_SetText(frameList, "Select category")


	-- table to contain the six dropdown menus
	frameList.statLists = {}

	do
		-- onClick function for all dropdown menu items
		local function onClick(self, frame)
			addon:SetStat(frame, self.value)
			db[UIDropDownMenu_GetSelectedValue(frameList)][frame.pos].name = self.value
			CloseDropDownMenus()
			PaperDollFrame_UpdateStats()
		end
		
		local info = {}
		
		-- dropdown menu initialize function that adds all the menu items
		local function initialize(self, level)
			wipe(info)
			
			if level == 1 then
				-- menu level 1; categories
				info.text = NONE
				info.value = "none"
				info.arg1 = self
				info.func = onClick
				UIDropDownMenu_AddButton(info, level)
				
				wipe(info)
				
				for i, cat in ipairs(statsDB) do
					info.text = cat.label
					info.value = cat.value
					info.notCheckable = true
					info.hasArrow = true
					UIDropDownMenu_AddButton(info, level)
				end
			elseif level == 2 then
				-- menu level 2; stats
				for i, cat in ipairs(statsDB) do
					if UIDROPDOWNMENU_MENU_VALUE == cat.value then
						wipe(info)
						info.text = cat.label
						info.isTitle = true
						info.notCheckable = true
						UIDropDownMenu_AddButton(info, level)
						
						-- add "Rating" menu
						if cat.ratings then
							wipe(info)
							info.text = RATING
							info.value = cat.label.."Ratings"
							info.notCheckable = true
							info.hasArrow = true
							UIDropDownMenu_AddButton(info, level)
						end
						
						-- add stat buttons
						for j, stat in ipairs(cat.stats) do
							wipe(info)
							info.text = stat.label
							info.value = stat.value
							info.arg1 = self
							info.func = onClick
							UIDropDownMenu_AddButton(info, level)
						end
					end
				end
			elseif level == 3 then
				-- menu level 3; ratings
				for i, cat in ipairs(statsDB) do
					if cat.ratings and UIDROPDOWNMENU_MENU_VALUE == cat.label.."Ratings" then
						wipe(info)
						info.text = RATING
						info.isTitle = true
						info.notCheckable = true
						UIDropDownMenu_AddButton(info, level)
						
						for j, rating in ipairs(cat.ratings) do
							wipe(info)
							info.text = rating.label..(rating.effective and " %" or "")
							info.value = rating.value
							info.arg1 = self
							info.func = onClick
							rating.isRating = true
							UIDropDownMenu_AddButton(info, level)
						end
					end
				end
			end
		end

		for i = 1, 6 do
			local frame = CreateFrame("Frame", "PDFStatsFrameListStat"..i, addon, "UIDropDownMenuTemplate")
			if i == 1 then
				frame:SetPoint("TOPLEFT", frameList, "BOTTOMLEFT", 0, -8)
			else
				frame:SetPoint("TOP", frameList.statLists[i - 1], "BOTTOM", 0, 4)
			end
			frame.pos = i
			frame:Hide()
			
			UIDropDownMenu_Initialize(frame, initialize)
			
			UIDropDownMenu_SetWidth(frame, 192)
			UIDropDownMenu_JustifyText(frame, "LEFT")
			UIDropDownMenu_SetSelectedValue(frame, "none")
			
			frameList.statLists[i] = frame
		end
	end
end


function addon:ADDON_LOADED(addon)
	if addon == "PDFStats" then
		statsDB = self.statsDB
		PDFStatsData = PDFStatsData or {}
		db = PDFStatsData
		
		-- insert our stored custom categories into table of default categories
		for i, v in ipairs(db) do
			self:InsertCategoryInTable(v.name)
		end
		self:InitializeDropDowns()
		
		self:UnregisterEvent("ADDON_LOADED")
	end
end


function addon:PLAYER_LOGIN()
	-- fallback to "Base stats" if a non existant custom category was selected
	for i, list in ipairs{"Left", "Right"} do
		if not tContains(PLAYERSTAT_DROPDOWN_OPTIONS, GetCVar("playerStat"..list.."Dropdown")) then
			self:FallbackToDefault(list)
		end
	end
end


SlashCmdList.PDFSTATS_TOGGLE = function()
	if addon:IsShown() then
		addon:Hide()
	else
		addon:Show()
	end
end
SLASH_PDFSTATS_TOGGLE1 = "/pdf"
SLASH_PDFSTATS_TOGGLE2 = "/stats"


-- given the value, retrieves data about a stat from the stats table
function addon:GetStatInfo(value)
	for i, cat in ipairs(statsDB) do
		for j, stat in ipairs(cat.stats) do
			if stat.value == value then
				return stat.label, stat.func, stat.onEnter, cat.label
			end
		end
		
		if cat.ratings then
			for j, rating in ipairs(cat.ratings) do
				if rating.value == value then
					return rating.label, rating.func, nil, cat.label, true, rating.effective
				end
			end
		end
	end
end


function addon:AddCategory(name)
	if not self:InsertCategoryInTable(name) then
		return
	end
	tinsert(db, {name = name, {},{},{},{},{},{}})
	return true
end


function addon:RemoveCategory(name)
	local statFrame = self:Codify(name)
	for i, v in ipairs(PLAYERSTAT_DROPDOWN_OPTIONS) do
		if v == statFrame then
			tremove(PLAYERSTAT_DROPDOWN_OPTIONS, i)
		end
	end
	_G[statFrame] = nil
	for i, v in ipairs(db) do
		if v.name == name then
			tremove(db, i)
			break
		end
	end
	for i, list in ipairs{"Left", "Right"} do
		if UIDropDownMenu_GetSelectedValue(_G["PlayerStatFrame"..list.."DropDown"]) == statFrame then
			self:FallbackToDefault(list)
		end
	end
	self:Print(format("Removed category '%s'.", name))
	self:SelectCategory(nil)
end


-- selects a category, setting appropriate values on all menus
function addon:SelectCategory(index)
	if index then
		UIDropDownMenu_SetSelectedValue(frameList, index)
		for i = 1, 6 do
			local catList = frameList.statLists[i]
			catList:Show()
			self:SetStat(catList, db[index][i].name)
		end
		deleteButton:Show()
	else
		UIDropDownMenu_SetSelectedValue(frameList, nil)
		UIDropDownMenu_SetText(frameList, "Select category")
		local menus = frameList.statLists
		for i = 1, 6 do
			menus[i]:Hide()
		end
		deleteButton:Hide()
	end
end


-- set a stat to one of the 6 menus
function addon:SetStat(frame, statValue)
	local stat, _, _, category, _, effective = addon:GetStatInfo(statValue)
	UIDropDownMenu_SetSelectedValue(frame, statValue or "none")
	UIDropDownMenu_SetText(frame, stat and format("%s - %s%s", category, stat, effective and " %" or "") or NONE)
end


function addon:InsertCategoryInTable(name)
	local statFrame = self:Codify(name)
	for i, v in ipairs(PLAYERSTAT_DROPDOWN_OPTIONS) do
		if v == statFrame then
			self:Print("A frame with this name already exists. Please choose another name.")
			return
		end
	end
	tinsert(PLAYERSTAT_DROPDOWN_OPTIONS, statFrame)
	_G[statFrame] = name
	return true
end


function addon:FallbackToDefault(list)
	local stats = "PLAYERSTAT_BASE_STATS"
	if list == "Right" then
		local _, class = UnitClass("player")
		if class == "PRIEST" or class == "MAGE" or class == "WARLOCK" then
			stats = "PLAYERSTAT_SPELL"
		elseif class == "HUNTER" then
			stats = "PLAYERSTAT_RANGED"
		else
			stats = "PLAYERSTAT_MELEE"
		end
	end
	SetCVar("playerStat"..list.."Dropdown", stats)
	_G["PlayerStatFrame"..list.."DropDown_OnShow"](_G["PlayerStatFrame"..list.."DropDown"])
	UpdatePaperdollStats("PlayerStatFrame"..list, stats)
end


-- convert a given string to a valid variable name
function addon:Codify(str)
	return "PLAYERSTAT_"..str:trim():upper():gsub("%W", "_")
end


function addon:Print(msg)
	print("|cff56a3ffPDFStats:|r", msg)
end


---------------------------------------------------
-- Below are several hooks and fixed to various
-- Blizz functions needed to make the system work!
---------------------------------------------------


-- hook original UpdatePaperDollStats so we can use our own custom frames
local Orig_UpdatePaperdollStats = UpdatePaperdollStats

local statFrames = {}

function UpdatePaperdollStats(prefix, index)
	for i = 1, 6 do
		statFrames[i] = _G[prefix..i]
		-- resets custom stat tooltips
		statFrames[i]:SetScript("OnEnter", PaperDollStatTooltip)
	end
	
	Orig_UpdatePaperdollStats(prefix, index)
	
	-- here we check if the stat frame we have chosen is one made by the addon
	local stat
	for _, v in ipairs(db) do
		if addon:Codify(v.name) == index then
			for i = 1, 6 do
				stat = v[i]
				if stat.name and stat.name ~= "none" then
					local _, func, onEnter, _, isRating, effective = addon:GetStatInfo(stat.name)
					-- the func field is a number representing the rating index for ratings, or base stat index
					if type(func) == "number" then
						if isRating then
							PaperDollFrame_SetRating(statFrames[i], func, effective)
						else
							PaperDollFrame_SetStat(statFrames[i], func)
						end
					else
						_G["PaperDollFrame_Set"..func](statFrames[i], "player")
						-- set custom tooltip for this stat if applicable
						if onEnter then
							statFrames[i]:SetScript("OnEnter", _G["Character"..onEnter.."_OnEnter"])
						end
					end
				else
					-- this line has no stat associated to it, hide
					statFrames[i]:Hide()
				end
			end
			break
		end
	end
end


local fixedStats = {
	[CR_DODGE] = CR_DODGE_TOOLTIP,
	[CR_PARRY] = CR_PARRY_TOOLTIP,
	[CR_BLOCK] = CR_BLOCK_TOOLTIP,
	[CR_CRIT_MELEE] = CR_CRIT_MELEE_TOOLTIP,
	[CR_HASTE_MELEE] = CR_HASTE_RATING_TOOLTIP,
	[CR_CRIT_RANGED] = CR_CRIT_RANGED_TOOLTIP,
	[CR_HASTE_RANGED] = CR_HASTE_RATING_TOOLTIP,
	[CR_HASTE_SPELL] = CR_HASTE_RATING_TOOLTIP,
	[CR_ARMOR_PENETRATION] = CR_ARMOR_PENETRATION_TOOLTIP,
}

-- hook SetRating function to fix several flaws in it...
local OrigPaperDollFrame_SetRating = PaperDollFrame_SetRating

function PaperDollFrame_SetRating(statFrame, ratingIndex, effectiveValue)
	local label = _G[statFrame:GetName().."Label"]
	local text = _G[statFrame:GetName().."StatText"]
	local statName = _G["COMBAT_RATING_NAME"..ratingIndex]
	label:SetText(statName..":")
	local rating = GetCombatRating(ratingIndex)
	local ratingBonus = GetCombatRatingBonus(ratingIndex)
	text:SetText(effectiveValue and format("%.2f%%", ratingBonus) or rating)

	-- Set the tooltip text
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, statName).." "..rating..FONT_COLOR_CODE_CLOSE
	-- Can probably axe this if else tree if all rating tooltips follow the same format
	if fixedStats[ratingIndex] then
		statFrame.tooltip2 = format(fixedStats[ratingIndex], rating, ratingBonus, ratingIndex == CR_BLOCK and GetShieldBlock())
		statFrame:Show()
		return
	elseif ratingIndex == CR_DEFENSE_SKILL then
		local defensePercent = GetDodgeBlockParryChanceFromDefense()
		statFrame.tooltip2 = format(DEFAULT_STATDEFENSE_TOOLTIP, GetCombatRating(CR_DEFENSE_SKILL), GetCombatRatingBonus(CR_DEFENSE_SKILL), defensePercent, defensePercent)
		statFrame:Show()
		return
	elseif ratingIndex == CR_CRIT_SPELL then
		local holySchool = 2;
		local minCrit = GetSpellCritChance(holySchool);
		statFrame.spellCrit = {};
		statFrame.spellCrit[holySchool] = minCrit;
		local spellCrit;
		for i=(holySchool+1), MAX_SPELL_SCHOOLS do
			spellCrit = GetSpellCritChance(i);
			minCrit = min(minCrit, spellCrit);
			statFrame.spellCrit[i] = spellCrit;
		end
		minCrit = format("%.2f%%", minCrit);
		statFrame.minCrit = minCrit;
		statFrame:SetScript("OnEnter", CharacterSpellCritChance_OnEnter)
		statFrame:Show()
		return
	elseif ratingIndex == CR_EXPERTISE then
		local expertise, offhandExpertise = GetExpertise()
		local speed, offhandSpeed = UnitAttackSpeed("player")
		local text
		if offhandSpeed then
			text = expertise.." / "..offhandExpertise
		else
			text = expertise
		end
		-- PaperDollFrame_SetLabelAndText(statFrame, STAT_EXPERTISE, text)
		
		statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, _G["COMBAT_RATING_NAME"..CR_EXPERTISE]).." "..text..FONT_COLOR_CODE_CLOSE
		
		local expertisePercent, offhandExpertisePercent = GetExpertisePercent()
		expertisePercent = format("%.2f", expertisePercent)
		if offhandSpeed then
			offhandExpertisePercent = format("%.2f", offhandExpertisePercent)
			text = expertisePercent.."% / "..offhandExpertisePercent.."%"
		else
			text = expertisePercent.."%"
		end
		statFrame.tooltip2 = format(CR_EXPERTISE_TOOLTIP, text, GetCombatRating(CR_EXPERTISE), GetCombatRatingBonus(CR_EXPERTISE))

		statFrame:Show()
		return
	end
	
	OrigPaperDollFrame_SetRating(statFrame, ratingIndex)
	
	text:SetText(effectiveValue and format("%.2f%%", ratingBonus) or rating)
end


-- need to force show the stat frame when using melee/ranged crit chance, as the original function doesn't do that
local OrigPaperDollFrame_SetMeleeCritChance = PaperDollFrame_SetMeleeCritChance

function PaperDollFrame_SetMeleeCritChance(statFrame)
	OrigPaperDollFrame_SetMeleeCritChance(statFrame)
	statFrame:Show()
end


local OrigPaperDollFrame_SetRangedCritChance = PaperDollFrame_SetRangedCritChance

function PaperDollFrame_SetRangedCritChance(statFrame)
	OrigPaperDollFrame_SetRangedCritChance(statFrame)
	statFrame:Show()
end


-- fix tooltip
local OrigPaperDollFrame_SetSpellPenetration = PaperDollFrame_SetSpellPenetration

function PaperDollFrame_SetSpellPenetration(statFrame)
	OrigPaperDollFrame_SetSpellPenetration(statFrame)
	local spellPenetration = GetSpellPenetration()
	statFrame.tooltip2 = SPELL_PENETRATION_TOOLTIP:format(spellPenetration, spellPenetration)
end


---------------------------------------
-- these are functions that were made
-- for "custom made" stat displays
---------------------------------------

-- shows casting mana regen instead of base
function PaperDollFrame_SetManaRegenCasting(statFrame)
	PaperDollFrame_SetManaRegen(statFrame)
	local base, casting = GetManaRegen()
	_G[statFrame:GetName().."StatText"]:SetText(floor(casting * 5))
end


-- this is your combined dodge, parry chance and chance to be missed
function PaperDollFrame_SetAvoidance(statFrame)
	local avoidance = GetDodgeChance() + GetBlockChance() + GetParryChance() + GetDodgeBlockParryChanceFromDefense()
	PaperDollFrame_SetLabelAndText(statFrame, AVOIDANCE, avoidance, 1)
	statFrame:Show()
end


function CharacterAvoidance_OnEnter(self)
	local dodge, parry, miss = GetDodgeChance(), GetParryChance(), GetDodgeBlockParryChanceFromDefense()
	local avoidance = dodge + parry + miss
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetText(HIGHLIGHT_FONT_COLOR_CODE..format("Avoidance %.2f%%", avoidance)..FONT_COLOR_CODE_CLOSE)
	GameTooltip:AddDoubleLine(DODGE_CHANCE, format("%.2f%%", dodge))
	GameTooltip:AddDoubleLine(PARRY_CHANCE, format("%.2f%%", parry))
	GameTooltip:AddDoubleLine(MISS_CHANCE, format("%.2f%%", miss))
	
	GameTooltip:Show()
end


-- same as above but including block chance
function PaperDollFrame_SetAvoidanceBlk(statFrame)
	local avoidance = GetDodgeChance() + GetBlockChance() + GetParryChance() + GetDodgeBlockParryChanceFromDefense()
	PaperDollFrame_SetLabelAndText(statFrame, AVOIDANCE, avoidance, 1)
	statFrame:Show()
end


function CharacterAvoidanceBlk_OnEnter(self)
	local dodge, parry, block, miss = GetDodgeChance(), GetParryChance(), GetBlockChance(), GetDodgeBlockParryChanceFromDefense()
	local avoidance = dodge + parry + block + miss
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetText(HIGHLIGHT_FONT_COLOR_CODE..format("Avoidance %.2f%%", avoidance)..FONT_COLOR_CODE_CLOSE)
	GameTooltip:AddDoubleLine(DODGE_CHANCE, format("%.2f%%", dodge))
	GameTooltip:AddDoubleLine(PARRY_CHANCE, format("%.2f%%", parry))
	GameTooltip:AddDoubleLine(BLOCK_CHANCE, format("%.2f%%", block))
	GameTooltip:AddDoubleLine(MISS_CHANCE, format("%.2f%%", miss))
	
	GameTooltip:Show()
end


function PaperDollFrame_SetBlockValue(statFrame)
	local blockValue = GetShieldBlock()
	PaperDollFrame_SetLabelAndText(statFrame, BLOCK_VALUE, blockValue)
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. format("Block value %d", blockValue) .. FONT_COLOR_CODE_CLOSE
	statFrame.tooltip2 = BLOCK_VALUE_TOOLTIP:format(blockValue)
	statFrame:Show()
end