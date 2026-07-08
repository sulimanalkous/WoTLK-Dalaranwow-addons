# DungeonDrops — Developer Reference & Session Log

## Addon Goal
Show best dungeon items for your class/level/spec with icons, tooltips, stat comparison vs equipped,
and upgrade scores. GUI via `/dd ui`. Supports all 10 classes, levels 10–80, Classic through Wrath.

---

## How the Addon Works (Architecture Overview)

### Data philosophy
**ALL item data comes from the server at runtime.** No hardcoded item names, IDs, ilvls, slots, or
dungeon→item mappings. Dungeon definitions (name, level range, location) are universal constants.
Item associations are read from AtlasLoot's runtime tables (`AtlasLootNewBossButtons` + `AtlasLoot_Data`),
which are populated from server DBC data. Item stats come from `GetItemInfo(itemID)`.

### Boot sequence
1. `ADDON_LOADED` → `Core:Initialize()` → reads SavedVars, registers events, calls `EnrichFromAtlasLoot()`
2. `PLAYER_LOGIN` → `Core:OnPlayerLogin()`:
    - `DungeonDropsData:InitFromAtlasLoot()` — force-loads AtlasLoot expansion modules
      (`LoadAddOn("AtlasLoot_*")`), then walks `AtlasLootNewBossButtons` per dungeon to find boss
      tables, reads `AtlasLoot_Data[bossKey]` for item IDs, builds `DungeonDropsData.ItemCache[dungeonKey] = {itemIDs}`.
      Deduplicates item IDs per dungeon via a `seen` table.
    - `RefreshPlayerInfo()` → `ScanGear()` (reads equipped items), `DetectSpec()` (talent tree analysis),
      `BuildStatProfile()` (stat weights from class+spec)
    - Starts item scanner (queries `GetItemInfo` on all known IDs to populate WoW's cache)
    - If enabled, calls `UpdateRecommendations()`
3. UI is lazy-initialized on first `/dd ui` call

### Recommendation pipeline (`GetRecommendations`)
1. `ScanGear()` + `DetectSpec()` + `BuildStatProfile()` (always refreshed on each call)
2. `DungeonDropsData:GetItemsForLevel(level, class)` — iterates `self.Dungeons` by level range,
    reads `self.ItemCache[dungeonKey]` (populated by AtlasLoot), returns flat `{dungeonKey, dungeonName,
    dungeonZone, dungeonExpansion, itemID}` list
3. For each item (`entry.itemID` — flat, no nesting):
    - `ok` flag pattern (Lua 5.1 compatible, no `break`-as-continue)
    - Skip if already equipped (item ID match in `self.equipped[]`)
    - `GetItemInfo(itemID)` → `name, ilvl, minLevel, subType` — skip if uncached (`name == nil`)
    - Level safety filter: skip if `minLevel > playerLevel + 5`
    - **Armor type filter**: `CanEquipArmorType(subType, class, level)` — skips cloth/leather/mail/plate
      types the class can't equip at their level (e.g., Shaman < 40 can't wear mail)
    - `GetSlotFromItemID(itemID)` — maps `GetItemInfo` equipLoc + subType to slot names via
      `MapEquipLocToSlot()` and `EQUIP_LOC_MAP`/`WEAPON_SUBTYPE_MAP`
    - `CalculateUpgradeScore(itemID, slot, ilvl)`:
      - If Pawn loaded + scale active → use Pawn score delta vs equipped
      - If item cached → use `GetItemStatScore()` with `playerStatProfile.weights` (positive AND negative)
      - If item NOT cached → ilvl delta fallback
    - Discard if `upgradeScore <= 0`
4. Sort descending by upgradeScore

### Stat profile system (`playerStatProfile`)
- Built by `BuildStatProfile()` after every `DetectSpec()` call
- Stored as `DungeonDrops.playerStatProfile` (public — other code reads it)
- Structure: `{ weights={}, source="builtin"|"pawn", class, spec, pawnScale }`
- `weights` table has BOTH positive (good stats) and negative (wrong-role stats) values
  - e.g. Holy Priest: `INT=1.5, SPI=1.2` but `DODGE=-3, DEFENSE=-3, PARRY=-3, BLOCK=-3`
  - Negative weights ensure tank items score largely negative and are filtered out
- `STAT_PROFILES` in Core.lua has full tables for all 10 classes × their specs
- Powers the **My Stats panel** — see `GetStatAnalysis()` and `ShowStatAnalysis()`

### My Stats panel (`GetStatAnalysis` + `ShowStatAnalysis`)
- Opened via the **"My Stats"** button (center of bottom bar in the UI window)
- Shows two sections in the right panel:
  - **▲ STATS TO PRIORITIZE** — stats with positive weight, sorted by priority tier, with current live value
  - **▼ STATS TO AVOID** — negative-weight stats the player actually has (wasted item budget)
