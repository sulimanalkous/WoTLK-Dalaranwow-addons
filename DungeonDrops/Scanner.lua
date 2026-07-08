--[[
    DungeonDrops Scanner
    Iterates all known item IDs from Data.lua to cache their info via GetItemInfo.
    No brute-force scanning of 1-250000 — only the IDs we actually use.
]]
DungeonDrops.ItemScanner = DungeonDrops.ItemScanner or {}
local Scanner = DungeonDrops.ItemScanner

Scanner.status = "idle"
Scanner.pendingIDs = {}
Scanner.currentIndex = 0
Scanner.batchSize = 10
Scanner.frame = nil
Scanner.callbacks = {}

function Scanner:BuildQueue()
    self.pendingIDs = {}
    local seen = {}
    if not DungeonDropsData.ItemCache then return end
    for _, itemIDs in pairs(DungeonDropsData.ItemCache) do
        for _, id in ipairs(itemIDs) do
            if id and id > 0 and not seen[id] then
                seen[id] = true
                tinsert(self.pendingIDs, id)
            end
        end
    end
end

function Scanner:Start()
    if self.status == "scanning" then return end
    self:BuildQueue()
    if #self.pendingIDs == 0 then
        self.status = "complete"
        self:FireCallbacks("complete")
        return
    end
    self.status = "scanning"
    self.currentIndex = 1
    self.frame = CreateFrame("Frame", "DungeonDropsScannerFrame")
    self.frame:SetScript("OnUpdate", function() Scanner:ScanBatch() end)
    self:FireCallbacks("start", #self.pendingIDs)
end

function Scanner:ScanBatch()
    local startTime = debugprofilestop()
    local count = 0
    while count < self.batchSize and self.currentIndex <= #self.pendingIDs do
        local id = self.pendingIDs[self.currentIndex]
        self.currentIndex = self.currentIndex + 1
        -- Query item info to populate WoW's internal cache
        GetItemInfo(id)
        count = count + 1
        if debugprofilestop() - startTime > 20 then
            break
        end
    end
    if self.currentIndex > #self.pendingIDs then
        self:Stop()
        return
    end
    self:FireCallbacks("progress", self.currentIndex - 1, #self.pendingIDs)
end

function Scanner:Stop()
    self.status = "complete"
    if self.frame then
        self.frame:SetScript("OnUpdate", nil)
        self.frame = nil
    end
    self:FireCallbacks("complete", self.currentIndex - 1, #self.pendingIDs)
end

function Scanner:FireCallbacks(event, ...)
    for _, cb in ipairs(self.callbacks) do
        if cb[event] then
            cb[event](...)
        end
    end
end

function Scanner:AddCallback(cbTable)
    tinsert(self.callbacks, cbTable)
end
