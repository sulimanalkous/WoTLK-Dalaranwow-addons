# DugisGuideViewerZ Addon Analysis and Modifications

This document summarizes the understanding of the `DugisGuideViewerZ` addon's functionality and the modifications attempted to integrate new dungeon guides.

## Addon Structure and Key Functions

The addon's core logic resides primarily in `DugisGuideViewer.lua`.

### 1. Guide Registration (`DugisGuideViewer:RegisterGuide`)
-   **Purpose:** This function is how guides are registered with the addon. It takes `title`, `nextguide`, `faction`, `guidetype`, and `rowinfo` (a function returning the guide content).
-   **Loading Mechanism:** For guides to appear in the addon, `RegisterGuide` must be executed when the game loads the corresponding Lua file. Original leveling guides call this function directly at the top level of their files.
-   **Data Storage:** Registered guides populate `self.guides` (mapping title to `rowinfo` function), `self.nextzones`, `self.gtype`, and `self.guidelist` (for UI display).

### 2. Content Decoding (`DugisGuideViewer:Retxyz`)
-   **Purpose:** This function decodes the "encrypted" guide content.
-   **Mechanism:** It implements a Caesar cipher with a `+3` shift for printable ASCII characters. It also handles multi-byte characters.
-   **Activation:** Decoding is activated by an `on` flag, which is set to `true` if `Retxyz` is called with `i=1` and `t="AAA"`. If `i=1` is not "AAA", decoding is disabled for that guide.

### 3. Guide Parsing (`DugisGuideViewer:ParseRows`)
-   **Purpose:** This function takes the raw (encoded) guide content, decodes it line by line, and populates internal tables (`DugisGuideViewer.actions`, `DugisGuideViewer.quests1`, `DugisGuideViewer.qid`, etc.).
-   **Input:** It receives the guide content as varargs (`...`) from a `string.split` operation.
-   **Line Processing:** For each line, it calls `Retxyz` to decode, then uses a regex (`"^(%a) ([^|]*)(.*)"`) to extract the action, quest name, and tags.
-   **Filtering:** It filters steps based on class (`|C|`) and race (`|R|`) tags.

### 4. State Management (`DugisGuideViewer:SetQuestsState`)
-   **Purpose:** Determines the initial state of a guide when selected (which steps are complete, which is current).
-   **Mechanism:**
    -   It iterates through all steps, checking `DugisGuideViewer:HasQuestBeenTurnedIn(qid)` and `DugisGuideViewer:GetQuestLogIndexByQID(qid)` to mark steps as "C" (Complete).
    -   It then uses a `while` loop to find the first step that is "U" (Unchecked) and not skippable by `CheckForOptionalLoot` or `CheckForLocation`.
    -   The `CurrentQuestIndex` is set to this found step, and `DugisGuideViewer:SetToQuestNumber` is called to highlight it.

## Problems Encountered and Hypotheses Tested

### 1. Initial Content Encoding (Solved)
-   **Problem:** New guides appeared as garbled text.
-   **Hypothesis:** Incorrect encoding.
-   **Solution:** Developed `correct_converter.py` to apply a `-3` Caesar cipher shift, reversing `Retxyz`.

### 2. Incorrect Guide Titles (Solved)
-   **Problem:** Titles showed IDs like "279(17-21)".
-   **Hypothesis:** Missing mapping for dungeon IDs.
-   **Solution:** Modified `correct_converter.py` to extract dungeon names and levels directly from filenames, making titles accurate.

### 3. "Guide Complete" on Selection (Solved by Saved Variable Reset)
-   **Problem:** Guides immediately showed "Complete" upon selection.
-   **Hypothesis 1:** Missing "Next Guide" parameter. (Incorrect)
-   **Hypothesis 2:** `|QID|` tags causing auto-completion due to `HasQuestBeenTurnedIn`. (Partially correct, but not the immediate cause of "complete" state).
-   **Solution:** User confirmed this was due to persisted saved variables. Resetting `DugisGuideViewerZ.lua` in the WTF folder resolved this.

### 4. Guides Not Appearing in List (Solved)
-   **Problem:** After a script change, the entire guide list became empty.
-   **Hypothesis:** Incompatible module structure.
-   **Solution:** Modified `correct_converter.py` to extract the `RegisterGuide` call from within the `RegisterModule` structure and place it at the top level of the generated `.lua` file, mimicking original leveling guides.

### 5. No Step Highlighted / Steps Not Advancing (Current Unresolved Issue)
-   **Problem:** Guides appear in the list, but no step is highlighted, and steps do not advance automatically or manually.
-   **Hypothesis 1 (Initial):** `ParseRows` failing due to `AAA` line being treated as a step. (Incorrect, `AAA` is skipped).
-   **Hypothesis 2 (Current):** `ParseRows` failing to populate `DugisGuideViewer.actions` (and thus `LastGuideNumRows` is 0) because the regex `text:find("^(%a) ([^|]*)(.*)")` is failing on the *decoded* text.
    -   **Evidence:** User's debug output `testtag=11.5` suggests `getCoords` is receiving malformed data, implying `quests2` (populated by `ParseRows`) is incorrect.
    -   **Specific Suspect:** The `Retxyz` function's `on` flag logic combined with `string.split`'s behavior. The `string.split("
", "
" .. self.guides[title]())` call produces an initial empty string `""` as the first element. This causes `Retxyz` to be called with `i=1` and `t=""`, which prevents the `on` flag from being set to `true` when `AAA` is processed (as `AAA` is at `i=2`). Consequently, `Retxyz` never decodes the content, and `ParseRows` attempts to match its regex against *encoded* text, which fails.
-   **Proposed Debugging:** Injecting `DebugPrint` statements into the generated Lua code to trace `ParseRows` execution, `Retxyz` output, and regex matching results.

## Changes Made to Files

### `correct_converter.py`
-   **Initial Encoding:** Implemented Caesar cipher for content.
-   **Title Generation:** Logic to extract dungeon names and levels from filenames.
-   **Module Extraction:** Logic to find `RegisterGuide` call within `RegisterModule` structure and place it at the top level.
-   **`AAA` Header:** Ensured `AAA` and a blank line are present after `return [[`.
-   **`nextguide` parameter:** Correctly resolved and populated.
-   **Debug Injection:** Added `DebugPrint` statements into the generated Lua code to trace `ParseRows` execution.

### `DugisGuideViewer.lua`
-   **Debug Flag:** Changed `local Debug = 0` to `local Debug = 1` to enable debug output in WoW.

## IMPORTANT CORRECTION — the `"\n" ..` prefix theory below was WRONG

An earlier pass through this session concluded the `"\n" .. self.guides[title]()` prefix at the
`ParseRows`/`getGuideSize` call sites was an off-by-one bug, "fixed" by removing it, and this file
briefly said so. **That was disproven and the change was reverted.** Removing the prefix broke
guide display entirely (empty guide window, empty compact window) — confirmed by the user
in-game. The prefix is correct **as shipped**; do not remove it again.

Root cause of the earlier confusion: reasoning about `string.split`'s behavior was done with a
hand-written Lua stand-in for WoW's real (C-implemented) `string.split`/`strsplit`, which does
**not** behave the same way the offline stand-in did around a leading delimiter. Real in-game
`Retxyz` debug captures (see below) prove `"AAA"` lands at split-index **1** exactly as the code
expects, `on` activates correctly, and every subsequent row decodes into perfectly correct,
readable guide text (verified end-to-end: action codes, `|N|` notes, coordinates, `|QID|`s all
intact). **The parsing/decoding engine (`Retxyz` + `ParseRows`) is not broken and needs no fix.**