- Priority tiers: Core stat (weight ≥ 1.2, green) → High (≥ 0.7) → Medium (≥ 0.4) → Low (< 0.4, gray)
- Data is read from **live WoW character APIs** (not from `GetItemStats`):
  - Primary stats (INT/SPI/STR/AGI/STA): `UnitStat("player", index)` — index 1–5
  - Secondary ratings (HIT/CRIT/HASTE/DEFENSE/DODGE/PARRY/BLOCK/EXPERTISE/ARMOR_PEN): `GetCombatRating(index)`
  - Spell power: `max(GetSpellBonusHealing(), GetSpellBonusDamage(5))`
  - Attack power: `UnitAttackPower("player")`
  - MP5: summed from `GetItemStats(link)` on equipped items (not a combat rating in WotLK)
- "Avoid" section only flags CR-based stats (purely from gear) or primary stats > 50 to avoid
  false positives from base stat values every class has at their level

### Pawn integration
- `GetActivePawnScale()` — finds first visible Pawn scale, nil if Pawn not loaded
- `GetPawnScore(link, scaleName)` — calls Pawn API, returns nil if item not cached
- Pawn is tried first in `CalculateUpgradeScore`; falls back to built-in weights if unavailable
- `DungeonDropsDB.OptionalDeps` includes `Pawn` in the TOC

### Item caching reality (WoW 3.3.5a)
Items are ONLY cached if the player has looted, inspected, or had them in inventory this session.
- `GetItemInfo(id)` → nil for uncached
- `GetItemStats(link)` → nil for uncached
- `GameTooltip:SetHyperlink(link)` → silent no-op for uncached
- The preloader tries `SetHyperlink` with `Show()`/`Hide()` cycles on a hidden off-screen tooltip
  to trigger server queries, but this is unreliable on private servers

### Tooltip behavior per item state
| State | Hover behavior |
|---|---|
| Cached item | `GameTooltip:SetHyperlink` — full native WoW tooltip |
| Uncached item (id > 0) | Manual `AddLine` tooltip: green name, white slot/ilvl, gold source; queues server query |
| id=0 item | Same manual tooltip — no server query attempted |

---

## File Structure
```
Interface/AddOns/DungeonDrops/
├── DungeonDrops.toc    — OptionalDeps: AtlasLoot, Pawn
├── Core.lua            — Events, gear scan, spec detect, stat profiles, Pawn, scoring, slash cmds,
│                         CLASS_ARMOR armor-type filter, GetSlotFromItemID
├── Data.lua            — 55 dungeons with atlasKey → AtlasLoot mapping, InitFromAtlasLoot()
│                         (LoadOnDemand expansion loading + ItemCache build), GetItemsForLevel(),
│                         ClassCanUseSlot(), EnrichFromAtlasLoot() (icon cache), LookupAtlasLootIcon()
│                         NO hardcoded items — all data from server at runtime
├── Scanner.lua         — Scans ItemCache IDs via GetItemInfo to populate WoW cache
├── Config.lua          — SavedVariables defaults
├── UI.lua              — GUI, item rows, tooltips, icon/stat/color helpers
└── SESSION.md          — This file
```

---

## Key Code Locations
| Feature | File:Line (approximate) |
|---|---|
| Event registration | Core.lua ~44 |
| Gear scanning (`ScanGear`) | Core.lua ~217 |
| Spec detection (`DetectSpec`) | Core.lua ~264 |
| **Stat profile build** (`BuildStatProfile`) | Core.lua ~348 |
| **STAT_PROFILES table** (all classes+specs) | Core.lua ~188 |
| `GetStatWeights` | Core.lua ~377 |
| `GetItemStatScore` | Core.lua ~417 |
| Pawn helpers | Core.lua ~647 |
| `CalculateUpgradeScore` | Core.lua ~663 |
| `GetSlotFromItemID` | Core.lua ~798 |
| `CanEquipArmorType` | Core.lua ~755 |
| `GetRecommendations` | Core.lua ~850 |
| **`GetStatAnalysis`** | Core.lua ~449 |
| `_CR_*` local constants | Core.lua ~431 |
| Dungeon ranking | Core.lua ~904 |
| Slash commands | Core.lua ~950 |
| Dungeon definitions (55 dungeons) | Data.lua:1–327 |
| `GetItemsForLevel` | Data.lua ~328 |
| `InitFromAtlasLoot` (LoadOnDemand + dedup) | Data.lua ~349 |
| `EnrichFromAtlasLoot` (icon cache) | Data.lua ~381 |
| `LookupAtlasLootIcon` | Data.lua ~392 |
| UI Initialize | UI.lua ~244 |
| Item row creation (`CreateItemRow`) | UI.lua ~102 |
| Tooltip OnEnter/OnLeave | UI.lua ~199 |
| Icon resolution | UI.lua ~57 |
| Stat diff display | UI.lua ~73 |
| **`ShowStatAnalysis`** | UI.lua ~587 |
| "My Stats" button | UI.lua ~381 |

---

