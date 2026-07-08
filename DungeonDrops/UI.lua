DungeonDrops.UI = {}

local QMARK = "Interface\\Icons\\INV_Misc_QuestionMark"

local SLOT_ICONS = {
    Head = "INV_Helmet_01", Neck = "INV_Jewelry_Necklace_01", Shoulder = "INV_Shoulder_01",
    Back = "INV_Misc_Cape_01", Chest = "INV_Chest_Cloth_01", Wrist = "INV_Bracer_01",
    Hands = "INV_Gauntlets_01", Waist = "INV_Belt_01", Legs = "INV_Pants_01",
    Feet = "INV_Boots_01", Ring = "INV_Jewelry_Ring_01", Trinket = "INV_Jewelry_Trinket_01",
    ["One-Hand Sword"] = "INV_Sword_01", ["Two-Hand Sword"] = "INV_Sword_04",
    ["One-Hand Mace"] = "INV_Mace_01", ["Two-Hand Mace"] = "INV_Mace_04",
    ["One-Hand Axe"] = "INV_Axe_01", ["Two-Hand Axe"] = "INV_Axe_04",
    Dagger = "INV_Weapon_ShortBlade_01", Staff = "INV_Staff_01",
    Polearm = "INV_Spear_01", Bow = "INV_Weapon_Bow_01", Gun = "INV_Musket_01",
    Wand = "INV_Wand_01", Shield = "INV_Shield_01", ["Off-Hand"] = "INV_Offhand_Hybrid_01",
    Ranged = "INV_Weapon_Bow_01", ["One-Hand Dagger"] = "INV_Weapon_ShortBlade_01",
    ["Two-Hand Staff"] = "INV_Staff_01", ["Two-Hand Mace2"] = "INV_Mace_04",
    Fist = "INV_Gauntlets_02", Totem = "INV_Misc_Totem_01",
}

local STAT_SHORT = {
    ITEM_MOD_STRENGTH = "Str", ITEM_MOD_AGILITY = "Agi", ITEM_MOD_STAMINA = "Sta",
    ITEM_MOD_INTELLECT = "Int", ITEM_MOD_SPIRIT = "Spi",
    ITEM_MOD_HIT_RATING = "Hit", ITEM_MOD_CRIT_RATING = "Crit",
    ITEM_MOD_HASTE_RATING = "Haste", ITEM_MOD_EXPERTISE_RATING = "Exp",
    ITEM_MOD_ARMOR_PENETRATION_RATING = "ArP",
    ITEM_MOD_DEFENSE_SKILL_RATING = "Def", ITEM_MOD_DODGE_RATING = "Dodge",
    ITEM_MOD_PARRY_RATING = "Parry", ITEM_MOD_BLOCK_RATING = "Block",
    ITEM_MOD_ATTACK_POWER = "AP", ITEM_MOD_SPELL_POWER = "SP",
    ITEM_MOD_SPELL_HEALING_DONE = "Heal", ITEM_MOD_SPELL_DAMAGE_DONE = "SP",
    ITEM_MOD_MANA_REGENERATION = "MP5", ITEM_MOD_ARMOR = "Armor",
}

-- WoW quality is 0-indexed: 0=poor(gray) 1=common(white) 2=uncommon(green) 3=rare(blue) 4=epic(purple) 5=legendary(orange)
local RARITY_COLORS = {
    [0] = "|cff9d9d9d", [1] = "|cffffffff", [2] = "|cff1eff00",
    [3] = "|cff0070dd", [4] = "|cffa335ee", [5] = "|cffff8000",
}



local function ReplaceContent(scrollFrame, oldContent, width)
    if oldContent then
        oldContent:SetParent(DungeonDrops.UI.frame)
        oldContent:Hide()
    end
    local content = CreateFrame("Frame", nil, scrollFrame)
    scrollFrame:SetScrollChild(content)
    content:SetWidth(width)
    return content
end

local function GetFallbackIcon(slot)
    return "Interface\\Icons\\" .. (SLOT_ICONS[slot] or "INV_Misc_QuestionMark")
end

local function GetItemIconPath(itemID, slot)
    if not itemID or itemID == 0 then return GetFallbackIcon(slot) end
    local cached = DungeonDrops:GetCachedItemInfo(itemID)
    if cached and cached.icon then return cached.icon end
    local icon = GetItemIcon(itemID) or select(10, GetItemInfo(itemID))
    if icon then return icon end
    icon = DungeonDropsData:LookupAtlasLootIcon(itemID)
    return icon or GetFallbackIcon(slot)
end

local function GetItemQualityColor(itemID)
    if not itemID or itemID == 0 then return "|cff1eff00" end  -- green (uncommon) for unknown quality
    local _, _, rarity = GetItemInfo(itemID)
    return RARITY_COLORS[rarity] or "|cff1eff00"  -- green fallback for uncached items
end

