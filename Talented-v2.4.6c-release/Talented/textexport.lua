local Talented = Talented
local ipairs = ipairs

local L = LibStub("AceLocale-3.0"):GetLocale("Talented")

function Talented:BuildTalentText(template, fullTree)
	local class = template.class
	local info = self:UncompressSpellData(class)
	local className = (LOCALIZED_CLASS_NAMES_MALE and LOCALIZED_CLASS_NAMES_MALE[class]) or class

	local lines = {}
	local name = template.name
	if name and name ~= "" then
		lines[#lines + 1] = ("%s (%s)"):format(name, className)
	else
		lines[#lines + 1] = className
	end
	lines[#lines + 1] = L["Total points: %d"]:format(self:GetPointCount(template))

	for tab, tree in ipairs(info) do
		local tabdata = self.tabdata[class][tab]
		local tabName = tabdata and tabdata.name or tab
		lines[#lines + 1] = ""
		lines[#lines + 1] = ("%s (%d)"):format(tabName, self:GetTalentTabCount(template, tab))
		for index, talent in ipairs(tree) do
			if not talent.inactive then
				local rank = template[tab][index] or 0
				if fullTree or rank > 0 then
					local extra = ""
					if fullTree then
						extra = (" - Row %d, Col %d"):format(talent.row, talent.column)
						if talent.req then
							extra = extra..(", requires %s"):format(self:GetTalentName(class, tab, talent.req) or "?")
						end
					end
					lines[#lines + 1] = ("  %s %d/%d%s"):format(self:GetTalentName(class, tab, index) or "?", rank, #talent.ranks, extra)
				end
			end
		end
	end

	return table.concat(lines, "\n")
end

local exportFrame

local function CreateExportFrame()
	local f = CreateFrame("Frame", "TalentedTextExportFrame", UIParent)
	f:SetSize(420, 380)
	f:SetPoint("CENTER")
	f:SetFrameStrata("DIALOG")
	f:SetBackdrop{
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		tile = true, tileSize = 32, edgeSize = 32,
		insets = { left = 11, right = 12, top = 12, bottom = 11 },
	}
	f:SetMovable(true)
	f:EnableMouse(true)
	f:RegisterForDrag"LeftButton"
	f:SetScript("OnDragStart", f.StartMoving)
	f:SetScript("OnDragStop", f.StopMovingOrSizing)
	f:SetToplevel(true)
	f:Hide()
	tinsert(UISpecialFrames, "TalentedTextExportFrame")

	local title = f:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOP", 0, -16)
	title:SetText(L["Talent Build"])
	f.title = title

	local hint = f:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	hint:SetPoint("TOP", title, "BOTTOM", 0, -4)
	hint:SetText(L["Select All (Ctrl+A) and copy (Ctrl+C)"])

	CreateFrame("Button", nil, f, "UIPanelCloseButton"):SetPoint("TOPRIGHT", -4, -4)

	local scrollFrame = CreateFrame("ScrollFrame", "TalentedTextExportScroll", f, "UIPanelScrollFrameTemplate")
	scrollFrame:SetPoint("TOPLEFT", 16, -56)
	scrollFrame:SetPoint("BOTTOMRIGHT", -32, 40)

	local editBox = CreateFrame("EditBox", nil, scrollFrame)
	editBox:SetMultiLine(true)
	editBox:SetFontObject(ChatFontNormal)
	editBox:SetWidth(360)
	editBox:SetAutoFocus(false)
	editBox:SetScript("OnEscapePressed", function () f:Hide() end)
	scrollFrame:SetScrollChild(editBox)
	f.editBox = editBox

	local selectAll = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
	selectAll:SetSize(120, 22)
	selectAll:SetPoint("BOTTOM", 0, 12)
	selectAll:SetText(L["Select All"])
	selectAll:SetScript("OnClick", function ()
		editBox:SetFocus()
		editBox:HighlightText()
	end)
	f.selectAll = selectAll

	exportFrame = f
	return f
end

function Talented:ShowTextExport(text)
	local f = exportFrame or CreateExportFrame()
	f.editBox:SetText(text)
	f.editBox:HighlightText()
	f.editBox:SetFocus()
	f:Show()
end