## Critical WoW 3.3.5a API Notes
- `GetItemInfo(id or link)` → `name, link, rarity, level, minLevel, type, subType, stackCount, equipLoc, icon` — nil for uncached
- `GetItemStats("item:ID:0:0:0")` → `{ITEM_MOD_INTELLECT=N, ...}` table — nil for uncached
- `GetItemIcon(id)` → texture path — nil for uncached
- `UnitClass("player")` → `localizedName, classToken` (use 2nd return value)
- `GetTalentTabInfo(tab)` → `name, iconTexture, pointsSpent, ...`
- `GetInventoryItemLink("player", slotID)` → full item link or nil
- `GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")` — must call before AddLine/SetHyperlink/Show
- **Pawn API**: `PawnGetItemData(link)`, `PawnGetItemValue(stats, socketBonus, scale)`, `PawnGetAllScales()`, `PawnIsScaleVisible(name)`
- TipTac hooks `GameTooltip.Show` and `FadeOut` — does not break standard usage
- `UnitStat("player", index)` → `baseStat, effectiveStat` — index 1=STR 2=AGI 3=STA 4=INT 5=SPI. Always works, no cache needed.
- `GetCombatRating(index)` → rating points from gear for that combat rating. Returns nil if index is invalid.
  **⚠ WARNING**: `CR_*` named globals (CR_DODGE, CR_PARRY, etc.) are NOT defined on Warmane 3.3.5a.
  Always define local fallbacks: `local _CR_DODGE = CR_DODGE or 3`. See numeric values below.
- `GetSpellBonusHealing()` → total healing spell power from all sources
- `GetSpellBonusDamage(school)` → spell damage for school (1=phys 2=holy 3=fire 4=nature 5=frost 6=shadow 7=arcane)
- `UnitAttackPower("player")` → `base, posBuff, negBuff` — add first two for effective AP
- `GetManaRegen()` → returns regen per second (not MP5). MP5 is a flat stat, not a combat rating — use GetItemStats.

### GetCombatRating numeric indices (WoW 3.3.5a)
Use these directly if `CR_*` globals are nil (Warmane):
```
2=Defense  3=Dodge  4=Parry  5=Block
6=HitMelee  7=HitRanged  8=HitSpell
9=CritMelee  10=CritRanged  11=CritSpell
18=HasteMelee  19=HasteRanged  20=HasteSpell
24=Expertise  25=ArmorPenetration
```
MP5 has NO combat rating index — it is a direct flat stat on items.

---

## Bugs Found and Fixed (with root causes)

### BUG 1 — AI-hallucinated items with id=0 (DeepSeek original)
**Symptom**: "Wave of Life", "Pyric Cloak", and 80+ other items had `id=0` and showed gray name
text and broken tooltips. None of these items exist in AtlasLoot, TDB SQL dump, or Informant.
**Root cause**: DeepSeek invented item names without verifying they exist in the game.
**Fix**: All id=0 items removed from the database. For Sunken Temple, replaced 5 fake items with
9 real items sourced from AtlasLoot_OriginalWoW and TDB_full_335.63 SQL.
**Rule**: NEVER add an item to Data.lua without a verified real item ID from AtlasLoot, Wowhead,
or TDB SQL (item_template table). If you don't have the ID, do not add the item.

### BUG 2 — Duplicate Lua table keys in specMap (DeepSeek original)
**Symptom**: Paladin Protection and Warrior Protection used the same weights; Shaman Restoration
and Druid Restoration both used Druid Restoration weights.
**Root cause**: The original `GetSpecStatWeights` had a flat `specMap` table with duplicate string
keys: `["Protection"]` appeared twice, `["Restoration"]` appeared twice. In Lua, duplicate table
keys silently discard the first value — only the LAST definition is kept.
**Fix**: Replaced the flat specMap with `STAT_PROFILES[class][spec]` — a two-level table keyed
by class then spec name. Each class has its own spec sub-table, so "Protection" can mean different
things for WARRIOR vs PALADIN.
**Rule**: In Lua table literals, duplicate string keys are a silent bug. Always use two-level
tables when spec names are shared across classes.

### BUG 3 — Only positive stat weights, tank items scoring as upgrades (DeepSeek original)
**Symptom**: Holy Priest at level 53 was seeing rings and trinkets with Dodge and Defense stats
in the recommendation list, scored as upgrades.
**Root cause**: `GetItemStatScore` had `if w > 0 then` guard — negative-weighted or zero-weighted
stats were simply skipped. Tank stats (DODGE, DEFENSE, PARRY, BLOCK) had no weight entry for
Priest, so they contributed 0. The ilvl bonus `(ilvlDiff * 0.5)` then made the item score positive.
**Fix**:
  1. Added negative weights for wrong-role stats to every class+spec profile
     (e.g. Holy Priest: `DODGE=-3, DEFENSE=-3, PARRY=-3, BLOCK=-3, STR=-1.5, AP=-1.5`)
  2. Removed the `if w > 0 then` guard in `GetItemStatScore` so negatives actually penalize
  3. Added `if upgradeScore <= 0 then skip` filter in `GetRecommendations` — items that score
     zero or negative are not shown at all
**Rule**: Stat weight tables MUST include negative weights for wrong-role stats. A Holy Priest
getting a tank ring as a suggestion means the scoring system is broken.

### BUG 4 — Item quality color fallback was white (DeepSeek original)
**Symptom**: Items with unknown quality (uncached or id=0) showed as white/common color in the
item list, making them look like poor/common quality items.
**Root cause**: `GetItemQualityColor` returned `"|cffffffff"` (white) for nil quality.
**Fix**: Return `"|cff1eff00"` (green/uncommon) for unknown quality — when we don't know the
quality, assume green since most dungeon drops are uncommon or better.

