MobMap - an ingame mob position database - v3.53
coded 2007-2009 by Slarti on EU-Blackhand

get the newest version of MobMap and the database at
http://www.mobmap.de

You can open the MobMap window ingame either by using the new
button added to the world map, by using the command /mobmap show,
by the MobMap minimap button or via a freely configurable key binding 
for MobMap.


changelog:

v1.00:  initial public release

v1.10:
- changed: the monolithic database has been splitted into 4 parts,
           which are now loaded on-demand
- added:   new options panel
- added:   configurable transparency for the "dots" on the world map
- fixed:   the "dots" have their own independent transparency value now 
           and won't inherit the transparency of the world map frame
- added:   the option to move the MobMap button to the right side of
           the world map frame

v1.11:  nothing changed, this is just a new version to fix the mess
        I created with the last version that had some files missing
	for the update via the MobMapUpdater.

v1.12:
- fixed:   a bug that caused the quest list and the merchant list not
           to appear if you did not enter a zone in the corresponding
	   zone filter box

v1.13:
- fixed:   token icons on merchant items which are bought in exchange
           for tokens are now correctly displayed
- added:   support for Extended Questlog
- added:   partial support for UberQuest
- added:   item tooltips for the recipe list entries
- fixed:   tooltips in various MobMap menus are now correctly displayed
           whether the world map is shown or not
- fixed:   the quest detail frame is now displayed correctly whether the
           world map is shown or not
- added:   another alternative position for the MobMap button on the
           world map frame (below the actual map)
- added:   the option to completely hide the MobMap button

v1.14:
- changed: DATABASE FORMAT CHANGE! You will need to get an updated database
           copy!
- added:   a new item name helper database that enables the user to search
           for item names in the quest and merchant tab
- added:   a new slash command /mobmap clear to wipe all collected data
           without having to open the data export frame
- added:   an option to turn off the MobMap world map tooltips
- added:   information about where to get buyable recipes and recipes from
           quest rewards - you can have MobMap search for the merchant or
	   quest with just one click at the recipe tab
- fixed:   MobMap should now work correctly on Macintosh systems.

v1.20:
- changed: export routines were optimized for better performance
- changed: complete refactoring of the MobMap addon code to gain more
           modularity, a better memory allocation behavior and a faster
	   initial loading time
- changed: DATABASE FORMAT CHANGE! The database format has also been
           refactored to conform to the new internal structure of the
	   MobMap addon
- fixed:   several minor bugs
- added:   loot data collection

v1.21:
- fixed:   a bug introduced with 1.20 that could cause a lua error when
           clicking on a link in the quest details

v1.22:
- added:   dynamically scaling position dots to improve visibility
           when only one or two are displayed
- fixed:   some problems with crashes occuring when trying to export 
           larger amounts of data
- fixed:   loot data is now properly deleted when the 'clear data' button
           is used

v1.30:
- added:   display of skill level required for recipes
- added:   possibility to sort recipes by skill level
- changed: item name helper database format changed to reduce memory usage
           by 15%
- added:   several help text tooltips
- added:   possibility to disable item detail data requests to the server
           (only recommended if you permanently get disconnected otherwise)
- added:   New drop rate database! It currently contains drop rates for all
           items necessary for the quests known to MobMap and the drop
	   rates for recipe reagents.
- added:   quicksearch buttons for recipe reagents to quickly search for mobs
           dropping the reagent or merchants offering it
- added:   the questionmark buttons next to quest objectives now also search
           the drop rate database if the quest objective is to collect an item
           obtainable by killing and looting mobs
- fixed:   using the MobMap check box on the world map does not cause a lua
           error anymore if the MobMap position database has not been loaded yet

v1.40:
- added:   new database containing positions of items which are 'picked up' in
           the world (currently quest items and items gathered by fishing, 
	   mining and collecting herbs are included). The integration of this
	   new database resulted in an overall database format change, so you
	   will have to get a new version after you installed the v1.40 addon.
- added:   options to turn off the ?-Buttons in the questlog and questtracker
- added:   clicking a MobMap dot on the world map will create a waypoint to
           that position if Cartographer with waypoint functionality is
	   installed and activated
- added:   some minor additions and changes in preparation for WoW patch 2.1.0
- added:   memory usage information display (WoW patch 2.1.0 required!)

v1.41:
- fixed:   interface version number in toc file changed for patch 2.1.0
- fixed:   posting enchant links in the chat does now work correctly
- fixed:   making the World Map Frame transparent using Cartographer will not
           influence the MobMap button or the MobMap dots anymore
