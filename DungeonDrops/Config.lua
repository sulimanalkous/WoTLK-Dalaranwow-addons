DungeonDrops.Config = {}

function DungeonDrops.Config:Initialize()
    if not DungeonDropsDB then
        DungeonDropsDB = {
            enabled = true,
            showMinimapButton = false,
            notifyOnLevelUp = true,
            showOnlyUsable = true,
            minUpgradeScore = 5,
        }
    end

    if not DungeonDropsCharDB then
        DungeonDropsCharDB = {
            lastDungeonViewed = nil,
            windowX = nil,
            windowY = nil,
            statTargets = {},
        }
    elseif not DungeonDropsCharDB.statTargets then
        DungeonDropsCharDB.statTargets = {}
    end

    if DungeonDropsCharDB.windowX and DungeonDropsCharDB.windowY and DungeonDrops.UI and DungeonDrops.UI.frame then
        DungeonDrops.UI.frame:SetPoint("CENTER", UIParent, "CENTER",
            DungeonDropsCharDB.windowX, DungeonDropsCharDB.windowY)
    end
end

function DungeonDrops.Config:SaveWindowPosition(frame)
    local x, y = frame:GetCenter()
    local parentWidth, parentHeight = UIParent:GetSize()
    local centerX = (x * 2 - parentWidth) / 2
    local centerY = (y * 2 - parentHeight) / 2
    DungeonDropsCharDB.windowX = math.floor(centerX)
    DungeonDropsCharDB.windowY = math.floor(centerY)
end

function DungeonDrops.Config:GetOption(key)
    if DungeonDropsDB and DungeonDropsDB[key] ~= nil then
        return DungeonDropsDB[key]
    end
    return nil
end

function DungeonDrops.Config:SetOption(key, value)
    if DungeonDropsDB then
        DungeonDropsDB[key] = value
    end
end