### BUG 5 — Fallback tooltip was all gray/muted (DeepSeek original)
**Symptom**: When an item was not cached, the manual `AddLine` fallback tooltip showed all text
in the same muted gray color — looked broken and unhelpful.
**Fix**: Rewrote fallback tooltip to use proper WoW-style coloring:
  - Item name → green (`0.12, 1.00, 0.12`)
  - Slot / item level → white (`1, 1, 1`)
  - Classes restriction → gray (`0.71, 0.71, 0.71`)
  - Dungeon source → gold (`1, 0.82, 0`)

### BUG 6 — Already-equipped items appearing in recommendations (DeepSeek original)
**Symptom**: Items the player already had equipped were shown as upgrade suggestions.
**Root cause**: No filter existed for currently-equipped items.
**Fix**: In `GetRecommendations`, before scoring, iterate `self.equipped` and compare item IDs.
If any equipped slot has the same item ID, set `alreadyEquipped = true` and skip scoring.
Handles dual rings (Finger1/Finger2) and dual trinkets naturally since both slots are in equipped.

### BUG 8 — GetStatAnalysis: "none on gear" for all stats
**Symptom**: The My Stats panel showed every stat as "none on gear" (amount = 0) even though
the player had gear equipped.
**Root cause**: `GetItemStats(link)` returns nil for equipped items at login time on Warmane
(private server caching behaviour). `ScanGear()` ran at `PLAYER_LOGIN` before the client had
fully populated the item cache, so `item.stats` was stored as `{}` for all slots and never
re-populated on its own.
**Fix**: Replaced `GetItemStats`-based gear aggregation with live WoW character APIs:
  - `UnitStat("player", 1..5)` for primary stats — always available, no cache needed
  - `GetCombatRating(index)` for secondary ratings — reads from gear, always available
  - `GetSpellBonusHealing()` / `GetSpellBonusDamage()` for spell power
  - MP5 still uses `GetItemStats` per item as a best-effort (genuinely not a combat rating)
**Rule**: Never rely on `ScanGear`-stored `item.stats` for the My Stats display. Always query
live character APIs. `GetItemStats` on equipped items can be nil at login even though the items
are cached for `GetItemInfo` and icon purposes.

### BUG 9 — `CR_*` global constants nil on Warmane, crashing GetStatAnalysis
**Symptom**: Clicking "My Stats" triggered: `Usage: GetCombatRating(ratingIndex)` at Core.lua:559.
**Root cause**: WoW 3.3.5a FrameXML defines `CR_DODGE`, `CR_PARRY`, `CR_DEFENSE_SKILL`, etc. as
global numeric constants. Warmane's server does NOT expose these globals to the Lua environment,
so they are all nil. Calling `GetCombatRating(nil)` causes WoW's own C-side argument validation
to throw the "Usage:" error.
**Fix**: Define nine local `_CR_*` constants before `GetStatAnalysis` using `GlobalName or N`:
```lua
local _CR_DEFENSE   = CR_DEFENSE_SKILL     or 2
local _CR_DODGE     = CR_DODGE             or 3
local _CR_PARRY     = CR_PARRY             or 4
local _CR_BLOCK     = CR_BLOCK             or 5
local _CR_HIT       = CR_HIT_MELEE         or 6
local _CR_CRIT      = CR_CRIT_MELEE        or 9
local _CR_HASTE     = CR_HASTE_MELEE       or 18
local _CR_EXPERTISE = CR_EXPERTISE         or 24
local _CR_ARPEN     = CR_ARMOR_PENETRATION or 25
```
These locals are resolved at file-load time (during `ADDON_LOADED`), before any function is called.
If the server provides the globals, they're used; if not, the correct numeric fallbacks apply.
**Rule**: NEVER use `CR_*` globals directly in WoW 3.3.5a addon code targeting private servers.
Always define local fallback versions with `or numericValue`. The numeric values are documented
in the API Notes section above.

### BUG 10 — Wrong dungeon→item mapping from hardcoded Data.lua
**Symptom**: Items from Wailing Caverns were shown under Ragefire Chasm; level 14 character getting
ilvl 57 suggestions; plate armor suggested for low-level Shaman.
**Root cause**: Original Data.lua had 132 manually-curated items with hardcoded dungeon associations,
item IDs, names, ilvls, and slot data. These were sourced from unreliable sources and never matched
the actual server data. Hardcoded data is inherently wrong on private servers.
**Fix**: **Complete architectural refactor** — removed ALL hardcoded item data from Data.lua
(names, IDs, ilvls, slots, classes). Added `atlasKey` field to each dungeon definition mapping
to AtlasLoot zone keys. Added `InitFromAtlasLoot()` that reads `AtlasLootNewBossButtons` and
`AtlasLoot_Data` at runtime to build `ItemCache[dungeonKey] = {itemIDs}`. Item names, ilvls, slots
now come exclusively from `GetItemInfo(itemID)` at recommendation time.
**Rule**: NEVER hardcode item names, IDs, ilvls, slots, or dungeon→item associations. All item
data MUST come from the server via `GetItemInfo` or AtlasLoot's runtime tables.