- added:   some more minor changes for patch 2.1.0 compatibility

v1.42:
- fixed:   a MetaMap compatibility issue: the dots should be in the right places
           now even if you used the MetaMap option to scale down the world map

v1.50:
- added:   new boss loot tables
- changed: MobMap window can now be resized vertically for better overview and
           less scrolling on downscaled UIs
- added:   Huffman-based compression for the quest objective texts, effectively
           reducing database size in memory by approx. 270kByte
- added:   a new item tooltip database that's being used to display tooltips
           of items that are likely to be unknown on your server
- added:   an option to use some more memory than necessary to improve response
           time of certain queries

v1.51:
- fixed:   drop chances for quest items should now be displayed correctly
- fixed:   an error in the profession data collection mechanism

v1.52:
- fixed:   changed all occurrences of bit.band to equivalent modulo operations
           to fix a problem that reportedly occured on some macintosh machines
- fixed:   an error that caused a "heroic only" flag to be displayed incorrectly
           on some items
- fixed:   Quests which are available for both sides, Alliance and Horde, under
           the same title but with different objective texts should now be
	   distinguished correctly when using the ?-Button next to the quest title
	   (you should get the version for the faction of your current character)
- added:   a new minimap button to open/close the MobMap window. The minimap button
           can be rotated around the minimap or dragged off the map and be placed
	   freely on the screen. It can also be hidden in the MobMap options.
- changed: the mob search result list is now scrollable

v1.53:
- fixed:   multiple minor glitches in the data collection mechanism that could cause 
           error messages when certain in-game actions were performed
- fixed:   the minimap button should now stay hidden if you hide it in the options

v1.54:
- fixed:   the profession selection in the recipe tab is now permanent (so if you
           switch to a different tab and switch back to recipes, the selection will
	   still be active)
- changed: the whole quest data gathering mechanism has been reworked to extend it,
           fix some inconsistencies and to fix a problem that prevented the database
	   from adding a few very specific quests

v1.55:
- fixed:   a few minor flaws in the data collection code which threw error messages in
           some rare occasions
- fixed:   interface version number changed for the 2.2 major patch

v1.56:
- changed: slight database format changes to compensate for growing amounts of data
           and growing ID ranges. You will need to get an updated database copy!
- fixed:   an error in the mob name search that prevented some specific mob names from
           being found
- added:   a new zone filtering textbox for the mob positions
- added:   item names in the drop rate database can now be linked in chat
- changed: toc version number updated for patch 2.3
- changed: the standard MobMap button placement on the world map has been changed to
           make room for a new dropdown menu added by Blizzard in patch 2.3

v1.57:
- fixed:   accepting quests from objects should not throw errors anymore
- added:   quicksearch buttons for reagents in the trade skill window

v1.58:
- fixed:   a few layer problems and logical errors with the new reagent quicksearch
           buttons
- fixed:   a slight error in the position data collection code
- changed: The MobMap dots on the world map have been reworked. They are bigger now and
           have a black border to make it easier to distinguish them from the map
- removed: The dot scaling options have been removed, since the new dots are bigger
           than the old ones in any case.

v1.60:
- fixed:   Interface version number changed for patch 2.4
- changed: The transparency setting for the dots on the world map has been replaced by
           configuration options for the outer and inner color of the dots. You can now
           customize colors _and_ transparency this way.
- added:   If a quest title quicksearch query does result in multiple quests with the
           same title, you will now be able to cycle through those quests by two new
	         buttons in the quest details window.

v1.61:
- fixed:   the game should no longer freeze when porting across continental boundaries
- fixed:   a bug that could cause an error at line 599 of MobMap.lua when visiting a
           vendor

v1.62:
- fixed:   a lua error that's been thrown since WoW patch 2.4.2 when looting a corpse
           with money inside

v2.00:
- added:   MobMap does now support user-created quest comments! You can write comments
           as well as read comments written by other players. This functionality can
	   be disabled in the options if you don't want to use it.
- changed: The database format has been changed to incorporate the quest comments as
           well as extend a limitation in the old format. YOU WILL NEED TO UPDATE
	   YOUR DATABASE COPY WHEN UPDATING MOBMAP!
- changed: The functionality of the quicksearch buttons next to quest titles has been
           improved. These buttons should now find the correct quest even if multiple
	   quests have the same title.
- added:   There are now quicksearch buttons at questgivers. They can of course be
           disabled optionally, like the other quicksearch buttons.

v2.01:
- fixed:   MobMap does not throw errors when completing quests anymore if Fizzwidgets
           Levelator is installed