local function GetStatDiff(itemID, slot, ilvl)
    local equipped = DungeonDrops:GetEquippedItem(slot)
    if not equipped then return format("|cff00ff00New slot|r"), "" end
    local newStats = GetItemStats("item:" .. itemID .. ":0:0:0")
    if not newStats then
        local ilvlDiff = ilvl - (equipped.ilvl or 0)
        if ilvlDiff > 0 then
            return format("|cff00ff00+%d ilvl|r", ilvlDiff), ""
        elseif ilvlDiff < 0 then
            return "", format("|cffff0000%d ilvl|r", ilvlDiff)
        end
        return "", ""
    end
    local gains, losses = {}, {}
    for key, newVal in pairs(newStats) do
        local oldVal = (equipped.stats and equipped.stats[key]) or 0
        local diff = newVal - oldVal
        if math.abs(diff) >= 1 then
            local name = STAT_SHORT[key] or key:gsub("ITEM_MOD_", ""):sub(1, 4)
            if diff > 0 then
                tinsert(gains, format("|cff00ff00+%d %s|r", diff, name))
            else
                tinsert(losses, format("|cffff0000%d %s|r", diff, name))
            end
        end
    end
    return table.concat(gains, " "), table.concat(losses, " ")
end

local function CreateItemRow(parent, rec, width)
    local itemID      = rec.itemID
    local itemName    = rec.itemName
    local slot        = rec.slot or "Unknown"
    local dungeonName = rec.dungeonName
    local ilvl        = rec.ilvl

    -- Use game-cached data when available (fixes wrong item ID mismatches in Data.lua)
    local gameName, _, _, gameIlvl = GetItemInfo(itemID)
    if gameName and gameIlvl and gameIlvl > 0 then
        itemName = gameName
        ilvl = gameIlvl
    end
    local upgrade     = rec.upgradeScore or rec.score or 0
    local rowWidth    = width or 380

    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(rowWidth, 38)

    -- Background / hover
    local bg = btn:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(btn)
    bg:SetTexture("Interface\\Buttons\\WHITE8X8")
    bg:SetVertexColor(0.07, 0.07, 0.11)
    bg:SetAlpha(0.6)

    local hov = btn:CreateTexture(nil, "HIGHLIGHT")
    hov:SetAllPoints(btn)
    hov:SetTexture("Interface\\Buttons\\WHITE8X8")
    hov:SetVertexColor(0.22, 0.32, 0.52)
    hov:SetAlpha(0.55)

    -- Icon (30x30, 4px left margin)
    local iconTex = btn:CreateTexture(nil, "ARTWORK")
    iconTex:SetPoint("LEFT", btn, "LEFT", 4, 0)
    iconTex:SetSize(30, 30)
    iconTex:SetTexture(GetItemIconPath(itemID, slot))
    iconTex:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    -- Score badge: top-right, 48px reserved
    local scoreColor = "|cff666666"
    if upgrade >= 10 then      scoreColor = "|cff00ff00"
    elseif upgrade >= 3 then   scoreColor = "|cff88ff44"
    elseif upgrade > 0 then    scoreColor = "|cffffff00"
    elseif upgrade < 0 then    scoreColor = "|cffff4444" end

    local scoreFS = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    scoreFS:SetPoint("TOPRIGHT", btn, "TOPRIGHT", -5, -4)
    scoreFS:SetJustifyH("RIGHT")
    scoreFS:SetText(format("%s%+.0f|r", scoreColor, upgrade))

    -- Item name: left-bounded by icon, right-bounded to leave room for score
    local color = GetItemQualityColor(itemID)
    local nameFS = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    nameFS:SetPoint("TOPLEFT",  iconTex, "TOPRIGHT", 6, -3)
    nameFS:SetPoint("TOPRIGHT", btn, "TOPRIGHT", -52, -3)
    nameFS:SetJustifyH("LEFT")
    nameFS:SetText(format("%s%s|r", color, itemName))

    -- Info line: ilvl + stat diff + dungeon, all bounded
    local infoFS = btn:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    infoFS:SetPoint("BOTTOMLEFT",  iconTex, "BOTTOMRIGHT", 6, 4)
    infoFS:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -5, 4)
    infoFS:SetJustifyH("LEFT")

    local gains, losses = GetStatDiff(itemID, slot, ilvl)
    local statPart = ""
    if gains ~= "" and losses ~= "" then
        statPart = "  " .. gains .. "  " .. losses
    elseif gains ~= "" then
        statPart = "  " .. gains
    elseif losses ~= "" then
        statPart = "  " .. losses
    end
    infoFS:SetText(format("|cff606060ilvl %d|r%s  |cff484848%s|r", ilvl, statPart, dungeonName))

    -- Bottom separator
    local sep = btn:CreateTexture(nil, "OVERLAY")
    sep:SetPoint("BOTTOMLEFT",  btn, "BOTTOMLEFT",  0, 0)
    sep:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 0, 0)
    sep:SetHeight(1)
    sep:SetTexture("Interface\\Buttons\\WHITE8X8")
    sep:SetVertexColor(0.18, 0.18, 0.22)
    sep:SetAlpha(0.7)

    -- Retry icon on first few frames in case cache wasn't ready yet
    local retries = 0
    btn:SetScript("OnUpdate", function()
        retries = retries + 1
        if retries > 10 then btn:SetScript("OnUpdate", nil) return end
        local cur = iconTex:GetTexture()
        if cur and not cur:find("QuestionMark") then
            btn:SetScript("OnUpdate", nil)
            return
        end
        local newPath = GetItemIconPath(itemID, slot)
        if newPath ~= cur then
            iconTex:SetTexture(newPath)
            btn:SetScript("OnUpdate", nil)
        end
    end)

    -- Tooltip on hover: use game tooltip if item is cached, styled fallback otherwise
    btn:SetScript("OnEnter", function()
        if itemID and itemID > 0 then
            local _, link = GetItemInfo(itemID)
            if link then
                GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
                GameTooltip:SetHyperlink(link)
                GameTooltip:Show()
                return
            end
        end
        -- Styled fallback that mimics the WoW item tooltip layout
        GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        -- Name in uncommon green (most dungeon boss drops are uncommon+)
        GameTooltip:AddLine(itemName, 0.12, 1.00, 0.12)
        -- Slot type in white (matches the real tooltip layout)
        GameTooltip:AddLine(slot, 1, 1, 1)
        -- Item level in white
        GameTooltip:AddLine(format("Item Level %d", ilvl), 1, 1, 1)
        -- Source dungeon in gold
        GameTooltip:AddLine(" ", 1, 1, 1)
        GameTooltip:AddLine(format("Drop: %s", dungeonName), 1, 0.82, 0)
        -- Note for items that have an ID but aren't cached yet
        if itemID and itemID > 0 then
            GameTooltip:AddLine("Full stats available after visiting the dungeon", 0.5, 0.5, 0.5, true)
        end
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- Click to link in chat
    btn:SetScript("OnClick", function()
        if itemID and itemID > 0 then
            local _, link = GetItemInfo(itemID)
            ChatEdit_InsertLink(link or format("|cffffffff|Hitem:%d:0:0:0|h[%s]|h|r", itemID, itemName))
        end
    end)

    return btn
end

function DungeonDrops.UI:Initialize()
    if self.frame then return end

    local frame = CreateFrame("Frame", "DungeonDropsMainFrame", UIParent)
    frame:SetSize(720, 520)
    frame:SetPoint("CENTER", UIParent, "CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetFrameStrata("DIALOG")
    frame:Hide()

    local border = CreateFrame("Frame", nil, frame)
    border:SetPoint("TOPLEFT", frame, "TOPLEFT", -3, 3)
    border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 3, -3)
    border:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    border:SetBackdropColor(0.06, 0.06, 0.06, 0.95)

    local titleBg = CreateFrame("Frame", nil, frame)
    titleBg:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    titleBg:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
    titleBg:SetHeight(26)
    titleBg:SetBackdrop({
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    titleBg:SetBackdropColor(0.12, 0.12, 0.22, 1)

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    title:SetPoint("TOP", frame, "TOP", 0, -6)
    title:SetText("DungeonDrops")

    local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)

    -- Scanner progress indicator (hidden until scanning starts)
    local scanText = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    scanText:SetPoint("RIGHT", closeButton, "LEFT", -5, 0)
    scanText:SetTextColor(0.6, 0.6, 0.6)
    scanText:Hide()

    local scanAnim = CreateFrame("Frame", nil, frame)
    scanAnim:Hide()
    local animDots = 0
    scanAnim:SetScript("OnUpdate", function()
        animDots = (animDots + 1) % 4
        local scanner = DungeonDrops.ItemScanner
        if not scanner then return end
        local dots = string.rep(".", animDots)
        scanText:SetText(format("Scanning items %d/%d%s", scanner.foundCount, scanner.totalNeeded, dots))
    end)

    if not DungeonDrops.ItemScanner then
        scanText:SetText("Scanner not loaded")
        scanText:Show()
    else
        if DungeonDrops.ItemScanner.status == "complete" then
            DungeonDrops:UpdateRecommendations()
        end
        DungeonDrops.ItemScanner:AddCallback({
        start = function(total)
            scanText:Show()
            scanAnim:Show()
            scanText:SetText(format("Scanning items 0/%d", total))
        end,
        progress = function(found, total)
            scanText:SetText(format("Scanning items %d/%d", found, total))
        end,
        complete = function()
            scanText:Hide()
            scanAnim:Hide()
            DungeonDrops:UpdateRecommendations()
            if DungeonDrops.UI and DungeonDrops.UI.frame and DungeonDrops.UI.frame:IsShown() then
                DungeonDrops.UI:UpdateDisplay()
            end
        end,
    })
    end

    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -26)
    bg:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    bg:SetTexture("Interface\\Buttons\\WHITE8X8")
    bg:SetVertexColor(0.05, 0.05, 0.05)
    bg:SetAlpha(0.95)

    local headerBg = CreateFrame("Frame", nil, frame)
    headerBg:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -30)
    headerBg:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, -30)
    headerBg:SetHeight(36)
    local hbgTex = headerBg:CreateTexture(nil, "BACKGROUND")
    hbgTex:SetAllPoints(headerBg)
    hbgTex:SetTexture("Interface\\Buttons\\WHITE8X8")
    hbgTex:SetVertexColor(0.1, 0.1, 0.16)
    hbgTex:SetAlpha(0.9)

    local levelText = headerBg:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    levelText:SetPoint("LEFT", headerBg, "LEFT", 10, 0)

    local specText = headerBg:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    specText:SetPoint("RIGHT", headerBg, "RIGHT", -100, 0)

    local refreshButton = CreateFrame("Button", nil, headerBg, "UIPanelButtonTemplate")
    refreshButton:SetSize(80, 22)
    refreshButton:SetPoint("RIGHT", headerBg, "RIGHT", -10, 0)
    refreshButton:SetText("Refresh")
    refreshButton:SetScript("OnClick", function()
        DungeonDrops:RefreshPlayerInfo()
        DungeonDrops:UpdateRecommendations()
    end)

    local leftPanel = CreateFrame("Frame", nil, frame)
    leftPanel:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -76)
    leftPanel:SetSize(200, 380)
    leftPanel:SetBackdrop({
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    leftPanel:SetBackdropColor(0.07, 0.07, 0.1, 0.95)

    local leftTitle = leftPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    leftTitle:SetPoint("TOPLEFT", leftPanel, "TOPLEFT", 6, -5)
    leftTitle:SetText("Best Dungeons")
    leftPanel.title = leftTitle

    local leftScroll = CreateFrame("ScrollFrame", "DungeonDropsLeftScroll", leftPanel, "UIPanelScrollFrameTemplate")
    leftScroll:SetPoint("TOPLEFT", leftPanel, "TOPLEFT", 6, -22)
    leftScroll:SetPoint("BOTTOMRIGHT", leftPanel, "BOTTOMRIGHT", -6, 6)

    local leftContent = CreateFrame("Frame", nil, leftScroll)
    leftScroll:SetScrollChild(leftContent)
    leftContent:SetWidth(170)
    leftPanel.scroll = leftScroll
    leftPanel.content = leftContent

    local rightPanel = CreateFrame("Frame", nil, frame)
    rightPanel:SetPoint("TOPLEFT", frame, "TOPLEFT", 220, -76)
    rightPanel:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 68)
    rightPanel:SetBackdrop({
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    rightPanel:SetBackdropColor(0.07, 0.07, 0.1, 0.95)

    local rightTitle = rightPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    rightTitle:SetPoint("TOPLEFT", rightPanel, "TOPLEFT", 6, -5)
    rightTitle:SetText("Item Recommendations")
    rightPanel.title = rightTitle

    local rightScroll = CreateFrame("ScrollFrame", "DungeonDropsRightScroll", rightPanel, "UIPanelScrollFrameTemplate")
    rightScroll:SetPoint("TOPLEFT", rightPanel, "TOPLEFT", 6, -22)
    rightScroll:SetPoint("BOTTOMRIGHT", rightPanel, "BOTTOMRIGHT", -6, 6)

    local rightContent = CreateFrame("Frame", nil, rightScroll)
    rightScroll:SetScrollChild(rightContent)
    rightContent:SetWidth(460)
    rightPanel.scroll = rightScroll
    rightPanel.content = rightContent

    local bottomBar = CreateFrame("Frame", nil, frame)
    bottomBar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 10, 40)
    bottomBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 40)
    bottomBar:SetHeight(22)
    bottomBar:SetFrameLevel(frame:GetFrameLevel() + 10)

    local topItemsBtn = CreateFrame("Button", nil, bottomBar, "UIPanelButtonTemplate")
    topItemsBtn:SetSize(130, 22)
    topItemsBtn:SetPoint("LEFT", bottomBar, "LEFT", 0, 0)
    topItemsBtn:SetText("Top Items")
    topItemsBtn:SetScript("OnClick", function() DungeonDrops.UI:ShowTopItems() end)

    local myStatsBtn = CreateFrame("Button", nil, bottomBar, "UIPanelButtonTemplate")
    myStatsBtn:SetSize(130, 22)
    myStatsBtn:SetPoint("CENTER", bottomBar, "CENTER", 0, 0)
    myStatsBtn:SetText("My Stats")
    myStatsBtn:SetScript("OnClick", function() DungeonDrops.UI:ShowStatAnalysis() end)

    local configStatsBtn = CreateFrame("Button", nil, bottomBar, "UIPanelButtonTemplate")
    configStatsBtn:SetSize(120, 22)
    configStatsBtn:SetPoint("RIGHT", bottomBar, "RIGHT", -135, 0)
    configStatsBtn:SetText("Config Stats")
    configStatsBtn:SetScript("OnClick", function() DungeonDrops.UI:ShowStatConfig() end)

    local allDungeonsBtn = CreateFrame("Button", nil, bottomBar, "UIPanelButtonTemplate")
    allDungeonsBtn:SetSize(120, 22)
    allDungeonsBtn:SetPoint("RIGHT", bottomBar, "RIGHT", 0, 0)
    allDungeonsBtn:SetText("All Dungeons")
    allDungeonsBtn:SetScript("OnClick", function() DungeonDrops.UI:ShowAllDungeons() end)

    local statusBar = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    statusBar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 12, 24)
    statusBar:SetText("")

    self.frame = frame
    self.leftPanel = leftPanel
    self.rightPanel = rightPanel
    self.leftContent = leftContent
    self.rightContent = rightContent
    self.leftScroll = leftScroll
    self.rightScroll = rightScroll
    self.levelText = levelText
    self.specText = specText
    self.statusBar = statusBar
    self.selectedDungeon = nil

    self:UpdateDisplay()
