--[[
===============================================================
Dugi's Guides Viewer Addon License Agreement
Copyright (c) 2010 Brevoort Internet Marketing LTD
All rights reserved.
File Source: http://www.ultimatewowguide.com
Author Name: Fransisco Brevoort
Email: fbrevoort@xtra.co.nz
The contents of this addon, excluding third-party resources, are
copyrighted to its author with all rights reserved, under United
States copyright law and various international treaties.
In particular, please note that you may not distribute this addon in
any form, with or without modifications, including as part of a
compilation, without prior written permission from its author.
The author of this addon hereby grants you the following rights:
1. You may use this addon for private use only.
2. You may make modifications to this addon for private use only.
All rights not explicitly addressed in this license are reserved by
the copyright holder.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
DugisGuideViewer = LibStub("AceAddon-3.0"):NewAddon("DugisGuideViewer")
DugisGuideViewer = {}
DugisGuideViewer.guides = {}
DugisGuideViewer.guidelist = {}
DugisGuideViewer.Lguidelist = {}
DugisGuideViewer.Dguidelist = {}
DugisGuideViewer.Eguidelist = {}
DugisGuideViewer.Iguidelist = {}
DugisGuideViewer.Mguidelist = {}
DugisGuideViewer.nextzones = {}
DugisGuideViewer.gtype = {}
DugisGuideViewer.queryquests = {}
DugisGuideViewer.guidesize = {}
DugisGuideViewer.actions = {}
DugisGuideViewer.quests1 = {}
DugisGuideViewer.quests1L = {} --localized quest list
DugisGuideViewer.quests2 = {}
DugisGuideViewer.useitem = {}
DugisGuideViewer.qid = {}
DugisGuideViewer.daily = {}
DugisGuideViewer.XVals = {}
DugisGuideViewer.YVals = {}
DugisGuideViewer.MappedPoints = {}
DugisGuideViewer.tags = {}
coords = {}
DugisGuideUser = {
  QuestState = {}, --Tristate either skipped (x), finished (check) or neither (empty)
  turnedinquests = {},
  toskip = {},
}
local CurrentAction
local CurrentQuestName
--local CurrentQuestWatch
local AbandonQID
local JustTurnedInQID = -1 --A quest that has just been turned in has its isComplete status indeterminate in quest log
local CurrentTag
local FirstTime = 1
local UID
--Saved Variables:
--local CurrentTitle (no its global!)
--local CurrentQuestIndex (no its global!)
--local CurrentZone --Guide specified zone.  First parameter of RegisterGuide
--[[local L = DUGISGUIDE_LOCALE
DUGISGUIDE_LOCALE = nil
DugisGuideViewer.Locale = L
--]]
local L = DugisLocals
if GetLocale() == "enUS" then
  DUGIS_LOCALIZE = 0
else
  DUGIS_LOCALIZE = 1
end
local SliderVal = {}
local SliderMax = {}
local LastGuideNumRows = 0
local Debug = 0    --Print Debug Messages
local Localize = 0 --Print Localization Error messages
local DebugFramesON = 1
function LocalizePrint(message)
  if Localize == 1 then
    print(message)
  end
end

function DebugPrint(message)
  if Debug == 1 then
    print(message)
  end
end

function DugisGuideViewer_Reload_ButtonClick()
  DugisGuideViewer:DisplayViewTab(DugisGuideViewer:revlocalize(CurrentTitle, "GUIDE"))
end

function DugisGuideViewer_Reset_ButtonClick()
  for i = 1, LastGuideNumRows do
    local IsEnabled = getglobal("RecapPanelDetail" .. i .. "Chk"):IsEnabled()
    if DugisGuideUser.QuestState[CurrentTitle .. ':' .. i] == "X" or (DugisGuideUser.QuestState[CurrentTitle .. ':' .. i] == "C" and IsEnabled == 1) then
      --DebugPrint("CHK cleared index="..i.."DugisGuideUser.QuestState[i]="..DugisGuideUser.QuestState[i])
      DugisGuideViewer:ClrChk(i)
    end
  end
  local nextindex = DugisGuideViewer:FindNextUnchecked(CurrentQuestIndex, 0)
  --DebugPrint("boxindex="..boxindex.."CurrentQuestIndex="..CurrentQuestIndex.."nextindex="..nextindex)
  if nextindex < CurrentQuestIndex then
    DugisGuideViewer:MoveToPrevQuest()
  end
end

local function tchelper(first, rest)
  --DebugPrint("first:"..first.."rest:"..rest)
  return first:upper() .. rest:lower()
end
--Detect hearth, quest accept or quest complete
function DugisGuideViewer:ChatMessage(event, msg)
  --DebugPrint("inChatmessage"..event..msg)
  local msgqid
  local curqid
  local questnoparen
  local optional
  local gindex
  local _, _, loc = msg:find(L["(.*) is now your home."])
  local _, _, accept = msg:find(L["Quest accepted: (.*)"])
  if loc then --Set Hearth
    loc = DugisGuideViewer:localize(loc, "ZONE")
    _, _, questnoparen = DugisGuideViewer.quests1[CurrentQuestIndex]:find("([^%(]*)")
    questnoparen = questnoparen:trim()
    DebugPrint("loc is" .. loc .. "questnoparen=" .. questnoparen .. "loc=" .. loc)
    if CurrentAction == "h" and questnoparen == loc then
      DebugPrint("Detected setting hearth to " .. loc .. "message:" .. msg)
      DugisGuideViewer:SetChkToComplete(CurrentQuestIndex)
      DugisGuideViewer:MoveToNextQuest()
    end
  elseif accept and CurrentTitle ~= nil then --Quest accept
    curqid = DugisGuideViewer.qid[CurrentQuestIndex]
    msgqid = DugisGuideViewer:GetQIDFromQuestName(accept)
    --gindx = DugisGuideViewer:GetGuideIndexByQID(msgqid)
    --optional = DugisGuideViewer:ReturnTag("O", gindx)
    DebugPrint("accept =" .. accept .. "quest id is" .. msgqid .. "*" .. "action =" .. CurrentAction .. "*")
    if CurrentAction == "A" and msgqid == curqid then
      DebugPrint("Detected quest accept ", accept)
      DugisGuideViewer:SetChkToComplete(CurrentQuestIndex)
      DugisGuideViewer:MoveToNextQuest()
    else --if not optional then
      --not current quest but accept by user into log
      DebugPrint("Not current quest but checked off")
      DugisGuideViewer:CompleteQID(msgqid, "A")
      DebugPrint("CompleteQID" .. msgqid)
    end
    --Skip breadcrumb
    if type(DugisGuideViewer.Chains[msgqid]) == "table" and DugisGuideViewer.Chains[msgqid][1] == "OR" then
      for i = 2, #DugisGuideViewer.Chains[msgqid] do
        DebugPrint("Found Breadcrumb:" .. DugisGuideViewer.Chains[msgqid][i] .. " of " .. msgqid)
        --table.insert(DugisGuideUser.toskip, DugisGuideViewer.Chains[msgqid][i])
        DugisGuideViewer:SkipQuestAcrossGuides(DugisGuideViewer.Chains[msgqid][i])
        --[[for j = 1, LastGuideNumRows do
--if msgqid == DugisGuideViewer.qid[j] and (DugisGuideViewer.actions[j] == "A" or DugisGuideViewer.actions[j] == "C" or DugisGuideViewer.actions[j] == "T") then
if (DugisGuideViewer.Chains[msgqid][i] == DugisGuideViewer.qid[j]) and strmatch(self.actions[j], "[ACT]") and DugisGuideViewer:GetTriStateChk(j) == "U" then
DugisGuideViewer:SetChktoX(j)
DebugPrint("Skip Breadcrumb"..DugisGuideViewer.Chains[msgqid][i])
end
end--]]
      end
    end
  end
end

function DugisGuideViewer:GetGuideIndexByQID(qid)
  for i = 1, LastGuideNumRows do
    if DugisGuideViewer.qid[i] == qid then return i end
  end
end

function DugisGuideViewer:GetQuestLogIndexByQID(qid)
  local numq, tmp = GetNumQuestLogEntries()
  --DebugPrint("GetNumQuestLogEntries="..tmp..numq) --zero on startup?
  for i = 1, numq do
    --temp = select(1, GetQuestLogTitle(i))
    --DebugPrint("quest #"..i..":"..temp)
    local qid2 = select(9, GetQuestLogTitle(i))
    if qid2 == qid then return i end
  end
end

function DugisGuideViewer:CompleteQID(qid, state)
  for i = 1, LastGuideNumRows do
    if DugisGuideViewer.qid[i] == qid and DugisGuideViewer.actions[i] == state then
      --DebugPrint("Set "..i.."to complete")
      DugisGuideViewer:SetChkToComplete(i)
    end
  end
end

function DugisGuideViewer:GetQIDFromQuestName(name)
  local logindx = getQuestIndexByQuestName(name)
  local qid
  --DebugPrint("logindx="..logindx)
  if logindx then
    --local qid = select(9, GetQuestLogTitle(4))
    qid = select(9, GetQuestLogTitle(logindx))
    --local questID = select(9, GetQuestLogTitle(QuestLogFrame.selectedIndex))
  end
  --DebugPrint("qid="..qid)
  return qid
end

function DugisGuideViewer:CompleteLOOTorQO(calledfrom, itemid)
  local flag = 0
  --Quest Objective or Loot completion
  local questtext = DugisGuideViewer:ReturnTag("QO")
  local logindex = DugisGuideViewer:GetQuestLogIndexByQID(DugisGuideViewer.qid[CurrentQuestIndex])
  local done = DugisGuideViewer:IsQuestObjectiveComplete(logindex, questtext)
  local lootitem, lootqty = DugisGuideViewer:ReturnTag("L", CurrentQuestIndex)
  local optional = DugisGuideViewer:ReturnTag("O", CurrentQuestIndex)
  local inlog = DugisGuideViewer:GetQuestLogIndexByQID(DugisGuideViewer.qid[CurrentQuestIndex])
  if calledfrom == "CMSG" then
    --DebugPrint("lootqty="..lootqty.."GetItemCount(lootitem)="..GetItemCount(lootitem))
    if done == true or ((lootitem and (GetItemCount(lootitem) + 1) >= lootqty) and lootitem == itemid) then
      if (optional and inlog) or (not optional) then
        flag = 1
      end
    end
  elseif calledfrom == "QLU" then
    if done == true or (lootitem and GetItemCount(lootitem) >= lootqty) then
      if (optional and inlog) or (not optional) then
        flag = 1
      end
    end
  end
  if flag == 1 then
    DebugPrint("Detected QUESTOBJECTIVE or Loot QTY completed quest." .. calledfrom)
    DugisGuideViewer:SetChkToComplete(CurrentQuestIndex)
    DugisGuideViewer:MoveToNextQuest()
  end
end

--QuestRewardCompleteButton_OnClick button and use GetTitleText
function DugisMainframe_OnEvent(self, event, msg, ...)
  local i
  DebugPrint("in on event.  event =" .. event .. "self=" .. self:GetName() .. "args=", ...)
  if CurrentQuestName then
    DebugPrint("CurrentAction" .. CurrentAction .. "CurrentQuestName" .. CurrentQuestName .. "CQI:" .. CurrentQuestIndex)
  end
  if event == "PLAYER_LOGIN" then
    --local addonName = "DugisGuideViewer"
    --if not addonName then return end
    DebugPrint("Player login")
    --DugisGuideViewer:HideLargeWindow()
    QueryQuestsCompleted()
  elseif event == "CHAT_MSG_LOOT" and CurrentTitle ~= nil then
    local _, _, itemid, name = msg:find(L["^You .*Hitem:(%d+).*(%[.+%])"])
    --DebugPrint("itemid="..itemid)
    --Check all previous quests to see if |O| + |L| or |U| item was picked up
    local newindex
    for i = 1, CurrentQuestIndex do
      local optional = DugisGuideViewer:ReturnTag("O", i)
      local action = DugisGuideViewer.actions[i]
      local lootitem, lootqty = DugisGuideViewer:ReturnTag("L", i)
      local useitem = DugisGuideViewer:ReturnTag("U", i)
      local state = DugisGuideUser.QuestState[CurrentTitle .. ':' .. i]
      local inlog = DugisGuideViewer:GetQuestLogIndexByQID(DugisGuideViewer.qid[i])
      --DebugPrint("useitem="..useitem.."state="..state.."action="..action.."CQI"..CurrentQuestIndex.."i="..i)
      if optional and action == "A" and state == "U" then
        if ((lootitem and (GetItemCount(lootitem) + 1) >= lootqty) and lootitem == itemid) or
            (useitem and useitem == itemid) then
          newindex = i
          DebugPrint("Detected an |L| or |U| item from chat msg loot, switching quests")
          break
        end
      end
    end
    if newindex then
      DugisGuideViewer:SetToQuestNumber(newindex)
    else
      --Quest Objective or Loot completion if needed
      DugisGuideViewer:CompleteLOOTorQO("CMSG", itemid)
    end
  elseif event == "ZONE_CHANGED" or event == "ZONE_CHANGED_NEW_AREA" or event == "ZONE_CHANGED_INDOORS" then
    local correctzone = DugisGuideViewer:CheckForLocation(CurrentQuestIndex)
    if correctzone == true then
      DugisGuideViewer:MoveToNextQuest()
    end
  elseif event == "CHAT_MSG_SYSTEM" then
    --if (CurrentAction == "T") or (CurrentAction == "A") or (CurrentAction == "SH") then
    DugisGuideViewer:ChatMessage(event, msg)
    --end
    --Works for completing a quest which turns its icon to '?'
  elseif event == "QUEST_LOG_UPDATE" then
    --PATCH: If I call OnLoad from PLAYER_LOGIN,
    --GetNumQuestLogEntries == 0 when it is not.
    --Value seems to be stable after initial QLU event
    if FirstTime then
      FirstTime = nil
      DugisGuideViewer:OnLoad()
    else
      --Abandoned Quest
      if AbandonQID and CurrentQuestIndex then
        local logidx = DugisGuideViewer:GetQuestLogIndexByQID(AbandonQID)
        if logidx then --user abandoned quest but it hasn't registered yet
          --DebugPrint("user abandoned quest but it hasn't registered yet log="..logidx.."qid="..AbandonQID)
        else
          DebugPrint("user abandoned")
          for i = 1, LastGuideNumRows do
            if DugisGuideViewer.qid[i] == AbandonQID and (DugisGuideViewer.actions[i] == "A" or DugisGuideViewer.actions[i] == "C" or DugisGuideViewer.actions[i] == "T") then
              DugisGuideViewer:ClrChk(i)
            end
          end
          local nextindex = DugisGuideViewer:FindNextUnchecked(CurrentQuestIndex, 0)
          if nextindex < CurrentQuestIndex then
            DugisGuideViewer:MoveToPrevQuest()
          elseif nextindex == CurrentQuestIndex and DugisGuideViewer.gtype[CurrentTitle] == "D" then --case where an optional (dailies) quest abandoned, uncheck last user X
            i = nextindex
            while (i > 1) do
              if DugisGuideViewer.actions[i] == "N" and DugisGuideUser.QuestState[CurrentTitle .. ':' .. i] == "X" then break end
              i = i - 1
            end
            DebugPrint("Detected a Dailies optional user abandoned quest" .. "nextindex=" .. nextindex .. "i=" .. i)
            DugisGuideViewer:ClrChk(i)
            DugisGuideViewer:MoveToPrevQuest()
          end
          AbandonQID = nil
        end
      end
      --Quest Objective or Loot completion if needed
      DugisGuideViewer:CompleteLOOTorQO("QLU")
      --Check for all completed or user uncompleted quests in quest log
      local num, _ = GetNumQuestLogEntries()
      for logIndex = 1, num do
        local _, _, _, _, _, _, isComplete, _, questID = GetQuestLogTitle(logIndex)
        guideIndex = 1
        found = false
        while (guideIndex <= LastGuideNumRows and found == false) do
          if (DugisGuideViewer.actions[guideIndex] == "C") and (questID == DugisGuideViewer.qid[guideIndex]) then
            if isComplete == 1 and DugisGuideUser.QuestState[CurrentTitle .. ':' .. guideIndex] == "U" then
              DebugPrint("Detected completed quest ")
              DugisGuideViewer:SetChkToComplete(guideIndex)
              if DugisGuideViewer.qid[CurrentQuestIndex] == questID then --current quest
                DugisGuideViewer:MoveToNextQuest()
              end
            elseif isComplete ~= 1 and DugisGuideUser.QuestState[CurrentTitle .. ':' .. guideIndex] == "C" and JustTurnedInQID ~= questID then
              DugisGuideViewer:ClrChk(guideIndex)
              DebugPrint("Detected UNcompleted quest " ..
                "CurrentQuestIndex=" .. CurrentQuestIndex .. "guideIndex=" .. guideIndex)
              if JustTurnedInQID then DebugPrint("JustTurnedInQID=" .. JustTurnedInQID .. "questID=" .. questID) end
              if CurrentQuestIndex > guideIndex then
                DugisGuideViewer:MoveToPrevQuest()
              end
            end
            found = true
          end
          guideIndex = guideIndex + 1
        end
      end
      -- Accept detection above (and in ChatMessage()) relies on CurrentQuestIndex already
      -- sitting on this quest's "A" row at the moment it happens. Dungeon guides commonly
      -- insert a separate "R" (travel) row ahead of the "A" row for the same quest -
      -- something leveling guides rarely do - so that's often not the case, and the
      -- checks above can miss it. SetQuestsState() is the same full-resync the guide's own
      -- "Reload" button calls (DisplayViewTab -> ... -> SetQuestsState) - it re-derives
      -- every row's state from the quest log directly (position-independent) and moves
      -- CurrentQuestIndex to the first genuinely incomplete row. Calling it here makes
      -- every quest-log change behave like clicking Reload automatically, matching how
      -- leveling guides are perceived to "just work".
      DugisGuideViewer:SetQuestsState()
      DugisGuideViewer:ViewFrameUpdate()
    end
  elseif event == "UI_INFO_MESSAGE" then
    if (CurrentAction == "f") then
      --local msg = select(1, ...)
      if msg == ERR_NEWTAXIPATH then
        DebugPrint("Detected completed new flight point")
        DugisGuideViewer:SetChkToComplete(CurrentQuestIndex)
        DugisGuideViewer:MoveToNextQuest()
      end
    end
  elseif event == "QUEST_QUERY_COMPLETE" then
    DebugPrint("QUEST_QUERY_COMPLETE")
    GetQuestsCompleted(DugisGuideViewer.queryquests)
    if DugisGuideViewer.queryquests then
      DugisGuideUser.turnedinquests = DugisGuideViewer.queryquests
    end
  elseif event == "ADDON_LOADED" then
    --DebugPrint("ADDON_LOADED"..msg)
    if msg == "DugisGuideViewerZ" then
      self:UnregisterEvent("ADDON_LOADED")
      DebugPrint("ADDON_LOADED" .. msg)
      DebugPrint("SELF" .. self:GetName())
      DugisGuideViewer:OnInitialize()
    end
  elseif event == "ACHIEVEMENT_EARNED" then
  end
end

local tabs
function DugisGuideViewer:OnInitialize()
  local defaults = {
    char = {
      settings = {
        sz = 7,
        [1] = { text = "Display Quest Level", checked = true, tooltip = "Show the quest level on the large and small frames", },
        [2] = { text = "Lock Small Frame", checked = false, tooltip = "Lock small frame into place", },
        [3] = { text = "Lock Large Frame", checked = false, tooltip = "Lock large frame into place", },
        [4] = { text = "Show Small Frame", checked = true, tooltip = "", },
        [5] = { text = "Automatic Waypoints", checked = true, tooltip = "Map each destination with TomTom", },
        [6] = { text = "Manual Mode", checked = true, tooltip = "This mode lets the user individually complete or skip quests. When unchecked, the guide will skip all quests in the quest sequence", },
        [7] = { text = "Item Button", checked = true, tooltip = "Shows a small window to click when an item is needed for a quest", },
        --[[[8] = { text = "Automatic Quest Watch", checked = true,tooltip = "",},--]]
      },
    },
  }
  self.db = LibStub("AceDB-3.0"):New("DugisGuideViewerDB", defaults)
  tabs = {
    [1] = { text = "Current Guide", title = "", desc = "", frame = _G["DGVTabFrame1"], guidetype = nil },
    [2] = { text = "Leveling", title = "Leveling Guides", desc = "Select a leveling guide closest to your current level", frame = _G["DGVTabFrame2"], guidetype = "L" },
    [3] = { text = "Dungeons", title = "Dungeon Guides", desc = "Select a leveling guide closest to your current level", frame = _G["DGVTabFrame3"], guidetype = "I" },
    [4] = { text = "Maps", title = "Dungeon Maps", desc = "Select a Dungeon Map", frame = _G["DGVTabFrame4"], guidetype = "M" },
    [5] = { text = "Dailies/Events", title = "Dailies and Events Guides", desc = "Complete the (Required For Dailies) guides first to qualify for dailies", frame = _G["DGVTabFrame5"], guidetype = "D" },
    [6] = { text = "Ach/Prof", title = "Achievements and Professions Guides", desc = "Coming soon.. stay tuned to UltimateWoWGuide.com", frame = _G["DGVTabFrame6"], guidetype = "E" },
    [7] = { text = "Settings", title = "Settings for Dugis Guide Viewer", desc = "", frame = _G["DGVTabFrame7"], guidetype = nil },
  }
  local i
  for i = 1, #tabs do
    SliderVal[i] = 1
    SliderMax[i] = 1
  end
end

--Update the look of the frame on QLU
function DugisGuideViewer:ViewFrameUpdate()
  local i, qid
  for i, qid in ipairs(DugisGuideViewer.actions) do
    DugisGuideViewer:SetQuestColor(i)
    DugisGuideViewer:SetQuestText(i)
    getglobal("RecapPanelDetail" .. i .. "Button"):SetNormalTexture(DugisGuideViewer:getIcon(DugisGuideViewer.actions[i],
      i))
  end
end

function DugisGuideViewer:SetQuestColor(i)
  local optional = DugisGuideViewer:ReturnTag("O", i)
  if optional and i ~= CurrentQuestIndex and DugisGuideUser.QuestState[CurrentTitle .. ':' .. i] ~= "C" then --gray out text
    getglobal("RecapPanelDetail" .. i .. "Name"):SetTextColor(0.75, 0.75, 0.75, 1)
    getglobal("RecapPanelDetail" .. i .. "Desc"):SetTextColor(0.75, 0.75, 0.75, 1)
    getglobal("RecapPanelDetail" .. i .. "Opt"):SetTextColor(0.75, 0.75, 0.75, 1)
    getglobal("RecapPanelDetail" .. i .. "Opt"):SetFontObject("GameFontHighlightSmall", 5)
  elseif strmatch(self.actions[i], "[ACT]") and self:GetFlag("QuestLevelOn") then --set difficulty color on A/C/T actions
    local color = self:GetQuestDiffColor(i)
    if color then
      getglobal("RecapPanelDetail" .. i .. "Name"):SetTextColor(color.r, color.g, color.b, 1)
      getglobal("RecapPanelDetail" .. i .. "Opt"):SetTextColor(color.r, color.g, color.b, 1)
    end
  else
    DugisGuideViewer:SetQuestTextNormal(i)
  end
end

function DugisGuideViewer:GetQuestDiffColor(i)
  local color
  local qid = self.qid[i]
  if qid then
    local lindex = DugisGuideViewer:GetQuestLogIndexByQID(qid)
    local level = DugisGuideViewer:GetQuestLevel(qid)
    if level then
      color = GetQuestDifficultyColor(level)
    end
  end
  return color
end

function DugisGuideViewer:SetAllQuestColor()
  local i, qid
  for i, qid in ipairs(DugisGuideViewer.actions) do
    DugisGuideViewer:SetQuestColor(i)
  end
end

function DugisGuideViewer:GetQuestLevel(qid)
  if self.ReqLevel[qid] then
    --DebugPrint("QID:"..qid.."RL:"..self.ReqLevel[qid][1])
    return self.ReqLevel[qid][1]
  end
end

function DugisGuideViewer:GetReqQuestLevel(qid)
  if self.ReqLevel[qid] then
    --DebugPrint("QID:"..qid.."RL:"..self.ReqLevel[qid][1])
    return self.ReqLevel[qid][2]
  end
end

function DugisGuideViewer:SetChkToComplete(i)
  DugisGuideUser.QuestState[CurrentTitle .. ':' .. i] = "C"
  getglobal("RecapPanelDetail" .. i .. "Chk"):SetChecked(1)
  if (DugisGuideViewer.actions[i] == "A" or DugisGuideViewer.actions[i] == "C" or DugisGuideViewer.actions[i] == "T") and (DugisGuideViewer.daily[i] == nil) then
    --getglobal("RecapPanelDetail"..i.."Chk"):Disable()
    if state == "T" then table.insert(DugisGuideUser.turnedinquests, DugisGuideViewer.qid[i]) end
  end
end

function DugisGuideViewer:SetQuestsState()
  local ret
  local inlog
  --if not DugisGuideUser then
  --DugisGuideUser = {}
  --DebugPrint("ERROR: no QuestState found")
  --end
  if DugisGuideUser.QuestState then
    --Find all previously completed quests and check them
    for i = 1, LastGuideNumRows do
      ret = DugisGuideViewer:HasQuestBeenTurnedIn(DugisGuideViewer.qid[i])
      logindex = DugisGuideViewer:GetQuestLogIndexByQID(DugisGuideViewer.qid[i])
      if ret == true then  --completed and turned in quest
        DugisGuideViewer:SetChkToComplete(i)
      elseif logindex then --In quest log
        local temp, _, _, _, _, _, isComplete = GetQuestLogTitle(logindex)
        --DebugPrint("Found in log #"..logindex..temp)
        if DugisGuideViewer.actions[i] == "A" then
          DugisGuideViewer:SetChkToComplete(i)
          --Case where a quest is found in log and a step with same quest number is before it
          local indx = i
          while (indx > 0) do
            if DugisGuideViewer.qid[indx] == DugisGuideViewer.qid[i] then
              DugisGuideViewer:SetChkToComplete(indx)
            end
            indx = indx - 1
          end
        elseif DugisGuideViewer.actions[i] ~= "T" and isComplete == 1 then
          DugisGuideViewer:SetChkToComplete(i)
          --getglobal("RecapPanelDetail"..i.."Chk"):Disable()
        end
      end
      if DugisGuideUser.QuestState[CurrentTitle .. ':' .. i] == "X" or DugisGuideViewer:InTable(DugisGuideViewer.qid[i], DugisGuideUser.toskip) == true then --User skipped
        DugisGuideViewer:SetChktoX(i)
        --DebugPrint("Set X on index: " ..i)
      elseif DugisGuideUser.QuestState[CurrentTitle .. ':' .. i] == "C" then
        DugisGuideViewer:SetChkToComplete(i)
      end
    end
    --Set current quest to first quest that is not skipped or finished
    i = 1
    while (i < LastGuideNumRows) do
      if DugisGuideUser.QuestState[CurrentTitle .. ':' .. i] == "U" and DugisGuideViewer:CheckForOptionalLoot(i) == false then
        --DebugPrint("U FOUND AT"..i)
        break
      end
      i = i + 1
    end
    if i == LastGuideNumRows then
      DebugPrint("no u found")
    end
    DugisGuideViewer:SetToQuestNumber(i)
  else
    DebugPrint("ERROR: no QuestState found")
  end
end

function DugisGuideViewer:HasQuestBeenTurnedIn(qid)
  for v, _ in pairs(DugisGuideUser.turnedinquests) do
    --DebugPrint("v="..v.."qid="..qid)
    if v == qid then
      --DebugPrint("return true")
      return true
    end
  end
  --DebugPrint("return false")
  return false
end

function DugisGuideViewer:ReturnTag(tag, i)
  i = i or CurrentQuestIndex
  local tags = DugisGuideViewer.tags[i]
  if not tags then return end
  if tag == "O" then
    return tags:find("|O|")
  elseif tag == "E" then
    return 1
  elseif tag == "QuestID" then
    return tonumber((tags:match("|QuestID=(%d+)|")))
  elseif tag == "L" then
    local _, _, lootitem, lootqty = tags:find("|L|(%d+)%s?(%d*)|")
    lootqty = tonumber(lootqty) or 1
    return lootitem, lootqty
  end
  return select(3, tags:find("|" .. tag .. "|([^|]*)|?"))
end

--local BZ, BZL, RBZL, BC, BCL, RBCL, BR, BRL, RBRL
if (LibStub("LibBabble-Zone-3.0", true) == nil or LibStub("LibBabble-Class-3.0", true) == nil or LibStub("LibBabble-Race-3.0", true) == nil) and (DUGIS_LOCALIZE == 1) then
  LocalizePrint(
    "ERROR: Localization requires LibBabble-Zone-3.0, LibBabble-Class-3.0 and LibBabble-Race-3.0 to work properly")
end
if DUGIS_LOCALIZE == 1 then
  if LibStub("LibBabble-Zone-3.0") then
    DugisGuideViewer.BZ = LibStub("LibBabble-Zone-3.0")
    --local BZL = BZ:GetBaseLookupTable() does't work
    --local BZL = BZ:GetLookupTable() works with popup errors
    DugisGuideViewer.BZL = DugisGuideViewer.BZ:GetUnstrictLookupTable()
    DugisGuideViewer.RBZL = DugisGuideViewer.BZ:GetReverseLookupTable()
    LocalizePrint("Loaded LibBabble-Zone-3.0")
  end
  if LibStub("LibBabble-Class-3.0") then
    DugisGuideViewer.BC = LibStub("LibBabble-Class-3.0")
    DugisGuideViewer.BCL = DugisGuideViewer.BC:GetUnstrictLookupTable()
    DugisGuideViewer.RBCL = DugisGuideViewer.BC:GetReverseLookupTable()
    LocalizePrint("Loaded LibBabble-Class-3.0")
  end
  if LibStub("LibBabble-Race-3.0") then
    DugisGuideViewer.BR = LibStub("LibBabble-Race-3.0")
    DugisGuideViewer.BRL = DugisGuideViewer.BR:GetUnstrictLookupTable()
    DugisGuideViewer.RBRL = DugisGuideViewer.BR:GetReverseLookupTable()
    LocalizePrint("Loaded LibBabble-Race-3.0")
  end
end
--English to native. Returns all lowercase
function DugisGuideViewer:localize(arg, ltype)
  local translation
  if DUGIS_LOCALIZE == 0 then return arg end
  if ltype == "ZONE" then
    if DugisGuideViewer.BZ then
      translation = DugisGuideViewer.BZL[arg]
    end
  elseif ltype == "CLASS" then
    if DugisGuideViewer.BC then
      if UnitSex("player") == 3 then --female
        translation = DugisGuideViewer.BCL[string.upper(arg)]
        if translation == nil then translation = DugisGuideViewer.BCL[arg] end
      else
        translation = DugisGuideViewer.BCL[arg]
      end
    end
  elseif ltype == "RACE" then
    if DugisGuideViewer.BR then
      if UnitSex("player") == 3 then
        translation = DugisGuideViewer.BRL[string.upper(arg)]
        if translation == nil then translation = DugisGuideViewer.BRL[arg] end
      else
        translation = DugisGuideViewer.BRL[arg]
      end
    end
  elseif ltype == "GUIDE" then
    translation = DugisGuideViewer:GuideTitleTranslator(arg)
  end
  if translation == nil then
    translation = arg
    LocalizePrint("ERROR: during localization of:" .. arg .. "*")
  end
  return translation
end

--native to English
function DugisGuideViewer:revlocalize(arg, ltype)
  local translation
  if DUGIS_LOCALIZE == 0 then return arg end
  if ltype == "ZONE" then
    if DugisGuideViewer.BZ then
      translation = DugisGuideViewer.RBZL[arg]
    end
  elseif ltype == "CLASS" then
    if DugisGuideViewer.BC then
      if UnitSex("player") == 3 then --female
        translation = DugisGuideViewer.RBCL[arg]
        if translation then translation = translation:gsub("(%a)([%w_']*)", tchelper) end
      else
        translation = DugisGuideViewer.RBCL[arg]
      end
    end
  elseif ltype == "RACE" then
    if DugisGuideViewer.BR then
      if UnitSex("player") == 3 then --female
        translation = DugisGuideViewer.RBRL[arg]
        if translation then translation = translation:gsub("(%a)([%w_']*)", tchelper) end
      else
        translation = DugisGuideViewer.RBRL[arg]
      end
    end
  elseif ltype == "GUIDE" then
    translation = DugisGuideViewer:RevGuideTitleTranslator(arg)
  end
  if translation == nil then
    translation = arg
    LocalizePrint("ERROR: during reverse localization of:" .. arg .. "*")
  end
  return translation
end

--Map current quest
function DugisGuideViewer:MapCurrentObjective()
  local i
  local ZoneToUse
  if TomTom then --Either TomTom or Carbonite Emulator
    if self:GetFlag("WaypointsOn") then
      local desc
      if DugisGuideViewer.actions[CurrentQuestIndex] == "A" or DugisGuideViewer.actions[CurrentQuestIndex] == "T" then
        desc = "[DG] " ..
            DugisGuideViewer.quests1L[CurrentQuestIndex] ..
            " (" .. self:RemoveParen(DugisGuideViewer.quests2[CurrentQuestIndex]) .. ")"
      else
        desc = "[DG] " .. DugisGuideViewer.quests1L[CurrentQuestIndex]
      end
      local zonefromnotetag = DugisGuideViewer:ReturnTag("Z", CurrentQuestIndex)
      local ContToUse
      -- Some source content (Anniversary-package dungeon guides) encodes |Z| as a numeric
      -- ID this old engine can't resolve by name, but the same line's note text usually
      -- carries the real zone name as literal {ZoneName} markup - prefer that when it
      -- names a zone different from the guide's own, since it reflects the step's actual
      -- location (e.g. a capital-city turn-in) rather than the guide's title zone.
      local notetext = DugisGuideViewer.quests2[CurrentQuestIndex]
      local zonefromcurlytag = notetext and notetext:match("{([^}]+)}")
      --If there is a |Zone= Darnassus| tag
      if zonefromcurlytag and DugisGuideViewer:IsZoneNameValid(zonefromcurlytag) then
        DebugPrint("Curly zone" .. zonefromcurlytag)
        ZoneToUse = DugisGuideViewer:GetZoneNumberFromZoneName(zonefromcurlytag)
        ContToUse = DugisGuideViewer:GetContinentNumberFromZoneName(zonefromcurlytag)
      elseif zonefromnotetag then
        zonefromnotetag = DugisGuideViewer:localize(zonefromnotetag, "ZONE")
        DebugPrint("Note zone" .. zonefromnotetag)
        ZoneToUse = DugisGuideViewer:GetZoneNumberFromZoneName(zonefromnotetag)
        ContToUse = DugisGuideViewer:GetContinentNumberFromZoneName(zonefromnotetag)
        --Check the guide header to see if a valid Guide Zone is stated
      elseif DugisGuideViewer:IsZoneNameValid(CurrentZone) then
        DebugPrint("Guide zone" .. CurrentZone)
        ZoneToUse = DugisGuideViewer:GetZoneNumberFromZoneName(CurrentZone)
        ContToUse = DugisGuideViewer:GetContinentNumberFromZoneName(CurrentZone)
      else
        SetMapToCurrentZone()
        ZoneToUse, ContToUse = GetCurrentMapZone(), GetCurrentMapContinent()
        DebugPrint("Default zone" .. ZoneToUse)
      end
      if not ZoneToUse or not ContToUse then
        DebugPrint("MapCurrentObjective: could not resolve zone/continent, skipping waypoint")
        return
      end
      self.XVals, self.YVals = DugisGuideViewer:getCoords(CurrentQuestIndex)
      --Remove previous objective's mapping
      local mappedpoints = self:getAllCoords()
      for i = 1, #mappedpoints do
        local uid = select(5, unpack(mappedpoints[i]))
        TomTom:RemoveWaypoint(uid)
        --DebugPrint("REMOVE UID:"..uid)
      end
      --Add new objectives
      self:removeAllPoints()
      if self.XVals and self.YVals then
        for i = #self.XVals, 1, -1 do
          --local ZoneToUse2, ContToUse2 = GetCurrentMapZone(), GetCurrentMapContinent()
          --DebugPrint("Zonetouse="..ZoneToUse.."ZoneToUse2="..ZoneToUse2.."Conttouse="..ContToUse.."ContToUse2="..ContToUse2)
          UID = TomTom:AddZWaypoint(ContToUse, ZoneToUse, self.XVals[i], self.YVals[i], desc, false)
          DebugPrint("self.XVals[i]=" ..
            self.XVals[i] .. "self.YVals[i]=" .. self.YVals[i] .. "UID=" .. UID .. "ContToUse=" .. ContToUse .. desc)
          self:addPoint(ContToUse, ZoneToUse, self.XVals[i], self.YVals[i], UID, desc)
        end
      end
    end --If DugisGuideViewer.Flag_Waypoints == 1
  end   --If TomTom
end

function DugisGuideViewer:getAllCoords()
  return coords
end

function DugisGuideViewer:addPoint(...)
  DebugPrint("add point")
  local c, z, x, y, uid, desc = ...
  lastLocation = { c, z, x / 100, y / 100, uid, desc }
  tinsert(coords, 1, lastLocation)
  show = true
  --[[for i = 1, #coords do
x_shift[i], y_shift[i] = 0,0
end--]]
  if Ants then
    Ants:ClearShift()
    TomTom.profile.persistence.cleardistance = 0
  end --Don't auto clear the arrow when arriving end
end

function DugisGuideViewer:removeAllPoints()
  if Ants then Ants:removeAllPoints() end
  table.wipe(coords)
end

local zonei, zonec, zonenames = {}, {}, {}
for ci, c in pairs { GetMapContinents() } do
  zonenames[ci] = { GetMapZones(ci) }
  for zi, z in pairs(zonenames[ci]) do
    zonei[z], zonec[z] = zi, ci
  end
end
function DugisGuideViewer:IsZoneNameValid(name)
  local zi
  zi = zonei[name]
  if not zi then
    --DebugPrint("invalid zone name"..name)
    return (false)
  else
    --DebugPrint("Valid zone name"..name)
    return (true)
  end
end

function DugisGuideViewer:GetZoneNumberFromZoneName(zonename)
  local zn
  zn = zonei[zonename]
  return zn
end

function DugisGuideViewer:GetContinentNumberFromZoneName(zonename)
  --DebugPrint("zonename is"..zonename)
  local continent = zonec[zonename]
  --DebugPrint("Continent is"..continent)
  return continent
end

function SmallFrameClickHandler(self, arg1)
  name = self:GetName()
  if name == "DugisSmallFrame" and arg1 == "RightButton" then
    if DugisMainframe:IsVisible() == 1 then
      DugisGuideViewer:HideLargeWindow()
      getglobal("DugisSmallFrameLogo"):Hide()
    else
      UIFrameFadeIn(DugisMainframe, 0.5, 0, 1)
      UIFrameFadeIn(Dugis, 0.5, 0, 1)
      UIFrameFadeIn(DugisSmallFrameLogo, 0.5, 0, 1)
      DugisGuideViewer:ShowLargeWindow()
    end
  end
end

function DugisGuideViewer_Close_ButtonClick()
  DugisGuideViewer:HideLargeWindow()
  getglobal("DugisSmallFrameLogo"):Hide()
end

function DugisGuideViewer:ShowLargeWindow()
  DugisGuideViewer:AutoScroll(CurrentQuestIndex)
  DugisMainframe:Show()
  getglobal("DugisSmallFrameLogo"):Show()
  Dugis:Show()
end

function DugisGuideViewer:AutoScroll(indx)
  if indx and crowheight then
    local val = (crowheight * indx) - 130
    if val < 0 then val = 0 end
    Dugis_VSlider:SetValue(val)
  end
end

function SmallFrameCheckButton_OnEvent(self, event, ...)
  DebugPrint("Small Frame Check Button")
  local SmallFramebutton = getglobal("DugisSmallFrameChk")
  if CurrentQuestIndex then --If a guide is loaded
    if CurrentQuestIndex == LastGuideNumRows then
      SmallFramebutton:SetChecked(0)
      DugisGuideViewer:LoadNextGuide()
    else
      if DugisGuideViewer:GetFlag("ManualMode") then
        DugisGuideViewer:SetChkToComplete(CurrentQuestIndex)
        --DugisGuideViewer:MoveToNextQuest()
      else
        SmallFramebutton:SetCheckedTexture("Interface\\RAIDFRAME\\ReadyCheck-NotReady")
        SmallFramebutton:SetChecked(1)
        DugisGuideViewer:SetChktoX(CurrentQuestIndex)
        DugisGuideViewer:SkipQuest(CurrentQuestIndex)
      end
      DelayandMoveToNextQuest(0.3)
    end
  end
end

--Large frame checkbox checked by user
function DugisGuideViewer_CheckButton_OnEvent(self, event, ...)
  name = self:GetName()
  local _, _, boxindex = name:find("RecapPanelDetail([^ ]*)Chk")
  boxindex = tonumber(boxindex)
  local chkboxname = "RecapPanelDetail" .. boxindex .. "Chk"
  local manualmode = DugisGuideViewer:GetFlag("ManualMode")
  if manualmode then
    DugisGuideViewer:TriStateChk(boxindex)
  end
  local chk = DugisGuideViewer:GetTriStateChk(boxindex)
  --If user is checking box, move to next step
  if (getglobal(chkboxname):GetChecked() == 1) then
    if not manualmode or chk == "X" then
      DugisGuideViewer:SetChktoX(boxindex)
      DugisGuideViewer:SkipQuest(boxindex)
    end
    --If CQI just got checked (either by user or because it has same QID as another user checked)
    if getglobal("RecapPanelDetail" .. CurrentQuestIndex .. "Chk"):GetChecked() == 1 then
      DugisGuideViewer:MoveToNextQuest()
    end
    if boxindex == LastGuideNumRows then
      DugisGuideViewer:LoadNextGuide()
    end
    --User is unchecking box, move to prev step
  else
    DugisGuideViewer:ClrChk(boxindex)
    DugisGuideViewer:UnSkipQuest(boxindex)
    --If CQI just got unchecked (either by user or because it has same QID as another user unchecked)
    local nextindex = DugisGuideViewer:FindNextUnchecked(CurrentQuestIndex, 0)
    DebugPrint("boxindex=" .. boxindex .. "CurrentQuestIndex=" .. CurrentQuestIndex .. "nextindex=" .. nextindex)
    if boxindex < CurrentQuestIndex then
      DugisGuideViewer:MoveToPrevQuest()
    end
  end
  SetPercentComplete()
end

function DugisGuideViewer:LoadNextGuide()
  local nextguide = DugisGuideViewer.nextzones[CurrentTitle]
  DugisGuideViewer:DisplayViewTab(nextguide)
end

function DugisGuideViewer:TriStateChk(index)
  local LargeFramebutton = getglobal("RecapPanelDetail" .. index .. "Chk")
  if DugisGuideUser.QuestState[CurrentTitle .. ':' .. index] == "X" then
    DugisGuideUser.QuestState[CurrentTitle .. ':' .. index] = "U"
    LargeFramebutton:SetCheckedTexture("")
    LargeFramebutton:SetChecked(0)
  elseif DugisGuideUser.QuestState[CurrentTitle .. ':' .. index] == "C" then
    DugisGuideUser.QuestState[CurrentTitle .. ':' .. index] = "X"
    LargeFramebutton:SetCheckedTexture("Interface\\RAIDFRAME\\ReadyCheck-NotReady")
    LargeFramebutton:SetChecked(1)
  elseif DugisGuideUser.QuestState[CurrentTitle .. ':' .. index] == "U" then
    DugisGuideUser.QuestState[CurrentTitle .. ':' .. index] = "C"
    LargeFramebutton:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
    LargeFramebutton:SetChecked(1)
  end
end

function DugisGuideViewer:GetTriStateChk(index)
  return DugisGuideUser.QuestState[CurrentTitle .. ':' .. index]
end

function DugisGuideViewer:SetChktoX(index)
  DugisGuideUser.QuestState[CurrentTitle .. ':' .. index] = "X"
  local LargeFramebutton = getglobal("RecapPanelDetail" .. index .. "Chk")
  LargeFramebutton:SetCheckedTexture("Interface\\RAIDFRAME\\ReadyCheck-NotReady")
  LargeFramebutton:SetChecked(1)
end

function DugisGuideViewer:ClrChk(index)
  DugisGuideViewer:RemoveKey(DugisGuideUser.toskip, DugisGuideViewer.qid[index])
  DugisGuideUser.QuestState[CurrentTitle .. ':' .. index] = "U"
  local LargeFramebutton = getglobal("RecapPanelDetail" .. index .. "Chk")
  LargeFramebutton:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
  LargeFramebutton:SetChecked(0)
  LargeFramebutton:Enable()
end

--User chose to skip the quest and is now changing their mind
function DugisGuideViewer:UnSkipQuest(qindex)
  local qid = DugisGuideViewer.qid[qindex]
  --if DugisGuideViewer.actions[qindex] == "A" or DugisGuideViewer.actions[qindex] == "C" or DugisGuideViewer.actions[qindex] == "T" then
  if strmatch(self.actions[qindex], "[ACT]") then
    --Mark all quests with this same qid
    --[[for i =1, LastGuideNumRows do
if (DugisGuideViewer.qid[i] == qid) and (DugisGuideUser.QuestState[CurrentTitle..':'..i] ~= "C") then
--DebugPrint("CHK cleared index="..i.."DugisGuideUser.QuestState[i]="..DugisGuideUser.QuestState[i])
DugisGuideViewer:ClrChk(i)
if DugisGuideViewer.actions[i] == "C" or DugisGuideViewer.actions[i] == "T" then
local logindex = DugisGuideViewer:GetQuestLogIndexByQID(DugisGuideViewer.qid[i])
if logindex then AddQuestWatch(logindex) end
end
end
end-]]
    --if not self:GetFlag("ManualMode") then
    DugisGuideViewer:UnSkipPostReqs(qid)
    --end
  else
    DugisGuideViewer:ClrChk(qindex)
  end
  WatchFrame_Update()
end

--User chose to not do this quest
function DugisGuideViewer:SkipQuest(qindex)
  local qid = DugisGuideViewer.qid[qindex]
  local logindex = DugisGuideViewer:GetQuestLogIndexByQID(DugisGuideViewer.qid[qindex])
  if logindex then RemoveQuestWatch(logindex) end
  WatchFrame_Update()
  --if DugisGuideViewer.actions[qindex] == "A" or DugisGuideViewer.actions[qindex] == "C" or DugisGuideViewer.actions[qindex] == "T" then
  if strmatch(self.actions[qindex], "[ACT]") then
    --Mark all quests with this same qid
    --[[for i =1, LastGuideNumRows do
--local prereq = DugisGuideViewer:ReturnTag("PRE", i)
if (DugisGuideViewer.qid[i] == qid) and (DugisGuideUser.QuestState[CurrentTitle..':'..i] ~= "C") then --or (prereq and prereq == DugisGuideViewer.quests1[qindex] )then
DugisGuideViewer:SetChktoX(i)
end
end--]]
    --if not self:GetFlag("ManualMode") then
    DugisGuideViewer:SkipPostReqs(qid)
    --end
  else --DugisGuideViewer.actions[qindex] == "N" or DugisGuideViewer.actions[qindex] == "F" then --note tag or flight, only skip this one
    DugisGuideViewer:SetChktoX(qindex)
  end
end

function DugisGuideViewer:SetQuestTextNormal(i)
  getglobal("RecapPanelDetail" .. i .. "Name"):SetTextColor(1, 0.82, 0, 1)
  getglobal("RecapPanelDetail" .. i .. "Desc"):SetTextColor(1, 1, 1, 1)
  getglobal("RecapPanelDetail" .. i .. "Opt"):SetText("")
end

function DugisGuideViewer:MoveToPrevQuest()
  --if CurrentQuestIndex > 1 then
  getglobal("RecapPanelDetail" .. CurrentQuestIndex):SetNormalTexture("")
  local nextindex = DugisGuideViewer:FindNextUnchecked(CurrentQuestIndex, 0)
  CurrentQuestIndex = nextindex
  DugisGuideViewer:SetQuestColor(CurrentQuestIndex)
  CurrentAction = DugisGuideViewer.actions[CurrentQuestIndex]
  CurrentQuestName = DugisGuideViewer.quests1L[CurrentQuestIndex]
  DugisGuideViewer:SetUseItem(DugisGuideViewer.useitem[CurrentQuestIndex])
  DugisGuideViewer:MapCurrentObjective()
  DugisGuideViewer:WatchQuest()
  DugisGuideViewer:PopulateSmallFrame(CurrentQuestIndex)
  UIFrameFadeIn(DugisSmallFrame, 0.8, 0, 1)
  SetPercentComplete()
  getglobal("RecapPanelDetail" .. CurrentQuestIndex):SetNormalTexture(
    "Interface\\FriendsFrame\\UI-FriendsFrame-HighlightBar")
  DebugPrint("Current quest now is: " .. DugisGuideViewer.quests1L[CurrentQuestIndex])
  --end
end

function DugisGuideViewer:WatchQuest()
  --if InterfaceOptionsObjectivesPanelAutoQuestTracking:GetChecked() then DebugPrint("AUto checked") else DebugPrint("AUto unchecked") end
  --[[if (CurrentAction == "C" or CurrentAction == "T")  and self:GetFlag("EnableQW") then
local logindex = DugisGuideViewer:GetQuestLogIndexByQID(DugisGuideViewer.qid[CurrentQuestIndex])
if logindex then AddQuestWatch(logindex) end
local i = CurrentQuestIndex
while( i <= LastGuideNumRows and (DugisGuideViewer.actions[i] == "C" or DugisGuideViewer.actions[i] == "T" ) and DugisGuideUser.QuestState[CurrentTitle..':'..i] ~= "X" )do
local logindex = DugisGuideViewer:GetQuestLogIndexByQID(DugisGuideViewer.qid[i])
if logindex then AddQuestWatch(logindex) end
i = i + 1
end
end--]]
  WatchFrame_Update()
end

function havelootitem(qid)
  local havel
  local lootitem, lootqty = DugisGuideViewer:ReturnTag("L", qid)
  if lootitem and (GetItemCount(lootitem) >= lootqty) then havel = true else havel = false end
  return havel
end

function haveuseitem(qid)
  local haveu
  local useitem = DugisGuideViewer:ReturnTag("U", qid)
  local uinbag = DugisGuideViewer:InBag(useitem)
  if (useitem and uinbag) then haveu = true else haveu = false end
  return haveu
end

function DugisGuideViewer:CheckForOptionalLoot(indx)
  local lootitem, lootqty = DugisGuideViewer:ReturnTag("L", indx)
  local optional = DugisGuideViewer:ReturnTag("O", indx)
  local useitem = DugisGuideViewer:ReturnTag("U", indx)
  --local uinbag = DugisGuideViewer:InBag(useitem)
  local inlog = DugisGuideViewer:GetQuestLogIndexByQID(DugisGuideViewer.qid[indx])
  local action = DugisGuideViewer.actions[indx]
  --local uneeded, lneeded
  haveuse = haveuseitem(indx)
  haveloot = havelootitem(indx)
  --|L| + "A" + Optional - skipped if the user does not have the item (and quantity) needed.
  --|U| + "A" + Optional - skipped if the user does not have the item to use
  if optional and action == "A" and (haveloot or haveuse) then
    DebugPrint("Detected use/loot item in bag, display quest")
    return false
  elseif optional and not inlog then
    DebugPrint("SKIP: not in log or not use/loot item")
    return true
  elseif optional and ((action == "A" and useitem and not haveuse) or (lootitem and not haveloot)) then
    DebugPrint("SKIP: not enough loot or no use item")
    return true
  else
    return false
  end
end

function DugisGuideViewer:CheckForLocation(indx)
  local action = DugisGuideViewer.actions[indx]
  --R - Run, F - Fly, b - Boat, H - Hearth, G -??
  if (action == "R" or action == "F" or action == "b" or action == "H") then
    local subzonetext = string.trim(GetSubZoneText()) -- returns blank if no subzone
    local zonetext = GetZoneText()
    --local subzonetag = ReturnTag("SubZone")
    local quest = DugisGuideViewer.quests1L[indx]
    --quest = DugisGuideViewer:revlocalize(quest, "ZONE")
    DebugPrint("subzonetext=" .. subzonetext .. "zonetext=" .. zonetext .. "quest=" .. quest)
    --if (subzonetext == CurrentQuestName) then
    if subzonetext == quest or zonetext == quest then
      DebugPrint("Detected correct area " .. CurrentQuestName .. "=" .. subzonetext)
      DugisGuideViewer:SetChkToComplete(indx)
      return true
    else
      return false
    end
  else
    return false
  end
end

function DugisGuideViewer:FindNextUnchecked(startindx, direction)
  local lastunchecked
  --Find first check box that is unchecked in the list
  if direction == 0 then
    indx = startindx
    while indx >= 1 do
      --DebugPrint("indx:"..indx.."Questate:"..DugisGuideUser.QuestState[CurrentTitle..':'..indx])
      if DugisGuideUser.QuestState[CurrentTitle .. ':' .. indx] == "U" and DugisGuideViewer:CheckForOptionalLoot(indx) == false and DugisGuideViewer:CheckForLocation(indx) == false then
        lastunchecked = indx
        --DebugPrint("Lastunchecked:"..lastunchecked)
      end
      indx = indx - 1
    end
    if lastunchecked == nil then lastunchecked = startindx end --new
    return lastunchecked
  elseif direction == 1 then
    indx = startindx + 1
    while indx <= LastGuideNumRows do
      if DugisGuideUser.QuestState[CurrentTitle .. ':' .. indx] == "U" and DugisGuideViewer:CheckForOptionalLoot(indx) == false and DugisGuideViewer:CheckForLocation(indx) == false then
        lastunchecked = indx
        return lastunchecked
      elseif indx == LastGuideNumRows then
        lastunchecked = indx
        return lastunchecked
      end
      indx = indx + 1
    end
    return LastGuideNumRows
  end
end

--Move to next quest after CurrentQuest we are on
function DugisGuideViewer:MoveToNextQuest()
  if CurrentQuestIndex < LastGuideNumRows then
    getglobal("RecapPanelDetail" .. CurrentQuestIndex):SetNormalTexture("")
    local nextunchecked = DugisGuideViewer:FindNextUnchecked(CurrentQuestIndex, 1)
    CurrentQuestIndex = nextunchecked
    --CurrentQuestIndex = DugisGuideViewer:CheckForOptionalLoot(CurrentQuestIndex, 1)
    DugisGuideViewer:SetQuestColor(CurrentQuestIndex)
    CurrentAction = DugisGuideViewer.actions[CurrentQuestIndex]
    CurrentQuestName = DugisGuideViewer.quests1L[CurrentQuestIndex]
    DugisGuideViewer:SetUseItem(DugisGuideViewer.useitem[CurrentQuestIndex])
    DugisGuideViewer:MapCurrentObjective()
    DugisGuideViewer:WatchQuest()
    DugisGuideViewer:PopulateSmallFrame(CurrentQuestIndex)
    UIFrameFadeIn(DugisSmallFrame, 0.8, 0, 1)
    local SmallFramebutton = getglobal("DugisSmallFrameChk")
    SmallFramebutton:SetChecked(0)
    SetPercentComplete()
    getglobal("RecapPanelDetail" .. CurrentQuestIndex):SetNormalTexture(
      "Interface\\FriendsFrame\\UI-FriendsFrame-HighlightBar")
    DebugPrint("Current quest now is: " .. DugisGuideViewer.quests1L[CurrentQuestIndex])
  end
end

--Uncheck quests and start from beginning of quest progress
function DugisGuideViewer:ResetAllQuests()
  --DebugPrint("resetting quests")
  for i = 1, LastGuideNumRows do
    DugisGuideViewer:ClrChk(i)
  end
  CurrentQuestName = DugisGuideViewer.quests1L[1]
  CurrentAction = DugisGuideViewer.actions[1]
  CurrentQuestIndex = 1
  DugisGuideViewer:PopulateSmallFrame(CurrentQuestIndex)
  DugisGuideViewer:SetUseItem(DugisGuideViewer.useitem[CurrentQuestIndex])
  QueryQuestsCompleted()
end

function DugisGuideViewer:SetToQuestNumber(num)
  local i
  for i = 1, LastGuideNumRows do
    getglobal("RecapPanelDetail" .. i):SetNormalTexture("")
  end
  CurrentQuestIndex = num
  CurrentQuestName = DugisGuideViewer.quests1L[num]
  CurrentQuestDesc = DugisGuideViewer.quests2[num]
  CurrentAction = DugisGuideViewer.actions[num]
  DugisGuideViewer:SetQuestColor(CurrentQuestIndex)
  DugisGuideViewer:SetUseItem(DugisGuideViewer.useitem[num])
  DugisGuideViewer:PopulateSmallFrame(CurrentQuestIndex)
  DugisGuideViewer:MapCurrentObjective()
  DugisGuideViewer:WatchQuest()
  getglobal("RecapPanelDetail" .. CurrentQuestIndex):SetNormalTexture(
    "Interface\\FriendsFrame\\UI-FriendsFrame-HighlightBar")
  SetPercentComplete()
end

function DugisGuideViewer:InitFramePositions()
  local frame = getglobal("DugisSmallFrame")
  frame:ClearAllPoints()
  frame:SetPoint("CENTER", 0, 220)
  local frame2 = getglobal("DugisMainframe")
  frame2:ClearAllPoints()
  frame2:SetPoint("CENTER", 0, 0)
  local frame3 = getglobal("DugisGuideViewerItemFrame")
  frame3:ClearAllPoints()
  frame3:SetPoint("CENTER", 0, 255)
end

function DugisGuideViewer:InitSmallFrame(str, texture)
  local icon = getglobal("SmallFrameDetail1Button")
  local text = getglobal("SmallFrameDetail1Name")
  local frame = getglobal("DugisSmallFrame")
  fontstring = frame:CreateFontString("tmpfontstr", "ARTWORK", "GameFontNormal")
  fontstring:SetText(str)
  local fontwidth = fontstring:GetStringWidth()
  text:SetWidth(fontwidth)
  text:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
  text:SetText(str)
  icon:SetNormalTexture(texture)
  icon:SetPoint("RIGHT", text, "LEFT", 0, 0)
  frame:SetWidth(fontwidth + 30)
end

function DugisGuideViewer:GetFontWidth(text, fonttype)
  local font = fonttype or "GameFontNormal"
  local frame = getglobal("DugisSmallFrame")
  fontstring = frame:CreateFontString("tmpfontstr", "ARTWORK", font)
  fontstring:SetText(text)
  local fontwidth = fontstring:GetStringWidth()
  return fontwidth
end

function DugisGuideViewer:PopulateSmallFrame(currquest)
  if currquest and DugisGuideViewer:isValidGuide(CurrentTitle) ~= nil then
    local icon = getglobal("SmallFrameDetail1Button")
    local text = getglobal("SmallFrameDetail1Name")
    local frame = getglobal("DugisSmallFrame")
    local level = DugisGuideViewer:GetQuestLevel(self.qid[currquest])
    local qName = DugisGuideViewer.quests1L[currquest]
    if level and strmatch(self.actions[currquest], "[ACT]") and self:GetFlag("QuestLevelOn") then
      qName = "[" ..
          level .. "] " .. qName
    end
    fontstring = frame:CreateFontString("tmpfontstr", "ARTWORK", "GameFontNormal")
    fontstring:SetText(qName)
    local fontwidth = fontstring:GetStringWidth()
    text:SetWidth(fontwidth)
    text:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
    text:SetText(qName)
    icon:SetNormalTexture(DugisGuideViewer:getIcon(DugisGuideViewer.actions[currquest], currquest))
    icon:SetPoint("RIGHT", text, "LEFT", 0, 0)
    frame:SetWidth(fontwidth + 30)
    local color = self:GetQuestDiffColor(currquest)
    if strmatch(self.actions[currquest], "[ACT]") and color and self:GetFlag("QuestLevelOn") then --set difficulty color on A/C/T actions
      text:SetTextColor(color.r, color.g, color.b, 1)
    else
      text:SetTextColor(1, 0.82, 0, 1)
    end
  end
end

function getQuestIndexByQuestName(name)
  local i
  local numq, _ = GetNumQuestLogEntries()
  for i = 1, numq do
    local title, _, _, _, isHeader = GetQuestLogTitle(i)
    if not isHeader then
      --DebugPrint("title="..title.."name="..name)
      --if (string.find(name, title)) then
      if name == title then
        --DebugPrint("Quest title"..title.."="..name)
        return i
      end
    end
  end
end

function printAllquests(name)
  local i
  local numq, _ = GetNumQuestLogEntries()
  for i = 1, numq do
    local title, _, _, _, isHeader = GetQuestLogTitle(i)
    if not isHeader then
      DebugPrint("Quest title" .. title)
    end
  end
end

function DugisGuideViewer:WipeOutViewTab()
  for i = 1, LastGuideNumRows do
    getglobal("RecapPanelDetail" .. i):Hide()
  end
  DugisGuideViewer:HidePercent()
  getglobal("RecapPanelDetail1Chk"):Hide()
end

--Called from clicking on a guide title
function DugisGuideViewer:DisplayViewTab(title)
  --DebugPrint("CurrentTitle:"..CurrentTitle)
  --Clear existing guide if any and load this guide
  if title == nil or DugisGuideViewer:isValidGuide(title) == nil then
    --DugisGuideViewer:SetViewTabTitle(L["No Guide Loaded"])
    --DugisGuideViewer:InitSmallFrame(L["No Guide Loaded. Click Here To Select One"], "Interface\\Minimap\\TRACKING\\Class" )
    --DugisGuideViewer:WipeOutViewTab()
    DugisGuideViewer:ClearScreen()
  else --if title ~= CurrentTitle then
    CurrentTitle = title
    DebugPrint("title is:" .. title)
    DugisGuideViewer:ParseRows(title, string.split("\n", "\n" .. self.guides[title]()))
    local zonename = title:match("%s*([^]]+) %(.*%)$")
    if zonename then CurrentZone = DugisGuideViewer:localize(zonename, "ZONE") end
    DugisGuideViewer:QuestsBackgroundTranslator()
    DugisGuideViewer:PopulateScreen(title)
    local name = title .. ":1"
    if DugisGuideUser.QuestState[name] == nil then
      --DebugPrint("First time loading"..title)
      DugisGuideViewer:ResetAllQuests()
    else
      --DebugPrint("NOT First time loading"..title)
    end
    DugisGuideViewer:ShowViewTab()
    DugisGuideViewer:SetQuestsState()
    DugisGuideViewer:PopulateSmallFrame(CurrentQuestIndex)
    DugisGuideViewer:SetAllPercents()
  end
end

function Dugis_OnMouseWheel(self, delta)
  local current = Dugis_VSlider:GetValue()
  local Max
  Max = SliderMax[DugisGuideViewer:CurrentTab()]
  if (delta < 0) and (current < Max) then
    Dugis_VSlider:SetValue(current + 100)
  elseif (delta > 0) and (current > 1) then
    Dugis_VSlider:SetValue(current - 100)
  end
end

function DugisGuideViewer:SetAllPercents()
  local guidename, guidesize, percent, text, checked
  if DugisGuideUser["QuestState"] then
    for t = 1, #tabs do
      local gtype = tabs[t].guidetype
      if gtype and DugisGuideViewer.guidelist[gtype] then
        for i = 1, #DugisGuideViewer.guidelist[gtype] do --Each guide title
          guidename = DugisGuideViewer.guidelist[gtype][i]
          guidesize = DugisGuideViewer:getGuideSize(guidename, string.split("\n", "\n" .. self.guides[guidename]()))
          unchecked = 0
          for j = 1, guidesize do
            if DugisGuideUser.QuestState[guidename .. ':' .. j] then
              if DugisGuideUser.QuestState[guidename .. ':' .. j] == "U" then unchecked = unchecked + 1 end
            else
              unchecked = unchecked + 1
            end
          end
          if unchecked == 1 then percent = 100 else percent = 100 - ((unchecked / guidesize) * 100) end
          if percent == 0 then
            --getglobal("DungeonsMapRow"..i.."Percent"):SetText("")
            getglobal("DugisTab" .. t .. "Row" .. i .. "Percent"):SetText("")
          else
            text = string.format("%.0f", percent)
            --getglobal("DungeonsMapRow"..i.."Percent"):SetText(text.."% "..L["Complete"])
            getglobal("DugisTab" .. t .. "Row" .. i .. "Percent"):SetText(text .. "% " .. L["Complete"])
            red, green, blue, alpha = getColor(percent)
            --getglobal("DungeonsMapRow"..i.."Percent"):SetTextColor(red, green, blue, alpha)
            getglobal("DugisTab" .. t .. "Row" .. i .. "Percent"):SetTextColor(red, green, blue, alpha)
          end
        end
      end
    end
  end
end

function DugisGuideViewer:getGuideSize(guidetitle, rowinfo, ...)
  if not DugisGuideViewer.guidesize[guidetitle] then
    local indx = 0
    local myClass = DugisGuideViewer:revlocalize(UnitClass("player"), "CLASS")
    local myRace = DugisGuideViewer:revlocalize(UnitRace("player"), "RACE")
    --Loop through all rows
    for i = 1, select("#", ...) do
      local text = select(i, ...)
      text = self:Retxyz(text, i)
      local _, _, classes = text:find("|C|([^|]+)|")
      local _, _, races = text:find("|R|([^|]+)|")
      local _, _, daily = text:find("(|D|)")
      if text ~= "" and (not classes or classes:find(myClass)) and (not races or races:find(myRace)) then
        if guidename == "Teldrassil (1-12 Night Elf)" then DebugPrint("CHECKED:" .. text) end
        indx = indx + 1
      end
    end
    DugisGuideViewer.guidesize[guidetitle] = indx
  end
  return DugisGuideViewer.guidesize[guidetitle]
end

function DugisGuideViewer:HidePercent()
  DugisPercentButtonName:Hide()
end

function SetPercentComplete()
  local percent
  local unchecked = 0
  if CurrentTitle then
    DugisPercentButtonName:Show()
    for i = 1, LastGuideNumRows do
      if DugisGuideUser.QuestState[CurrentTitle .. ':' .. i] == "U" then unchecked = unchecked + 1 end
    end
    if unchecked == 1 then
      percent = 100
    else
      percent = 100 - ((unchecked / LastGuideNumRows) * 100)
    end
    --DebugPrint("Percent complete: Unchecked:"..unchecked.."total"..LastGuideNumRows)
    local text = string.format("%.0f", percent)
    getglobal("DugisPercentButtonName"):SetText(text .. "% " .. L["Complete"])
    red, green, blue, alpha = getColor(percent)
    getglobal("DugisPercentButtonName"):SetTextColor(red, green, blue, alpha)
  else
    getglobal("DugisPercentButtonName"):SetText("")
  end
end

function getColor(percent)
  --someText:SetTextColor(red,green,blue,alpha)
  if percent < 25 then
    red = 1
    green = 0
    blue = 0
    alpha = 1
    --getglobal("DugisPercentButtonName"):SetTextColor(1.0, 0, 0, 1) -- red
  elseif percent < 50 then
    red = 1
    green = 0.5
    blue = 0
    alpha = 1
    --getglobal("DugisPercentButtonName"):SetTextColor(1.0, 0.5, 0, 1) --orange
  elseif percent < 75 then
    red = 1
    green = 1
    blue = 0
    alpha = 1
    --getglobal("DugisPercentButtonName"):SetTextColor(1.0, 1.0, 0, 1.0) --yellow
  else
    red = 0
    green = 1
    blue = 0
    alpha = 1
    --getglobal("DugisPercentButtonName"):SetTextColor(0, 1, 0, 1)--green
  end
  return red, green, blue, alpha
end

function DugisGuideViewer:SkipPostReqs_Inner2(qid, safety, postreqs)
  safety = safety + 1
  if DugisGuideViewer.RevChains[qid] == nil or safety > 500 then return end --base case
  for post, pre in ipairs(DugisGuideViewer.RevChains[qid]) do
    DebugPrint("CLEAR:" .. pre)
    table.insert(postreqs, pre)
    DugisGuideViewer:SkipPostReqs_Inner2(pre, safety, postreqs)
  end
end

function DugisGuideViewer:UnSkipPostReqs(qid)
  local DugisGuideViewer_postreqs = {}
  table.insert(DugisGuideViewer_postreqs, qid)
  DugisGuideViewer:SkipPostReqs_Inner2(qid, 0, DugisGuideViewer_postreqs)
  --Clear all skipped that are A, C, T
  for q, pr in pairs(DugisGuideViewer_postreqs) do
    local guideidx = DugisGuideViewer:GetGuideIndexByQID(pr)
    DebugPrint("UNSKIP:" .. pr)
    if not guideidx then DebugPrint(pr .. " Not in current guide") end
    --if not DugisGuideUser.toskip then DugisGuideUser.toskip = {pr} else table.insert(DugisGuideUser.toskip, pr) end
    for i = 1, LastGuideNumRows do
      if (DugisGuideViewer.qid[i] == pr) and (DugisGuideUser.QuestState[CurrentTitle .. ':' .. i] == "X") then
        if (DugisGuideViewer.actions[i] == "A" or DugisGuideViewer.actions[i] == "C" or DugisGuideViewer.actions[i] == "T") then
          DugisGuideViewer:ClrChk(i)
        end
      end
    end
  end
end

function DugisGuideViewer:SkipPostReqs_Inner(qid, safety, postreqs)
  safety = safety + 1
  if DugisGuideViewer.RevChains[qid] == nil or safety > 500 then return end --base case
  for post, pre in ipairs(DugisGuideViewer.RevChains[qid]) do
    if DugisGuideViewer:InTable(pre, DugisGuideViewer.RevChains["OR"]) == true then
      table.insert(ors, pre)
    else
      if DugisGuideViewer:InTable(pre, postreqs) == false then table.insert(postreqs, pre) end
    end
    DugisGuideViewer:SkipPostReqs_Inner(pre, safety, postreqs)
  end
end

function DugisGuideViewer:SkipPostReqs(qid)
  local DugisGuideViewer_ands = {}
  --local DugisGuideViewer_ors  = {}
  local DugisGuideViewer_postreqs = {}
  table.insert(DugisGuideViewer_postreqs, qid)
  DugisGuideViewer:SkipPostReqs_Inner(qid, 0, DugisGuideViewer_postreqs)
  --Find if there are Ands in the Postreqs
  for q, pr in pairs(DugisGuideViewer_postreqs) do
    if DugisGuideViewer:InTable(pr, DugisGuideViewer.RevChains["AND"]) == true then
      table.insert(DugisGuideViewer_ands, pr)
    end
  end
  --Skip if any ANDs are skipped
  for q, pr in pairs(DugisGuideViewer_ands) do
    local num = 0
    for i = 1, #DugisGuideViewer.Chains[pr] do                                                                      --ex: [9] = {"AND", 2, 20}
      if DugisGuideViewer:InTable(DugisGuideViewer.Chains[pr][i], DugisGuideViewer_postreqs) then num = num + 1 end --If qid is set to be skipped
    end
    if num == 0 then
      local rem = DugisGuideViewer:RemoveKey(DugisGuideViewer_postreqs, pr) --no ANDs skipped, remove from skip table
      --DugisGuideViewer:RemoveKey(DugisGuideViewer_postreqs, pr)
      DebugPrint("DONT SKIP AND==" .. pr .. "num=" .. num ..
        "#DugisGuideViewer.Chains[pr]=" .. #DugisGuideViewer.Chains[pr])
      if rem then DebugPrint("removed:" .. rem) end
    end
  end
  --Skip breadcrumbs (ORS) - they happen before quest skipped
  for q, pr in pairs(DugisGuideViewer_postreqs) do
    if type(DugisGuideViewer.Chains[pr]) == "table" and DugisGuideViewer.Chains[pr][1] == "OR" then --Skip all these
      for i = 2, #DugisGuideViewer.Chains[pr] do
        DebugPrint("Breadcrumb:" .. DugisGuideViewer.Chains[pr][i])
        table.insert(DugisGuideViewer_postreqs, DugisGuideViewer.Chains[pr][i])
      end
    end
  end
  DebugPrint("********************")
  --Check all skipped that are A, C, T
  for q, pr in pairs(DugisGuideViewer_postreqs) do
    DugisGuideViewer:SkipQuestAcrossGuides(pr)
    --[[local guideidx = DugisGuideViewer:GetGuideIndexByQID(pr)
DebugPrint("SKIP:"..pr)
if not guideidx then DebugPrint(pr.." Not in current guide") end
if not DugisGuideUser.toskip then DugisGuideUser.toskip = {pr} else table.insert(DugisGuideUser.toskip, pr) end
for i = 1, LastGuideNumRows do
if (DugisGuideViewer.qid[i] == pr) and (DugisGuideUser.QuestState[CurrentTitle..':'..i] ~= "C") then
if (DugisGuideViewer.actions[i] == "A" or DugisGuideViewer.actions[i] == "C" or DugisGuideViewer.actions[i] == "T") then
DugisGuideViewer:SetChktoX(i)
end
end
end
--]]
  end
end

function DugisGuideViewer:SkipQuestAcrossGuides(qid)
  local guideidx = DugisGuideViewer:GetGuideIndexByQID(qid)
  DebugPrint("SKIP:" .. qid)
  if not DugisGuideUser.toskip then DugisGuideUser.toskip = { qid } else table.insert(DugisGuideUser.toskip, qid) end
  if not guideidx then
    DebugPrint(qid .. " Not in current guide")
  else
    for i = 1, LastGuideNumRows do
      if (DugisGuideViewer.qid[i] == qid) and (DugisGuideUser.QuestState[CurrentTitle .. ':' .. i] ~= "C") then
        if (DugisGuideViewer.actions[i] == "A" or DugisGuideViewer.actions[i] == "C" or DugisGuideViewer.actions[i] == "T") then
          DugisGuideViewer:SetChktoX(i)
        end
      end
    end
  end
end

function DugisGuideViewer:RemoveKey(t, key)
  if t then
    for q, pr in pairs(t) do
      if pr == key then
        t[q] = nil
        return key
      end
    end
  end
end

function DugisGuideViewer:InTable(el, tbl)
  if tbl then
    for i, key in pairs(tbl) do
      if key == el then return true end
    end
  end
  return false
end

function DugisGuideViewer:PrintChains()
  --Print All Chains
  DebugPrint("***CHAINS:")
  for q, pr in pairs(DugisGuideViewer.Chains) do
    if type(pr) == "table" then
      DebugPrint("QID:" .. q)
      --for pre,post in ipairs(pr) do
      --DebugPrint("PRE:"..post)
      --end
      for i = 1, #pr do
        DebugPrint("PRE:" .. pr[i])
      end
      DebugPrint("@")
    elseif type(pr) == "number" then
      DebugPrint("QID:" .. q .. ",PRE:" .. pr)
    end
  end
  DebugPrint("***")
  --Print All Reverse Chains
  DebugPrint("***REV CHAINS:")
  for q, pr in pairs(DugisGuideViewer.RevChains) do
    --if type(pr) == "table" then
    DebugPrint("QID:" .. q)
    for pre, post in ipairs(pr) do
      --DebugPrint(q..","..post)
      DebugPrint("POST:" .. post)
    end
    DebugPrint("@")
    --end
  end
  DebugPrint("***")
end

function DugisGuideViewer:OnHyperlinkClick(self, link)
  DebugPrint("OnHyperlinkclick" .. link)
end

function DugisGuideViewer:OnHyperlinkEnter(self, link)
  DebugPrint("OnHyperlinkenter" .. link)
end

function DugisGuideViewer:OnHyperlinkLeave(self, link)
  DebugPrint("OnHyperlinkleave" .. link)
end

function DugisGuideViewer:isValidGuide(title)
  if self.guides[title] then
    return true
  end
end

function DugisGuideViewer:Test()
  if InterfaceOptionsObjectivesPanelAutoQuestTracking:GetChecked() then
    DebugPrint("AUto checked")
  else
    DebugPrint(
      "AUto unchecked")
  end
  --Ants:Debugz()
  DebugPrint("L[Automatic Waypoints]=" .. L["Automatic Waypoints"])
  --[[
local achievementID = 867 --http://www.wowhead.com/achievement=867
index = 14
local categoryID = GetAchievementCategory(achievementID)
--local _, name, _, completed = GetAchievementInfo(categoryID, 1)
local description, name, _, completed = GetAchievementCriteriaInfo(achievementID, index)
DebugPrint("CATEGORY ID:"..categoryID.."ACHIEVE NAME:"..description.."NAME:"..name.."completed"..completed) --Carrion Hill
--]]
  local achievementID = 760 --http://www.wowhead.com/achievement=760 Explore alterac mountains
  index = 7                 --Galvin's naze
  local categoryID = GetAchievementCategory(achievementID)
  --local _, name, _, completed = GetAchievementInfo(categoryID, 1)
  local description, name, _, completed = GetAchievementCriteriaInfo(achievementID, index)
  DebugPrint("CATEGORY ID:" .. categoryID .. "ACHIEVE NAME:" .. description .. "NAME:" .. name .. "completed" ..
    completed) --
  --[[
DebugPrint("ACHIEVE NAME:"..name)
if completed then DebugPrint("completed") else DebugPrint("NOT completed") end
 _, name, _, completed = GetAchievementInfo(867, 6)
DebugPrint("ACHIEVE NAME:"..name)
if completed then DebugPrint("completed") else DebugPrint("NOT completed") end
--]]
end

function DugisGuideViewer:OnLoad()
  DebugPrint("Localized item button=" .. L["Item Button"])
  DugisGuideViewer:PopulateTabs()
  DugisGuideViewer:InitViewTab()
  DugisGuideViewer:HideLargeWindow()
  --Load saved guide
  if CurrentTitle then
    DugisGuideViewer:DisplayViewTab(CurrentTitle)
    --Load Default
  else
    if UnitLevel("player") == 1 and UnitXP("player") == 0 then
      DebugPrint("RACE:" .. select(2, UnitRace("player")))
      local startguides = {
        BloodElf = "Eversong Woods (1-13 Blood Elf)",
        Orc = "Durotar (1-12 Orc & Troll)",
        Troll = "Durotar (1-12 Orc & Troll)",
        Tauren = "Mulgore (1-12 Tauren)",
        Undead = "Tirisfal Glades (1-12 Undead)",
        Dwarf = "Dun Morogh (1-12 Dwarf & Gnome)",
        Gnome = "Dun Morogh (1-12 Dwarf & Gnome)",
        Draenei = "Azuremyst Isle (1-12 Draenei)",
        Human = "Elwynn Forest (1-12 Human)",
        NightElf = "Teldrassil (1-12 Night Elf)"
      }
      CurrentTitle = startguides[select(2, UnitRace("player"))]
      DugisGuideViewer:DisplayViewTab(CurrentTitle)
    else
      DugisGuideViewer:SetViewTabTitle(L["No Guide Loaded"])
      DugisGuideViewer:InitSmallFrame(L["No Guide Loaded. Click Here To Select One"],
        "Interface\\Minimap\\TRACKING\\Class")
    end
  end
  if Debug == 1 and DebugFramesON == 1 then
    DGV_TestFrame:Show()
  end
  DugisGuideViewer:SettingFrameChkOnClick()
end

function DugisGuideViewer:HideLargeWindow()
  DugisMainframe:Hide()
  Dugis:Hide()
end

--[[
function DugisGuideViewer:SmallWindowTooltipInit()
DebugPrint("************************************************")
text = ""
GameTooltip:SetOwner( getglobal("SmallFrameDetail1"))
GameTooltip:AddLine(text, 1, 1, 1, 1, true)
GameTooltip:Show()
GameTooltip:ClearAllPoints()
GameTooltip:SetPoint("TOPRIGHT", SmallFrameDetail1, "BOTTOMRIGHT", 0, 10)
end
--]]
function DugisGuideViewer:SmallWindowTooltip_OnEnter(self, event)
  if CurrentQuestIndex then
    local text = DugisGuideViewer.quests2[CurrentQuestIndex] or ""
    GameTooltip:SetOwner(getglobal("SmallFrameDetail1")) --,"ANCHOR_TOPRIGHT", 0, 0)
    GameTooltip:AddLine(text, 1, 1, 1, 1, true)
    GameTooltip:Show()
    GameTooltip:ClearAllPoints()
    GameTooltip:SetPoint("TOPRIGHT", SmallFrameDetail1, "BOTTOMRIGHT", 0, 10)
  end
end

function DugisGuideViewer:SmallWindowTooltip_OnLeave()
  GameTooltip:Hide()
end

function DugisGuideViewer:Tooltip_OnEnter(self, event, ...)
  local name = self:GetName()
  local text
  text = getglobal(self:GetName() .. "Desc"):GetText()
  GameTooltip:SetOwner(getglobal(name), "ANCHOR_CURSOR")
  GameTooltip:AddLine(text, 1, 1, 1, 1, true)
  GameTooltip:Show()
end

function DugisGuideViewer:Tooltip_OnLeave()
  GameTooltip:Hide()
end

--[[
A = "Interface\\AddOns\\DugisGuideViewer\\Artwork\\accept.tga" 'accept
C = "Interface\\AddOns\\DugisGuideViewer\\Artwork\\cog.tga" 'complete
T = "Interface\\AddOns\\DugisGuideViewer\\Artwork\\turnin.tga" 'turnin
G = "Interface\\AddOns\\DugisGuideViewer\\Artwork\\horse.tga"'travel
F = "Interface\\Minimap\\TRACKING\\FlightMaster"'fly
B = "Interface\\AddOns\\DugisGuideViewer\\Artwork\\waves.tga",'boat
H = "Interface\\Minimap\\TRACKING\\Innkeeper"'hearth
P = "Interface\\Minimap\\TRACKING\\Auctioneer"'buy
U = "Interface\\Minimap\\TRACKING\\None"'use
SH = "Interface\\GossipFrame\\Petitiongossipicon"'sethearth
FP = "Interface\\AddOns\\DugisGuideViewer\\Artwork\\flightpath.tga"'getflightpoint
N = "Interface\\Minimap\\TRACKING\\Profession"'note
K = "Interface\\Minimap\\TRACKING\\Ammunition"'kill
--]]
local icontbl = {
  [1] = { path = "Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\accept.tga", text = "Accept Quest" },
  [2] = { path = "Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\cog.tga", text = "Complete Quest" },
  [3] = { path = "Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\turnin.tga", text = "Turn in Quest" },
  [4] = { path = "Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\flightpath.tga", text = "Get Flight Point" },
  [5] = { path = "Interface\\Minimap\\TRACKING\\Auctioneer", text = "Buy Item" },
  [6] = { path = "Interface\\Minimap\\TRACKING\\None", text = "Use Item" },
  [7] = { path = "Interface\\Minimap\\TRACKING\\Profession", text = "Note" },
  [8] = { path = "Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\resting.tga", text = "Set Hearthstone" },
  [9] = { path = "Interface\\Minimap\\TRACKING\\Innkeeper", text = "Use Hearthstone" },
  [10] = { path = "Interface\\Minimap\\TRACKING\\Ammunition", text = "Kill NPC" },
  [11] = { path = "Interface\\Minimap\\TRACKING\\FlightMaster", text = "Fly to" },
  [12] = { path = "Interface\\Minimap\\TRACKING\\StableMaster", text = "Travel to" },
  [13] = { path = "Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\waves.tga", text = "Boat to" },
  [14] = { path = "Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\accept_g.tga", text = "Too High Level" },
  [15] = { path = "Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\turnin_g.tga", text = "Too High Level" },
  [16] = { path = "Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\accept_d.tga", text = "Accept Daily" },
  [17] = { path = "Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\turnin_d.tga", text = "Turn in Daily" },
  [18] = { path = "Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\dungeon.tga", text = "Use Dungeon Finder" },
}
--[[
mt = {}
setmetatable(icontbl, mt)
function mt._index(t,key)
   --if key == 'length' then return string.len(t.value) end
DebugPrint("META T:"..t.."META KEY:"..key)
end
--]]
function DugisGuideViewer:getIcon(objectiveType, i)
  local isDaily, isDungeon, isTooHigh, reqLevel
  reqLevel = DugisGuideViewer:GetReqQuestLevel(self.qid[i])
  if (DugisGuideViewer.daily[i]) then isDaily = true end
  if (DugisGuideViewer:ReturnTag("I", i)) then isDungeon = true end
  if reqLevel and reqLevel > UnitLevel("player") then isTooHigh = true end
  if isTooHigh and objectiveType == "A" then
    return "Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\accept_g.tga"
  elseif isTooHigh and objectiveType == "T" then
    return "Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\turnin_g.tga"
  elseif isDaily and objectiveType == "A" then
    return "Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\accept_d.tga"
  elseif isDaily and objectiveType == "T" then
    return "Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\turnin_d.tga"
  elseif isDungeon then
    return "Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\dungeon.tga"
  elseif (objectiveType == "A") then
    return "Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\accept.tga"
  elseif (objectiveType == "C") then
    return "Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\cog.tga"
  elseif (objectiveType == "T") then
    return "Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\turnin.tga"
  elseif (objectiveType == "G" or objectiveType == "R") then
    return "Interface\\Minimap\\TRACKING\\StableMaster"
  elseif (objectiveType == "F") then
    return "Interface\\Minimap\\TRACKING\\FlightMaster"
  elseif (objectiveType == "b") then
    return "Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\waves.tga"
  elseif (objectiveType == "H") then
    return "Interface\\Minimap\\TRACKING\\Innkeeper"
  elseif (objectiveType == "B") then
    return "Interface\\Minimap\\TRACKING\\Auctioneer"
  elseif (objectiveType == "U") then
    return "Interface\\Minimap\\TRACKING\\None"
  elseif (objectiveType == "h") then
    return "Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\resting.tga"
  elseif (objectiveType == "f") then
    return "Interface\\AddOns\\DugisGuideViewerZ\\Artwork\\flightpath.tga"
  elseif (objectiveType == "N") then
    return "Interface\\Minimap\\TRACKING\\Profession"
  else -- (objectiveType == "K" ) then
    return "Interface\\Minimap\\TRACKING\\Ammunition"
  end
end

--title: A string describing the zone and level range
--nextguide: (Optional) The next guide to load when this guide is completed
--faction:Values: Horde, Alliance or nil means both factions
--guidetype: Levling(L), Dailies(D) or Events(E) type of guide
--rowinfo: Containins the actual guide data
function DugisGuideViewer:RegisterGuide(title, nextguide, faction, guidetype, rowinfo)
  local myfaction = UnitFactionGroup("player") --No need to localize
  if faction == myfaction or faction == nil then
    --DebugPrint( "Title:"..title.."nextguide:"..nextguide.."faction:"..faction.."guidetype"..guidetype)
    self.guides[title] = rowinfo
    self.nextzones[title] = nextguide
    self.gtype[title] = guidetype
    table.insert(self.guidelist, title)
    if guidetype == "L" then
      if not self.guidelist["L"] then self.guidelist["L"] = {} end
      table.insert(self.guidelist["L"], title)
    end
    if guidetype == "D" then
      if not self.guidelist["D"] then self.guidelist["D"] = {} end
      table.insert(self.guidelist["D"], title)
    end
    if guidetype == "E" then
      if not self.guidelist["E"] then self.guidelist["E"] = {} end
      table.insert(self.guidelist["E"], title)
    end
    if guidetype == "I" then
      if not self.guidelist["I"] then self.guidelist["I"] = {} end
      table.insert(self.guidelist["I"], title)
    end
    if guidetype == "M" then
      if not self.guidelist["M"] then self.guidelist["M"] = {} end
      table.insert(self.guidelist["M"], title)
    end
    --[[if guidetype == "L" then
table.insert(self.Lguidelist, title)
end
if guidetype == "D" then
table.insert(self.Dguidelist, title)
end
if guidetype == "E" then
table.insert(self.Eguidelist, title)
end
if guidetype == "I" then
table.insert(self.Iguidelist, title)
end
if guidetype == "M" then
table.insert(self.Mguidelist, title)
end--]]
    --DebugPrint( "Title: "..title.."rowinfo: "..self.guides[title])
  end
  --DebugPrint("guidename: "..title.."guidetype: "..guidetype.."Length of table is: "..#self.Eguidelist)
end

--Return a table of current coordinates from the Note tag
function DugisGuideViewer:getCoords()
  local XVals = {}
  local YVals = {}
  local note = DugisGuideViewer.quests2[CurrentQuestIndex]
  --local _, _, coord2, coord3 = tag:find("(%d+%.?%d*)%s-,%s-(%d+%.?%d*)")
  for x, y in note:gmatch("%(([%d.]+),%s?([%d.]+)%)") do
    DebugPrint(x .. "in testag:" .. y)
    table.insert(XVals, tonumber(x))
    table.insert(YVals, tonumber(y))
  end
  return XVals, YVals
end

function DugisGuideViewer:Retxyz(t, i)
  if i == 1 and t == "AAA" then
    on = true
    t = ""
  elseif i == 1 then
    on = false
  end
  if on then
    local textd = ""
    local chard
    local data = 0
    for j = 1, #t do
      local c = t:sub(j, j)
      local cb = string.byte(c, 1)
      local k = 3
      chard = ""
      if cb < 128 - k then
        chard = string.char(cb + k)
      elseif cb < 192 then
        local joined = bit.bor(bit.band(63, cb), data)
        joined = joined + k
        local upper2 = bit.bor(bit.rshift(bit.band(192, joined), 6), 192)
        local lower2 = bit.bor(bit.band(63, joined), 128)
        chard = string.char(upper2) .. string.char(lower2)
      elseif cb < 224 and cb > 193 then
        data = bit.lshift(bit.band(3, cb), 6)
      else
        DebugPrint("Range Err")
      end
      textd = textd .. chard
    end
    t = textd
  end
  return t
end

--Parse rows and fill up 3 items: Objective type (actions), Quest name, Note Tag (actions, quests, tags)
function DugisGuideViewer:ParseRows(guidetitle, rowinfo, ...)
  local index
  local tmp
  local indx = 1
  local on
  local myClass = DugisGuideViewer:revlocalize(UnitClass("player"), "CLASS")
  local myRace = DugisGuideViewer:revlocalize(UnitRace("player"), "RACE")
  --DebugPrint("myClassEN="..myClass.."myClassLOC="..UnitClass("player").."myRaceEN="..myRace.."myRaceLOC="..UnitRace("player"))
  --Clear old data from tables
  local key, value
  for key, value in pairs(DugisGuideViewer.actions) do
    DugisGuideViewer.actions[key] = nil
  end
  for key, value in pairs(DugisGuideViewer.quests1) do
    DugisGuideViewer.quests1[key] = nil
  end
  for key, value in pairs(DugisGuideViewer.quests1L) do
    DugisGuideViewer.quests1L[key] = nil
  end
  for key, value in pairs(DugisGuideViewer.quests2) do
    DugisGuideViewer.quests2[key] = nil
  end
  --Loop through all rows
  for i = 1, select("#", ...) do
    local text = select(i, ...)
    text = self:Retxyz(text, i)
    local _, _, classes = text:find("|C|([^|]+)|")
    local _, _, races = text:find("|R|([^|]+)|")
    local _, _, daily = text:find("(|D|)")
    if text ~= "" and (not classes or classes:find(myClass)) and (not races or races:find(myRace)) then
      local _, _, action, quest, tag = text:find("^(%a) ([^|]*)(.*)") --local _, _, action, quest, tag = text:find("([^ ]*) - ([^|]*)(.*)")
      action = action:trim()
      quest = quest:trim()
      --Find Use items
      local _, _, useitem = tag:find("|U|([^|]+)|") --tag:find("|Use=([^|]*)")
      DugisGuideViewer.useitem[indx] = useitem
      --If there is a second objective line, retrieve that
      questtest = tag
      local _, _, questtest = questtest:find("|N|([^|]+)|") --questtest:find("|Note=([^|]*)")
      if questtest then
        --DebugPrint("questtest is"..questtest)
        quest2 = questtest
      else
        quest2 = ""
      end
      local _, _, qid = tag:find("|QID|([^|]+)|") --tag:find("|QuestID=([^|]*)")
      qid = tonumber(qid)
      -- For dungeon guides, extract just the integer part of quest ID (ignore decimal sub-objectives)
      if qid and qid ~= math.floor(qid) then
        qid = math.floor(qid)
      end
      --DebugPrint("action:"..action.."quest:"..quest)
      DugisGuideViewer.actions[indx] = action:trim()
      DugisGuideViewer.quests1[indx] = quest:trim()
      DugisGuideViewer.quests1L[indx] = quest:trim()
      DugisGuideViewer.quests2[indx] = quest2:trim()
      DugisGuideViewer.tags[indx] = tag
      DugisGuideViewer.qid[indx] = qid
      DugisGuideViewer.daily[indx] = daily
      indx = indx + 1
    end
  end
end

function DugisGuideViewer:InBag(itemid)
  if itemid then
    for bag = 0, 4 do
      for slot = 1, GetContainerNumSlots(bag) do
        local item = GetContainerItemLink(bag, slot)
        --if item and string.find(item, "item:"..itemid) then return bag, slot end
        if item and string.find(item, "item:" .. itemid) then return true end
      end
    end
  end
  return false
end

--Load a guide from a tab
function DugisGuideViewer_TabRow_OnEvent(self, event, ...)
  local rowtitle
  rowtitle = getglobal(self:GetName() .. "Title"):GetText()
  if rowtitle ~= L["No Guide Loaded"] then
    if (self:GetParent():GetName() == "DGVTabFrame4") then
      local Dframe = getglobal("DGV_DungeonFrame")
      Dframe:ClearAllPoints()
      Dframe:SetPoint("CENTER")
      Dframe:SetWidth(820)
      Dframe:SetHeight(554)
      local SF = getglobal("WGEditScrollFrame")
      SF:ClearAllPoints()
      SF:SetPoint("TOPLEFT", Dframe, "TOPLEFT", 15, -31)
      SF:SetPoint("BOTTOMRIGHT", Dframe, "BOTTOMRIGHT", -35, 10)
      WGEditBox:SetAllPoints(SF)
      WGEditScrollFrameScrollBar:SetFrameStrata("LOW")
      rowtitle = DugisGuideViewer:revlocalize(rowtitle, "GUIDE")
      WGEditBox:SetText(DugisGuideViewer.guides[rowtitle]())
      UIFrameFadeIn(DGV_DungeonFrame, 0.5, 0, 1)
    else
      DugisGuideViewer:DisplayViewTab(DugisGuideViewer:revlocalize(rowtitle, "GUIDE"))
      PanelTemplates_SetTab(Dugis, 1);
    end
  end
end

function DugisGuideViewer:SaveLastScrollBar(lasttab)
  SliderVal[lasttab] = Dugis_VSlider:GetValue()
end

function DugisGuideViewer:RestoreScrollBar(currenttab)
  Dugis_VSlider:SetValue(SliderVal[currenttab])
  Dugis_VSlider:SetMinMaxValues(1, SliderMax[currenttab])
end

function DugisGuideViewer:InitViewTab()
  DugisGuideViewer:ShowTab(1)
  --getglobal("RecapPanelDetail1Chk"):Hide()
end

function DugisGuideViewer:ShowViewTab()
  DugisGuideViewer:ShowTab(1)
end

function DugisGuideViewer:CurrentTab()
  for i = 1, #tabs do
    if tabs[i].frame:IsShown() then return i end
  end
end

function DugisGuideViewer:ShowTab(tabnum)
  local DGV = self
  DGV:SaveLastScrollBar(DGV:CurrentTab())
  --Hide all
  for i = 1, #tabs do
    tabs[i].frame:Hide()
    _G["DugisTab" .. i .. "Title"]:Hide()
    _G["DugisTab" .. i .. "Desc"]:Hide()
  end
  if tabnum == 1 then
    DugisReloadButton:Show()
    DugisResetButton:Show()
    DugisPercentButton:Show()
  else
    DugisReloadButton:Hide()
    DugisResetButton:Hide()
    DugisPercentButton:Hide()
  end
  --Show tabnum
  _G["DugisTab" .. tabnum .. "Title"]:Show()
  _G["DugisTab" .. tabnum .. "Desc"]:Show()
  tabs[tabnum].frame:Show()
  Dugis:SetScrollChild(tabs[tabnum].frame:GetName())
  DugisGuideViewer:RestoreScrollBar(tabnum)
  DugisGuideViewer:SetAllPercents()
end

function DugisGuideViewer:SetViewTabTitle(title)
  getglobal("DugisTab1Title"):SetText(title)
end

function DugisGuideViewer:SetSmallFrameText(text)
  getglobal("SmallFrameDetail1Name"):SetText(text)
end

function DugisGuideViewer:ClearScreen()
  DugisGuideViewer:SetViewTabTitle(L["No Guide Loaded"])
  DugisGuideViewer:InitSmallFrame(L["No Guide Loaded. Click Here To Select One"], "Interface\\Minimap\\TRACKING\\Class")
  DugisGuideViewer:WipeOutViewTab()
end

--Fill screen with 3 items: Objective type (actions), Quest name, Note Tag (actions, quests, tags)
function DugisGuideViewer:PopulateScreen(title)
  local name = "RecapPanelDetail"
  local numrows = 0
  local rowspacing = 0
  crowheight = 34.4
  local optional, LOptional
  --Clear any old data
  for i = 1, LastGuideNumRows do
    getglobal("RecapPanelDetail" .. i):Hide()
    getglobal("RecapPanelDetail" .. i):SetNormalTexture("")
    DugisGuideViewer:SetQuestTextNormal(i)
  end
  DugisGuideViewer:SetViewTabTitle(DugisGuideViewer:localize(title, "GUIDE"))
  for i = 1, #DugisGuideViewer.actions do
    if i ~= 1 and getglobal("RecapPanelDetail" .. i) == nil then
      local b = CreateFrame("Button", "RecapPanelDetail" .. i, DGVTabFrame1, "RecapPanelDetailTemplate");
      b:SetPoint("TOP", "RecapPanelDetail" .. i - 1, "BOTTOM", "0", rowspacing)
    end
    getglobal("RecapPanelDetail" .. i .. "Chk"):Enable()
    getglobal("RecapPanelDetail" .. i .. "Chk"):SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
    getglobal("RecapPanelDetail" .. i .. "Chk"):SetChecked(0)
    getglobal("RecapPanelDetail" .. i .. "Chk"):Show()
    getglobal("RecapPanelDetail" .. i .. "Button"):SetNormalTexture(DugisGuideViewer:getIcon(DugisGuideViewer.actions[i],
      i))
    DugisGuideViewer:SetQuestText(i)
    DugisGuideViewer:SetQuestColor(i)
    getglobal("RecapPanelDetail" .. i):Show()
    numrows = numrows + 1
  end
  local fwidth = DugisGuideViewer:GetFontWidth(L["Reload"])
  DugisReloadButton:SetText(L["Reload"])
  DugisReloadButton:SetWidth(fwidth + 20)
  local fwidth = DugisGuideViewer:GetFontWidth(L["Reset"])
  DugisResetButton:SetText(L["Reset"])
  DugisResetButton:SetWidth(fwidth + 20)
  SliderMax[1] = (crowheight * numrows)
  getglobal("Dugis_VSlider"):SetMinMaxValues(1, SliderMax[1])
  LastGuideNumRows = numrows
end

function DugisGuideViewer:SetQuestText(i)
  local frame = getglobal("DugisSmallFrame")
  local fontstring = frame:CreateFontString("tmpfontstr", "ARTWORK", "GameFontNormal")
  local qName = DugisGuideViewer.quests1L[i]
  local level = DugisGuideViewer:GetQuestLevel(self.qid[i])
  if level and strmatch(self.actions[i], "[ACT]") and self:GetFlag("QuestLevelOn") then
    qName = "[" .. level ..
        "] " .. qName
  end
  fontstring:SetText(qName)
  local width = fontstring:GetStringWidth()
  getglobal("RecapPanelDetail" .. i .. "Name"):SetWidth(width + 10)
  getglobal("RecapPanelDetail" .. i .. "Name"):SetText(qName)
  getglobal("RecapPanelDetail" .. i .. "Desc"):SetText(DugisGuideViewer.quests2[i])
  local optional = DugisGuideViewer:ReturnTag("O", i)
  if optional then
    LOptional = " (" .. L["Optional"] .. ")"
    getglobal("RecapPanelDetail" .. i .. "Opt"):SetText(LOptional)
  else
    LOptional = ""
  end
end

function TabRowClickHandlerOnEnter(self, event, ...)
  name = self:GetName() .. "Title"
  --getglobal(name):SetFontObject("GameFontNormal")
end

function TabRowClickHandlerOnLeave(self, event, ...)
  name = self:GetName() .. "Title"
  --getglobal(name):SetFontObject("GameFontHighlight")
end

function DugisGuideViewer:PopulateTabs()
  local xofs = 10
  local yofs = -5
  local rowheight = 14
  local i
  local b
  --Tab rows
  for i = 1, #tabs - 1 do
    getglobal("DugisTab" .. i):SetText(L[tabs[i].text])
    getglobal("DugisTab" .. i .. "Title"):SetText(L[tabs[i].title])
    getglobal("DugisTab" .. i .. "Desc"):SetText(L[tabs[i].desc])
    getglobal("DugisTab" .. i .. "Desc"):SetWidth(500)
    local gtype = tabs[i].guidetype
    if gtype and DugisGuideViewer.guidelist[gtype] then
      for j = 1, #DugisGuideViewer.guidelist[gtype] do
        b = CreateFrame("Button", "DugisTab" .. i .. "Row" .. j, _G["DGVTabFrame" .. i], "ButtonTabRowTemplate")
        if j == 1 then
          b:SetPoint("TOPLEFT", "DGVTabFrame" .. i, "TOPLEFT", xofs, "-5")
        else
          b:SetPoint("TOPLEFT",
            "DugisTab" .. i .. "Row" .. j - 1, "BOTTOMLEFT", "0", yofs)
        end
        getglobal("DugisTab" .. i .. "Row" .. j .. "Title"):SetText(DugisGuideViewer:localize(
          DugisGuideViewer.guidelist[gtype][j], "GUIDE"))
        getglobal("DugisTab" .. i .. "Row" .. j .. "Title"):Show()
      end
      SliderMax[i] = rowheight * #DugisGuideViewer.guidelist[gtype] + 50
    end
    if gtype and not DugisGuideViewer.guidelist[gtype] then
      b = CreateFrame("Button", "DugisTab" .. i .. "Row1", _G["DGVTabFrame" .. i], "ButtonTabRowTemplate")
      b:SetPoint("TOPLEFT", "DGVTabFrame" .. i, "TOPLEFT", xofs, "-5")
      getglobal("DugisTab" .. i .. "Row1Title"):SetText(L["No Guide Loaded"])
      getglobal("DugisTab" .. i .. "Row1Title"):Show()
    end
  end
  --Settings Frame
  local tabi = 7
  _G["DugisTab" .. tabi .. "Title"]:SetText(L[tabs[tabi].title])
  _G["DugisTab" .. tabi .. "Desc"]:SetText(L[tabs[tabi].desc])
  _G["DugisTab" .. tabi]:SetText(L[tabs[tabi].text])
  for i = 1, self.db.char.settings.sz do
    local chkBox = CreateFrame("CheckButton", "DGV.ChkBox" .. i, _G["DGVTabFrame" .. tabi],
      "InterfaceOptionsCheckButtonTemplate")
    if i == 1 then
      chkBox:SetPoint("TOPLEFT", "DGVTabFrame" .. tabi, "TOPLEFT", "40", "-10")
    elseif i == 5 then
      chkBox:SetPoint("TOPLEFT", "DGV.ChkBox1", "TOPLEFT", "250", "0")
    else
      chkBox:SetPoint("TOPLEFT", "DGV.ChkBox" .. (i - 1), "BOTTOMLEFT", "0", "-10")
    end
    local chkBoxText = getglobal(chkBox:GetName() .. "Text")
    chkBoxText:SetText(L[self.db.char.settings[i].text])
    chkBox:SetHitRectInsets(0, -200, 0, 0)
    chkBox:SetChecked(self.db.char.settings[i].checked)
    chkBox:RegisterForClicks("LeftButtonDown")
    chkBox:SetScript("OnClick", function() DugisGuideViewer:SettingFrameChkOnClick(chkBox) end)
    chkBox:SetScript("OnEnter", function() DugisGuideViewer:SettingsTooltip_OnEnter(chkBox, event) end)
    chkBox:SetScript("OnLeave", function() DugisGuideViewer:SettingsTooltip_OnLeave(chkBox, event) end)
  end
  local button = CreateFrame("Button", "DGV_ResetFramesButton", _G["DGVTabFrame" .. tabi], "UIPanelButtonTemplate")
  local buttext = L["Reset Frames Position"]
  local fontstring = DugisSmallFrame:CreateFontString("tmpfontstr", "ARTWORK", "GameFontHighlight")
  fontstring:SetText(buttext)
  local fontwidth = fontstring:GetStringWidth()
  button:SetText(buttext)
  button:SetWidth(fontwidth + 30)
  button:SetHeight(20)
  button:SetPoint("TOPLEFT", "DGV.ChkBox" .. self.db.char.settings.sz, "BOTTOMLEFT", "0", "0")
  button:RegisterForClicks("LeftButtonDown")
  button:SetScript("OnClick", function() DugisGuideViewer:InitFramePositions() end)
  local wrow1 = 0
  local wrow2 = 0
  local wrow3 = 0
  local wmax = 0
  for i = 1, 18 do
    local width = self:GetFontWidth(L[icontbl[i].text])
    if width > wmax then wmax = width end
    if i == 6 then
      wrow1 = wmax
      wmax = 0
    elseif i == 12 then
      wrow2 = wmax
      wmax = 0
    elseif i == 18 then
      wrow3 = wmax
      wmax = 0
    end
  end
  for i = 1, 18 do
    local icon = CreateFrame("Button", "DGV_Settingsicon" .. i, _G["DGVTabFrame" .. tabi], "IconReferenceTemplate")
    local icon_text = getglobal("DGV_Settingsicon" .. i .. "Name")
    local icon_pic = getglobal("DGV_Settingsicon" .. i .. "Button")
    icon_pic:SetNormalTexture(icontbl[i].path)
    icon_text:SetText(L[icontbl[i].text])
    icon_text:SetJustifyH("LEFT")
    if i < 7 then
      icon:SetWidth(wrow1 + 50)
      icon_text:SetWidth(wrow1)
    elseif i < 13 then
      icon:SetWidth(wrow2 + 50)
      icon_text:SetWidth(wrow2)
    elseif i < 19 then
      icon:SetWidth(wrow3 + 50)
      icon_text:SetWidth(wrow3)
    end
    if i == 1 then
      icon:SetPoint("TOPLEFT", "DGV.ChkBox4", "BOTTOMLEFT", -20, -10)
    elseif i == 7 then
      icon:SetPoint("LEFT", "DGV_Settingsicon1", "RIGHT", -15, 0)
    elseif i == 13 then
      icon:SetPoint("LEFT", "DGV_Settingsicon7", "RIGHT", -15, 0)
    else
      icon:SetPoint("TOP", "DGV_Settingsicon" .. (i - 1), "BOTTOM", 0, 10)
    end
  end
end

function DugisGuideViewer:GetFlag(name)
  local DGVsettings = self.db.char.settings
  if name == "QuestLevelOn" then
    return DGVsettings[1].checked
  elseif name == "LargeFrameLocked" then
    return DGVsettings[3].checked
  elseif name == "ShowSmallFrame" then
    return DGVsettings[4].checked
  elseif name == "WaypointsOn" then
    return DGVsettings[5].checked
  elseif name == "ManualMode" then
    return DGVsettings[6].checked
  elseif name == "ItemButtonOn" then
    return DGVsettings[7].checked
  elseif name == "EnableQW" then
    return DGVsettings[8].checked
  end
end

function DugisGuideViewer:SettingFrameChkOnClick(box)
  local DGVsettings = self.db.char.settings
  for i = 1, DGVsettings.sz do
    if getglobal("DGV.ChkBox" .. i):GetChecked() then self.db.char.settings[i].checked = true else self.db.char.settings[i].checked = false end
  end
  --Quest Level On
  if DugisGuideViewer:GetFlag("QuestLevelOn") then
    --DebugPrint("Quest Level on")
    DugisGuideViewer:ViewFrameUpdate()
    DugisGuideViewer:PopulateSmallFrame(CurrentQuestIndex)
  else
    --DebugPrint("Quest Level off")
    DugisGuideViewer:ViewFrameUpdate()
    DugisGuideViewer:PopulateSmallFrame(CurrentQuestIndex)
  end
  --Large Frame Lock
  if DugisGuideViewer:GetFlag("LargeFrameLocked") then
    --DebugPrint("Large Frame Lock")
    DugisMainframe:EnableMouse(false)
    DugisMainframe:SetMovable(false)
  else
    --DebugPrint("Large Frame UNLock")
    DugisMainframe:EnableMouse(true)
    DugisMainframe:SetMovable(true)
  end
  --Show Small Frame
  if DugisGuideViewer:GetFlag("ShowSmallFrame") then
    --DugisGuideViewer:PopulateSmallFrame(CurrentQuestIndex)
    DugisSmallFrame:Show()
  else
    DugisSmallFrame:Hide()
  end
  if DugisGuideViewer:GetFlag("ItemButtonOn") then
    self:SetUseItem(self.useitem[CurrentQuestIndex])
  else
    DugisGuideViewerItemFrame:Hide()
  end
  --[[
if self:GetFlag("EnableQW") then
--InterfaceOptionsObjectivesPanelAutoQuestTracking:SetChecked(self.db.char.settings.autoquestwatch)
--InterfaceOptionsObjectivesPanelAutoQuestTracking:SetChecked(true)
--AUTO_QUEST_WATCH = 1
--SetCVar("autoQuestWatch", "1","AUTO_QUEST_WATCH_TEXT")
local setting = uvarInfo["AUTO_QUEST_WATCH"]
DebugPrint("get cvar: "..GetCVar(setting.cvar))
(setting.cvar,"1")
DebugPrint("Enabling AQW\nSetting.cvar = "..setting.cvar)
DebugPrint("Setting.val = "..GetCVar(setting.cvar))
DebugPrint("Setting.event = "..setting.event)
InterfaceOptionsOptionsFrame_RefreshCategories ()
local self = getglobal("InterfaceOptionsFrameOkay")
InterfaceOptionsFrameOkay_OnClick (nil, nil, true)
else
--InterfaceOptionsObjectivesPanelAutoQuestTracking:SetChecked(false)
--AUTO_QUEST_WATCH = 0
--SetCVar("autoQuestWatch", "0", "AUTO_QUEST_WATCH_TEXT")
InterfaceOptionsFrameOkay_OnClick ()
local setting = uvarInfo["AUTO_QUEST_WATCH"]
DebugPrint("get cvar: "..GetCVar(setting.cvar))
SetCVar(setting.cvar,"0")
DebugPrint("Disabling AQW\nSetting.cvar = "..setting.cvar)
DebugPrint("Setting.val = "..GetCVar(setting.cvar))
DebugPrint("Setting.event = "..setting.event)
InterfaceOptionsOptionsFrame_RefreshCategories ()
local self = getglobal("InterfaceOptionsFrameOkay")
InterfaceOptionsFrameOkay_OnClick ()
end
WatchFrame_Update()
--]]
end

function DugisGuideViewer:SettingsTooltip_OnEnter(chk, event)
  --name = self:GetName()
  local _, _, boxindex = chk:GetName():find("DGV.ChkBox([%d]*)")
  boxindex = tonumber(boxindex)
  local DGVsettings = self.db.char.settings
  if DGVsettings[boxindex].tooltip ~= "\"\"" then
    GameTooltip:SetOwner(chk, "ANCHOR_BOTTOMLEFT")
    GameTooltip:AddLine(L[DGVsettings[boxindex].tooltip], 1, 1, 1, 1, true)
    GameTooltip:Show()
    GameTooltip:ClearAllPoints()
    GameTooltip:SetPoint("BOTTOMLEFT", chk, "TOPLEFT", 25, 0)
  end
end

function DugisGuideViewer:SettingsTooltip_OnLeave(self, event)
  GameTooltip:Hide()
end

function DugisGuideViewer:OnDragStart(frame)
  if (not self.db.char.settings[2].checked) then
    frame:StartMoving();
    frame.isMoving = true;
  end
end

function DugisGuideViewer:OnDragStop(self)
  self:StopMovingOrSizing();
  self.isMoving = false;
end

SLASH_DG1 = "/dg"
SlashCmdList["DG"] = function(msg)
  if msg == "" then -- "/dg" command
    if SmallFrameDetail1:IsVisible() == 1 then
      print("|cff11ff11" .. "Dugis Guide Off")
      DugisGuideViewer:HideAll()
    else
      print("|cff11ff11" .. "Dugis Guide On")
      DugisGuideViewer:ShowAll()
    end
  elseif msg == "reset" then --"/dg reset" command
    print("|cff11ff11" .. "Dugis Frame Reset")
    DugisGuideViewer:InitFramePositions()
  elseif msg == "fix" then
    print("|cff11ff11" .. "Dugis Clear Variables")
    DugisGuideViewer:ClearScreen()
    CurrentTitle = nil
    CurrentQuestIndex = nil
    CurrentQuestName = nil
    DugisGuideUser = {
      ["toskip"] = {},
      ["QuestState"] = {},
      ["turnedinquests"] = {},
    }
    DugisGuideViewerDB = nil
  end
end
function DugisGuideViewer:RemoveParen(text)
  local _, _, noparen = text:find("([^%(]*)")
  noparen = noparen:trim()
  return noparen
end

function DugisGuideViewer:HideAll()
  DugisGuideViewer:HideLargeWindow()
  DugisSmallFrame:Hide()
end

function DugisGuideViewer:ShowAll()
  DugisGuideViewer:ShowLargeWindow()
  DugisSmallFrame:Show()
end

if not DelayFrame then
  DelayFrame = CreateFrame("Frame")
  DelayFrame:Hide()
end
function DelayandMoveToNextQuest(delay, func)
  DelayFrame.func = func
  DelayFrame.delay = delay
  DelayFrame:Show()
end

DelayFrame:SetScript("OnUpdate", function(self, elapsed)
  self.delay = self.delay - elapsed
  if self.delay <= 0 then
    self:Hide()
    --self.func()
    DugisGuideViewer:MoveToNextQuest()
  end
end)
if not DelayFrame2 then
  DelayFrame2 = CreateFrame("Frame")
  DelayFrame2:Hide()
end
function Delay(delay)
  DelayFrame2.delay = delay
  DelayFrame:Show()
end

DelayFrame2:SetScript("OnUpdate", function(self, elapsed)
  self.delay = self.delay - elapsed
  if self.delay <= 0 then
    self:Hide()
  end
end)
--self:GimmeTag("QuestObjective")
function DugisGuideViewer:IsQuestObjectiveComplete(qi, questtext)
  for i = 1, GetNumQuestLeaderBoards(qi) do if GetQuestLogLeaderBoard(i, qi) == questtext then return true end end
end

local orig = AbandonQuest
function AbandonQuest(...)
  DebugPrint("AbandonQuest()")
  local i = GetQuestLogSelection()
  AbandonQID = select(9, GetQuestLogTitle(i))
  DebugPrint("Clicked abandon on" .. AbandonQID)
  return orig(...)
end

local togglewatch = {}
--[[local addqworig = AddQuestWatch
function AddQuestWatch(...)
DebugPrint("In AddQuestWatch() *****")
local i = select(1, ...)
if togglewatch[i] == true then DebugPrint("togglewatch is true") elseif togglewatch[i] == false then DebugPrint("togglewatch is false") else DebugPrint("togglewatch is nil") end
if (togglewatch[i] == true) then
DebugPrint("add watch#" ..select(1, GetQuestLogTitle(GetQuestLogSelection())))
return addqworig(...)
elseif ((not DugisGuideViewer:GetFlag("EnableQW")) and togglewatch[i] == nil) or togglewatch[i] == false then
DebugPrint("remove watch#" ..select(1, GetQuestLogTitle(GetQuestLogSelection()))) RemoveQuestWatch( i )
end
--QuestLog_Update();
--WatchFrame_Update()
togglewatch[i] = nil
DebugPrint("***")
--if DugisGuideViewer:GetFlag("EnableQW") or addwatch then addwatch = nil return addqworig(...) else RemoveQuestWatch( GetQuestLogSelection()) end
--return addqworig(...)
end
--]]
--Called after Toggle quest watch button is clicked
--[[QuestLogFrameTrackButton:HookScript("OnClick", function(...)
--QuestLog_Update();
local i = GetQuestLogSelection()
--local questCheck = getglobal("QuestLogTitleButton"..i)
WatchFrame_Update()
DebugPrint("In QuestLogFrameTrackButton() ***")
--if not IsQuestWatched(i)  then
if not WatchFrame_GetVisibleIndex(i) then
DebugPrint("Add Quest Watch #:"..select(1, GetQuestLogTitle(i)))
togglewatch[i] = true
--AddQuestWatch(i)
else
DebugPrint("Remove Quest Watch #:"..select(1, GetQuestLogTitle(i)))
togglewatch[i] = false
--RemoveQuestWatch( i )
end
--QuestLog_Update()
WatchFrame_Update()
DebugPrint("***")
end)
--]]
--Called after AddQuestWatch
--[[function Dugis_AddQuestWatch(...)
DebugPrint("In AddQuestWatch() *****")
local i = select(1, ...)
if togglewatch[i] == true then DebugPrint("togglewatch is true") elseif togglewatch[i] == false then DebugPrint("togglewatch is false") else DebugPrint("togglewatch is nil") end
if (togglewatch[i] == true) then
DebugPrint("add watch#" ..select(1, GetQuestLogTitle(GetQuestLogSelection())))
--return addqworig(...)
elseif ((not DugisGuideViewer:GetFlag("EnableQW")) and togglewatch[i] == nil) then
DebugPrint("remove watch#" ..select(1, GetQuestLogTitle(GetQuestLogSelection()))) RemoveQuestWatch( i )
end
--QuestLog_Update();
--WatchFrame_Update()
togglewatch[i] = nil
DebugPrint("***")
end
hooksecurefunc("AddQuestWatch", Dugis_AddQuestWatch);
--]]
--[[
function Dugis_QuestLogTitleButton_OnEvent( self, event, ...)
DebugPrint("title button on event")
end
--QuestLogTitleButton_OnEvent(self, event, ...)
hooksecurefunc("QuestLogTitleButton_OnEvent", Dugis_QuestLogTitleButton_OnEvent)
--]]
--Occurs BEFORE QuestFrameCompleteQuestButton OnClick (works with questguru, doesn't work with carbonite)
function Dugis_RewardComplete_Click()
  if IsAddOnLoaded("QuestGuru") then
    DebugPrint("Finished a quest, hooked QuestRewardCompleteButton_OnClick")
    local qid = DugisGuideViewer:GetQIDFromQuestName(GetTitleText())
    --Turning in a quest '!'
    --DebugPrint("turnin ="..turnin.."quest is"..quest.."*".."action ="..CurrentAction.."*")
    if CurrentAction and qid then
      DebugPrint("HOOK qid is" ..
        qid .. "*" .. "action =" .. CurrentAction .. "*" .. "titletext=" .. GetTitleText())
    end
    local acceptandcomplete = DugisGuideViewer:ReturnTag("E")
    if acceptandcomplete then DebugPrint("Detected accept and complete tag") end
    local _, _, questnoparen = DugisGuideViewer.quests1L[CurrentQuestIndex]:find("([^%(]*)")
    questnoparen = questnoparen:trim()
    if (CurrentAction == "T" and DugisGuideViewer.qid[CurrentQuestIndex] == qid) or (acceptandcomplete and GetTitleText() == L[questnoparen]) then
      DebugPrint("Detected curent quest turned in")
      DugisGuideViewer:SetChkToComplete(CurrentQuestIndex)
      DugisGuideViewer:MoveToNextQuest()
    else
      --not current quest but turned in by user anyway
      DugisGuideViewer:CompleteQID(qid, "T")
    end
    JustTurnedInQID = qid
  end
end

hooksecurefunc("QuestRewardCompleteButton_OnClick", Dugis_RewardComplete_Click);
--Occurs AFTER QuestFrameCompleteQuestButton OnClick (doesn't work with questguru, works with carbonite)
QuestFrameCompleteQuestButton:HookScript("OnClick", function(...)
  if (IsAddOnLoaded("QuestGuru") == nil) then
    DebugPrint("Finished a quest, HookScript QuestFrameCompleteQuestButton")
    local qid = DugisGuideViewer:GetQIDFromQuestName(GetTitleText())
    --Turning in a quest '!'
    --DebugPrint("turnin ="..turnin.."quest is"..quest.."*".."action ="..CurrentAction.."*")
    if CurrentAction and qid then
      DebugPrint("HOOK qid is" ..
        qid .. "*" .. "action =" .. CurrentAction .. "*" .. "titletext=" .. GetTitleText())
    end
    local acceptandcomplete = DugisGuideViewer:ReturnTag("E")
    if acceptandcomplete then DebugPrint("Detected accept and complete tag") end
    local _, _, questnoparen = DugisGuideViewer.quests1L[CurrentQuestIndex]:find("([^%(]*)")
    questnoparen = questnoparen:trim()
    if (CurrentAction == "T" and DugisGuideViewer.qid[CurrentQuestIndex] == qid) or (acceptandcomplete and GetTitleText() == L[questnoparen]) then
      DebugPrint("Detected curent quest turned in")
      DugisGuideViewer:SetChkToComplete(CurrentQuestIndex)
      DugisGuideViewer:MoveToNextQuest()
    else
      DugisGuideViewer:CompleteQID(qid, "T")
    end
    JustTurnedInQID = qid
  end
end)
function DugisGuideViewer:MinimizeDungeonMap()
  DGV_DungeonFrame:Hide()
  DugisSmallFrameMaximize:Show()
end