- fixed:   The minimap dots now stay where they should be and don't "move" around while
           you approach the target position
- fixed:   The recipe minimum level number fields are now more tolerant to wider custom
           fonts

v2.02:
- fixed:   The strange problems with Cartographer and not-showing dots on the map that
           only occured on a small number of machines (hopefully) are a thing of the past
- added:   An optional display of dots on the battlefield minimaps (which you can also
           use outside of battlefields, of course)
- added:   Newly displayed dots will now flash for a few seconds to make it easier to
           spot them on the map. This functionality can of course be disabled.
- added:   Quest comments are now automatically being shown, if possible. This behavior 
           can be disabled optionally.
- added:   Tracking of quest event targets (that is, targets like "go to point x") has
           been added. Functionality to display the positions of such quest targets will
           be added in the next major version.
- fixed:   Some issues with german Umlauts and other special characters in the comment
           system have been fixed. All new comments shouldn't have problems with those
           special characters anymore.

v2.10:
- changed: There has been a major DATABASE FORMAT CHANGE! You'll need to download a
           new database when installing v2.10!
- added:   New quest event database, which can be queried through a new interface panel
           or by using the quicksearch buttons on quest event targets
- changed: Options panel was moved to the Blizzard Interface->Addons settings screen and
           reorganized slightly
- fixed:   The new settings added with v2.02 (flashing dots, battlefield minimap, quest
           comment autoshow) are now being saved permanently
- changed: The functionality of the quicksearch buttons next to quest titles has been
           further improved. These buttons now use the Blizzard QuestIDs to find the
           correct quest whenever possible.

v2.11:
- fixed:   A slight incompatibility with MobMap v2.10 and LightHeaded has been fixed.
           This problem could break LightHeaded's Next/Previous-Buttons if some
           specific circumstances were met.

v2.12:
- fixed:   A bug in the quest event data collection mechanism that resulted in
           erroneous data especially with quests which have more than one quest event
           objective.

v3.0:
- added:   full compatibility with WoW patch 3.0 and WotLK

v3.01:
- fixed:   a bug introduced with v3.0 that caused an error when displaying mob entries in
           the drop chance window and rendered the window useless
- fixed:   an error on the pickup database window (caused a wrong size of a dropdown window
           but did not impact any functionality)
- fixed:   merchant filtering by zone works correctly now, as well as the zone display in
           the merchant window

v3.02:
- fixed:   an error that could cause unintended interference with the tradeskill
           window in certain conditions
- fixed:   several internal errors concerning the data collection mechanisms