end

function DungeonDrops.UI:Toggle()
    if not self.frame then self:Initialize() end
    if self.frame:IsShown() then
        GameTooltip:Hide()
        self.frame:Hide()
    else
        self:UpdateDisplay()
        self.frame:Show()
    end
end

function DungeonDrops.UI:UpdateDisplay()
    if not self.frame or not self.frame:IsShown() then return end
    local level = DungeonDrops:GetPlayerLevel()
    local spec = DungeonDrops.primarySpec or "No Talents"
    self.levelText:SetText(format("Level %d  |cff888888%s|r", level, spec))
    self.specText:SetText("Hover for tooltip | Click to link")
    if DungeonDrops.currentRecommendations then
        self.statusBar:SetText(format("%d items | Green = stat gain, Red = stat loss vs equipped", #DungeonDrops.currentRecommendations))
    else
        self.statusBar:SetText("Click Refresh to scan gear")
    end
    self:UpdateLeftPanel()
    if self.selectedDungeon then
        self:UpdateRightPanel(self.selectedDungeon)
    else
        self:ShowTopItems()
    end
end

function DungeonDrops.UI:UpdateLeftPanel()
    local content = ReplaceContent(self.leftScroll, self.leftContent, 170)
    self.leftContent = content
    local bestDungeons = DungeonDrops:GetBestDungeons()
    local yOffset = 0
    local bh = 22
    for i, d in ipairs(bestDungeons) do
        local btn = CreateFrame("Button", nil, content)
        btn:SetSize(170, bh)
        btn:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -yOffset)
        local tex = btn:CreateTexture(nil, "BACKGROUND")
        tex:SetAllPoints(btn)
        tex:SetTexture("Interface\\Buttons\\WHITE8X8")
        tex:SetVertexColor(0.12, 0.14, 0.2)
        tex:SetAlpha(0.6)
        local hov = btn:CreateTexture(nil, "HIGHLIGHT")
        hov:SetAllPoints(btn)
        hov:SetTexture("Interface\\Buttons\\WHITE8X8")
        hov:SetVertexColor(0.25, 0.35, 0.55)
        hov:SetAlpha(0.7)
        local cnt = btn:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        cnt:SetPoint("RIGHT", btn, "RIGHT", -4, 0)
        cnt:SetJustifyH("RIGHT")
        cnt:SetText(d.count .. "")
        local text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        text:SetPoint("LEFT", btn, "LEFT", 4, 0)
        text:SetPoint("RIGHT", cnt, "LEFT", -2, 0)
        text:SetJustifyH("LEFT")
        text:SetText(format("%d. %s", i, d.name))
        btn:SetScript("OnClick", function()
            self.selectedDungeon = d.key
            self:UpdateRightPanel(d.key)
        end)
        yOffset = yOffset + bh
    end
    if #bestDungeons == 0 then
        local t = content:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        t:SetPoint("TOPLEFT", content, "TOPLEFT", 4, -4)
        t:SetText("No dungeons available.\nLevel up or click Refresh.")
    end
    content:SetHeight(yOffset + 10)
    self.leftScroll:UpdateScrollChildRect()
end

function DungeonDrops.UI:UpdateRightPanel(dungeonKey)
    local content = ReplaceContent(self.rightScroll, self.rightContent, 460)
    self.rightContent = content
    local dungeon = DungeonDropsData.Dungeons[dungeonKey]
    if not dungeon then return end
    self.rightPanel.title:SetText(dungeon.name .. "  |cff888888" .. dungeon.zone .. "|r")
    local recs = {}
    for _, rec in ipairs(DungeonDrops.currentRecommendations or {}) do
        if rec.dungeonKey == dungeonKey then
            tinsert(recs, rec)
        end
    end
    local yOffset = 0
    local rowH = 38
    for i, rec in ipairs(recs) do
        if i > 40 then break end
        local btn = CreateItemRow(content, rec, 450)
        btn:SetPoint("TOPLEFT", content, "TOPLEFT", 2, -yOffset)
        yOffset = yOffset + rowH
    end
    if #recs == 0 then
        local t = content:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        t:SetPoint("TOPLEFT", content, "TOPLEFT", 4, -4)
        t:SetText("No usable items for your class in this dungeon.")
    end
    content:SetHeight(yOffset + 10)
    self.rightScroll:UpdateScrollChildRect()
end

function DungeonDrops.UI:ShowTopItems()
    self.rightPanel.title:SetText("Top Items (hover for tooltip)")
    local content = ReplaceContent(self.rightScroll, self.rightContent, 460)
    self.rightContent = content
    DungeonDrops:GetRecommendations()
    local recs = DungeonDrops.currentRecommendations or {}
    local yOffset = 0
    local rowH = 38
    for i, rec in ipairs(recs) do
        if i > 50 then break end
        local btn = CreateItemRow(content, rec, 450)
        btn:SetPoint("TOPLEFT", content, "TOPLEFT", 2, -yOffset)
        yOffset = yOffset + rowH
    end
    if #recs == 0 then
        local t = content:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        t:SetPoint("TOPLEFT", content, "TOPLEFT", 4, -4)
        t:SetText("No recommendations found. Click Refresh or level up.")
    end
    content:SetHeight(yOffset + 10)
    self.rightScroll:UpdateScrollChildRect()
    self.selectedDungeon = nil
end

function DungeonDrops.UI:ShowStatAnalysis()
    self.selectedDungeon = nil
    self.rightPanel.title:SetText("Stat Profile")

    DungeonDrops:ScanGear()
    DungeonDrops:BuildStatProfile()
    local analysis = DungeonDrops:GetStatAnalysis()
    local profile  = analysis.profile

    local content = ReplaceContent(self.rightScroll, self.rightContent, 460)
    self.rightContent = content

    local yOffset = 10
    local LH      = 20   -- standard line height

    -- Helper: add a single full-width text line
    local function Line(text, font)
        local fs = content:CreateFontString(nil, "OVERLAY", font or "GameFontNormalSmall")
        fs:SetPoint("TOPLEFT", content, "TOPLEFT", 14, -yOffset)
        fs:SetWidth(440)
        fs:SetJustifyH("LEFT")
        fs:SetText(text)
        yOffset = yOffset + LH
    end

    -- Helper: horizontal divider line
    local function Divider(r, g, b)
        local t = content:CreateTexture(nil, "OVERLAY")
        t:SetPoint("TOPLEFT",  content, "TOPLEFT",  14, -yOffset)
        t:SetPoint("TOPRIGHT", content, "TOPRIGHT", -14, -yOffset)
        t:SetHeight(1)
        t:SetTexture("Interface\\Buttons\\WHITE8X8")
        t:SetVertexColor(r or 0.3, g or 0.3, b or 0.3, 0.7)
        yOffset = yOffset + 8
    end

    -- Helper: one stat row — bullet at x=14, name at x=30, gear amount at x=210, tag at x=350
    local function StatRow(bulletColor, labelText, amountText, tagText, tagColor)
        local blt = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        blt:SetPoint("TOPLEFT", content, "TOPLEFT", 14, -yOffset)
        blt:SetText(format("|cff%s●|r", bulletColor))

        local lbl = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        lbl:SetPoint("TOPLEFT", content, "TOPLEFT", 30, -yOffset)
        lbl:SetWidth(170)
        lbl:SetJustifyH("LEFT")
        lbl:SetText(labelText)
        lbl:SetTextColor(1, 1, 1)

        local amt = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        amt:SetPoint("TOPLEFT", content, "TOPLEFT", 210, -yOffset)
        amt:SetWidth(130)
        amt:SetJustifyH("LEFT")
        amt:SetText(amountText)

        if tagText then
            local tag = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            tag:SetPoint("TOPLEFT", content, "TOPLEFT", 350, -yOffset)
            tag:SetWidth(100)
            tag:SetJustifyH("LEFT")
            tag:SetText(format("|cff%s%s|r", tagColor or "888888", tagText))
        end
        yOffset = yOffset + LH
    end

    -- ── Header ───────────────────────────────────────────────────────────────
    Line(format("|cffffff00%s|r  ·  |cff88ff88%s|r  ·  |cff888888%s|r",
        profile.class, profile.spec, profile.source), "GameFontHighlight")
    Line("|cff666666Live character stats — gear + talents + enchants|r")
    yOffset = yOffset + 6

    -- ── Prioritize section ───────────────────────────────────────────────────
    Divider(0.2, 0.5, 1.0)
    Line("|cff44aaff▲  STATS TO PRIORITIZE|r", "GameFontHighlight")
    yOffset = yOffset + 4

    local statTargets = DungeonDropsCharDB.statTargets or {}

    if #analysis.wanted == 0 then
        Line("|cff666666  No stat profile available — spec not detected yet. Click Refresh.|r")
    else
        for _, entry in ipairs(analysis.wanted) do
            local bulletColor, tagText, tagColor
            if entry.weight >= 1.2 then
                bulletColor, tagText, tagColor = "00ff88", "Core stat", "00ff88"
            elseif entry.weight >= 0.7 then
                bulletColor, tagText, tagColor = "88ff44", "High",      "88ff44"
            elseif entry.weight >= 0.4 then
                bulletColor, tagText, tagColor = "ffdd00", "Medium",    "ffdd00"
            else
                bulletColor, tagText, tagColor = "888888", "Low",       "888888"
            end

            local amountText
            if entry.amount and entry.amount > 0 then
                if statTargets[entry.stat] ~= nil and statTargets[entry.stat] > 0 then
                    local gap = entry.gap or (statTargets[entry.stat] - entry.amount)
                    if gap > 0 then
                        local gapColor = "ff6644"
                        if gap < statTargets[entry.stat] * 0.2 then
                            gapColor = "ffdd44"
                        end
                        amountText = format("|cffdddddd%d|r → |cffffcc00%d|r |cff%s+%d|r", entry.amount, statTargets[entry.stat], gapColor, gap)
                    else
                        amountText = format("|cffdddddd%d|r → |cff44ff44%d|r |cff44ff44✔|r", entry.amount, statTargets[entry.stat])
                    end
                else
                    amountText = format("|cffdddddd%d|r", entry.amount)
                end
            else
                amountText = "|cff666666—|r"
            end

            StatRow(bulletColor, entry.label, amountText, tagText, tagColor)
        end
    end

    yOffset = yOffset + 8

    -- ── Avoid section ────────────────────────────────────────────────────────
    Divider(1.0, 0.3, 0.3)
    Line("|cffff4444▼  STATS TO AVOID  (wrong for your spec)|r", "GameFontHighlight")
    yOffset = yOffset + 4

    if #analysis.avoid == 0 then
        Line("|cff00ff00  No wasted stats on your current character.|r")
    else
        for _, entry in ipairs(analysis.avoid) do
            StatRow(
                "ff4444",
                entry.label,
                format("|cffff6666%d|r", entry.amount),
                "Wasted budget",
                "ff4444"
            )
        end
        yOffset = yOffset + 4
        Line(format("|cff666666Replace items with these stats with %s-friendly gear.|r",
            profile.spec))
    end

    yOffset = yOffset + 14

    -- Action buttons: Auto-Fill and Reset
    local autofillBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    autofillBtn:SetSize(100, 22)
    autofillBtn:SetPoint("BOTTOMLEFT", content, "BOTTOMLEFT", 14, 8)
    autofillBtn:SetText("Auto-Fill")
    autofillBtn:SetScript("OnClick", function()
        DungeonDrops:AutoFillStatTargets()
        DungeonDrops.UI:ShowStatAnalysis()
    end)

    local resetBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    resetBtn:SetSize(100, 22)
    resetBtn:SetPoint("LEFT", autofillBtn, "RIGHT", 8, 0)
    resetBtn:SetText("Reset")
    resetBtn:SetScript("OnClick", function()
        DungeonDrops:ResetAllStatTargets()
        DungeonDrops.UI:ShowStatAnalysis()
    end)

    if next(statTargets) then
        local statusLine = content:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        statusLine:SetPoint("LEFT", resetBtn, "RIGHT", 10, 0)
        local count = 0
        for _ in pairs(DungeonDrops:GetStatTargets()) do count = count + 1 end
        statusLine:SetText(format("|cff888888%d targets set|r", count))
    end

    -- Extend content height to make room for buttons
    yOffset = yOffset + 40
    content:SetHeight(yOffset)
    self.rightScroll:UpdateScrollChildRect()
end

function DungeonDrops.UI:ShowStatConfig()
    self.selectedDungeon = nil
    self.rightPanel.title:SetText("Configure Stat Targets")

    DungeonDrops:BuildStatProfile()
    local weights = DungeonDrops:GetStatWeights()
    local statTargets = DungeonDrops:GetStatTargets()

    local content = ReplaceContent(self.rightScroll, self.rightContent, 460)
    self.rightContent = content

    local yOffset = 10
    local LH = 22

    local function Line(text, font)
        local fs = content:CreateFontString(nil, "OVERLAY", font or "GameFontNormalSmall")
        fs:SetPoint("TOPLEFT", content, "TOPLEFT", 14, -yOffset)
        fs:SetWidth(440)
        fs:SetJustifyH("LEFT")
        fs:SetText(text)
        yOffset = yOffset + LH
    end

    Line("Set target values for each stat. My Stats panel", "GameFontNormalSmall")
    Line("will show your current stat vs target.", "GameFontNormalSmall")
    Line("Press Enter to save, or click Auto-Fill below.", "GameFontNormalSmall")
    yOffset = yOffset + 8

    -- Header
    local function HeaderRow()
        local hdr = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        hdr:SetPoint("TOPLEFT", content, "TOPLEFT", 30, -yOffset)
        hdr:SetText("Stat")
        local val = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        val:SetPoint("LEFT", hdr, "RIGHT", 120, 0)
        val:SetText("Current")
        local tgt = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        tgt:SetPoint("LEFT", val, "RIGHT", 60, 0)
        tgt:SetText("Target")
        yOffset = yOffset + LH
    end
    HeaderRow()

    -- Collect positive-weight stats sorted by weight descending
    local sortedStats = {}
    for stat, weight in pairs(weights) do
        if weight > 0 then
            table.insert(sortedStats, { stat = stat, weight = weight })
        end
    end
    table.sort(sortedStats, function(a, b) return a.weight > b.weight end)

    -- Cache live stats once
    local liveStats = {}
    pcall(function() local a = DungeonDrops:GetStatAnalysis(); liveStats = a.live or {} end)

    local editBoxes = {}
    for _, entry in ipairs(sortedStats) do
        local stat = entry.stat
        local label = DungeonDrops.STAT_FULL_NAMES[stat] or stat

        -- Stat label
        local lbl = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        lbl:SetPoint("TOPLEFT", content, "TOPLEFT", 30, -yOffset)
        lbl:SetWidth(120)
        lbl:SetJustifyH("LEFT")
        lbl:SetText(label)
        lbl:SetTextColor(1, 1, 1)

        -- Current value (read from cached live stats)
        local liveAmt = math.floor(liveStats[stat] or 0)
        local curText = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        curText:SetPoint("LEFT", lbl, "RIGHT", 10, 0)
        curText:SetWidth(60)
        curText:SetJustifyH("LEFT")
        curText:SetText(tostring(math.floor(liveAmt)))

        -- Target EditBox
        local eb = CreateFrame("EditBox", nil, content, "InputBoxTemplate")
        eb:SetSize(70, 20)
        eb:SetPoint("LEFT", curText, "RIGHT", 10, 0)
        eb:SetAutoFocus(false)
        eb:SetScript("OnEnterPressed", function()
            local val = tonumber(eb:GetText())
            if val and val >= 0 then
                DungeonDrops:SetStatTarget(stat, val)
            else
                DungeonDrops:ClearStatTarget(stat)
            end
            eb:ClearFocus()
        end)
        eb:SetScript("OnEscapePressed", function()
            eb:SetText(tostring(statTargets[stat] or ""))
            eb:ClearFocus()
        end)
        if statTargets[stat] then
            eb:SetText(tostring(statTargets[stat]))
        end
        editBoxes[stat] = eb

        yOffset = yOffset + LH
    end

    yOffset = yOffset + 14

    -- Bottom buttons
    local autofillBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    autofillBtn:SetSize(100, 22)
    autofillBtn:SetPoint("BOTTOMLEFT", content, "BOTTOMLEFT", 14, 8)
    autofillBtn:SetText("Auto-Fill")
    autofillBtn:SetScript("OnClick", function()
        DungeonDrops:AutoFillStatTargets()
        DungeonDrops.UI:ShowStatConfig()
    end)

    local resetBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    resetBtn:SetSize(100, 22)
    resetBtn:SetPoint("LEFT", autofillBtn, "RIGHT", 8, 0)
    resetBtn:SetText("Reset All")
    resetBtn:SetScript("OnClick", function()
        DungeonDrops:ResetAllStatTargets()
        DungeonDrops.UI:ShowStatConfig()
    end)

    local closeBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    closeBtn:SetSize(100, 22)
    closeBtn:SetPoint("LEFT", resetBtn, "RIGHT", 8, 0)
    closeBtn:SetText("Back")
    closeBtn:SetScript("OnClick", function()
        DungeonDrops.UI:ShowStatAnalysis()
    end)

    content:SetHeight(math.max(yOffset, 200))
    self.rightScroll:UpdateScrollChildRect()
end

function DungeonDrops.UI:ShowAllDungeons()
    self.rightPanel.title:SetText("All Dungeons")
    local content = ReplaceContent(self.rightScroll, self.rightContent, 460)
    self.rightContent = content
    local dungeons = DungeonDropsData:GetAllDungeons()
    local yOffset = 0
    local lh = 16
    local exp = nil
    for _, entry in ipairs(dungeons) do
        local d = DungeonDropsData.Dungeons[entry.key]
        if d.expansion ~= exp then
            exp = d.expansion
            local t = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            t:SetPoint("TOPLEFT", content, "TOPLEFT", 4, -yOffset)
            t:SetText("--- " .. d.expansion .. " ---")
            yOffset = yOffset + lh + 2
        end
        local t = content:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        t:SetPoint("TOPLEFT", content, "TOPLEFT", 8, -yOffset)
        t:SetWidth(440)
        local fs = d.faction and " (" .. d.faction .. ")" or ""
        t:SetText(format("%s (%d-%d)%s", d.name, d.minLevel, d.maxLevel, fs))
        yOffset = yOffset + lh
    end
    content:SetHeight(yOffset + 10)
    self.rightScroll:UpdateScrollChildRect()
    self.selectedDungeon = nil
end