### BUG 11 — AtlasLoot LoadOnDemand modules not loaded at login
**Symptom**: "No recommendations found" for all characters despite AtlasLoot being installed.
**Root cause**: AtlasLoot_OriginalWoW, AtlasLoot_BurningCrusade, and AtlasLoot_WrathoftheLichKing
are all `## LoadOnDemand: 1` addons — their `AtlasLoot_Data` tables (containing actual loot data)
are NOT loaded at login. `InitFromAtlasLoot()` ran but found no loot data.
**Fix**: Added `LoadAddOn("AtlasLoot_OriginalWoW")`, `LoadAddOn("AtlasLoot_BurningCrusade")`, and
`LoadAddOn("AtlasLoot_WrathoftheLichKing")` at the top of `InitFromAtlasLoot()` before any
`AtlasLoot_Data` lookups. This is safe — calling `LoadAddOn` on an already-loaded module returns
true without side effects.
**Rule**: Never assume LoadOnDemand addon data is available at `PLAYER_LOGIN`. Always call
`LoadAddOn` before reading their globals.

### BUG 12 — Duplicate items from AtlasLootNewBossButtons
**Symptom**: Items appeared multiple times in recommendations (e.g., same item 3+ times).
**Root cause**: `AtlasLootNewBossButtons` contains duplicate entries for many dungeons
(e.g., RagefireChasm appears at lines 1354 AND 3160 in instances.en.lua). Each entry has the
same boss keys, so `InitFromAtlasLoot()` appended identical item IDs to the cache multiple times.
**Fix**: Added per-dungeon `seen = {}` table in `InitFromAtlasLoot` that tracks which item IDs
have already been inserted for the current dungeon key.
**Rule**: Always deduplicate item IDs when reading from tables that may have duplicate entries.

### BUG 13 — Scanner built empty queue after Data.lua refactor
**Symptom**: Items never got `GetItemInfo` calls to populate WoW's internal cache.
**Root cause**: Scanner's `BuildQueue()` iterated `dungeon.items` but Data.lua no longer has
items stored under dungeons — items now live in `DungeonDropsData.ItemCache` built by
`InitFromAtlasLoot()`.
**Fix**: Rewrote `BuildQueue()` to iterate `DungeonDropsData.ItemCache` (two-level:
`dungeonKey → {itemIDs}`) instead of the removed `dungeon.items` array.
**Rule**: When data storage strategy changes, update ALL consumers of the old structure.

### BUG 14 — Lua 5.1 `break` exits outer loop instead of skipping item
**Symptom**: First filtered item caused all subsequent items to be skipped, returning few results.
**Root cause**: Used `break` inside a `for _, entry in ipairs(allItems)` loop to skip items.
In Lua 5.1 (WoW 3.3.5a), `break` exits the nearest enclosing `for`/`while`/`repeat` — it does NOT
skip to the next iteration (that's `continue`, which doesn't exist in Lua 5.1).
**Fix**: Replaced all `break`-as-continue patterns with an `ok` flag pattern:
`local ok = true` then `if ok then ... end` for each filter, and only process/insert at the end
if `ok` is still true.
**Rule**: In Lua 5.1, never use `break` to simulate `continue`. Use an `ok` flag or wrap the
loop body in `repeat ... until true` (creating a block scope that can be `break`ed).

### BUG 15 — `rec.item.name` references after data structure change
**Symptom**: Lua errors when rendering item rows: attempt to index field 'item' (a nil value).
**Root cause**: `GetRecommendations` changed from `{item={name="...", id=N, ...}}` to
`{itemID=N, itemName="..."}` flat structure, but UI.lua still referenced `rec.item.name`,
`rec.item.classes`, etc.
**Fix**: Updated UI.lua: `rec.itemName` replaces `rec.item.name`; removed `rec.item.classes`
entirely (class tagging no longer exists in the data model).
**Rule**: After changing data structures, grep for ALL references to the old field paths.

### BUG 7 — Loop structure broke after adding alreadyEquipped check
**Symptom**: After adding the alreadyEquipped filter, `table.insert` was still outside the
`if not alreadyEquipped` block, so equipped items were still inserted into results.
**Root cause**: `end` placement error when restructuring nested if-blocks.
**Fix**: Ensure `table.insert(results, ...)` is inside `if not alreadyEquipped and itemID > 0 then`,
and the `upgradeScore > 0` filter is the innermost guard. Structure must be:
```
if not alreadyEquipped and itemID > 0 then
    score = CalculateUpgradeScore(...)
    -- penalties...
    if upgradeScore > 0 then
        table.insert(results, {...})
    end
end
```