Lesson: when a hypothesis about engine behavior can't be tested against the real WoW client
directly, get real captured data from the client (e.g. write suspect values into an existing,
already-working SavedVariable table, `/reload`, then read the resulting file) before changing
"working" code based on an offline simulation. Also: the `Read` tool silently drops/renders
non-printable bytes (e.g. the cipher's encoded-space byte `0x1D`) when displaying file content —
always re-derive raw bytes via a script (`open(path, 'rb')`) rather than eyeballing/retyping
Read-tool output when byte-exact data matters.

## What was actually wrong (found via real in-game verification)

The addon's guide **engine** works. The problem was always **bad guide content**:

1. **Previously-converted classic dungeon guides reference quest/NPC IDs that don't exist on this
   server.** Checked directly against the account's own `DungeonDrops/TDB_full_335.63_2017_04_18.7z`
   SQL dump (the real Warmane/TrinityCore 3.3.5 world database). Example: `DugisGuide_Dungeons_
   Alliance_En/15_17_The_Deadmines.lua` references quest IDs 27790/27756 and NPC IDs 46612/47162
   ("The Foreman") — **none of these exist in `quest_template`/`creature_template`.** That data is
   from a modern/Cataclysm-redesigned Deadmines (Vanessa VanCleef storyline), not the original
   classic dungeon that exists in 3.3.5a. This affects the whole `DugisGuide_Dungeons_Alliance_En`
   / `DugisGuide_Dungeons_Horde_En` folder — **not yet rebuilt, still broken**.
2. **`DugisGuide_WOTLK_Dungeons_A` / `_H` (Wrath dungeon guides) are empty stub files** — literally
   6 bytes (`return`), no `RegisterGuide` call at all. Never actually got real content.
3. **One file crashes on load**: `DugisGuide_Dungeons_Alliance_En/51_58_Blackrock_Depths_Upper.lua`
   still uses the modern `local Guide = DugisGuideViewer:RegisterModule(...)` wrapper. This
   engine build (v4.19) has **no `RegisterModule` function at all** (confirmed: zero matches
   grepping the live `DugisGuideViewer.lua`) — calling it is a hard Lua error
   (`attempt to call method 'RegisterModule' (a nil value)`) every time this file loads.
   **Fixed this session**: disabled its `<Script>` line in that folder's `Guides.xml` (commented
   out, file left on disk for future proper conversion). Swept the whole addon folder for any
   other stray `RegisterModule` usage — only one other hit, `test_conversion.lua` at the addon
   root, which isn't referenced by any `Guides.xml`/`.toc` entry so it was never actually loaded
   (harmless leftover, not fixed, not urgent).

## Work completed this session: Outland (TBC) dungeon guides rebuilt from verified data

Built fresh Outland (levels 58-70) dungeon guides from `Dugis Guide All/
DugiGuides_TBCAnniversary_2.13.zip` (Blizzard's Burning Crusade Classic Anniversary package —
period-correct quest/NPC IDs, unlike the modern MoP package which uses retrofitted IDs).

**Verification method**: extracted the full `TDB_full_world_335.63_2017_04_18.sql` from the
account's own TDB dump, built a set of every valid `quest_template` ID, and checked every single
`|QID|` referenced in the source files against it before shipping anything.

**Findings from that check**: 113 of 120 unique quest IDs across all 16 dungeons × 2 factions were
valid. The other 7 — all in the level-70 "endgame" dungeons (Shattered Halls, Shadow Labyrinth,
Botanica, Mechanar, Arcatraz, Magisters' Terrace, Black Morass) — referenced Anniversary-event-only
quest content (e.g. fake NPC 55007, quests like "Severed Communications") that doesn't exist in
real WotLK/3.3.5a data. Those specific lines were stripped programmatically (any line containing
an invalid `|QID|N|` dropped entirely, not just cosmetically edited) — necessary, not just tidy,
because a step referencing an untrackable quest would permanently stall `SetQuestsState`'s
"find the first incomplete step" logic.

**Conversion pipeline** (`convert_tbc.py`, written this session, not saved into the addon folder —
lives in the session scratchpad only): parses the source files' modern
`RegisterModule`/`Guide:Load()` wrapper (8-argument `RegisterGuide` call, tolerant of literal `nil`
args), derives a unique per-dungeon title from the filename (source files share one generic title
across the whole 58-70 Outland chain, which would silently collide/overwrite in `self.guides` if
used as-is), resolves "next guide" references to another dungeon's title only when that ID is
itself one of the 16 dungeons converted (cross-references to outdoor zone guides outside this
batch resolve to empty), Caesar-shifts the (plaintext, not yet ciphered) source content into the
form `Retxyz` expects, and emits old-style flat `RegisterGuide(title, nextguide, faction,
guidetype, function() ... end)` calls matching what this engine build requires.

**Note on scope of content**: these guide files are the *original* TBC Anniversary source
material, which is really "quest through the outdoor zone, and the dungeon's own quest chain is
at the end" content (e.g. Hellfire Ramparts' file is mostly Hellfire Peninsula outdoor quests,
with the actual "enter dungeon → kill 3 bosses → turn in" chain only in its last ~15 lines,
identifiable via the `|I|` "instance entry" tag and `|DMAP|` "in-dungeon objective" tags). This
was **not trimmed down** to dungeon-only content — shipped as full files. Reasoning: the addon's
own `HasQuestBeenTurnedIn`-based state detection should auto-skip whatever outdoor prerequisite
quests the player has already completed and land on the real next actionable step, so a level-63+
character should land close to the dungeon-relevant part anyway without needing manual trimming
(which also risks cutting a chain that continues into the *next* sequential file — confirmed
happening for at least Slave Pens, whose "Lost in Action" quest accept has no turn-in in that same
file, it's presumably in the following zone's guide file, not converted here). If in-game testing
shows this produces confusing/wrong results (e.g. it insists on outdoor prerequisites a
tank/healer player skipped by queuing via LFD), revisit with a proper `|I|`/`|DMAP|`-based trim.

