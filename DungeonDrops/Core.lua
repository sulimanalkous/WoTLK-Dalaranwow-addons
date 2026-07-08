DungeonDrops = {}
DungeonDrops.version = "2.0.0"
DungeonDrops.addonName = "DungeonDrops"

local defaults = {
    enabled = true,
    showMinimapButton = false,
    notifyOnLevelUp = true,
    showOnlyUsable = true,
    minUpgradeScore = 5,
}

local frame = CreateFrame("Frame", "DungeonDropsFrame")

local INVENTORY_SLOTS = {
    ["Head"] = 1, ["Neck"] = 2, ["Shoulder"] = 3, ["Back"] = 15,
    ["Chest"] = 5, ["Wrist"] = 9, ["Hands"] = 10, ["Waist"] = 6,
    ["Legs"] = 7, ["Feet"] = 8, ["Finger1"] = 11, ["Finger2"] = 12,
    ["Trinket1"] = 13, ["Trinket2"] = 14, ["MainHand"] = 16,
    ["OffHand"] = 17, ["Ranged"] = 18,
}

local function OnEvent(self, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == "DungeonDrops" then
            DungeonDrops:Initialize()
        end
    elseif event == "PLAYER_LOGIN" then
        DungeonDrops:OnPlayerLogin()
    elseif event == "PLAYER_LEVEL_UP" then
        local newLevel = ...
        DungeonDrops:OnPlayerLevelUp(newLevel)
    elseif event == "CHARACTER_POINTS_CHANGED" then
        DungeonDrops:OnTalentsChanged()
    elseif event == "UNIT_INVENTORY_CHANGED" then
        local unit = ...
        if unit == "player" then
            DungeonDrops:OnGearChanged()
        end
    end
end

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_LEVEL_UP")
frame:RegisterEvent("CHARACTER_POINTS_CHANGED")
frame:RegisterEvent("UNIT_INVENTORY_CHANGED")
frame:SetScript("OnEvent", OnEvent)

function DungeonDrops:Initialize()
    if not DungeonDropsDB then
        DungeonDropsDB = CopyTable(defaults)
    else
        for key, value in pairs(defaults) do
            if DungeonDropsDB[key] == nil then
                DungeonDropsDB[key] = value
            end
        end
    end

    if not DungeonDropsCharDB then
        DungeonDropsCharDB = {}
    end

    DungeonDropsData:EnrichFromAtlasLoot()

    self:Print("DungeonDrops " .. self.version .. " loaded. Type /dd for commands.")
end

function DungeonDrops:GetCachedItemInfo(itemID)
    if self.itemCache and self.itemCache[itemID] then
        return self.itemCache[itemID]
    end
    if not itemID or itemID == 0 then return nil end
    local name, _, _, _, _, _, _, _, _, icon = GetItemInfo(itemID)
    if icon then
        return { name = name, icon = icon }
    end
    return nil
end

function DungeonDrops:OnPlayerLogin()
    self:RefreshPlayerInfo()
    DungeonDropsData:InitFromAtlasLoot()
    if DungeonDrops.ItemScanner then
        DungeonDrops.ItemScanner:Start()
    end
    if DungeonDropsDB.enabled then
        self:UpdateRecommendations()
    end
end

function DungeonDrops:OnPlayerLevelUp(newLevel)
    self.playerLevel = newLevel
    self:ScanGear()
    self:UpdateRecommendations()
    if DungeonDropsDB.notifyOnLevelUp then
        self:ShowLevelUpNotification()
    end
end

function DungeonDrops:OnTalentsChanged()
    self:DetectSpec()
    self:UpdateRecommendations()
end

function DungeonDrops:OnGearChanged()
    self:ScanGear()
    self:UpdateRecommendations()
end

function DungeonDrops:RefreshPlayerInfo()
    local _, playerClass = UnitClass("player")
    self.playerClass = playerClass
    self.playerLevel = UnitLevel("player")
    self:ScanGear()
    self:DetectSpec()
    self:BuildStatProfile()
end

-- Gear Scanning
function DungeonDrops:ScanGear()
    if not self.equipped then
        self.equipped = {}
    end
    for slotName, slotID in pairs(INVENTORY_SLOTS) do
        local link = GetInventoryItemLink("player", slotID)
        if link then
            local itemID = tonumber(link:match("item:(%d+)"))
            local itemName, _, quality, itemLevel = GetItemInfo(link)
            local stats = GetItemStats(link)
            self.equipped[slotName] = {
                id = itemID,
                name = itemName,
                ilvl = itemLevel or 1,
                quality = quality,
                link = link,
                stats = stats or {},
            }
        else
            self.equipped[slotName] = nil
        end
    end
end

-- Maps item slot names (from the DB) to the equipped[] keys (from INVENTORY_SLOTS)
local ITEM_SLOT_TO_EQUIPPED = {
    Ring              = "Finger1",
    Trinket           = "Trinket1",
    ["One-Hand Sword"]= "MainHand", ["One-Hand Mace"] = "MainHand", ["One-Hand Axe"] = "MainHand",
    ["Two-Hand Sword"]= "MainHand", ["Two-Hand Mace"] = "MainHand", ["Two-Hand Axe"] = "MainHand",
    ["Two-Hand Staff"]= "MainHand", Staff = "MainHand", Polearm = "MainHand",
    Dagger            = "MainHand", Fist = "MainHand",
    Shield            = "OffHand",  ["Off-Hand"] = "OffHand",
    Wand              = "Ranged",   Bow = "Ranged", Gun = "Ranged", Crossbow = "Ranged",
    Ranged            = "Ranged",   Totem = "Ranged", Relic = "Ranged",
}

function DungeonDrops:GetEquippedItem(slot)
    if not self.equipped then return nil end
    local mapped = ITEM_SLOT_TO_EQUIPPED[slot]
    if mapped then
        return self.equipped[mapped]
    end
    return self.equipped[slot]
end

-- Spec Detection
function DungeonDrops:DetectSpec()
    self.specs = {}
    local numTabs = GetNumTalentTabs()
    if not numTabs or numTabs == 0 then
        self.primarySpec = "No Talents"
        return
    end
    for tab = 1, numTabs do
        local name, _, spent = GetTalentTabInfo(tab)
        table.insert(self.specs, { name = name or "Unknown", spent = spent or 0, index = tab })
    end
    table.sort(self.specs, function(a, b) return a.spent > b.spent end)
    self.primarySpec = self.specs[1] and (self.specs[1].spent > 0 and self.specs[1].name or "No Talents") or "Unknown"
end

-- Full stat profiles per class+spec.
-- Positive = useful for this role, Negative = harmful/irrelevant (penalises wrong-role items).
-- playerStatProfile (set by BuildStatProfile) is public so other features can read it.
local STAT_PROFILES = {
    PRIEST = {
        default = {
            INT=1.5, SPI=1.0, SP=0.8, HASTE=0.7, CRIT=0.5, MP5=0.5, HIT=0.4, STA=0.2,
            DEFENSE=-3, DODGE=-3, PARRY=-3, BLOCK=-3, STR=-1.5, AP=-1.5, AGI=-0.8, ARMOR_PEN=-1.5, EXPERTISE=-1.5,
        },
        ["Holy"] = {
            INT=1.5, SPI=1.2, SP=0.9, HASTE=0.8, CRIT=0.6, MP5=0.7, HIT=0.2, STA=0.15,
            DEFENSE=-3, DODGE=-3, PARRY=-3, BLOCK=-3, STR=-1.5, AP=-1.5, AGI=-0.8, ARMOR_PEN=-1.5, EXPERTISE=-1.5,
        },
        ["Discipline"] = {
            INT=1.5, SPI=0.8, SP=1.0, HASTE=0.9, CRIT=0.7, MP5=0.5, HIT=0.3, STA=0.15,
            DEFENSE=-3, DODGE=-3, PARRY=-3, BLOCK=-3, STR=-1.5, AP=-1.5, AGI=-0.8, ARMOR_PEN=-1.5, EXPERTISE=-1.5,
        },
        ["Shadow"] = {
            INT=1.2, SPI=0.5, SP=1.0, HIT=1.0, CRIT=0.7, HASTE=0.8, STA=0.2,
            DEFENSE=-3, DODGE=-3, PARRY=-3, BLOCK=-3, STR=-1.5, AP=-1.5, AGI=-0.8, ARMOR_PEN=-1.5, EXPERTISE=-1.5,
        },
    },
    MAGE = {
        default = {
            INT=1.5, SPI=0.4, SP=1.0, HIT=1.0, HASTE=0.8, CRIT=0.7, STA=0.2,
            DEFENSE=-3, DODGE=-3, PARRY=-3, BLOCK=-3, STR=-1.5, AP=-1.5, AGI=-0.8, ARMOR_PEN=-1.5, EXPERTISE=-1.5,
        },
    },
    WARLOCK = {
        default = {
            INT=1.5, SPI=0.5, SP=1.0, HIT=1.0, HASTE=0.7, CRIT=0.6, STA=0.2,
            DEFENSE=-3, DODGE=-3, PARRY=-3, BLOCK=-3, STR=-1.5, AP=-1.5, AGI=-0.8, ARMOR_PEN=-1.5, EXPERTISE=-1.5,
        },
    },
    WARRIOR = {
        default = {
            STR=1.5, AP=0.8, HIT=0.9, CRIT=0.7, HASTE=0.5, EXPERTISE=0.7, ARMOR_PEN=0.6, STA=0.4,
            SP=-2, SPI=-1.5, INT=-0.5,
        },
        ["Arms"] = {
            STR=1.5, AP=0.8, ARMOR_PEN=1.0, HIT=0.9, CRIT=0.8, EXPERTISE=0.7, HASTE=0.5, STA=0.4,
            SP=-2, SPI=-1.5, INT=-0.5, DODGE=-0.5, BLOCK=-0.8, DEFENSE=-0.5, PARRY=-0.8,
        },
        ["Fury"] = {
            STR=1.5, AP=0.8, HASTE=0.9, HIT=0.9, CRIT=0.7, EXPERTISE=0.7, ARMOR_PEN=0.7, STA=0.4,
            SP=-2, SPI=-1.5, INT=-0.5, DODGE=-0.5, BLOCK=-1, DEFENSE=-0.5, PARRY=-0.5,
        },
        ["Protection"] = {
            STA=1.0, DEFENSE=1.5, DODGE=1.2, PARRY=1.2, BLOCK=1.0, STR=0.5, ARMOR_PEN=0.2,
            HIT=0.4, EXPERTISE=0.4, AP=0.3, SP=-2, SPI=-1.5, INT=-0.5,
        },
    },
    PALADIN = {
        default = {
            STR=1.0, AP=0.5, HIT=0.8, CRIT=0.6, HASTE=0.5, EXPERTISE=0.7, STA=0.4,
        },
        ["Holy"] = {
            INT=1.5, SPI=0.5, SP=1.0, HASTE=0.8, CRIT=0.7, MP5=0.6, STA=0.2,
            DEFENSE=-2, DODGE=-2, PARRY=-2, BLOCK=-2, STR=-0.5, AGI=-0.5, AP=-1, ARMOR_PEN=-1.5, EXPERTISE=-1.5,
        },
        ["Protection"] = {
            STA=1.0, DEFENSE=1.5, DODGE=1.2, PARRY=1.2, BLOCK=1.0, STR=0.5, INT=0.4, SPI=0.2,
            SP=-1, AGI=-0.5, ARMOR_PEN=-1.5,
        },
        ["Retribution"] = {
            STR=1.5, AP=0.8, HIT=0.9, CRIT=0.7, HASTE=0.7, EXPERTISE=0.7, STA=0.4, ARMOR_PEN=0.5,
            DEFENSE=-0.5, DODGE=-1, PARRY=-0.5, BLOCK=-1, AGI=-0.3, SPI=-0.3,
        },
    },
    HUNTER = {
        default = {
            AGI=1.5, AP=0.8, HIT=0.8, CRIT=0.7, HASTE=0.6, ARMOR_PEN=0.5, STA=0.3, INT=0.2,
            DEFENSE=-2, PARRY=-2, BLOCK=-2, SP=-2, SPI=-1, STR=-0.5,
        },
        ["Beast Mastery"] = {
            AGI=1.5, AP=0.9, HIT=0.8, CRIT=0.7, HASTE=0.6, ARMOR_PEN=0.4, STA=0.3, INT=0.2,
            DEFENSE=-2, PARRY=-2, BLOCK=-2, SP=-2, SPI=-1, STR=-0.5,
        },
        ["Marksmanship"] = {
            AGI=1.5, AP=0.8, HIT=0.9, CRIT=0.8, HASTE=0.6, ARMOR_PEN=0.6, STA=0.3, INT=0.2,
            DEFENSE=-2, PARRY=-2, BLOCK=-2, SP=-2, SPI=-1, STR=-0.5,
        },
        ["Survival"] = {
            AGI=1.5, AP=0.8, HIT=0.8, CRIT=0.9, ARMOR_PEN=0.7, HASTE=0.5, STA=0.3, INT=0.2,
            DEFENSE=-2, PARRY=-2, BLOCK=-2, SP=-2, SPI=-1, STR=-0.5,
        },
    },
    ROGUE = {
        default = {
            AGI=1.5, AP=0.8, HIT=0.9, CRIT=0.7, HASTE=0.6, EXPERTISE=0.7, ARMOR_PEN=0.6, STA=0.3,
            DEFENSE=-2, PARRY=-2, BLOCK=-2, SP=-2, SPI=-1.5, INT=-0.8,
        },
        ["Assassination"] = {
            AGI=1.5, AP=0.8, HIT=1.0, CRIT=0.7, HASTE=0.6, EXPERTISE=0.7, ARMOR_PEN=0.5, STA=0.3,
            DEFENSE=-2, PARRY=-2, BLOCK=-2, SP=-2, SPI=-1.5, INT=-0.8,
        },
        ["Combat"] = {
            AGI=1.5, AP=0.8, HIT=0.9, CRIT=0.7, HASTE=0.8, EXPERTISE=0.7, ARMOR_PEN=0.6, STA=0.3,
            DEFENSE=-2, PARRY=-2, BLOCK=-2, SP=-2, SPI=-1.5, INT=-0.8,
        },
        ["Subtlety"] = {
            AGI=1.5, AP=0.8, HIT=0.8, CRIT=0.7, ARMOR_PEN=0.7, HASTE=0.6, EXPERTISE=0.7, STA=0.3,
            DEFENSE=-2, PARRY=-2, BLOCK=-2, SP=-2, SPI=-1.5, INT=-0.8,
        },
    },
    SHAMAN = {
        default = {
            INT=1.2, SPI=0.4, SP=0.8, HIT=0.8, CRIT=0.6, HASTE=0.7, STA=0.3,
            PARRY=-2, BLOCK=-1,
        },
        ["Elemental"] = {
            INT=1.5, SPI=0.4, SP=1.0, HIT=0.9, CRIT=0.7, HASTE=0.8, STA=0.2,
            DEFENSE=-2, DODGE=-1, PARRY=-2, BLOCK=-2, STR=-0.5, AP=-1, ARMOR_PEN=-1.5, EXPERTISE=-1.5,
        },
        ["Enhancement"] = {
            AGI=1.2, STR=0.8, AP=0.8, HIT=0.8, CRIT=0.7, HASTE=0.7, EXPERTISE=0.6, STA=0.3, SP=0.3,
            DEFENSE=-1, PARRY=-1, BLOCK=-1, ARMOR_PEN=0.3,
        },
        ["Restoration"] = {
            INT=1.5, SPI=0.8, SP=1.0, HASTE=0.8, CRIT=0.6, MP5=0.7, STA=0.2,
            DEFENSE=-2, DODGE=-2, PARRY=-2, BLOCK=-2, STR=-1, AGI=-0.5, AP=-1, ARMOR_PEN=-1.5, EXPERTISE=-1.5,
        },
    },
    DRUID = {
        default = {
            INT=0.8, AGI=0.6, STR=0.6, SPI=0.5, HIT=0.7, CRIT=0.6, HASTE=0.5, STA=0.3,
        },
        ["Balance"] = {
            INT=1.5, SPI=0.5, SP=1.0, HIT=0.9, CRIT=0.7, HASTE=0.8, STA=0.2,
            DEFENSE=-2, DODGE=-1, PARRY=-2, BLOCK=-2, STR=-0.5, AP=-1, ARMOR_PEN=-1.5, EXPERTISE=-1.5,
        },
        ["Feral Combat"] = {
            AGI=1.5, STR=1.0, AP=0.8, CRIT=0.7, HIT=0.7, ARMOR_PEN=0.6, STA=0.3,
            SP=-1.5, SPI=-0.5, INT=-0.3, PARRY=-2, BLOCK=-2,
        },
        ["Restoration"] = {
            INT=1.5, SPI=0.8, SP=1.0, HASTE=0.8, CRIT=0.6, MP5=0.7, STA=0.2,
            DEFENSE=-2, DODGE=-2, PARRY=-2, BLOCK=-2, STR=-1, AGI=-0.3, AP=-1, ARMOR_PEN=-1.5, EXPERTISE=-1.5,
        },
    },
    DEATHKNIGHT = {
        default = {
            STR=1.5, AP=0.8, HIT=0.8, CRIT=0.6, HASTE=0.5, EXPERTISE=0.7, ARMOR_PEN=0.6, STA=0.5,
            SP=-2, SPI=-1.5, INT=-0.5,
        },
        ["Blood"] = {
            STR=1.5, AP=0.8, ARMOR_PEN=0.8, HIT=0.8, CRIT=0.7, EXPERTISE=0.7, HASTE=0.5, STA=0.5,
            SP=-2, SPI=-1.5, INT=-0.5,
        },
        ["Frost"] = {
            STR=1.5, AP=0.8, HIT=0.8, CRIT=0.7, HASTE=0.7, EXPERTISE=0.7, ARMOR_PEN=0.5, STA=0.5,
            SP=-2, SPI=-1.5, INT=-0.5,
        },
        ["Unholy"] = {
            STR=1.5, AP=0.8, HIT=0.8, CRIT=0.7, HASTE=0.7, EXPERTISE=0.6, ARMOR_PEN=0.6, STA=0.5,
            SP=-2, SPI=-1.5, INT=-0.5,
        },
    },
}

-- Builds and stores the active stat profile for the current class+spec.
-- DungeonDrops.playerStatProfile is public: { weights={}, source="builtin"|"pawn", class, spec, pawnScale }
-- Foundation for future stat-gap analysis (which stats are low vs needed).
function DungeonDrops:BuildStatProfile()
    local class = self.playerClass or "PRIEST"
    local spec  = self.primarySpec  or "default"

    local classProfiles = STAT_PROFILES[class]
    local weights
    if classProfiles then
        weights = classProfiles[spec] or classProfiles.default or { INT = 1.0 }
    else
        weights = { INT = 1.0 }
    end

    self.playerStatProfile = {
        weights = weights,
        source  = "builtin",
        class   = class,
        spec    = spec,
    }

    local pawnScale = self:GetActivePawnScale()
    if pawnScale then
        self.playerStatProfile.pawnScale = pawnScale
        self.playerStatProfile.source    = "pawn"
    end

    return self.playerStatProfile
end

-- Returns the active weight table (from profile, falling back to a minimal INT default).
function DungeonDrops:GetStatWeights()
    if self.playerStatProfile then
        return self.playerStatProfile.weights
    end
    return { INT = 1.0 }
end

-- Human-readable display names for the short keys used in STAT_PROFILES
DungeonDrops.STAT_FULL_NAMES = {
    STR="Strength", AGI="Agility", STA="Stamina", INT="Intellect", SPI="Spirit",
    HIT="Hit Rating", CRIT="Crit Strike", HASTE="Haste Rating",
    EXPERTISE="Expertise", ARMOR_PEN="Armor Penetration",
    DEFENSE="Defense Rating", DODGE="Dodge Rating",
    PARRY="Parry Rating", BLOCK="Block Rating",
    AP="Attack Power", SP="Spell Power", MP5="Mana per 5 sec",
}

-- Maps GetItemStats API keys to the short names used in weight tables
local STAT_KEY_TO_SHORT = {
    ITEM_MOD_STRENGTH              = "STR",
    ITEM_MOD_AGILITY               = "AGI",
    ITEM_MOD_STAMINA               = "STA",
    ITEM_MOD_INTELLECT             = "INT",
    ITEM_MOD_SPIRIT                = "SPI",
    ITEM_MOD_HIT_RATING            = "HIT",
    ITEM_MOD_CRIT_RATING           = "CRIT",
    ITEM_MOD_HASTE_RATING          = "HASTE",
    ITEM_MOD_EXPERTISE_RATING      = "EXPERTISE",
    ITEM_MOD_ARMOR_PENETRATION_RATING = "ARMOR_PEN",
    ITEM_MOD_DEFENSE_SKILL_RATING  = "DEFENSE",
    ITEM_MOD_DODGE_RATING          = "DODGE",
    ITEM_MOD_PARRY_RATING          = "PARRY",
    ITEM_MOD_BLOCK_RATING          = "BLOCK",
    ITEM_MOD_ATTACK_POWER          = "AP",
    ITEM_MOD_SPELL_POWER           = "SP",
    ITEM_MOD_SPELL_HEALING_DONE    = "SP",
    ITEM_MOD_SPELL_DAMAGE_DONE     = "SP",
    ITEM_MOD_MANA_REGENERATION     = "MP5",
}

function DungeonDrops:GetItemStatScore(itemStats)
    if not itemStats then return 0 end
    local weights = (self.playerStatProfile and self.playerStatProfile.weights) or self:GetStatWeights()
    local score = 0
    for statKey, value in pairs(itemStats) do
        local shortKey = STAT_KEY_TO_SHORT[statKey]
        if shortKey and weights[shortKey] then
            score = score + (value * weights[shortKey])
        end
    end
    return score
end

-- CR_* numeric constants — not always defined as globals on private servers
local _CR_DEFENSE   = CR_DEFENSE_SKILL     or 2
local _CR_DODGE     = CR_DODGE             or 3
local _CR_PARRY     = CR_PARRY             or 4
local _CR_BLOCK     = CR_BLOCK             or 5
local _CR_HIT       = CR_HIT_MELEE         or 6
local _CR_CRIT      = CR_CRIT_MELEE        or 9
local _CR_HASTE     = CR_HASTE_MELEE       or 18
local _CR_EXPERTISE = CR_EXPERTISE         or 24
local _CR_ARPEN     = CR_ARMOR_PENETRATION or 25
-- MP5 is a flat stat, not a rating in WotLK — queried via GetItemStats instead

-- Reads the player's live stats via WoW character APIs (always available, no cache dependency).
-- Primary stats: UnitStat("player", index) → base, effective  (1=STR 2=AGI 3=STA 4=INT 5=SPI)
-- Secondary ratings: GetCombatRating(index) → rating points from gear only (no base/racial interference)
-- Spell power: GetSpellBonusHealing / GetSpellBonusDamage
-- AP: UnitAttackPower → base + positive buff
-- "avoid" only uses CR-based stats so base-level primary stats (e.g. Priest's tiny base STR) don't show.
-- Returns: { wanted=[{stat,label,weight,amount}], avoid=[{stat,label,weight,amount}], live={}, profile }
function DungeonDrops:GetStatAnalysis()
    if not self.playerStatProfile then
        self:BuildStatProfile()
    end

    -- Live character stats -------------------------------------------------
    local live = {}

    -- Primary stats (effective = base + gear + talents + buffs)
    live.STR = select(2, UnitStat("player", 1)) or 0
    live.AGI = select(2, UnitStat("player", 2)) or 0
    live.STA = select(2, UnitStat("player", 3)) or 0
    live.INT = select(2, UnitStat("player", 4)) or 0
    live.SPI = select(2, UnitStat("player", 5)) or 0

    -- Combat ratings (from gear only — no base/racial values in these)
    -- Uses local _CR_* constants defined above to avoid missing-global errors
    if GetCombatRating then
        live.DEFENSE   = GetCombatRating(_CR_DEFENSE)   or 0
        live.DODGE     = GetCombatRating(_CR_DODGE)     or 0
        live.PARRY     = GetCombatRating(_CR_PARRY)     or 0
        live.BLOCK     = GetCombatRating(_CR_BLOCK)     or 0
        live.HIT       = GetCombatRating(_CR_HIT)       or 0
        live.CRIT      = GetCombatRating(_CR_CRIT)      or 0
        live.HASTE     = GetCombatRating(_CR_HASTE)     or 0
        live.EXPERTISE = GetCombatRating(_CR_EXPERTISE) or 0
        live.ARMOR_PEN = GetCombatRating(_CR_ARPEN)     or 0
    end

    -- MP5: flat stat, not a combat rating — sum from equipped item stats
    if self.equipped then
        local mp5 = 0
        for _, item in pairs(self.equipped) do
            if item and item.link then
                local s = GetItemStats and GetItemStats(item.link)
                if s and s.ITEM_MOD_MANA_REGENERATION then
                    mp5 = mp5 + s.ITEM_MOD_MANA_REGENERATION
                end
            end
        end
        live.MP5 = mp5
    end

    -- Spell power (max of healing and damage power)
    local healSP = (GetSpellBonusHealing and GetSpellBonusHealing()) or 0
    local dmgSP  = (GetSpellBonusDamage  and GetSpellBonusDamage(5)) or 0
    live.SP = math.max(healSP, dmgSP)

    -- Attack power from gear (total AP minus base AP from primary stats)
    if UnitAttackPower then
        local base, pos = UnitAttackPower("player")
        live.AP = (base or 0) + (pos or 0)
    end

    -- Build wanted / avoid ------------------------------------------------
    local weights = self.playerStatProfile.weights
    -- CR-based stats: purely from gear — safe to flag even small amounts
    local CR_STAT = { DEFENSE=true, DODGE=true, PARRY=true, BLOCK=true,
                      HIT=true, CRIT=true, HASTE=true, EXPERTISE=true,
                      ARMOR_PEN=true, MP5=true }

    local targets = DungeonDropsCharDB.statTargets or {}

    local wanted = {}
    local avoid  = {}

    for stat, weight in pairs(weights) do
        local amount = live[stat] or 0
        local target = targets[stat]
        local gap = target and (target - amount) or nil
        local entry = {
            stat   = stat,
            label  = DungeonDrops.STAT_FULL_NAMES[stat] or stat,
            weight = weight,
            amount = amount,
            target = target,
            gap    = gap,
        }
        if weight > 0 then
            table.insert(wanted, entry)
        elseif weight < 0 and amount > 0 then
            -- Only flag in "avoid" if it's a CR-based stat (purely from gear)
            -- or if the amount is large enough to be meaningful from gear items
            if CR_STAT[stat] or amount > 50 then
                table.insert(avoid, entry)
            end
        end
    end

    -- Highest-weight first; ties broken by lower current amount (more urgent to fix)
    table.sort(wanted, function(a, b)
        if a.weight ~= b.weight then return a.weight > b.weight end
        return a.amount < b.amount
    end)
    table.sort(avoid, function(a, b) return a.amount > b.amount end)

    return {
        wanted  = wanted,
        avoid   = avoid,
        live    = live,
        profile = self.playerStatProfile,
    }
end

-- Stat target management ----------------------------------------------------
-- Targets are stored in DungeonDropsCharDB.statTargets (per-character saved var).
-- Users can set custom targets in the "Configure Stats" panel (/dd ui → Configure Stats).
-- Auto-fill computes level-appropriate targets from spec weights and level.

function DungeonDrops:GetStatTargets()
    if not DungeonDropsCharDB.statTargets then
        DungeonDropsCharDB.statTargets = {}
    end
    return DungeonDropsCharDB.statTargets
end

function DungeonDrops:SetStatTarget(stat, value)
    if not DungeonDropsCharDB.statTargets then
        DungeonDropsCharDB.statTargets = {}
    end
    DungeonDropsCharDB.statTargets[stat] = value
end

function DungeonDrops:ClearStatTarget(stat)
    if DungeonDropsCharDB.statTargets then
        DungeonDropsCharDB.statTargets[stat] = nil
    end
end

function DungeonDrops:ResetAllStatTargets()
    if DungeonDropsCharDB.statTargets then
        DungeonDropsCharDB.statTargets = {}
    end
end

-- Computes level-appropriate stat targets from the current spec weights + level.
-- Capped stats (HIT, EXPERTISE, DEFENSE) use exact WoW formulas.
-- Scaling stats use weight-proportional heuristics.
-- The result is written into DungeonDropsCharDB.statTargets.
function DungeonDrops:AutoFillStatTargets()
    local level = self:GetPlayerLevel()
    local weights = self:GetStatWeights()
    local targets = {}

    if not weights then
        DungeonDropsCharDB.statTargets = targets
        return targets
    end

    local levelFactor = level / 80

    -- Determine if this is a caster or melee spec based on SP weight
    local isCaster = weights.SP and weights.SP > 0.5

    -- Capped stats
    if isCaster then
        targets.HIT = math.floor(17 * 26.23 * levelFactor)
    else
        targets.HIT = math.floor(8 * 32.79 * levelFactor)
    end
    targets.EXPERTISE = math.floor(26 * 8.20 * levelFactor)
    local defNeeded = math.max(0, 540 - level * 5)
    targets.DEFENSE = math.floor(defNeeded * 4.92 * levelFactor)

    -- Find max positive weight
    local maxWeight = 0
    for _, w in pairs(weights) do
        if w > maxWeight then maxWeight = w end
    end
    if maxWeight <= 0 then maxWeight = 0.1 end

    -- Scaling stats: distribute budget by weight ratio
    for stat, weight in pairs(weights) do
        if weight > 0 and targets[stat] == nil then
            local ratio = weight / maxWeight
            if stat == "AP" then
                targets[stat] = math.floor(level * 15 * ratio)
            elseif stat == "SP" then
                targets[stat] = math.floor(level * 5 * ratio)
            elseif stat == "MP5" then
                targets[stat] = math.floor(level * 2 * ratio)
            elseif stat == "STR" or stat == "AGI" or stat == "INT" then
                targets[stat] = math.floor(level * 3.5 * ratio)
            elseif stat == "STA" then
                targets[stat] = math.floor(level * 3 * ratio)
            elseif stat == "SPI" then
                targets[stat] = math.floor(level * 2.5 * ratio)
            else -- HASTE, CRIT, ARMOR_PEN, etc.
                targets[stat] = math.floor(level * 2 * ratio)
            end
        end
    end

    DungeonDropsCharDB.statTargets = targets
    return targets
end

-- Returns Pawn score for a given item link and scale, or nil if unavailable.
function DungeonDrops:GetPawnScore(link, scaleName)
    if not (PawnGetItemData and PawnGetItemValue and link) then return nil end
    local data = PawnGetItemData(link)
    if not (data and data.Stats) then return nil end
    return PawnGetItemValue(data.Stats, data.SocketBonusStats, scaleName) or 0
end

-- Finds the first Pawn scale that is visible for the current character.
function DungeonDrops:GetActivePawnScale()
    if not (PawnGetAllScales and PawnIsScaleVisible) then return nil end
    for _, name in ipairs(PawnGetAllScales()) do
        if PawnIsScaleVisible(name) then return name end
    end
    return nil
end

function DungeonDrops:CalculateUpgradeScore(itemID, slot, knownIlvl)
    local link = "item:" .. itemID .. ":0:0:0"
    local itemName, fullLink, _, itemLevel = GetItemInfo(link)
    local equipped = self:GetEquippedItem(slot)

    if not itemName then
        -- Item not cached: mild ilvl comparison (only suggests if clearly better)
        local ilvl = knownIlvl or 0
        if ilvl == 0 then return 0 end
        if not equipped then return 5 end
        local diff = ilvl - (equipped.ilvl or 0)
        if diff <= 0 then return 0 end
        return diff * 0.3
    end

    -- Pawn scoring: use user's configured stat weights when Pawn is loaded
    local pawnScale = self:GetActivePawnScale()
    if pawnScale and fullLink then
        local newPawn = self:GetPawnScore(fullLink, pawnScale)
        if newPawn then
            local eqPawn = 0
            if equipped and equipped.link then
                eqPawn = self:GetPawnScore(equipped.link, pawnScale) or 0
            end
            if not equipped then
                return math.max(newPawn, 0) + 5
            end
            return newPawn - eqPawn
        end
    end

    -- Built-in stat weight scoring (pure stat comparison, no ilvl bonus)
    local itemStats = GetItemStats(link)
    if not itemStats then
        -- Can't read stats: ilvl fallback
        if not equipped then return 5 end
        local diff = (itemLevel or 0) - (equipped.ilvl or 0)
        if diff <= 0 then return 0 end
        return diff * 0.3
    end

    local itemScore = self:GetItemStatScore(itemStats)

    local equippedScore = 0
    if equipped and equipped.stats then
        equippedScore = self:GetItemStatScore(equipped.stats)
    end

    if not equipped then
        return math.max(itemScore, 0) + 5
    end

    return itemScore - equippedScore
end

-- Slots where armor type matters (cloth/leather/mail/plate) — not rings/neck/trinkets/cloak
local TYPED_ARMOR_SLOTS = {
    Head=true, Shoulder=true, Chest=true, Wrist=true,
    Hands=true, Waist=true, Legs=true, Feet=true,
}
-- Physical melee weapon slots that are useless for pure casters
local MELEE_WEAPON_SLOTS = {
    ["One-Hand Sword"]=true, ["One-Hand Mace"]=true, ["One-Hand Axe"]=true,
    ["Two-Hand Sword"]=true, ["Two-Hand Mace"]=true, ["Two-Hand Axe"]=true,
    Polearm=true, Fist=true,
}
-- All weapon slot types used in Data.lua
local ALL_WEAPON_SLOTS = {
    ["One-Hand Sword"]=true, ["One-Hand Mace"]=true, ["One-Hand Axe"]=true,
    ["Two-Hand Sword"]=true, ["Two-Hand Mace"]=true, ["Two-Hand Axe"]=true,
    ["Two-Hand Staff"]=true, Dagger=true, Polearm=true, Fist=true,
    Wand=true, Ranged=true, Bow=true, Crossbow=true, Gun=true,
}
-- Classes that always prefer spells over melee and can only wear cloth
local CASTER_ONLY = { PRIEST=true, MAGE=true, WARLOCK=true }

-- Max armor type each class can wear, indexed by level threshold
-- Shaman/Hunter: leather → mail at 40
-- Warrior/Paladin/DK: mail → plate at 40 (DK at 55)
local CLASS_ARMOR = {
    PRIEST      = { Cloth=true },
    MAGE        = { Cloth=true },
    WARLOCK     = { Cloth=true },
    DRUID       = { Cloth=true, Leather=true },
    ROGUE       = { Cloth=true, Leather=true },
    HUNTER      = { Cloth=true, Leather=true, Mail=true },
    SHAMAN      = { Cloth=true, Leather=true, Mail=true },
    WARRIOR     = { Cloth=true, Leather=true, Mail=true, Plate=true },
    PALADIN     = { Cloth=true, Leather=true, Mail=true, Plate=true },
    DEATHKNIGHT = { Cloth=true, Leather=true, Mail=true, Plate=true },
}
local CLASS_MAIL_LEVEL = { HUNTER=40, SHAMAN=40, WARRIOR=40, PALADIN=40, DEATHKNIGHT=55 }
local CLASS_PLATE_LEVEL = { WARRIOR=40, PALADIN=40, DEATHKNIGHT=55 }

-- Map GetItemInfo equipLoc + itemSubType to our slot names
local EQUIP_LOC_MAP = {
    INVTYPE_HEAD = "Head",
    INVTYPE_NECK = "Neck",
    INVTYPE_SHOULDER = "Shoulder",
    INVTYPE_CLOAK = "Back",
    INVTYPE_CHEST = "Chest",
    INVTYPE_ROBE = "Chest",
    INVTYPE_WAIST = "Waist",
    INVTYPE_LEGS = "Legs",
    INVTYPE_FEET = "Feet",
    INVTYPE_WRIST = "Wrist",
    INVTYPE_HAND = "Hands",
    INVTYPE_FINGER = "Ring",
    INVTYPE_TRINKET = "Trinket",
    INVTYPE_SHIELD = "Shield",
    INVTYPE_HOLDABLE = "Off-Hand",
    INVTYPE_WEAPON = "One-Hand",
    INVTYPE_WEAPONMAINHAND = "One-Hand",
    INVTYPE_WEAPONOFFHAND = "Off-Hand",
    INVTYPE_2HWEAPON = "Two-Hand",
    INVTYPE_RANGED = "Ranged",
    INVTYPE_RANGEDRIGHT = "Ranged",
    INVTYPE_THROWN = "Ranged",
    INVTYPE_RELIC = "Relic",
    INVTYPE_TABARD = "Tabard",
    INVTYPE_BAG = "Bag",
}

local WEAPON_SUBTYPE_MAP = {
    ["One-Hand Swords"] = "One-Hand Sword",
    ["One-Hand Maces"] = "One-Hand Mace",
    ["One-Hand Axes"] = "One-Hand Axe",
    ["Two-Hand Swords"] = "Two-Hand Sword",
    ["Two-Hand Maces"] = "Two-Hand Mace",
    ["Two-Hand Axes"] = "Two-Hand Axe",
    Staves = "Two-Hand Staff",
    Daggers = "Dagger",
    Polearms = "Polearm",
    ["Fist Weapons"] = "Fist",
    Wands = "Wand",
    Bows = "Bow",
    Crossbows = "Crossbow",
    Guns = "Gun",
    thrown = "Ranged",
}

local function MapEquipLocToSlot(equipLoc, itemSubType)
    if not equipLoc or equipLoc == "" then return nil end
    local slot = EQUIP_LOC_MAP[equipLoc]
    if slot == "Ranged" and itemSubType then
        if itemSubType == "Bows" then return "Bow" end
        if itemSubType == "Crossbows" then return "Crossbow" end
        if itemSubType == "Guns" then return "Gun" end
        if itemSubType == "Wands" then return "Wand" end
    end
    if slot == "One-Hand" then
        return WEAPON_SUBTYPE_MAP[itemSubType] or "One-Hand Sword"
    end
    if slot == "Two-Hand" then
        return WEAPON_SUBTYPE_MAP[itemSubType] or "Two-Hand Sword"
    end
    return slot
end

local ARMOR_SUBTYPES = { Cloth=true, Leather=true, Mail=true, Plate=true }

function DungeonDrops:CanEquipArmorType(subType, playerClass, level)
    if not ARMOR_SUBTYPES[subType] then return true end
    local allowed = CLASS_ARMOR[playerClass]
    if not allowed then return false end
    if not allowed[subType] then return false end
    -- Check level thresholds for Mail and Plate
    if subType == "Mail" then
        local reqLevel = CLASS_MAIL_LEVEL[playerClass]
        if reqLevel and level < reqLevel then return false end
    elseif subType == "Plate" then
        local reqLevel = CLASS_PLATE_LEVEL[playerClass]
        if reqLevel and level < reqLevel then return false end
    end
    return true
end

-- Relic subtypes (Librams/Idols/Totems/Sigils) each belong to exactly one class.
-- Every other class (including cloth casters that use a Wand instead) cannot equip them at all.
local RELIC_SUBTYPES = { Librams=true, Idols=true, Totems=true, Sigils=true }
local CLASS_RELIC = {
    PALADIN     = "Librams",
    DRUID       = "Idols",
    SHAMAN      = "Totems",
    DEATHKNIGHT = "Sigils",
}

function DungeonDrops:CanEquipRelic(subType, playerClass)
    if not RELIC_SUBTYPES[subType] then return true end
    return CLASS_RELIC[playerClass] == subType
end

function DungeonDrops:GetSlotFromItemID(itemID)
    local itemType, itemSubType = select(6, GetItemInfo(itemID))
    local equipLoc = select(9, GetItemInfo(itemID))
    if not itemType then return nil end
    local slot = MapEquipLocToSlot(equipLoc, itemSubType)
    if slot then return slot end
    -- Fallback for relics/totems/etc
    if itemType == "Armor" and itemSubType then
        local armorMap = {
            Cloth = "Chest", Leather = "Chest", Mail = "Chest", Plate = "Chest",
            Shields = "Shield", Misc = "Off-Hand",
        }
        return armorMap[itemSubType] or nil
    end
    return nil
end

function DungeonDrops:GetRecommendations()
    self:ScanGear()
    self:DetectSpec()
    self:BuildStatProfile()
    local level = self:GetPlayerLevel()
    local playerClass = self:GetPlayerClass()
    local allItems = DungeonDropsData:GetItemsForLevel(level, playerClass)

    local results = {}
    for _, entry in ipairs(allItems) do
        local itemID = entry.itemID
        local slot
        local ok = itemID and itemID > 0

        -- Skip items the player already has equipped
        if ok and self.equipped then
            for _, eq in pairs(self.equipped) do
                if eq and eq.id == itemID then
                    ok = false
                    break
                end
            end
        end

        -- Get real item data from server
        local name, _, _, serverIlvl, minLevel, _, subType
        if ok then
            name, _, _, serverIlvl, minLevel, _, subType = GetItemInfo(itemID)
            if not name then ok = false end
        end

        -- Per-item level safety filter
        if ok and minLevel and minLevel > level + 5 then
            ok = false
        end

        -- Skip armor types the class can't equip (cloth/leather/mail/plate)
        if ok and subType and not self:CanEquipArmorType(subType, playerClass, level) then
            ok = false
        end

        -- Skip relics (Libram/Idol/Totem/Sigil) the class can't equip
        if ok and subType and not self:CanEquipRelic(subType, playerClass) then
            ok = false
        end

        -- Determine slot from game data
        if ok then
            slot = self:GetSlotFromItemID(itemID)
            if not slot then ok = false end
        end

        local upgradeScore = 0
        if ok then
            upgradeScore = self:CalculateUpgradeScore(itemID, slot, serverIlvl or 0)

            -- Slot verification: skip if game's item class doesn't match slot type
            if upgradeScore > 0 then
                local gameClass = select(6, GetItemInfo(itemID))
                if gameClass then
                    if ALL_WEAPON_SLOTS[slot] and gameClass ~= "Weapon" then
                        upgradeScore = 0
                    elseif not ALL_WEAPON_SLOTS[slot] and slot ~= "Bag" and gameClass ~= "Armor" then
                        upgradeScore = 0
                    end
                end
            end

            if upgradeScore > 0 then
                table.insert(results, {
                    dungeonKey   = entry.dungeonKey,
                    dungeonName  = entry.dungeonName,
                    dungeonZone  = entry.dungeonZone,
                    itemID       = itemID,
                    itemName     = name,
                    ilvl         = serverIlvl or 0,
                    upgradeScore = upgradeScore,
                    slot         = slot,
                })
            end
        end
    end

    table.sort(results, function(a, b) return a.upgradeScore > b.upgradeScore end)
    self.currentRecommendations = results
    return results
end

function DungeonDrops:GetTopRecommendations(count)
    count = count or 10
    if not self.currentRecommendations then
        self:GetRecommendations()
    end
    local results = {}
    for i = 1, math.min(count, #self.currentRecommendations) do
        table.insert(results, self.currentRecommendations[i])
    end
    return results
end

function DungeonDrops:GetBestDungeons()
    if not self.currentRecommendations or #self.currentRecommendations == 0 then
        self:GetRecommendations()
    end
    local dungeonScore = {}
    for _, rec in ipairs(self.currentRecommendations) do
        local key = rec.dungeonKey
        dungeonScore[key] = dungeonScore[key] or { name = rec.dungeonName, zone = rec.dungeonZone, score = 0, count = 0 }
        dungeonScore[key].score = dungeonScore[key].score + rec.upgradeScore
        dungeonScore[key].count = dungeonScore[key].count + 1
    end
    local results = {}
    for key, data in pairs(dungeonScore) do
        table.insert(results, {
            key = key,
            name = data.name,
            zone = data.zone,
            score = data.score,
            count = data.count,
            avgScore = data.score / data.count,
        })
    end
    table.sort(results, function(a, b) return a.score > b.score end)
    return results
end

function DungeonDrops:GetPlayerLevel()
    return self.playerLevel or UnitLevel("player")
end

function DungeonDrops:GetPlayerClass()
    return self.playerClass or select(2, UnitClass("player"))
end

function DungeonDrops:UpdateRecommendations()
    self:GetRecommendations()
    if self.UI and self.UI.UpdateDisplay then
        self.UI:UpdateDisplay()
    end
end

function DungeonDrops:ShowLevelUpNotification()
    local level = self:GetPlayerLevel()
    local recs = self:GetTopRecommendations(3)
    if #recs > 0 then
        local linkText = ""
        if recs[1].itemID > 0 then
            linkText = "|cffffffff|Hitem:" .. recs[1].itemID .. ":0:0:0|h[" .. recs[1].itemName .. "]|h|r"
        else
            linkText = recs[1].itemName
        end
        self:Print(string.format("Level %d! Check DungeonDrops for new loot.", level))
        self:Print(string.format("Top pick: %s from %s", linkText, recs[1].dungeonName))
    end
end

function DungeonDrops:Print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ccff[DungeonDrops]|r " .. message)
end

SLASH_DUNGEONDROPS1 = "/dungeondrops"
SLASH_DUNGEONDROPS2 = "/dd"
SlashCmdList["DUNGEONDROPS"] = function(msg)
    local args = { strsplit(" ", msg) }
    local command = string.lower(args[1] or "")

    if command == "" or command == "help" then
        DungeonDrops:ShowHelp()
    elseif command == "toggle" then
        DungeonDropsDB.enabled = not DungeonDropsDB.enabled
        DungeonDrops:Print("DungeonDrops " .. (DungeonDropsDB.enabled and "enabled" or "disabled"))
    elseif command == "ui" then
        DungeonDrops:ToggleUI()
    elseif command == "list" then
        DungeonDrops:ListDungeons()
    elseif command == "items" then
        DungeonDrops:ListTopItems(tonumber(args[2]) or 10)
    elseif command == "rescan" then
        DungeonDrops:RefreshPlayerInfo()
        DungeonDrops:UpdateRecommendations()
        DungeonDrops:Print("Re-scanned gear and talents.")
    elseif command == "status" then
        DungeonDrops:ShowStatus()
    elseif command == "reset" then
        DungeonDropsDB = CopyTable(defaults)
        DungeonDrops:Print("Settings reset to defaults.")
    else
        DungeonDrops:Print("Unknown command. Type /dd help for available commands.")
    end
end

function DungeonDrops:ShowHelp()
    self:Print("=== DungeonDrops Commands ===")
    self:Print("/dd help - Show this help")
    self:Print("/dd toggle - Enable/disable addon")
    self:Print("/dd ui - Toggle the DungeonDrops window")
    self:Print("/dd list - List dungeons available for your level")
    self:Print("/dd items [n] - Show top n item recommendations")
    self:Print("/dd rescan - Re-scan gear and talents")
    self:Print("/dd status - Show current player status")
    self:Print("/dd reset - Reset all settings")
end

function DungeonDrops:ListDungeons()
    local level = self:GetPlayerLevel()
    local bestDungeons = self:GetBestDungeons()
    self:Print(string.format("=== Best Dungeons for Level %d %s ===", level, self:GetPlayerClass()))
    local count = 0
    for _, d in ipairs(bestDungeons) do
        count = count + 1
        self:Print(string.format("%d. %s (%s) - score: %.1f (%d items)", count, d.name, d.zone, d.score, d.count))
    end
    if count == 0 then
        self:Print("No dungeons available for your level.")
    end
end

function DungeonDrops:ListTopItems(count)
    local recs = self:GetTopRecommendations(count)
    local level = self:GetPlayerLevel()
    self:Print(string.format("=== Top %d Items for Level %d %s ===", #recs, level, self:GetPlayerClass()))
    for i, rec in ipairs(recs) do
        if rec.itemID > 0 then
            local link = "|cffffffff|Hitem:" .. rec.itemID .. ":0:0:0|h[" .. rec.itemName .. "]|h|r"
            self:Print(string.format("%d. %s (ilvl %d, +%.1f) - %s [%s]", i, link, rec.ilvl, rec.upgradeScore, rec.dungeonName, rec.slot))
        else
            self:Print(string.format("%d. %s (ilvl %d) - %s [%s]", i, rec.itemName, rec.ilvl, rec.dungeonName, rec.slot))
        end
    end
end

function DungeonDrops:ShowStatus()
    self:Print("=== DungeonDrops Status ===")
    self:Print("Version: " .. self.version)
    self:Print("Enabled: " .. tostring(DungeonDropsDB.enabled))
    self:Print("Class: " .. tostring(self:GetPlayerClass()))
    self:Print("Level: " .. tostring(self:GetPlayerLevel()))
    self:Print("Spec: " .. tostring(self.primarySpec or "Unknown"))
    if self.equipped then
        local count = 0
        for _ in pairs(self.equipped) do count = count + 1 end
        self:Print("Equipped Items: " .. count .. "/17")
    end
    if self.currentRecommendations then
        self:Print("Recommendations: " .. #self.currentRecommendations)
    end
end

function DungeonDrops:ToggleUI()
    if self.UI then
        self.UI:Toggle()
    else
        self:Print("UI not available. Check that all addon files are loaded.")
    end
end