### BUG 16 — `INVTYPE_WEAPON` / `INVTYPE_2HWEAPON` missing from EQUIP_LOC_MAP
**Symptom**: Most weapon drops (one-hand swords/maces/axes/daggers usable in either hand, and
ALL two-handed weapons: swords, maces, axes, staves, polearms) never appeared in recommendations,
even when they were clear upgrades and correctly cached.
**Root cause**: `EQUIP_LOC_MAP` in Core.lua only mapped `INVTYPE_WEAPONMAINHAND` (main-hand-only
one-handers) and `INVTYPE_WEAPONOFFHAND` (off-hand-only one-handers). The much more common
`INVTYPE_WEAPON` (regular either-hand one-handers) and `INVTYPE_2HWEAPON` (all two-handers) equip
locations were absent from the table, so `MapEquipLocToSlot` returned `nil` for them.
`GetSlotFromItemID`'s fallback only covers `itemType == "Armor"`, not `"Weapon"`, so these items
got `slot = nil` and were dropped entirely in `GetRecommendations` (`if not slot then ok = false`).
**Fix**: Added `INVTYPE_WEAPON = "One-Hand"` and `INVTYPE_2HWEAPON = "Two-Hand"` to `EQUIP_LOC_MAP`,
and added a `slot == "Two-Hand"` branch in `MapEquipLocToSlot` (mirrors the existing `"One-Hand"`
branch) that resolves the real slot name via `WEAPON_SUBTYPE_MAP`. Also fixed `Wands` falling
through to generic `"Ranged"` instead of `"Wand"` (same function, missing subtype case).
**Rule**: When mapping `GetItemInfo` equip locations, enumerate ALL real `INVTYPE_*` constants for
a category (there are 4 weapon-hand equip locs, not 2) — cross-check against another addon that
already handles the full set (e.g. Baggins-Filtering.lua) rather than assuming the visible cases
are complete.

### Known dead code — `ClassCanUseSlot` (Data.lua) never wired in
`Data.lua` defines a full per-class weapon/shield-usability table (`ClassCanUseSlot(class, slot)`)
but it is never called from anywhere, including `GetRecommendations`. Now that BUG 16 is fixed and
weapons actually reach the recommendation pipeline, wrong-class weapons (e.g. a caster seeing an
axe) can theoretically surface if their raw stats happen to score positively. Not fixed yet because
the existing `Off-Hand`/`Shield` class logic in that function looks suspect (e.g. it currently
denies Mage/Warlock/Rogue/Druid/Hunter any `Off-Hand` holdable, which is not how WoW works) and
needs a correctness pass before being wired in, rather than blindly connecting it.

### BUG 17 — Most TBC/Wrath `atlasKey` values didn't match AtlasLoot's real keys
**Symptom**: "No recommendations found" for level 60-70 characters (Outland dungeons), even with
AtlasLoot fully loaded/enabled and BUG 16 (weapon slot mapping) fixed. Also silently zero items
for all 4 Scarlet Monastery wings (levels 28-45).
**Root cause**: `InitFromAtlasLoot()` looks up `AtlasLootNewBossButtons[dungeon.atlasKey]` — if the
key doesn't exist in that table, the dungeon's `ItemCache` entry is simply never populated (no
error, just silently empty). Checked every `atlasKey` in Data.lua against the real keys in
`AtlasLoot/AtlasLayout/instances.en.lua` and found:
  - ALL 13 non-Magisters'-Terrace TBC dungeons had wrong keys — AtlasLoot prefixes these with the
    zone/wing abbreviation (`HC`=Hellfire Citadel, `CFR`=Coilfang Reservoir, `Auch`=Auchindoun,
    `CoT`=Caverns of Time, `TempestKeep`), which Data.lua's atlasKeys didn't include at all
    (e.g. `TheBloodFurnace` vs actual `HCBloodFurnace`, `TheSlavePens` vs `CFRTheSlavePens`).
  - `HallsOfStone`/`HallsOfLightning` (Wrath) were missing the `Ulduar` prefix
    (`UlduarHallsofStone`/`UlduarHallsofLightning`).
  - All 4 Scarlet Monastery wings shared one bogus key `ScarletMonastery`; AtlasLoot actually keys
    them separately as `SMGraveyard`/`SMLibrary`/`SMArmory`/`SMCathedral`.
**Fix**: Corrected all 16 wrong atlasKeys in Data.lua. Verified every one of the 55 dungeon
atlasKeys now has a matching top-level key in `AtlasLootNewBossButtons` (scripted check against
`instances.en.lua`).
**Rule**: Never assume an `atlasKey` string is correct just because it "looks like" the dungeon
name — AtlasLoot's internal keys use inconsistent zone-abbreviation prefixes per expansion.
Always verify new atlasKeys against the actual `AtlasLootNewBossButtons` table contents (or a
scripted check like the one used here) before trusting them.