**Shipped**: `DugisGuideViewerZ/DugisGuide_Outland_Dungeons_A/` and `_H/`, one file per dungeon
(Hellfire Ramparts through Magisters' Terrace, 16 each), plus `Guides.xml` in each folder, both
registered in `DugisGuideViewerZ.toc`. All 32 files pass `luac -p` syntax validation. One data typo
fixed by hand: both `68_70_The_Steamvault.lua` files had `guidetype = "i"` (lowercase) in the
source, which would silently exclude Steamvault from the engine's `guidelist["I"]` instance-tab
grouping (case-sensitive equality check) — corrected to `"I"` in both.

## Also fixed this session (both confirmed real, unrelated to the above)

### `SmallWindowTooltip_OnEnter` nil-error
**Symptom**: hovering the compact/mini guide window threw `attempt to index a nil value` at
`DugisGuideViewer.lua:1707`.
**Root cause**: it read `getglobal("RecapPanelDetail" .. CurrentQuestIndex .. "Desc"):GetText()`,
but `RecapPanelDetailN` frames are created dynamically, one per row, only when the *large* guide
window renders its step list. If a guide is only ever viewed in the compact/mini window, that
frame for the current step number may never have been created.
**Fix**: read the step text directly from `DugisGuideViewer.quests2[CurrentQuestIndex]` (the same
table `PopulateSmallFrame` already sources the compact window's own label from) instead of relying
on a frame that may not exist for that UI mode. Still in place, not reverted.

## Bug found and fixed this session: `ContToUse` nil-concat crash in `MapCurrentObjective`

**Symptom** (from in-game test after the Outland-guide work above): selecting a step in one of the
new Outland guides threw `attempt to concatenate local 'ContToUse' (a nil value)` at
`DugisGuideViewer.lua:733`, called via `MapCurrentObjective` ← `SetToQuestNumber` ←
`SetQuestsState` ← `DisplayViewTab`.

**Root cause**: classic Lua variable-shadowing bug, pre-existing in the shipped engine (not
introduced by the Outland conversion). `MapCurrentObjective` (around line 686) declares
`local ZoneToUse` (line 689) and, inside the TomTom-waypoint block, `local ContToUse` (line 701) in
the outer function scope. It then picks one of three branches to populate them: a `|Zone=|` note
tag, the guide's own stated zone (`IsZoneNameValid(CurrentZone)`), or a fallback default — and that
fallback branch read:
```lua
else
  local ZoneToUse, ContToUse = GetCurrentMapZone(), GetCurrentMapContinent()
```
The `local` here declares *brand new* variables scoped only to that `else` block, shadowing the
outer ones instead of assigning to them. The outer `ContToUse` stays `nil` forever, and every later
use of it (lines 731/733/734, building/adding the TomTom waypoint) crashes.

This branch is only reached when neither of the first two zone-resolution paths succeeds — i.e.
when a guide's title-derived zone name isn't present in the engine's internal `zonei`/`zonec`
lookup tables (checked via `IsZoneNameValid`/`GetZoneNumberFromZoneName`/
`GetContinentNumberFromZoneName`, all simple table lookups keyed by zone name). The new Outland
guides are apparently the first content this engine build has ever loaded whose zone name isn't in
that table, which is why this dormant bug had never fired before.

**Fix applied (part 1)**: removed the `local` keyword so the assignment writes to the existing
outer-scope variables instead of shadowing them:
```lua
else
  ZoneToUse, ContToUse = GetCurrentMapZone(), GetCurrentMapContinent()
```

**Second occurrence, different root cause, confirmed via a level-33 mage doing Razorfen Kraul (a
classic dungeon guide, unrelated to the Outland batch)**: same crash, same line, *after* the part-1
fix was already in the file (verified by reading the file back — the `local` was gone). This proved
the shadowing wasn't the only problem: `GetCurrentMapContinent()`/`GetCurrentMapZone()` reflect
whichever zone the World Map UI is currently "looking at," not necessarily the player's real
location — they only reliably reflect the player's actual position after `SetMapToCurrentZone()`
has been called at least once. Since a normal player never opens the world map before triggering
this code path, the API can return `nil`, and `ContToUse` crashes again for an unrelated reason.

**Fix applied (part 2)**: call `SetMapToCurrentZone()` immediately before reading the two values in
that fallback branch, plus an added guard right after the if/elseif/else that returns early
(skipping just the waypoint for this step, not the whole guide) if `ZoneToUse`/`ContToUse` still
came back nil from any branch — this is a boundary against an external Blizzard API whose behavior
isn't fully controlled by this addon, so defensive handling here is warranted (unlike elsewhere in
the codebase):
```lua
else
  SetMapToCurrentZone()
  ZoneToUse, ContToUse = GetCurrentMapZone(), GetCurrentMapContinent()
  DebugPrint("Default zone" .. ZoneToUse)
end
if not ZoneToUse or not ContToUse then
  DebugPrint("MapCurrentObjective: could not resolve zone/continent, skipping waypoint")
  return
end
```
`luac -p` passes on the modified file. Not yet re-tested in-game.

**Follow-up worth checking**: this fallback branch fires whenever a guide's title-derived zone name
doesn't match an entry in `zonei`/`zonec` (populated from `GetMapContinents()`/`GetMapZones()` at
file load, so these are real Blizzard zone-name strings). Worth checking, once testing resumes,
whether the guide's declared zone name is simply wrong/missing (e.g. a mismatch introduced by
`convert_tbc.py` or the earlier `correct_converter.py`) rather than always relying on the
current-position fallback — the fallback now works without crashing, but a `|Zone=|` tag or a
correct title zone name would give more accurate waypoints than "wherever the player happens to be
standing right now."

## Work completed this session: classic dungeon guides (13-58) rebuilt from verified data

Same treatment as the Outland rebuild. Root cause (documented above under "What was actually
wrong"): the previously-shipped classic dungeon guides in `DugisGuide_Dungeons_Alliance_En`/
`_Horde_En` came from a source that used Cataclysm-redesigned quest/NPC content — this is also
almost certainly the explanation for the user's separate observation ("guides say go to the
dungeon first, before collecting quests") since Cataclysm's revamp of old dungeons commonly moved
quest givers inside the instance, unlike the original design of gathering quests outside first.

**Source**: `Dugis Guide All/DugiGuides_ClassicEra_1.89.zip` (Blizzard's Classic Anniversary
package) → `DugisGuideViewerZ/DugisGuide_Dungeon_Alliance_En/` and `_Horde_En/`, 15 dungeon files
each, same modern `RegisterModule`/`Guide:Load()` 8-arg `RegisterGuide` wrapper format as the TBC
Anniversary source used for Outland.

**Verification**: extracted `quest_template` (9,464 IDs) and `creature_template` (29,923 IDs) from
the account's own TDB dump (same one used for Outland and for `DungeonDrops`). Checked every single
`|QID|` and NPC reference (`|NPC|`/`(npc:N)`) across all 30 source files (15 dungeons × 2 factions)
against these sets. **Result: 100% valid — 276/276 unique quest IDs, 306/306 unique NPC IDs. Zero
lines needed stripping.** Notably cleaner than Outland (which had 7 invalid IDs from
Anniversary-event-only endgame content) — the classic 13-58 source apparently has no such
event-exclusive content mixed in.

**Conversion pipeline**: `convert_classic.py`, written this session and saved into the addon folder
(unlike the Outland session's `convert_tbc.py`, which was left in scratchpad only and is now lost —
lesson applied). Also saved `valid_quest_ids.txt` and `valid_creature_ids.txt` (the verified ID
sets extracted from the TDB dump) into the addon folder alongside it, so a future Wrath-guide
rebuild can reuse both the script and the ID sets without re-extracting the 7z/SQL dump. Unlike the
Outland source (which reused one generic title across the whole chain, requiring the converter to
derive unique titles from filenames), the ClassicEra source already gives each dungeon a unique,
correctly formatted title in its own `RegisterGuide` call — simpler case, titles used as-is.
Handles one format wrinkle Outland's source didn't have: the last dungeon in each faction's chain
passes a literal `nil` (not a quoted string) for the "next guide" argument.

**Scope note — coverage gap, not a bug**: the ClassicEra source does not include every dungeon the
previous (broken) conversion attempted. Missing from both factions: **Dire Maul** (East/West/North)
entirely. Missing from Alliance only: **Shadowfang Keep** (Horde's copy exists; Alliance's own quest
path to it apparently isn't covered by this dungeon-guide package, likely folded into an outdoor
Duskwood/Silverpine guide instead). **Blackrock Depths** is one consolidated file here (matching
the source), replacing the old broken two-file split (`..._Detention.lua` / `..._Upper.lua`). This
means the old `51_58_Blackrock_Depths_Upper.lua` — the file that used the incompatible
`RegisterModule` wrapper and crashed this engine build, previously just disabled via a commented-out
`Guides.xml` line — no longer exists at all; that fix is now moot rather than pending. If Dire Maul
/ Alliance Shadowfang Keep guides matter, they'd need sourcing and converting separately (no
verified Blizzard Classic-Anniversary source for them found yet).

