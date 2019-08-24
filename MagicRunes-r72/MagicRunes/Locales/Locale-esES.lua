local L = LibStub("AceLocale-3.0"):NewLocale("MagicRunes", "esES")
if not L then return end

-- To help localize Magic Runes please enter phrase translations on the
-- following URL:
-- http://www.wowace.com/projects/magicrunes/localization/
-- This file should not be edited manually!

--[==[ L[ [=[ - All alpha level parameters.

]=] ] = "" ]==]
--[==[ L[ [=[ - Flash Mode, Alpha Flash (color flash doesn't work)
]=] ] = "" ]==]
-- L["Add a new bar"] = ""
-- L["Alert sound effect"] = ""
-- L["Alert sound trigger"] = ""
-- L["All the other decorations and effects don't make sense for icons and thus don't work."] = ""
-- L["Alpha Flash"] = ""
-- L["Alpha Levels"] = ""
-- L["Alpha Settings"] = ""
-- L["Alpha level for ready runes when out of combat."] = ""
-- L["Alpha level of active runes when the remaining cooldown is longer than the global cooldown."] = ""
-- L["Alpha level of active runes when the remaining cooldown is shorter the global cooldown."] = ""
-- L["Alpha level of ready runes when in combat."] = ""
-- L["Animate icons"] = ""
--[==[ L[ [=[As with the normal layout, you can specify the order of the runes using the rune order parameter.

]=] ] = "" ]==]
-- L["Background"] = ""
-- L["Background Frame"] = ""
-- L["Background Texture"] = ""
-- L["Bar #"] = ""
-- L["Bar Configuration"] = ""
-- L["Bar Layout"] = ""
-- L["Blood"] = ""
-- L["Blood #1"] = ""
-- L["Blood #1 Angle"] = ""
-- L["Blood #2"] = ""
-- L["Blood #2 Angle"] = ""
-- L["Button Facade"] = ""
-- L["Circle"] = ""
-- L["Circle Layout"] = ""
-- L["Color Flash"] = ""
-- L["Color flash does not work with these bars, nor are there any labels yet."] = ""
-- L["Color used for background texture."] = ""
-- L["Color used for blood rune bars."] = ""
-- L["Color used for death rune bars."] = ""
-- L["Color used for frost rune bars."] = ""
-- L["Color used for the Blood Plague bar."] = ""
-- L["Color used for the Frost Fever bar."] = ""
-- L["Color used for the runic power bar."] = ""
-- L["Color used for unholy rune bars."] = ""
-- L["Colors"] = ""
-- L["Columns"] = ""
-- L["Cooldown Count"] = ""
-- L["Create a new bar."] = ""
--[==[ L[ [=[Currently there's no built-in option to display cooldown count text on the icons. You can however install an addon such as OmniCC to get this feature.

]=] ] = "" ]==]
-- L["Death"] = ""
-- L["Decoration and Effects"] = ""
-- L["Decorations"] = ""
-- L["Documentation"] = ""
-- L["Each option comes with its own set of parameters that controls the layout. "] = ""
-- L["Ellipse"] = ""
-- L["Ellipse Layout"] = ""
-- L["Enable Icon Display"] = ""
-- L["Enable Rune Bars"] = ""
-- L["Enable minimap icon"] = ""
-- L["Fade alpha from gcd to ready"] = ""
-- L["Fade alpha level between the in GCD and out of GCD alpha level. This can be used to make the rune cooldown displays become incrementally more visible as the cooldown decreases."] = ""
-- L["Fade alpha level of active runes"] = ""
-- L["Fade the alpha level between the GCD level and the ready level. This option is ignored if the alpha flash notification is enabled."] = ""
-- L["Flash mode"] = ""
-- L["Flash when ready"] = ""
-- L["Flip horizontal growth direction"] = ""
-- L["Flip vertical growth direction"] = ""
-- L["Font"] = ""
-- L["Font & Texture"] = ""
-- L["Font and Texture"] = ""
-- L["Font size"] = ""
-- L["Font used on the bars"] = ""
-- L["Frost"] = ""
-- L["Frost #1"] = ""
-- L["Frost #1 Angle"] = ""
-- L["Frost #2"] = ""
-- L["Frost #2 Angle"] = ""
-- L["Hide anchor when bars are locked."] = ""
-- L["Hide bar"] = ""
-- L["Hide the Blizzard rune frame"] = ""
-- L["Horizontal Radius"] = ""
-- L["Horizontal Spacing"] = ""
-- L["Horizontal animated icons"] = ""
-- L["Horizontal labeled bars"] = ""
-- L["Icon Display"] = ""
-- L["Icon Scale"] = ""
-- L["Icon Spread"] = ""
-- L["If checked you can specify the exact location of each rune on the circle or ellipse. If unchecked you specify the start angle, spread and order of the icons instead."] = ""
-- L["If enabled, the icons will move with the bar. If the bar texture is hidden, you'll get a display simply showing the cooldown using icons."] = ""
-- L["If toggled, the icons will expand to the left instead of to the right."] = ""
-- L["If toggled, the icons will expand upwards instead of downwards."] = ""
-- L["In the future you'll be able to use either an external cooldown count addon or builtin text."] = ""
-- L["In-Combat ready rune alpha"] = ""
-- L["In-GCD active rune alpha"] = ""
-- L["Individual icon placement"] = ""
-- L["Instead showing the time elapsed on the cooldown, show the time remaining. This means that the bars will shrink as the cooldown lowers instead of grow."] = ""
-- L["Introduction"] = ""
-- L["Label"] = ""
-- L["Label used for vertical bars"] = ""
-- L["Label used on horizontal bars"] = ""
-- L["Layout"] = ""
-- L["Layout Options"] = ""
-- L["Layout Style"] = ""
-- L["Layout and Sorting"] = ""
-- L["Length"] = ""
-- L["Load preset"] = ""
-- L["Lock bar positions"] = ""
-- L["Magic Runes"] = ""
-- L["Many options in the module core is used for this addon, such as alpha levels, alpha flash, ready flash and rune icon set."] = ""
-- L["Minimal 2x3 layout"] = ""
-- L["Minimal 3x2 layout"] = ""
-- L["Minimal horizontal layout"] = ""
-- L["Minimal vertical layout"] = ""
-- L["NOTE: RUNE BARS IS STILL WORK IN PROGRESS. Many features are still missing!"] = ""
-- L["Never"] = ""
-- L["None"] = ""
-- L["Normal"] = ""
-- L["Normal Layout"] = ""
-- L["Normally the time is shown with one decimal place when the remaining cooldown is less than the global cooldown. If this toggled on, only seconds will be shown."] = ""
-- L["Number of columns per row."] = ""
-- L["Number of flashes"] = ""
-- L["Number of icons per row."] = ""
-- L["Number of times to flash bars when the remaining is less than the GCD. Set to zero to disable flashing."] = ""
-- L["On GCD"] = ""
-- L["On readiness"] = ""
-- L["Orientation"] = ""
-- L["Out of combat alpha"] = ""
-- L["Out-of-GCD active rune alpha"] = ""
-- L["Overall Scale"] = ""
-- L["Presets are primarily here to give you a few ideas on how you can configure the bars. Note that the presets do now change font, texture or color options. The global scale is also not changed."] = ""
-- L["Profiles"] = ""
-- L["Radius"] = ""
-- L["Ready flash duration"] = ""
-- L["Regardless of layout, you can always pick the rune icon set to use and the icon scale."] = ""
-- L["Reverse Sorting"] = ""
-- L["Reverse growth direction"] = ""
-- L["Reverse icon placement order"] = ""
-- L["Reverse the order in which bars are added relative to the anchor."] = ""
-- L["Reverses the direction of icon placement on the circle or ellipse"] = ""
-- L["Rune #"] = ""
-- L["Rune Bars"] = ""
-- L["Rune Bars Introduction"] = ""
-- L["Rune Icon Set"] = ""
-- L["Rune Order"] = ""
-- L["Runes"] = ""
-- L["Runic"] = ""
-- L["Runic bar"] = ""
-- L["Seconds only"] = ""
-- L["Select preset to load..."] = ""
-- L["Shared Parameters"] = ""
-- L["Short Label"] = ""
-- L["Show Rune Icons"] = ""
-- L["Show an icon to open the config at the Minimap"] = ""
-- L["Show configuration dialog"] = ""
-- L["Show icons"] = ""
-- L["Show labels"] = ""
-- L["Show labels on the bars indicating the rune type. Note the timer cannot be shown on the icon while labels are enabled."] = ""
-- L["Show remaining time"] = ""
-- L["Show spark"] = ""
-- L["Show the countdown timer on top of the icon instead of on the bar. This option is only available when labels are hidden."] = ""
-- L["Show timer"] = ""
-- L["Show timer on icon"] = ""
-- L["Some parameters are shared between layouts, while others are not. "] = ""
-- L["Sort Method"] = ""
-- L["Sorting Weight"] = ""
-- L["Spacing"] = ""
-- L["Standard bars"] = ""
-- L["Start Angle"] = ""
-- L["Static icons, timer, no bars"] = ""
-- L["Texture"] = ""
-- L["The Icon Display has three different layout options: Normal, Circle and Ellipse. "] = ""
-- L["The Rune Bar module is a replacement for the built-in original rune bars. It is currently not complete but is entirely usable."] = ""
-- L["The alpha level of the frame background when out of combat and no runes are active."] = ""
-- L["The angle of Blood Rune #1."] = ""
-- L["The angle of Blood Rune #2."] = ""
-- L["The angle of Frost Rune #1."] = ""
-- L["The angle of Frost Rune #2."] = ""
-- L["The angle of Unholy Rune #1."] = ""
-- L["The angle of Unholy Rune #2."] = ""
-- L["The angle to start putting the icons on."] = ""
--[==[ L[ [=[The background frames allows you to set an optional backdrop behind the bars. You can configure the border and background texture and color.

]=] ] = "" ]==]
--[==[ L[ [=[The background frames allows you to set an optional backdrop behind the icons. You can configure the border and background texture and color.

]=] ] = "" ]==]
-- L["The background texture for the bars. ."] = ""
--[==[ L[ [=[The circle layout will place the icons around an invisible circle. This is done using a radius, starting angle and icon spread parameters.

]=] ] = "" ]==]
--[==[ L[ [=[The ellipse is identical to circle layout except it allows you to specify both horizontal and vertical radius. These two parameters are used to determine the size and shape of the ellipse.

]=] ] = "" ]==]
--[==[ L[ [=[The icon display is fully integrated with the ButtonFacade addon. This addon lets you skin the buttons for a more personalized display.

]=] ] = "" ]==]
--[==[ L[ [=[The icon display uses the addon global settings for decorations. The following decorations and effects works for icons: 

]=] ] = "" ]==]
--[==[ L[ [=[The icons are fully integrated with the ButtonFacade addon. This addon lets you skin the buttons for a more personalized display.

]=] ] = "" ]==]
-- L["The normal layout lets you put the icons in straight vertical or/or horizontal rows and colums. "] = ""
-- L["The number of degrees to spread the icons over - 180 degrees is a half circle, 360 degrees is a full circle."] = ""
-- L["The radius of the circle."] = ""
-- L["The radius of the major axis of the ellipse."] = ""
-- L["The radius of the minor axis of the ellipse."] = ""
-- L["The sound effect to play when the sound alert trigger occurs."] = ""
--[==[ L[ [=[The space between columns is controlled by the horizontal spacing parameter. Use the vertical spacing parameter to control the space between rows.

]=] ] = "" ]==]
--[==[ L[ [=[The spread decides how far apart the icons are while the start angle determines where the first icon should be placed. You can reverse the placement direction as well.

]=] ] = "" ]==]
-- L["The texture used for active bars."] = ""
-- L["The time in seconds that the bar should flash when a rune becomes ready."] = ""
-- L["The weight used when sorting this bar. A value less than 1 means it's sorted before rune bars. A value above 6 means it's sorted after the rune bars."] = ""
--[==[ L[ [=[The width of the border is controlled by the edge size parameter. To add some extra padding between the border and icons you can set the padding.

]=] ] = "" ]==]
-- L["Thickness"] = ""
-- L["Tiny horizontal bars"] = ""
-- L["Tiny vertical bars"] = ""
--[==[ L[ [=[To be able to change the border and background you need the SharedMedia and SharedMedia-Blizzard addons installed. You can find these at http://wow.curse.com/

]=] ] = "" ]==]
--[==[ L[ [=[To be able to change the border and background you need the SharedMedia and SharedMedia-Blizzard addons installed. You can find these at http://www.curse.com/

]=] ] = "" ]==]
--[==[ L[ [=[To configure the looks, open the ButtonFacade configuration UI using the /buttonfacade command. Select Addons => Magic Runes => Rune Bars.

]=] ] = "" ]==]
--[==[ L[ [=[To configure the looks, open the ButtonFacade configuration UI using the /buttonfacade command. Select Addons => MagicRunes => Icon Display.

]=] ] = "" ]==]
-- L["Toggle visibility of this bar."] = ""
-- L["Toggle whether or not to show the spark on active bars."] = ""
-- L["Type of flashing to use to indicate imminent readiness."] = ""
-- L["Unholy"] = ""
-- L["Unholy #1"] = ""
-- L["Unholy #1 Angle"] = ""
-- L["Unholy #2"] = ""
-- L["Unholy #2 Angle"] = ""
--[==[ L[ [=[Using the width parameter you can select how many icons to put in a row. A width of 1 means you'll have a single vertical column while a width of 6 means you'll have a single horizontal row.

]=] ] = "" ]==]
-- L["Vertical Radius"] = ""
-- L["Vertical Spacing"] = ""
-- L["Vertical animated icons"] = ""
-- L["Vertical labeled bars"] = ""
-- L["When a rune cooldown is finish, flash the bar as an extra notification source."] = ""
-- L["When to play the alert sound: On GCD => play when the remaining cooldown of a run goes below the global cooldown. On readiness => play when a rune becomes ready for use."] = ""
-- L["Width"] = ""
--[==[ L[ [=[You can also choose to place icons individually. This allows you to specify the exact angle to use for each rune icon. When this option is used, the start angle, icon spread, placement direction and rune order parameters aren't used.

]=] ] = "" ]==]
--[==[ L[ [=[You can change the order of the runes using the rune order parameter.

]=] ] = "" ]==]
-- L["You can find ButtonFacade and many different skins on http://wow.curse.com/"] = ""
-- L["You can find ButtonFacade and many different skins on http://wow.curse.com/."] = ""
--[==[ L[ [=[You control the growth direction with the horizontal and vertical growth direction toggles.

]=] ] = "" ]==]
--[==[ L[ [=[|cffffff00Left click|r to open the configuration screen.
|cffffff00Right click|r to toggle the Magic Target window lock.]=] ] = "" ]==]