### BUG 18 — Relics (Totem/Libram/Idol/Sigil) recommended to every class
**Symptom**: A Priest was recommended `[Totem of the Thunderhead]` and `[Libram of Saints Departed]`
— items no Priest can ever equip.
**Root cause**: Two compounding gaps:
  1. No filter existed for relic subtypes at all. `CanEquipArmorType` only checks
     Cloth/Leather/Mail/Plate; relics (itemType "Armor", subType `Librams`/`Idols`/`Totems`/`Sigils`
     — plural, confirmed against Baggins-Filtering.lua's class list) fell through with no
     restriction, unlike actual armor which is gated by `CLASS_ARMOR`.
  2. `ITEM_SLOT_TO_EQUIPPED` had no `Relic -> Ranged` mapping (it had a dead `Totem -> Ranged` entry
     that could never be reached, since `GetSlotFromItemID` returns `"Relic"`, not `"Totem"`, for
     these items). So `GetEquippedItem("Relic")` always returned nil, meaning every relic was
     scored as filling an empty slot — a guaranteed "upgrade" for any class, valid or not.
**Fix**: Added `RELIC_SUBTYPES` / `CLASS_RELIC` tables and `CanEquipRelic(subType, playerClass)`
(Paladin→Librams, Druid→Idols, Shaman→Totems, Death Knight→Sigils; every other class denied
outright). Wired it into `GetRecommendations` right next to the existing `CanEquipArmorType` check.
Also fixed `ITEM_SLOT_TO_EQUIPPED` to map `Relic -> Ranged` so relic-using classes get a proper
upgrade-score comparison against whatever they currently have equipped in that slot, instead of
every relic looking like a free empty-slot upgrade.
**Rule**: Relics share inventory slot 18 with wands/ranged weapons but are strictly one-subtype-
per-class — like armor types, they need an explicit class allowlist, not just "is it the right
itemType". Any item category with hard class restrictions (armor proficiency, relic type, weapon
skill) needs its own allowlist checked in `GetRecommendations`; `CanEquipArmorType` alone does not
cover non-armor-type restrictions.

### BUG 19 — All items showed "+0" score once Pawn was involved
**Symptom**: Every item row in the UI displayed a score of `+0`, even for items that were clearly
real upgrades and correctly passed the `upgradeScore > 0` filter to appear in the list at all.
**Root cause**: `CalculateUpgradeScore`'s Pawn-scoring branch multiplied the Pawn score delta by an
arbitrary `0.05` (`(newPawn - eqPawn) * 0.05`), while the built-in stat-weight branch just below it
returns the raw, unscaled `itemScore - equippedScore`. Pawn is installed on this account/character
(confirmed via `SavedVariables/Pawn.lua`), so `GetActivePawnScale()` returns a scale and the Pawn
branch runs for every item. Typical per-item deltas at appropriate level (single-digit to low
double-digit point differences) got crushed to well under 1.0 by the `* 0.05` factor, and the UI
formats the score with `%.0f` (`CreateItemRow` in UI.lua), which rounds anything below 0.5 down to
`0`. The item was still correctly sorted/ranked internally (the tiny positive float was real and
`> 0`), it just always *displayed* as `+0`.
**Fix**: Removed the `* 0.05` scaling from both Pawn-branch return paths in `CalculateUpgradeScore`,
so Pawn-based scores are on the same raw scale as the built-in weight-based scores (both are now a
direct, unscaled score delta).
**Rule**: Don't apply an ad-hoc scaling constant to only one of two code paths that feed the same
downstream display/threshold logic (`upgradeScore > 0` filter, `%.0f` display, score-color bucket
thresholds at 3/10 in `CreateItemRow`) — it silently breaks the assumption that both paths produce
comparable magnitudes.

---

## Known Limitations (not bugs, working as designed)

### Uncached items cannot be stat-filtered
For items the player has never encountered, `GetItemStats` returns nil. The fallback scores
purely on ilvl delta with slot-type penalties for caster vs melee weapons/armor. A tank ring
and a caster ring of the same ilvl look identical when uncached. Once the player visits the
dungeon and the items get cached, proper stat scoring kicks in on next refresh.

### Dungeon items depend on AtlasLoot being installed
Items are read from AtlasLoot runtime tables. If AtlasLoot or its expansion modules are not
installed, `InitFromAtlasLoot()` builds an empty ItemCache and no recommendations appear.
AtlasLoot modules are LoadOnDemand — `InitFromAtlasLoot` calls `LoadAddOn` on them.

### GameTooltip preloader is unreliable
The `StartServerQuery()` preloader attempts to cache items via hidden tooltip Show/Hide cycles,
but this does not reliably trigger server queries on private servers. Items remain uncached
until the player physically encounters them in-game.

---

## Lua 5.1 Constraints (WoW 3.3.5a)
- **No `goto` or `continue`**: Use `break` with a flag variable, or restructure loops.
- **No `table.unpack`**: Use `unpack()` (global in Lua 5.1).
- **Integer division**: Use `math.floor(a/b)`, not `//`.
- **String formatting**: `string.format` / `format` (global alias). No string interpolation.
- **Duplicate table keys are silent bugs**: `{["a"]=1, ["a"]=2}` → `{["a"]=2}`. No warning.
- **Nil in pairs()**: `pairs` skips nil values. Never assume sequential access on sparse tables.
- **No bitwise operators**: Use bit library (`bit.band`, `bit.bor`, etc.) if needed.

---

## Data.lua Dungeon Definition Format
```lua
["rfc"] = {
    name = "Ragefire Chasm", minLevel = 13, maxLevel = 16, faction = "Horde",
    location = "Kalimdor", zone = "Orgrimmar", expansion = "Classic",
    atlasKey = "RagefireChasm",  -- key into AtlasLootNewBossButtons
},
```
- `name` — display name for the dungeon
- `minLevel` / `maxLevel` — level range filter
- `faction` — optional, "Horde" or "Alliance" (nil = both)
- `location` / `zone` — for display purposes
- `expansion` — "Classic", "TBC", or "Wrath"
- `atlasKey` — maps to `AtlasLootNewBossButtons[atlasKey]` for runtime item retrieval