**Also cleaned up in passing**: the old `Guides.xml` in both folders carried `<Script>` references
to `..\DugisGuide_Cata_Dungeon_A\*.lua` / `_H\*.lua` — those folders **don't exist on disk at all**,
so these were already-dead references predating this session (not something this session broke).
Regenerating `Guides.xml` from the new file list dropped them; also dropped the (harmless, since
they're 6-byte `return`-only stubs per item 4 below) references to `DugisGuide_WOTLK_Dungeons_A/_H`
that lived in the same file — those stub files are untouched on disk, just no longer referenced
from this particular `Guides.xml`. Neither change should affect current behavior since both
referenced nothing that actually registered a guide.

**Shipped**: `DugisGuideViewerZ/DugisGuide_Dungeons_Alliance_En/` and `_Horde_En/`, 15 files each,
old broken files and `.lua.backup` leftovers removed, fresh `Guides.xml` per folder. All 30 files
pass `luac -p`. Round-trip decode spot-checked by hand (simulating the engine's `+3` Retxyz shift
against the encoded output) — confirmed byte-exact match to the original plaintext source line.
`DugisGuideViewerZ.toc` needed no changes (same folder/file names as before).

## Bug found and fixed this session: `.toc` manifest needs a full client restart, not just relog

**Symptom**: after the classic dungeon rebuild, user debug-printed `#DugisGuideViewer.guidelist["I"]`
and got 17 (16 Outland + only 1 classic entry), with the guide-browsing experience jumping straight
from an early classic dungeon to Outland content, nothing in between. A full relog (log out to
character select and back in) did **not** fix it.

**Root cause**: this was stale addon-manifest state, not a bug in the new files — confirmed because
running the actual `RegisterGuide` function (copied verbatim) through a standalone Lua interpreter
against all 15 shipped files, in the exact `.toc` load order, correctly registers all 15 in order
every time. **A full client exit and restart** (not just `/reload` or relog-to-character-select)
was required before the fresh file list actually took effect. Whatever caches the addon's `.toc`-
declared file list on this client apparently survives a character-select relog but not a full
process restart. Confirmed fixed by the user after a full exit/restart.

**Takeaway for future sessions**: when shipping changes to a `Guides.xml`/`.toc` file list (as
opposed to editing an already-loaded file's contents), tell the user up front that a full client
restart may be needed to verify, not just `/reload`.

## Bug found and fixed this session: wrong TomTom waypoints (guide's title zone used for every step)

**Symptom**: reported by user testing a classic dungeon chain — a step whose actual location was
Undercity got a waypoint in Hillsbrad Foothills instead (the character walked to the wrong place
entirely).

**Root cause**: found by comparing the Anniversary-sourced dungeon content (Outland + this
session's classic rebuild) against the addon's own original, presumably-correct leveling guides.
In the original leveling guides, the `|Z|` tag stores a real zone **name** string, e.g.
`|Z|Stormwind City|` — exactly what `MapCurrentObjective`'s call to
`GetZoneNumberFromZoneName`/`GetContinentNumberFromZoneName` (both simple `zonei`/`zonec` table
lookups keyed by real Blizzard zone-name strings, populated from the live `GetMapContinents()`/
`GetMapZones()` API) expects, and it resolves correctly there. But the Anniversary source package
encodes that same tag as a raw **numeric ID** instead (e.g. `|Z|1413|`, `|Z|1458|` for Undercity) —
a completely different addressing scheme (almost certainly a Blizzard AreaID) that this old
3.3.5a-era engine has no live API to resolve by number, only by name. So `zonei["1458"]` always
silently returns `nil`, `MapCurrentObjective` falls through to using **the guide's own title zone**
for that waypoint (e.g. "Uldaman" or whatever dungeon guide is open) regardless of the step's real
location — wrong for any step that sends the player back to a capital city or a different zone
mid-chain, which is common in this source content (many classic quest chains detour through
Undercity/Orgrimmar/Stormwind for class-quest turn-ins).

This is a **pre-existing engine limitation exposed by new content**, not a bug introduced by this
session's conversions — it would affect any guide (mine or otherwise) that ever ships an Anniversary-
style numeric `|Z|` tag. It stayed invisible before because (a) the original leveling guides always
use name-string `|Z|` tags, and (b) dungeon guides previously crashed before ever reaching this code.

**Fix**: the real zone name is already present as plain, human-readable `{ZoneName}` markup in the
same line's note text (e.g. `{Undercity}`, `{Ratchet}`) — used only for cosmetic display previously
(`SetQuestText` prints it as literal text, nothing parses it). Added a new, highest-priority branch
in `MapCurrentObjective` (`DugisGuideViewer.lua` around line 700) that extracts `{([^}]+)}` from
`DugisGuideViewer.quests2[CurrentQuestIndex]` and, if it names a zone `IsZoneNameValid` recognizes,
resolves the waypoint's zone/continent from that instead of the (broken) numeric `|Z|` tag or the
guide's title-zone fallback. Verified this curly-brace markup is exclusive to the Anniversary-
sourced content — grepped all main leveling guide files and found zero `{...}` usage there, so this
new branch can never fire for guides that were already working correctly; the existing name-based
`|Z|` tag path and the title-zone fallback are both left untouched as lower-priority fallbacks.
`luac -p` passes. Not yet re-tested in-game (fix just applied).

## Bug found and fixed this session: quest-accept not auto-detected on dungeon guides

**Symptom**: reported by user after waypoints were confirmed working - accepting a quest the
guide pointed them at did not tick the checkbox or advance to the next step in the compact
guide window, even though the same behavior works fine on the original leveling guides.
Requested: dungeon guides should behave identically to leveling guides here.

**Root cause**: real-time "quest accepted" detection lives in `ChatMessage()` (around line 126),
which parses the client's own `"Quest accepted: X"` system chat message, resolves it to a real
QID via the quest log, and only acts if `CurrentAction == "A"` - i.e. only if the guide's
currently-displayed row is literally the "A" (accept) row for that quest at the exact moment the
accept happens. Dungeon guide content (this session's classic rebuild and the earlier Outland
rebuild both) very commonly inserts a separate `R` (travel-to-NPC) row immediately before the `A`
row for the same quest, e.g. `R Ratchet |QID|1221|...` then `A Blueleaf Tubers |QID|1221|...` -
a structure the original leveling guides rarely use. `R` rows only advance via a *different*,
independent mechanism (`CheckForLocation`, comparing `GetZoneText()`/`GetSubZoneText()` against
the row's own destination text, checked only on `ZONE_CHANGED*` events) - so if that hasn't fired
yet when the player accepts the quest, `CurrentQuestIndex` is still parked on the `R` row, and the
chat-message-based accept detection silently misses it. It doesn't error - `CompleteQID()` still
marks the (not-currently-displayed) `A` row's saved state as complete in the background - but
nothing moves `CurrentQuestIndex` forward, so the compact window visibly never changes.

**Fix, first attempt (superseded)**: initially added a parallel `elseif` branch to the existing
`QUEST_LOG_UPDATE` incremental scan (which already handled `"C"` completion rows position-
independently) to also catch `"A"` accept rows the same way. Worked, but the user pointed out
something better: each guide panel already has a **"Reload" button**
(`DugisGuideViewer_Reload_ButtonClick`, line 102) that re-derives the *entire* row state from the
quest log and correctly figures out accepted/completed/abandoned regardless of which row was
showing - and asked why live quest events don't just trigger the same thing automatically. They
were right.

**Actual fix**: Reload calls `DisplayViewTab(CurrentTitle)`, whose real work (for state purposes)
is `SetQuestsState()` (line 516) - it loops every row, checks `GetQuestLogIndexByQID`/
`HasQuestBeenTurnedIn` directly (fully position-independent), marks `"A"` rows complete the moment
their quest is in the log (even walking backward to also complete earlier rows sharing the same
qid - handles the `R`-then-`A` case even better than the first attempt did), and then moves
`CurrentQuestIndex` to the first genuinely incomplete row from scratch. Removed the first-attempt
branch and instead just call `DugisGuideViewer:SetQuestsState()` once at the end of the
`QUEST_LOG_UPDATE` handler (after the existing incremental logic, which still separately handles
reverting a step if a quest becomes un-completed - `SetQuestsState()` doesn't cover that case).
Net effect: every quest-log change now automatically does what clicking "Reload" already did
manually, closing the gap with how leveling guides are perceived to behave. `SetQuestsState()` is
pre-existing, already-exercised code (runs on every guide open/reload); calling it more often
carries the same safety profile it already had. `luac -p` passes. Not yet re-tested in-game.

**Not touched, believed already correct**: quest-abandon detection (`AbandonQID`, set from a hook
on the in-game abandon-quest button around line 2504) already scans all `LastGuideNumRows` rows
by qid regardless of position and adjusts `CurrentQuestIndex` backward if needed - this doesn't
have the same "wrong row displayed" dependency the accept path had, so it should already work the
same for dungeon guides as it does for leveling guides. Flagged here rather than assumed silently
in case in-game testing shows otherwise.

## Bug found and fixed this session: two quest IDs were stale (server updated, dump didn't)

**Symptom**: user reported that even the guide's own "Reload" button (which calls
`SetQuestsState()`, verified sound by direct simulation against this exact guide's parsed
content) never detected an already-accepted quest as complete.

**Root cause**: not a code bug at all. The quest was "Into The Scarlet Monastery" - the guide's
`|QID|1048|` is a real, valid `quest_template` row in the account's TDB dump
(`TDB_full_335.63_2017_04_18.7z`, dated April 2017), with the right name, right NPC (2425,
"Bragor Bloodfist" in Undercity), right level range - it passed every check this session's
TDB-based verification could perform. But **existence in a quest_template dump proves an ID
is/was valid data, not that it's the ID the live server currently hands out** - Warmane has
evidently patched their world database since 2017, and quest 1048 is now `historical` (dead
data, kept for compatibility) while a duplicate, `14355`, is what NPC-driven quest-giving
actually issues today. The player's real quest log confirmed this directly: `GetQuestLogTitle`
reported QID **14355** for a quest textually identical to what the guide called 1048 - proving
the API/detection logic was fine all along, the data was just stale.

**Verification method**: cross-checked against [wotlkdb.com](https://wotlkdb.com), a
3.3.5a-specific community quest/item/NPC database that embeds structured JSON directly in its
pages (not just rendered text) - notably a `"historical":true` flag on deprecated quest
entries, and a `"Not available to players"` string in the infobox, plus a same-page "see-also"
listview pointing straight at the replacement ID. Wrote a small reusable tool for this
(`AddOns/wotlkdb-tool/`, see below) rather than checking by hand, and ran it against **every
unique QID across every rebuilt dungeon guide (368 total, both Outland and classic, both
factions)**. Result: **only these two were affected**, both tied to the same Undercity NPC:

| Old QID | Name | New QID | Old NPC | New NPC |
|---|---|---|---|---|
| 1048 | Into The Scarlet Monastery | **14355** | 2425 | **36273** |
| 5725 | The Power to Destroy... | **14356** | 2425 | **36273** |

Both replacement quests are confirmed `available:true` on wotlkdb, same name, same level/
reqlevel, same "Bragor Bloodfist" quest giver - just a different underlying NPC entity
(36273, presumably added when Blizzard's later Undercity revamp duplicated this NPC) and a new
quest ID. Everything else (all 366 other QIDs, spanning both Outland and classic guides) came
back `available:true` with no replacement suggested - the TDB dump is stale in general, not
uniformly wrong, and this appears to be an isolated case (both hits share one NPC/questline).

**Fix applied**: `13_18_Ragefire_Chasm.lua`, `27_33_Scarlet_Monestary_Graveyard_Library.lua`,
and `34_39_Scarlet_Monestary_Armory_Cathedral.lua` (all `DugisGuide_Dungeons_Horde_En` - this
is Horde-only content, no Alliance guide references either quest) had every `|QID|1048|` /
`|QID|5725|`, `(npc:2425)`, and `|NPC|2425|` occurrence on the affected lines updated to
`14355`/`14356` and `36273` respectively (8 lines total, exact match counts confirmed before
writing). Done via direct substitution on the encoded bytes (encoding just the search/replace
substrings with the same `-3` cipher and doing a plain string replace on the raw file) rather
than a full decode/re-encode round-trip, to avoid the cipher's special-cased space-byte
(`0x1D`) complicating a manual re-implementation. All three files pass `luac -p`; decoded
content spot-checked and confirmed correct.

## New tool built this session: `AddOns/wotlkdb-tool/`

A small, reusable, **general-purpose** (not DugisGuideViewerZ-specific) client + local cache for
[wotlkdb.com](https://wotlkdb.com), built at the user's request as infrastructure for *any*
future 3.3.5a addon work, not just this fix:

- `wotlkdb_client.py` - fetches and parses `?quest=`, `?item=`, and `?npc=` pages. Extracts the
  structured JSON these pages embed (`g_quests`/`g_items` objects, `Mapper` objective/NPC data,
  `Listview` "see-also"/"reward-from-quest" blocks) rather than scraping rendered text, since
  that's both more reliable and how the "historical" flag and replacement-ID lookup were found.
  Every fetch is cached in `cache.sqlite` (both raw HTML and parsed fields) so repeat runs/tools
  never re-hit the site for the same ID. Rate-limited to 1.5s between requests - this is a
  low-volume verification tool for the IDs a specific guide/addon actually references (a few
  hundred), explicitly **not** a bulk scraper of the whole site.
- `verify_guide_quests.py` - batch-checks a list of quest IDs (one per line) and reports which
  are unavailable/historical, with their replacement ID. Used this session to check all 368
  guide QIDs in one pass instead of discovering mismatches one bug report at a time.
- Confirmed working: `curl`/`urllib` with a normal browser `User-Agent` gets a clean HTTP 200
  from wotlkdb.com (Cloudflare-fronted, but not blocking scripted clients outright - the
  `WebFetch` tool's own request got a 403, likely from its specific request signature, not a
  blanket anti-bot measure).
- Lives in `AddOns/wotlkdb-tool/`, not inside `DugisGuideViewerZ/`, specifically so it's
  discoverable and reusable for whatever addon is worked on next.

## Bug found and fixed this session: waypoint zone detection missed rows without {ZoneName} markup

**Symptom**: user reported "The Underbog (63-65)" guide's waypoint "not working".

**Root cause**: the `{ZoneName}` curly-brace fix from earlier this session only helps when a
row's note text actually contains that markup - and several "R" (travel) rows in this specific
file's source don't have it, e.g. `R Sporeggar |N|Travel to Sporeggar (19.5,50.1)| |Z|1946|`
(no `{Sporeggar}` anywhere) vs. other rows in the same file like
`R Sporeggar |N|Travel to {Sporeggar} (19.6,52)| |Z|1946|` (has it). Inconsistent even within
one file - looks like an authoring quirk in the source, not something specific to one line
type. Affected rows (checked this file specifically): the "Sporeggar" travel step at row 6,
"Sporeggar" again at row 27, "Coilfang Reservoir" at rows 32 and 44, and another "Sporeggar" at
row 47 (which also happens to use a different, equally-unusable numeric `|Z|467|` instead of
the `|Z|1946|` every other row in the file uses - harmless given neither numeric tag resolves
anyway, but noted as a further sign this source data isn't fully consistent).

**Fix**: added a *higher-priority* check ahead of the `{ZoneName}` one - for "R"/"F"/"b"/"H"
(travel-type) rows specifically, try the row's own name field (`quests1[CurrentQuestIndex]`,
e.g. literally "Sporeggar") as the zone name first. This isn't a new invention - it's the exact
same convention `CheckForLocation()` (the *separate* function that detects zone-arrival to
auto-advance a travel row) already relies on, comparing `GetZoneText()`/`GetSubZoneText()`
against that same field - so it's already a supported, working assumption elsewhere in this
engine, just not previously reused for waypoint placement. Falls through gracefully to the
`{ZoneName}` check (and beyond) if the row's name isn't a valid zone (e.g. non-travel rows, or
a travel destination that's a subzone/POI rather than a full mappable zone) - purely additive,
doesn't change behavior for rows that were already resolving correctly. `luac -p` passes.

## Improvement this session: current-zone waypoint fallback instead of giving up

Underbog's waypoint was still not working after the row-name-as-zone fix, and live debug output
(`Debug = 1`, temporarily enabled - **still on**, not reverted, see next-steps) couldn't be
captured at the right moment to diagnose further (the user pressed a different, unrelated "Test"
button in the settings panel by mistake, which only prints Blizzard's own auto-quest-tracking
checkbox state - not connected to `MapCurrentObjective` at all). Rather than keep chasing the
exact zone-name mismatch for this specific step, changed the failure mode itself: previously,
when no zone-name candidate resolved, `MapCurrentObjective` just skipped the waypoint entirely
(the defensive guard from earlier this session). Now it falls back to
`TomTom:AddWaypoint(x, y, desc)` - places the marker at the guide's coordinates in **whatever
zone the player is currently in**, without needing to resolve a zone name/index at all. This
works because these problematic steps are reached by first traveling to the right outdoor zone
(flight path, etc.), then walking to a specific coordinate within it - so "current zone" is very
often already correct even when the code can't confirm its name. Should turn "no waypoint at
all" into "usually-correct waypoint" for whatever's still hitting the zone-resolution gap.
`luac -p` passes. Not yet re-tested in-game.

## Bug found and fixed this session: guide referenced a quest without its required prerequisite

**Symptom**: user reported reaching the NPC the Underbog guide names for "Observing the
Sporelings" and finding no quest available, despite the NPC and location being correct - a
higher-level character confirmed the quest genuinely exists and is obtainable.

**Root cause**: quest verification so far (existence, availability/historical status) doesn't
check quest **chains** - "Observing the Sporelings" (QID 9701) requires prerequisite quest
**9697** ("Watcher Leesa'oh") to be turned in first, and the guide never included that step at
all; it jumps straight from an unrelated earlier objective to accepting 9701 directly. Any
character who hadn't independently done 9697 through some other means would hit exactly this
wall. Confirmed via `wotlkdb-tool`'s new chain-parsing (see below): `fetch_quest(9701)` returns
`prereq_id: 9697`.

**Fix**: extended `wotlkdb_client.fetch_quest()` to parse wotlkdb's "Series" infobox table
(present on any quest that's part of a chain) into an ordered `chain` list and a direct
`prereq_id` field. Looked up 9697's own quest-giver location via the same page's embedded
`Mapper` objective data (gives exact NPC IDs/coordinates, not just zone name) - start NPC 17834
"Lethyn Moonfire" at (78.5, 63.1) in Zangarmarsh, turned in to NPC 17831 "Watcher Leesa'oh" at
(23.3, 66.2) - the same NPC/location the guide's existing (correct) step for 9701 already uses,
confirming turning in 9697 there is what unlocks 9701 from that same NPC. Verified both NPCs
and the quest ID against the TDB reference lists. Inserted three new lines (R/A/T for the
missing 9697 chain) immediately before the existing "Cenarion Watchpost" step, in both
`DugisGuide_Outland_Dungeons_A/63_65_The_Underbog.lua` and the Horde copy (identical content,
same gap in both). `luac -p` passes both files; decoded content spot-checked.

**Scope note**: this was found and fixed for one specific quest the user happened to hit -
**not** a systematic check across all 368 guide quest IDs. The chain-parsing capability now
exists in the tool to do that broader pass (check every guide's `|QID|` for a `prereq_id`, and
flag any whose prerequisite doesn't appear as an earlier step in the same guide/chain), but
that full sweep hasn't been run yet - see next steps.

## New feature this session: in-game "Check Chains" button

At the user's request - rather than hand-fixing every quest chain gap one bug report at a
time, or doing an untargeted "check literally every quest in the game" - built an **in-game**
button that checks whichever guide is currently open against a **static prerequisite table
baked in at build time**, live against the player's actual quest state.

**Why static, not live-queried**: WoW's Lua API doesn't expose quest chain/prerequisite data
for quests not already in your log - there's no `GetQuestPrereq(qid)` or similar. So the chain
data has to come from somewhere outside the client. Used `wotlkdb-tool`'s chain-parsing (added
earlier this session) offline to build the table once; the addon itself does no scraping and
has no network dependency.

**Built**:
- `DugisGuideViewerZ/PrereqData.lua` (new file, added to `.toc` right after
  `DugisGuideViewer.lua`) - generated by running `wotlkdb_client.fetch_quest()` across all 368
  quest IDs used in the rebuilt guides (reusing the cached HTML from the earlier
  historical-quest batch check - no new network requests needed for those). Contains
  `DugisGuideViewer.QuestPrereqs[qid] = prereq_qid` for the 147 quests that wotlkdb reports as
  part of a chain, plus `DugisGuideViewer.QuestNames[qid] = "name"` for readable messages
  (222 entries - covers both the 147 chained quests and their prerequisite quests).
- New **"Check Chains"** button in `DugisGuideViewer.xml`, next to Reload/Reset. Calls
  `DugisGuideViewer_CheckChains_ButtonClick()` (new function in `DugisGuideViewer.lua`, next
  to the other button handlers): scans every `"A"` (accept) row in the *currently open* guide,
  looks up its prereq in the table, and checks whether it's satisfied via the player's *live*
  quest state (`HasQuestBeenTurnedIn`/`GetQuestLogIndexByQID` - not just "is it in this guide
  file", since a player may have completed a prerequisite through normal leveling outside any
  guide). Prints one line per unsatisfied prerequisite, distinguishing "this guide includes
  that step, keep going" (yellow) from "this guide never covers it at all" (red) - the latter
  is the same class of bug as the Underbog case fixed earlier this session. Manual/on-demand
  per the user's choice, not automatic on guide open (avoids a message every single time
  nothing's wrong).

**Bug fixed in passing**: `HasQuestBeenTurnedIn` (used by this new feature, and already used by
`SetQuestsState`) only ever compared the *key* from a `pairs()` iteration over
`turnedinquests`, but that table is populated two inconsistent ways elsewhere in this same
file - wholesale-overwritten from Blizzard's `GetQuestsCompleted()` as `{[questID]=true}`
(key = ID, correct for the old check), *or* appended to via `table.insert(...)` as a plain
array (value = ID, key = insertion index, wrong for the old check). Fixed to check both the
key and the value, so it works regardless of which path populated the table. This likely also
explains some of the difficulty diagnosing "already accepted quest not recognized" earlier this
session for quests fully turned in and no longer in the log at all (as opposed to still-in-log,
which the separate `GetQuestLogIndexByQID` check already covered correctly).

**Scope note carried over from before**: the prerequisite *data* only covers the 368 quest IDs
already referenced by the rebuilt guides (and their 222 total prerequisite/name lookups) - not
the whole game. The 22 guide files with a confirmed missing-prerequisite gap (found via a
static cross-check, listed in the previous section for Underbog) have **not** all been
hand-fixed yet, only Underbog's has. The new button lets the user (or future testing) surface
the rest live, one guide at a time, without needing a from-scratch data-gathering pass each
time - but the underlying 22-item list from the static check is also available as a to-do if a
bulk fix is preferred instead. `luac -p` and `xmllint` both pass on the modified files. Not yet
tested in-game (need a full client restart, not just `/reload`, since `PrereqData.lua` is a new
`.toc`-declared file - same caveat as the earlier Guides.xml manifest lesson this session).

### Reference: the 22 guide files with a confirmed missing-prerequisite gap (static check)

Raw data (`prereqs.json`, `quest_names.json`) saved in `wotlkdb-tool/` for reuse. Underbog's
(`63_65_The_Underbog.lua`, both factions, QID 9701 needing 9697) is the only one fixed so far -
the rest are unconfirmed-but-likely real gaps, same class of bug, not yet hand-fixed:

- `DugisGuide_Dungeons_Alliance_En/15_20_The_Deadmines.lua`: QID 14 needs 13; QID 2040 needs 2041
- `DugisGuide_Dungeons_Alliance_En/15_21_Wailing_Caverns.lua`: QID 914 needs 1490
- `DugisGuide_Dungeons_Alliance_En/25_29_Gnomeregan.lua`: QID 2924 needs 2925; QID 2930 needs 2931
- `DugisGuide_Dungeons_Alliance_En/48_52_Sunken_Temple.lua`: QID 4787 needs 3527; QID 3444 needs 3380
- `DugisGuide_Dungeons_Alliance_En/52_55_Blackrock_Depths.lua`: QID 3982 needs 3981
- `DugisGuide_Dungeons_Horde_En/15_21_Wailing_Caverns.lua`: QID 870 needs 886
- `DugisGuide_Dungeons_Horde_En/20_24_Blackfathom_Deeps.lua`: QID 6563 needs 6562
- `DugisGuide_Dungeons_Horde_En/27_33_Scarlet_Monestary_Graveyard_Library.lua`: QID 1113 needs 1109
- `DugisGuide_Dungeons_Horde_En/34_39_Scarlet_Monestary_Armory_Cathedral.lua`: QID 1951 needs 1950
- `DugisGuide_Dungeons_Horde_En/42_47_ZulFarrak.lua`: QID 2865 needs 2864; QID 2770 needs 2769; QID 2846 needs 2861
- `DugisGuide_Dungeons_Horde_En/48_52_Sunken_Temple.lua`: QID 4787 needs 3527; QID 2937 needs 2936
- `DugisGuide_Outland_Dungeons_A/70_Magister_Terrace.lua`: QID 11490 needs 11488
- `DugisGuide_Outland_Dungeons_A/70_The_Black_Morass.lua`: QID 10297 needs 10296
- `DugisGuide_Outland_Dungeons_H/61_63_The_Blood_Furnace.lua`: QID 9608 needs 9572
- `DugisGuide_Outland_Dungeons_H/70_Magister_Terrace.lua`: QID 11490 needs 11488
- `DugisGuide_Outland_Dungeons_H/70_The_Black_Morass.lua`: QID 10297 needs 10296

Caveat: this static check only flags "prereq not present anywhere in the same file" - it can't
tell whether a player would already have that prerequisite from normal leveling (the in-game
Check Chains button handles that nuance; this list doesn't). Some of these may turn out to be
non-issues in practice; treat as candidates to verify, not confirmed bugs like Underbog was.

## Bug found and fixed this session: crash on lines carried through as disabled source content

**Symptom**: level 42 Warlock got `attempt to index local 'action' (a nil value)` at
`ParseRows()` line 2054, triggered from `DisplayViewTab()` when opening a guide.

**Root cause**: some lines in the original Anniversary source packages (both TBC and Classic
era, used for the Outland and this session's classic dungeon rebuilds) start with `--` (e.g.
`--A Featherbeard's Endorsement |QID|9469|...`). In the *source* Lua files this looked like an
ordinary comment, but by the time it's embedded inside the `return [[ ... ]]` string literal
that actually ships in the guide, `--` is just two literal dash characters, not a comment
marker - strings don't have comments. `ParseRows`'s `text:find("^(%a) ...")` requires the first
character to be a letter, so it doesn't match a line starting with `-`, leaving `action` as
`nil`, and the very next line (`action:trim()`) crashes trying to call a method on nil. Not
something introduced by this session's conversions specifically - it was latent in the source
material both times, just never hit because these particular lines only apply to certain
classes/dungeons/scenarios that hadn't been tested yet (this one needed a Warlock specifically,
via a `|C|Warlock|` tag elsewhere on one of the surrounding lines making the whole batch of
lines around them get parsed for the first time).

**Investigation note**: took a couple of false starts to find, because my own exploration
script (used throughout this session to eyeball decoded guide content) had a boundary-detection
bug of its own - it kept decoding a couple of trailing lines *past* the real `]]` closing
marker (which appears literally, unencoded, in the raw file, not as an encoded byte sequence),
so it flashed some real Lua code/dead `--[[ ]]` comment blocks as if they were garbled content.
Once the boundary detection was fixed to stop at a literal `]]` line, the actual `--`-prefixed
content became clearly visible.

**Fix (two parts)**:
1. **Defensive**: `ParseRows` now checks `if not action then` and skips the line (with a
   `DebugPrint`) instead of crashing, regardless of *why* a line failed to parse - this
   protects against this whole class of bug for any future content, not just these specific
   lines.
2. **Root cause**: removed all 21 `--`-prefixed lines found across 5 files (
   `DugisGuide_Dungeons_Alliance_En/42_47_ZulFarrak.lua` x14,
   `DugisGuide_Dungeons_Horde_En/42_47_ZulFarrak.lua` x2,
   `DugisGuide_Dungeons_Horde_En/52_55_Blackrock_Depths.lua` x1,
   `DugisGuide_Outland_Dungeons_A/65_67_Auchenai_Crypts.lua` x2,
   `DugisGuide_Outland_Dungeons_H/65_67_Auchenai_Crypts.lua` x2) - a full sweep of *every* guide
   file (all folders, not just these 5) with the boundary-fixed script found zero remaining
   occurrences afterward. Chose to remove rather than "activate" these lines (stripping the
   `--` and keeping the content) since we don't know why the original source author disabled
   them - safer to match their apparent intent than to guess.

`luac -p` passes on `DugisGuideViewer.lua` and all 5 modified guide files.

## New feature this session: "Target" button on the compact guide window

At the user's request - a button that targets the NPC/enemy involved in the current guide
step, equivalent to typing `/target NPCName`, without having to read the name and type it or
find/click the NPC in the world first.

**Why a name lookup table was needed**: many rows' displayed name is the *quest* name (e.g.
"Blueleaf Tubers" for an accept row), not the NPC's name, so it can't be used directly for most
rows - only "K" (kill) rows commonly show a plain mob name in that field. The reliable signal
is each row's own `|NPC|id[,id2,...]|` tag, but that only stores the numeric creature ID, and
this old engine has **no existing mechanism at all** to resolve `(npc:ID)` placeholders from
the source content into real names (the guide text itself sometimes shows the raw ID to the
player already, for the same reason). So a static ID-to-name table was needed, same approach as
`PrereqData.lua`.

**Built**:
- `DugisGuideViewerZ/NPCData.lua` (new, added to `.toc` after `PrereqData.lua`) -
  `DugisGuideViewer.NPCNames[npcID] = "name"` for all 495 unique creature IDs referenced via
  `|NPC|` tags across every rebuilt dungeon guide (Outland + classic, both factions). Fetched
  via a new `wotlkdb-tool/fetch_npc_names.py` batch script (same rate-limited/cached approach as
  the quest batches). All 495 resolved successfully, zero failures.
- New **"Target"** icon button on the compact/small guide window (`DugisSmallFrame`, next to
  the existing maximize button), wired to `DugisGuideViewer_Target_ButtonClick()` (new function
  in `DugisGuideViewer.lua`, next to the other button handlers): reads the current row's
  `|NPC|` tag, takes the first listed ID (some rows list several, e.g. "kill either of these"),
  looks it up in `NPCNames`, and calls `TargetByName(name, false)`. Falls back to the row's own
  displayed name only for "K" rows without an `|NPC|` tag at all, and only if that name isn't
  itself an unresolved `(npc:ID)` placeholder. Prints a colored chat confirmation either way.

`luac -p` and `xmllint` both pass. Not yet tested in-game (new `.toc` file - needs a full
client restart, not just `/reload`, same caveat as `PrereqData.lua` and the earlier Guides.xml
manifest lesson this session).

## Bug found and fixed this session: current-zone waypoint fallback could itself crash

**Symptom**: `attempt to concatenate upvalue 'UID' (a nil value)` at `MapCurrentObjective()`
line 859, on a plain `/reload` (not tied to any button click).

**Root cause**: the current-zone waypoint fallback added earlier this session
(`TomTom:AddWaypoint(...)`) can itself return `nil` - its own implementation (`TomTom.lua`
line 730) does `local c,z = GetCurrentMapContinent(), GetCurrentMapZone(); if not c or not z or
c<1 then return end` before placing anything. Since this fallback only activates *after* this
same engine's own "Default zone" branch already tried `SetMapToCurrentZone()` +
`GetCurrentMapContinent()/GetCurrentMapZone()` and got nothing usable, `TomTom:AddWaypoint`
doing the same underlying lookup (minus the `SetMapToCurrentZone()` call) can plausibly fail
the exact same way - a case the debug-print line wasn't guarding against.

**Fix**: wrapped the debug print with `tostring(UID)` so a nil UID no longer crashes the
concatenation, and skip storing the point (`addPoint`) entirely when `UID` comes back nil,
since there's nothing real to track in that case - degrades to "no waypoint placed" rather
than a crash, consistent with how the rest of this fallback chain is meant to fail safely.
`luac -p` passes.

**Also reported**: `attempt to call global 'DugisGuideViewer_Target_ButtonClick' (a nil
value)` when clicking the new Target button. The function is correctly defined in
`DugisGuideViewer.lua` (verified present, correctly spelled, matching the XML's `OnClick`
reference exactly) and `luac -p` finds no syntax errors anywhere in the file that could have
aborted its execution partway through - almost certainly this was tested before the full
client restart `NPCData.lua`/`PrereqData.lua` (new `.toc` entries) need, per the established
manifest-caching lesson this session. Not otherwise changed; ask the user to confirm after a
full restart.

## New feature this session: resolve (npc:ID) placeholders to real names everywhere

At the user's request - the raw `(npc:ID)` placeholders from the source content (already
identified as a gap when building the Target button) were showing up as literal IDs in guide
step text and tooltips, not just being unusable for targeting.

**Fix**: added `DugisGuideViewer:ResolveNPCNames(text)` (right before `ParseRows`, using the
same `NPCData.lua` table built for the Target button) and call it on both the row's name field
and its note text *inside* `ParseRows`, before they're stored into `quests1`/`quests2`. Since
every other piece of UI - the large window, the compact window, tooltips - all read from these
same two tables, this fixes it everywhere at once rather than needing separate fixes per UI
element. Leaves the placeholder untouched (doesn't blank it out) if the ID isn't in the table,
e.g. an NPC outside the 495 collected across the rebuilt guides. Verified directly against real
guide content: `"Collect (item:7146) from (npc:6487) the final boss"` → `"...from Arcanist Doan
the final boss"`. `luac -p` passes.

## Bug found and fixed this session: Target button used a nonexistent API function

**Symptom**: `attempt to call global 'TargetByName' (a nil value)` when clicking the Target
button (this session's earlier suspicion that the "nil function" error was just a stale-load
issue was wrong - confirmed by testing after a proper restart).

**Root cause**: `TargetByName` isn't available as a global function on this client - assumed
it existed based on general WoW API knowledge without verifying against this specific 3.3.5a
client build.

**Fix**: instead of relying on a specific targeting API function, go through the chat edit box
the same way a player typing `/target Name` themselves would -
`DEFAULT_CHAT_FRAME.editBox:SetText("/target " .. name)` then `ChatEdit_SendText(editbox, 0)`.
This works regardless of whatever `/target` is internally implemented with, since it's the
exact same path the client already guarantees works. `luac -p` passes. Not yet re-tested
in-game.

## Remaining work / next steps

0. **`Debug = 1` is still enabled** (`DugisGuideViewer.lua` line 87) from this session's
   diagnostic attempt - very chatty (prints on nearly everything). Revert to `Debug = 0` once
   the Underbog waypoint fix above is confirmed working and no further live debugging is needed.

1. **Get user confirmation the `MapCurrentObjective` fixes resolve the crash and that guides
   actually work in-game** (step highlighting/advancement, waypoints pointing somewhere sensible)
   for both the Outland guides and the newly-rebuilt classic guides — this is the immediate next
   thing to check. The classic guides have not been tested in-game yet at all (converted and
   syntax-validated this session, but zero in-game confirmation so far).
2. If step-advancement still doesn't work even though the engine is proven sound and content is
   verified, the next suspects (in order of likelihood) are: (a) something about how
   `SetQuestsState`/`HasQuestBeenTurnedIn` interacts with a *fresh* (never-visited) guide's initial
   state, (b) the guide-list UI itself (where the user is looking, e.g. a specific tab/category
   filter), not the data — worth asking exactly where in the UI they're looking when they say
   "only classic dungeons show."
3. ~~Rebuild `DugisGuide_Dungeons_Alliance_En` / `_Horde_En` (classic, levels 13-58)~~ — **done this
   session**, see above. Not yet in-game tested. Known gap: no Dire Maul (either faction) or
   Alliance Shadowfang Keep — no verified Anniversary source found for those; would need separate
   sourcing if wanted.
4. **Build Wrath dungeon guides (68-80)** — `DugisGuide_WOTLK_Dungeons_A/_H` are empty stubs.
   Only available source found so far is `DugiGuides_MoP_5.19.zip`, which uses modern retrofitted
   NPC IDs (confirmed, e.g. NPC 54667) and "use your dungeon finder" text not applicable to a
   3.3.5a launch-era client — would need the same TDB-verification-and-strip treatment as Outland,
   likely losing more content than Outland did since Wrath dungeons may have more Anniversary/
   Cataclysm-only retrofit content mixed in. No Wrath-Classic/Anniversary Blizzard package exists
   (as of this session) to use as a cleaner source instead. `convert_classic.py` and the
   `valid_quest_ids.txt`/`valid_creature_ids.txt` TDB extracts (now saved in the addon folder) can
   likely be reused/adapted for this rather than starting from scratch.
5. ~~Fix or properly convert `51_58_Blackrock_Depths_Upper.lua`~~ — **moot**: that file (and its
   broken sibling `47_52_Blackrock_Depths_Detention.lua`) no longer exists; the classic rebuild
   replaced both with a single verified `52_55_Blackrock_Depths.lua`.
6. `convert_tbc.py` (the Outland converter) still only exists in that earlier session's temp
   scratchpad directory, still not saved anywhere permanent — unlike `convert_classic.py` (this
   session's classic-dungeon converter), which *was* saved into the addon folder. If a Wrath
   rebuild reuses `convert_tbc.py`'s title-deriving-from-filename logic (needed because that
   source reused one generic title per chain, unlike ClassicEra's source), it needs rewriting from
   scratch or adapting from `convert_classic.py` instead.

### BUG (follow-up) — `SmallWindowTooltip_OnEnter` nil-error once steps actually advance
**Symptom**: After the fix above, hovering the compact/mini guide window ("SmallFrame") threw
`attempt to index a nil value` at `DugisGuideViewer.lua:1707`.
**Root cause**: `SmallWindowTooltip_OnEnter` read `getglobal("RecapPanelDetail" .. CurrentQuestIndex
.. "Desc"):GetText()`. But `RecapPanelDetailN` frames are created dynamically, one per row, only
when the *large* guide window renders its step list (see the loop around line 2096-2121). If a
guide is only ever viewed in the compact/mini window (`DugisSmallFrame` / `SmallFrameDetail1`),
that per-row frame for the current step number may never have been created, so `getglobal(...)`
returns `nil` and `:GetText()` errors. This was dormant before the fix above because
`CurrentQuestIndex` never meaningfully advanced, so the code path was never exercised with a
realistic index.
**Fix**: Read the step text directly from `DugisGuideViewer.quests2[CurrentQuestIndex]` (the same
parsed-data table `PopulateSmallFrame` already sources the compact window's name label from),
instead of depending on a `RecapPanelDetailN` frame that may not exist in compact-only usage.
**Rule**: When a UI element is populated from a parsed-data table elsewhere in the same file, read
that table directly rather than reading back text from a dynamically-created sibling frame that
may not exist for every UI mode.
