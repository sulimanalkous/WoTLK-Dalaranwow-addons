local DugisGuideViewer = DugisGuideViewer
local texture, item
local frame = CreateFrame("Button", "DugisGuideViewerItemFrame", UIParent, "SecureActionButtonTemplate")
frame:SetFrameStrata("LOW")
frame:SetHeight(36)
frame:SetWidth(36)

frame:SetPoint("TOPRIGHT", Minimap, "BOTTOMLEFT", -150, -150)
frame:Hide()
local cooldown = CreateFrame("Cooldown", nil, frame)
cooldown:SetAllPoints(frame)
cooldown:Hide()
local function RefreshCooldown()
	if not item or not frame:IsVisible() then return end
	local start, duration, enabled = GetItemCooldown(item)
	if enabled then
		cooldown:Show()
		cooldown:SetCooldown(start, duration)
	else cooldown:Hide() end
end
cooldown:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
cooldown:SetScript("OnEvent", RefreshCooldown)
frame:SetScript("OnShow", RefreshCooldown)
local itemicon = frame:CreateTexture(nil, "ARTWORK")
itemicon:SetWidth(24) itemicon:SetHeight(24)
itemicon:SetTexture("Interface\\Icons\\INV_Misc_Bag_08")
itemicon:SetAllPoints(frame)
frame:RegisterForClicks("anyUp")
frame:HookScript("OnClick", function() 
	DebugPrint("GetItemIcon(DugisGuideViewer.useitem[CurrentQuestIndex]) ="..GetItemIcon(DugisGuideViewer.useitem[CurrentQuestIndex]) .."itemicon:GetTexture()="..itemicon:GetTexture())
	--if GetItemIcon(DugisGuideViewer.useitem[CurrentQuestIndex]) == itemicon:GetTexture() then 
	if CurrentAction == "U" then
		DebugPrint("Detected use item")
		DugisGuideViewer:SetChkToComplete(CurrentQuestIndex)
		DugisGuideViewer:MoveToNextQuest()	
	end 
end)

local function PLAYER_REGEN_ENABLED(self)
	if texture and DugisGuideViewer:GetFlag("ItemButtonOn") then 
		itemicon:SetTexture(texture)
		frame:SetAttribute("type1", "item")
		frame:SetAttribute("item1", "item:"..item)
		frame:Show()
		texture = nil
	else
		frame:SetAttribute("item1", nil)
		frame:Hide()
	end
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
end
frame:SetScript("OnEvent", PLAYER_REGEN_ENABLED)
function DugisGuideViewer:SetUseItem(useitem)
	item, texture = useitem, useitem and GetItemIcon(useitem)
	if InCombatLockdown() then frame:RegisterEvent("PLAYER_REGEN_ENABLED") else PLAYER_REGEN_ENABLED(frame) end
end

frame:RegisterForDrag("LeftButton")
frame:SetMovable(true)
frame:SetClampedToScreen(true)
frame:SetScript("OnDragStart", frame.StartMoving)

frame:SetScript("OnDragStop", function(frame)
	frame:StopMovingOrSizing()
end)