v3.03:
- fixed:   the quest event position display now actually displays positions again
- fixed:   the newbie tooltip integration does now work as expected (tooltips only show
           if newbie tips are enabled; otherwise they don't show at all)
- fixed:   displaying multiple quest givers at once on a map does now work correctly
- changed: the MobMap button and other stuff on the world map has been resized and slightly 
           redesigned to better coexist with elements from other addons (i.e. Mapster, TomTom)
- added:   TomTom support! You can now click on a dot on the world map to create a TomTom
           waypoint if you have TomTom installed (just like with Cartographer)
- changed: some of the data gathering routines have been improved in anticipation of WotLK

v3.04:
- added:   Quest completion tracking! MobMap can now track which quests you have finished and
           show that information in the MobMap quest list. You can also search for quests
           you haven't finished yet.
- fixed:   Various minor issues

v3.10:
- added:   The new MobMap quest tracker was added. This tool allows you to track all your
           quests at once like with the Blizzard Quest Watch, but it has multiple improvements
           like showing quests which don't have a target, showing an estimated distance
           to the place you have to go to for each target MobMap knows about, allowing quick
           access to the questlog page of a quest and showing the NPC where a quest has to be 
           turned in as a "quest target", all complete with MobMap quicksearch buttons of course.
- added:   A new MobMap options sub-panel on the Blizzard interface options screen to configure
           the new quest tracker (or disabling it entirely, if you wish so)
- added:   An option to directly create TomTom/Cartographer waypoints when searching for a quest
           objective via the new quest tracker
- changed: when using the quicksearch buttons to search for quest objectives, the MobMap window
           will not pop up anymore if an objective is found that is only located in one zone,
           if a quest drop is found which only drops from one mob in one zone or if a
           pickup item is found which can only be gathered in one zone. Instead, the locations
           you need are directly shown on the map.

v3.11:
- fixed:   An issue with Carbonite that caused the Carbonite map to flicker in certain situations
- added:   A new tooltip to the MobMap quest tracker toggle button that explains how to use it
- added:   A shortcut to completely disable the new quest tracker by alt-clicking onto the toggle
           button (can be reenabled using the regular option in the MobMap configuration sub-panel
           in the interface options)
- added:   New options for the quest tracker: Option to hide finished objectives, an option to hide
           finished quests, an option to hide the "turn in to..." objectives and an option to hide
           the distance to quest targets
- added:   new tooltips when hovering over quest names in the tracker that show the short quest
           description from the questlog
- added:   Finished quests are now colored in a bright green color to indicate their finished status
- added:   Quest levels are now being displayed in the quest titles, as well as minimum group size
           suggestions from Blizzard
- fixed:   Reenabling the quest tracker now works without an interface reload

v3.12:
- fixed:   A critical bug in 3.11 that caused MobMap to fuck up quest turn-ins and tradeskill windows

v3.13:
- fixed:   the indentation of the right side of the quest tracker window does now work correctly
           if a scrollbar has to be shown
- fixed:   toggling the quest tracker window does now work correctly again in any situation
- fixed:   some general performance improvements considering the quest tracker

v3.14:
- fixed:   The error that has been shown when switching to the pickup database manually has been fixed
- changed: Quest targets (like "Kill 10 foozles: 0/10") will now line-wrap in the quest tracker to
           always allow you to read the full text
- changed: Scrolling in the quest tracker has been changed from line-based scrolling to pixel-exact
           scrolling
- fixed:   Displaying pickup item positions in multiple zones simultaneously does now work again

v3.15:
- fixed:   The scrollbar issues in the quest tracker have been solved somehow. Unfortunately hiding 
           the scrollbar and using the space to make the text a little bit wider didn't work out as
	   desired with the line-wrapping quest targets, so I switched to a static text width for 
	   the moment, still only showing the bar when it's required though.

v3.16:
- fixed:   A recent incompatibility with the TomTom addon (setting a waypoint by clicking on a dot on
           the world map does now work as intended again)
- changed: Some internal optimizations (thanks go to Cladhaire for pointing out the problem) to reduce
           CPU load during general use and improve compatibility with other map addons. This might
	   also fix framerate problems some people might have had with certain addon combinations.

v3.17:
- fixed:   A tiny bug introduced with v3.16 which caused an error message when entering an instance
- fixed:   An error message that could appear in combination with Carbonite (hopefully it's fixed,
           unfortunately I was not really able to reproduce it)

v3.20:
- changed: DATABASE FORMAT CHANGE! You will need to get an updated database copy!
- fixed:   Token costs are now correctly displayed in the merchant tab
- fixed:   The 'Suppress World Map' option setting of the MobMap quest tracker is now saved correctly
           between sessions
- added:   The names of group members which are on a specific quest are now listed in the quest tracker
           quest tooltips, as well as the total number of group members on a quest which is shown
	   directly in the quest title
- added:   The type of a quest is now indicated by a letter in the quest title next to the quest
           level ("r"=Raid, "g"=Group, "d"=Daily, "p"=PvP)
- added:   Shift-clicking a quest in the quest tracker now links the quest in chat
- fixed:   Quests with all objectives completed are now correctly colored in the quest tracker
- changed: The color of completed quests in the tracker has been changed from light green to blue
           to make finished quests more distinguishable from quests below your level
- added:   Quest tracker does now also show distance/position of objects where quests can be turned in
- added:   Dynamic quest tracker distance calculation if mobs/items/... are spread out over a large
           area - distance is based on shortest path to the area now instead of a fixed position in
	   the middle of the area. Automatically created TomTom waypoints are also being updated
	   so that they always show the shortest path to the target area.
- added:   Intelligent sorting of quest targets by distance has been added (can be disabled in the
           quest tracker options if you don't want the feature)
- fixed:   World Map dots created from coords in quest comments are now displayed on the minimap, too
- fixed:   When displaying dots in multiple zones at once, these dots are now displayed on the minimap
           as well
- changed: The minimap handling has been improved. This lowers the resource consumption and allows
           the minimap dots to extend to the full minimap size (instead of being displayed only on a
	   part of the minimap around the center)
- added:   Configurable background color for the quest tracker

v3.30:
- changed: DATABASE FORMAT CHANGE! You will need to get an updated database copy!
- fixed:   A bug causing errors when searching for specific quest targets in the Blizzard quest log
- changed: The addon has been updated for Patch 3.1
- added:   Little icons for quest-specific items next to the quest titles in the quest tracker
           (very similar to the new item icons in the Blizzard quest tracker)
- added:   Guide functionality: by right-clicking the MobMap minimap icon you can open the new
           guide which points you to the nearest (repair) vendor/flightmaster/banker/... - there
	         is already a nice list of supported targets and more are to be added in the future

v3.31:
- changed: DATABASE FORMAT CHANGE! You will need to get an updated database copy!
- fixed:   A bug in the database routines which caused MobMap to either show wrong quest targets
           or throw an error in MobMap_itemdropdata.lua for certain quest target searches and
	   which displayed the wrong mob names in the drop database
- fixed:   Another bug that caused the wrong recipe reagents to be displayed
- added:   Shift-clicking a recipe line in the recipe database will now link it into chat!

v3.32:
- fixed:   The configuration checkbox "automatically show quest comments" does now store
           its setting correctly instead of enabling the functionality when the checkbox is
	   being disabled and the other way round
- fixed:   A compatibility issue with Cartographer which prevented players from opening
           dropdown menus in instances if both MobMap and Cartographer were enabled
- fixed:   Several misbehaviors when searching for quest targets in both the MobMap and the 
           Blizzard quest tracker
- fixed:   A stack overflow bug that could cause the WoW client to freeze when displaying the
           positions of mobs in the Dalaran sewers

v3.33:
- fixed:   The MobMap quest tracker will now update correctly if data collection was disabled
- fixed:   boss loot tables are now fully functional again (that means: chests work, too)

v3.40:
- changed: The addon has been updated for Patch 3.2

v3.41:
- fixed:   A nasty bug which basically made the MobMap quest tracker non-reactive to user input
           and quest log changes
- fixed:   Updated the version of the Astrolabe library to rev. 107

v3.42:
- fixed:   An internal bug in the data collection system
- fixed:   Mysterious Cooldown.lua errors (hopefully, was unable to replicate those for debug)

v3.43:
- changed: Boss loot tables have been revised a little to include the new distinction between
           10 and 25 player raid instances. An icon next to the "heroic" icon will mark loots
	   which are only available in the 25 player version. The new instance "Trial of the
	   Crusader" will also appear in the instance list now.
- changed: DATABASE FORMAT CHANGE! You will have to get a new database copy when updating!

v3.44:
- fixed:   A bug in the data collection system

v3.45:
- changed: Quest targets which have you collect items dropped by a lot of different mobs will now
           display a maximum of only 4 mob names below the auto-generated TomTom waypoint arrow
- fixed:   The small quest item buttons in the MobMap quest tracker will now work correctly
           in every situation
- changed: The "collapsed/expanded" status of the quest group headers in MobMaps quest tracker
           and Blizzards quest log are now synchronized (was required to fix the bug above)
- fixed:   Clicking on a quest title in the MobMap quest tracker will now correctly display the
           WoW quest log at its correct position, not sticking at the top of the screen
- fixed:   A problem has been corrected which caused a few quests with more than one quest target
           to only display the distance to the first target in the MobMap quest tracker (however,
	   you will also have to fetch a fresh database copy for this fix to work)
- changed: Several minor internal improvements and tweaks have been made to the quest tracker

v3.46:
- fixed:   The quest tracker item buttons which I accidentially broke in 3.45 are now fixed (and
           yeah, they should finally work fine in any situation now!)

v3.50:
- changed: MobMap is now WoW patch 3.3 compatible
- added:   A new button to synchronize the "finished" flag of quests with the server was added
           to the quests database view
- changed: The classic "question mark buttons" in the original quest tracker and quest log have
           been changed into a MobMap-specific styled button to clearly distinguish them from
	   Blizzards' own new quest helper buttons
- changed: The behavior of the MobMap quest tracker when a quest title is clicked has been
           altered to match the behavior of the Blizzard quest tracker
- added:   When a question mark for a quest target in the MobMap quest tracker is clicked,
           the corresponding quest in Blizzards' quest POI system is selected too, if possible
- added:   An additional "B"-style button has been added in the MobMap quest tracker next to
           quest titles. This button displays Blizzards' POI marker for that quest on the map.
- added:   MobMap can now display the exact positions of mobs in instances (provided that there
           is a map for the instance, like it's the case with all post-WotLK instances)

v3.51:
- fixed:   Error messages when getting a quest or returning a quest at a questgiver
- fixed:   Wrong dot positioning on the map if the Mapster addon is used
- fixed:   Wrong positioning of the MobMap button on the smaller map

v3.52:
- fixed:   removed some debug code I forgot in v3.51 ;-)

v3.53:
- fixed:   A bug in the data collection mechanisms