**NO items are stored in dungeon definitions.** All item data comes from AtlasLoot at runtime.

## Item data flow
1. `InitFromAtlasLoot()` force-loads AtlasLoot expansion modules (`LoadAddOn("AtlasLoot_*")`)
2. Walks `AtlasLootNewBossButtons[dungeon.atlasKey]` for boss table keys
3. Reads `AtlasLoot_Data[bossKey]` for item entries → extracts `entry[2]` (itemID)
4. Stores `ItemCache[dungeonKey] = {deduplicated itemIDs}`
5. `GetItemsForLevel(level, class)` filters by dungeon level range, returns flat `{itemID}` list
6. `GetRecommendations` calls `GetItemInfo(itemID)` for real name/ilvl/slot at scoring time

## AtlasLoot data format (for EnrichFromAtlasLoot)
```lua
{ index, itemID, iconRef, "=qN=Item Name", "=ds=#sN# #aN#", "", "drop%" }
```
- Field 2 = numeric item ID
- Field 4 = item name prefixed with `=qN=` where N is quality (1=white, 2=green, 3=blue, 4=purple)
- Match by stripping `=qN=` prefix and comparing names

---

## STAT_PROFILES quick reference (Core.lua)
Each class has a `default` sub-table used when spec is "No Talents" or unrecognised, plus
named spec sub-tables. Spec names match exactly what `GetTalentTabInfo` returns in 3.3.5a:
- Warrior: "Arms", "Fury", "Protection"
- Paladin: "Holy", "Protection", "Retribution"
- Hunter: "Beast Mastery", "Marksmanship", "Survival"
- Rogue: "Assassination", "Combat", "Subtlety"
- Priest: "Discipline", "Holy", "Shadow"
- Shaman: "Elemental", "Enhancement", "Restoration"
- Mage: "Arcane", "Fire", "Frost"  ← Mage only has default currently (all specs share weights)
- Warlock: "Affliction", "Demonology", "Destruction"  ← Warlock only has default currently
- Druid: "Balance", "Feral Combat", "Restoration"
- Death Knight: "Blood", "Frost", "Unholy"

Stat short keys used in weight tables (mapped from GetItemStats API keys in STAT_KEY_TO_SHORT):
`STR AGI STA INT SPI HIT CRIT HASTE EXPERTISE ARMOR_PEN DEFENSE DODGE PARRY BLOCK AP SP MP5`

## CLASS_ARMOR filter (Core.lua)
Defines which armor types each class can equip. Used by `CanEquipArmorType(subType, class, level)`:
- Cloth-only: PRIEST, MAGE, WARLOCK
- Leather: DRUID, ROGUE (+ cloth)
- Mail at 40: HUNTER, SHAMAN (+ cloth, leather). Level threshold: `CLASS_MAIL_LEVEL`
- Plate at 40: WARRIOR, PALADIN (+ cloth, leather, mail). Level threshold: `CLASS_PLATE_LEVEL`
- Plate at 55: DEATHKNIGHT. Level threshold: `CLASS_PLATE_LEVEL`

When a filter check fails (`CanEquipArmorType` returns false), the item is skipped entirely
(not just scored low). This prevents showing plate items to cloth classes at any score level.

## EQUIP_LOC_MAP (Core.lua)
Maps `GetItemInfo` equipLoc strings (e.g. `"INVTYPE_CHEST"`) to our slot names (e.g. `"Chest"`).
Weapon types use `WEAPON_SUBTYPE_MAP` to map `itemSubType` (e.g. `"One-Hand Swords"`) to our
slot names (e.g. `"One-Hand Sword"`).
Unmapped slots fall through to armor fallback in `GetSlotFromItemID`.

---

## playerStatProfile (public variable)
`DungeonDrops.playerStatProfile` is set by `BuildStatProfile()` and is public.
Any part of the addon can read it:
```lua
DungeonDrops.playerStatProfile = {
    weights  = { INT=1.5, SPI=1.2, DODGE=-3, ... },  -- full signed weights
    source   = "builtin",   -- or "pawn" if Pawn is loaded with a visible scale
    class    = "PRIEST",
    spec     = "Holy",
    pawnScale = nil,        -- name of active Pawn scale, or nil
}
```
This powers both the item recommendation scoring (`GetItemStatScore`) and the My Stats panel
(`GetStatAnalysis`). Any future feature that needs to know what stats the player values can
read `DungeonDrops.playerStatProfile.weights` directly.

---

## Immediate Next Steps
1. ✅ Test My Stats panel in-game for Paladin Holy, Shaman Enhancement, Feral Druid
2. ✅ Add Arcane/Fire/Frost spec variants to Mage profile if spec matters for that content
3. ✅ Stat-gap / My Stats panel — implemented via `GetStatAnalysis` + `ShowStatAnalysis`
4. ✅ Complete architectural refactor: all item data now from server via AtlasLoot at runtime
5. ✅ Deduplicate items from AtlasLootNewBossButtons duplicate entries
6. ✅ Add LoadOnDemand expansion module loading
