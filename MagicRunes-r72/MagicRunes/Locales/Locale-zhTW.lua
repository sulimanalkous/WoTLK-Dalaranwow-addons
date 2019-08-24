local L = LibStub("AceLocale-3.0"):NewLocale("MagicRunes", "zhTW")
if not L then return end

-- To help localize Magic Runes please enter phrase translations on the
-- following URL:
-- http://www.wowace.com/projects/magicrunes/localization/
-- This file should not be edited manually!

L[ [=[ - All alpha level parameters.

]=] ] = "所有透明度參數"
L[ [=[ - Flash Mode, Alpha Flash (color flash doesn't work)
]=] ] = "閃爍方式，透明度閃爍（不作用於顏色閃爍）"
L["Add a new bar"] = "新增計時條 "
L["Alert sound effect"] = "警報音效"
L["Alert sound trigger"] = "警報音效觸發"
L["All the other decorations and effects don't make sense for icons and thus don't work."] = "所有其它的修飾和效果對於圖示無效，所以也不會起作用。"
L["Alpha Flash"] = "透明度閃爍"
L["Alpha Levels"] = "透明度"
L["Alpha Settings"] = "透明度設定"
L["Alpha level for ready runes when out of combat."] = "離開戰鬥時已就緒的符文條透明度"
L["Alpha level of active runes when the remaining cooldown is longer than the global cooldown."] = "剩餘冷卻時間長於公共冷卻時間的已啟用符文計時條的透明度"
L["Alpha level of active runes when the remaining cooldown is shorter the global cooldown."] = "剩餘冷卻時間短於公共冷卻時間的已啟用符文計時條的透明度"
L["Alpha level of ready runes when in combat."] = "戰鬥中已就緒的符文條的透明度"
L["Animate icons"] = "動畫圖示"
L[ [=[As with the normal layout, you can specify the order of the runes using the rune order parameter.

]=] ] = "在正常樣式下，你可以利用符文排序參數設定符文序列。"
L["Background"] = "背景"
L["Background Frame"] = "背景框架"
L["Background Texture"] = "背景材質"
L["Bar #"] = "計時條 #"
L["Bar Configuration"] = "計時條設定"
L["Bar Layout"] = "計時條樣式"
L["Blood"] = "血魄符文"
L["Blood #1"] = "血魄符文 #1"
L["Blood #1 Angle"] = "血魄符文 #1 角度"
L["Blood #2"] = "血魄符文 #2"
L["Blood #2 Angle"] = "血魄符文 #2 角度"
L["Button Facade"] = "Button Facade"
L["Circle"] = "環形"
L["Circle Layout"] = "環形樣式"
L["Color Flash"] = "顏色閃爍"
L["Color flash does not work with these bars, nor are there any labels yet."] = "顏色閃爍未在條中作用，也尚未有標籤。"
L["Color used for background texture."] = "背景材質顏色"
L["Color used for blood rune bars."] = "血魄符文計時條顏色"
L["Color used for death rune bars."] = "死亡符文計時條顏色"
L["Color used for frost rune bars."] = "冰霜符文計時條顏色"
L["Color used for the Blood Plague bar."] = "血魄瘟疫計時條顏色"
L["Color used for the Frost Fever bar."] = "冰霜熱疫計時條顏色"
L["Color used for the runic power bar."] = "符能條顏色"
L["Color used for unholy rune bars."] = "穢邪符文計時條顏色"
L["Colors"] = "顏色"
-- L["Columns"] = ""
L["Cooldown Count"] = "冷卻計時"
L["Create a new bar."] = "新增計時條"
L[ [=[Currently there's no built-in option to display cooldown count text on the icons. You can however install an addon such as OmniCC to get this feature.

]=] ] = "目前尚未內置選項來在圖標上顯示冷卻計時。不過你可以安裝OmniCC一類的插件來或者這種功能。"
L["Death"] = "死亡符文"
L["Decoration and Effects"] = "修飾與效果"
L["Decorations"] = "修飾"
L["Documentation"] = "檔案說明"
L["Each option comes with its own set of parameters that controls the layout. "] = "每一個設定對應自己的一套參數來控制樣式。"
L["Ellipse"] = "橢圓形"
L["Ellipse Layout"] = "橢圓形樣式"
L["Enable Icon Display"] = "啟用圖示顯示"
L["Enable Rune Bars"] = "啟用符文條"
L["Enable minimap icon"] = "顯示小地圖圖示"
L["Fade alpha from gcd to ready"] = "從公共冷卻狀態到可用狀態的透明度漸變"
L["Fade alpha level between the in GCD and out of GCD alpha level. This can be used to make the rune cooldown displays become incrementally more visible as the cooldown decreases."] = "從公共冷卻狀態過度的透明度漸變程度。可以使公共冷卻更加易於觀察。"
L["Fade alpha level of active runes"] = "啟用符文的透明度漸變程度"
L["Fade the alpha level between the GCD level and the ready level. This option is ignored if the alpha flash notification is enabled."] = "在公共冷卻狀態和可用狀態之間漸變透明度程度。這個設定在透明度閃爍通知選項啟用時將被忽略。"
L["Flash mode"] = "閃爍方式"
L["Flash when ready"] = "就緒時閃爍"
L["Flip horizontal growth direction"] = "水平伸展方向"
L["Flip vertical growth direction"] = "垂直伸展方向"
L["Font"] = "字型"
L["Font & Texture"] = "字型和材質"
L["Font and Texture"] = "字型和材質"
L["Font size"] = "字型大小"
L["Font used on the bars"] = "計時條字型"
L["Frost"] = "冰霜符文"
L["Frost #1"] = "冰霜符文 #1"
L["Frost #1 Angle"] = "冰霜符文 #1 角度"
L["Frost #2"] = "冰霜符文 #2"
L["Frost #2 Angle"] = "冰霜符文 #2 角度"
L["Hide anchor when bars are locked."] = "計時條鎖定時隱藏拖動錨點"
L["Hide bar"] = "隱藏計時條"
L["Hide the Blizzard rune frame"] = "隱藏暴風雪符文框架"
L["Horizontal Radius"] = "水平半徑"
L["Horizontal Spacing"] = "水平間距"
L["Horizontal animated icons"] = "水平動畫圖示"
L["Horizontal labeled bars"] = "水平標籤動作條"
L["Icon Display"] = "圖示顯示"
L["Icon Scale"] = "圖示縮放"
L["Icon Spread"] = "圖示伸展"
L["If checked you can specify the exact location of each rune on the circle or ellipse. If unchecked you specify the start angle, spread and order of the icons instead."] = "如果選定你可以安排每一個圖示在環形或者橢圓形上的確切位置。如果未選定你可以安排初始角度，伸展和圖示序列。"
L["If enabled, the icons will move with the bar. If the bar texture is hidden, you'll get a display simply showing the cooldown using icons."] = "如果可用，圖示將和計時條共同移動。如果計時條材質被隱藏，將在圖示上簡單顯示冷卻時間。"
L["If toggled, the icons will expand to the left instead of to the right."] = "如果選定，圖示將擴展到左側而不是右側"
L["If toggled, the icons will expand upwards instead of downwards."] = "如果選定，圖示將擴展到上方而不是下方"
L["In the future you'll be able to use either an external cooldown count addon or builtin text."] = "不久你就能夠使用外置的冷卻計時或者內置計時文字。"
L["In-Combat ready rune alpha"] = "戰鬥中就緒的符文透明度"
L["In-GCD active rune alpha"] = "處於公共冷卻時間的已啟用符文的透明度"
L["Individual icon placement"] = "單獨圖示放置"
L["Instead showing the time elapsed on the cooldown, show the time remaining. This means that the bars will shrink as the cooldown lowers instead of grow."] = "顯示符文剩餘冷卻時間取代經過的時間。即計時條將隨冷卻時間的減少變的收縮而不是增長。"
L["Introduction"] = "簡介"
L["Label"] = "標籤"
L["Label used for vertical bars"] = "垂直計時條標籤"
L["Label used on horizontal bars"] = "水平計時條標籤"
L["Layout"] = "樣式"
L["Layout Options"] = "樣式設定"
L["Layout Style"] = "樣式風格"
L["Layout and Sorting"] = "樣式與排序"
L["Length"] = "長"
L["Load preset"] = "載入預設"
L["Lock bar positions"] = "鎖定計時條位置"
L["Magic Runes"] = "Magic Runes"
L["Many options in the module core is used for this addon, such as alpha levels, alpha flash, ready flash and rune icon set."] = "許多核心模組設定已經被插件所使用，例如透明度、閃爍動畫、就緒動畫還有符文圖示設定。"
-- L["Minimal 2x3 layout"] = ""
-- L["Minimal 3x2 layout"] = ""
-- L["Minimal horizontal layout"] = ""
-- L["Minimal vertical layout"] = ""
L["NOTE: RUNE BARS IS STILL WORK IN PROGRESS. Many features are still missing!"] = "注意: 符文條正在研發. 許多功能仍然缺少!"
L["Never"] = "從不"
L["None"] = "無"
L["Normal"] = "標準"
L["Normal Layout"] = "標準樣式"
L["Normally the time is shown with one decimal place when the remaining cooldown is less than the global cooldown. If this toggled on, only seconds will be shown."] = "當冷卻時間少於公共冷卻時間時，正常時間顯示帶有一位小數。如果本選項被選定，將僅僅顯示整數秒。"
-- L["Number of columns per row."] = ""
L["Number of flashes"] = "閃爍次數"
L["Number of icons per row."] = "每列圖示數量"
L["Number of times to flash bars when the remaining is less than the GCD. Set to zero to disable flashing."] = "當冷卻時間少於公共冷卻時間時計時條的閃爍次數。選擇0則禁止閃爍。"
L["On GCD"] = "在公共冷卻狀態"
L["On readiness"] = "在可用狀態"
L["Orientation"] = "方向"
L["Out of combat alpha"] = "離開戰鬥透明度"
L["Out-of-GCD active rune alpha"] = "不在公共冷卻狀態的已啟用符文條透明度"
L["Overall Scale"] = "整體比例"
L["Presets are primarily here to give you a few ideas on how you can configure the bars. Note that the presets do now change font, texture or color options. The global scale is also not changed."] = "預設外觀方案首先為你在幾個方面配置計時條。請注意改變字型、材質和顏色的預設外觀方案，整體比例也不會隨之改變。"
L["Profiles"] = "設定檔"
L["Radius"] = "半徑"
L["Ready flash duration"] = "就緒閃爍持續時間"
L["Regardless of layout, you can always pick the rune icon set to use and the icon scale."] = "不考慮樣式，你總是可以選擇符文圖示組合和縮放。"
L["Reverse Sorting"] = "逆向排序"
L["Reverse growth direction"] = "反向增長方向"
L["Reverse icon placement order"] = "翻轉排列圖示組合"
L["Reverse the order in which bars are added relative to the anchor."] = "相對增加錨點到反向順序條"
L["Reverses the direction of icon placement on the circle or ellipse"] = "在圓形或者橢圓形上翻轉圖示排列方向"
L["Rune #"] = "符文 #"
L["Rune Bars"] = "符文條"
L["Rune Bars Introduction"] = "符文條簡介"
L["Rune Icon Set"] = "符文圖示組合"
L["Rune Order"] = "符文順序"
L["Runes"] = "符文"
L["Runic"] = "符能"
L["Runic bar"] = "符能條"
L["Seconds only"] = "只顯示秒"
-- L["Select preset to load..."] = ""
L["Shared Parameters"] = "共用參數"
L["Short Label"] = "短標籤"
-- L["Show Rune Icons"] = ""
L["Show an icon to open the config at the Minimap"] = "在小地圖顯示圖示開啟設定"
L["Show configuration dialog"] = "顯示設定對話框"
L["Show icons"] = "顯示圖示"
L["Show labels"] = "顯示標籤"
L["Show labels on the bars indicating the rune type. Note the timer cannot be shown on the icon while labels are enabled."] = "顯示在計時條上的標籤說明符文類型。當標籤啟用注意無法在圖示上顯示冷卻時間。"
L["Show remaining time"] = "顯示剩餘時間"
L["Show spark"] = "顯示閃光"
L["Show the countdown timer on top of the icon instead of on the bar. This option is only available when labels are hidden."] = "在圖示上顯示冷卻時間計時以取代計時條。這個選項只有在標籤被隱藏的情況下可用。"
L["Show timer"] = "顯示計時"
L["Show timer on icon"] = "在圖示上顯示計時"
L["Some parameters are shared between layouts, while others are not. "] = "在不同樣式下可以共用的參數，但是其他參數不可共用。"
L["Sort Method"] = "排序方式"
L["Sorting Weight"] = "排序重要度"
L["Spacing"] = "間距"
-- L["Standard bars"] = ""
L["Start Angle"] = "起始角度"
L["Static icons, timer, no bars"] = "靜態圖標，計時顯示，無標籤"
L["Texture"] = "材質"
L["The Icon Display has three different layout options: Normal, Circle and Ellipse. "] = "圖示的顯示有三種不同的樣式選項：標準、圓形和橢圓形。"
L["The Rune Bar module is a replacement for the built-in original rune bars. It is currently not complete but is entirely usable."] = "符文條模組將取代內建的符文條。目前尚未完成但是完全可用。"
L["The alpha level of the frame background when out of combat and no runes are active."] = "背景框架透明度當離開戰鬥和沒有符文作用。"
L["The angle of Blood Rune #1."] = "血魄符文 #1 的角度"
L["The angle of Blood Rune #2."] = "血魄符文 #2 的角度"
L["The angle of Frost Rune #1."] = "冰霜符文 #1 的角度"
L["The angle of Frost Rune #2."] = "冰霜符文 #2 的角度"
L["The angle of Unholy Rune #1."] = "穢邪符文 #1 的角度"
L["The angle of Unholy Rune #2."] = "穢邪符文 #2 的角度"
L["The angle to start putting the icons on."] = "圖示放置的起始角度"
L[ [=[The background frames allows you to set an optional backdrop behind the bars. You can configure the border and background texture and color.

]=] ] = "背景框架允許您設定在可選的背景。你可以設定框架和背景材質和顏色。"
L[ [=[The background frames allows you to set an optional backdrop behind the icons. You can configure the border and background texture and color.

]=] ] = "框架背景允許你配置圖示後面的背景。你可以設定邊框、背景材質和顏色。"
L["The background texture for the bars. ."] = "計時條背景材質"
L[ [=[The circle layout will place the icons around an invisible circle. This is done using a radius, starting angle and icon spread parameters.

]=] ] = "圓形樣式將把圖示置於一個隱形的圓環上。這是通過設定半徑、起始角度和圖示伸展參數實現的。"
L[ [=[The ellipse is identical to circle layout except it allows you to specify both horizontal and vertical radius. These two parameters are used to determine the size and shape of the ellipse.

]=] ] = "橢圓形樣式允許你指定水平和垂直半徑，其他方面和圓形樣式是一樣的。這兩個參數用來確定橢圓形的大小和形狀。"
L[ [=[The icon display is fully integrated with the ButtonFacade addon. This addon lets you skin the buttons for a more personalized display.

]=] ] = "圖示顯示與 ButtonFacade插件完全整合。這插件讓你的按鈕外觀更個性化顯示。"
L[ [=[The icon display uses the addon global settings for decorations. The following decorations and effects works for icons: 

]=] ] = "圖示顯示的修飾適用插件的全局設定。但是下面的修飾和效果僅適用於圖示："
L[ [=[The icons are fully integrated with the ButtonFacade addon. This addon lets you skin the buttons for a more personalized display.

]=] ] = "圖示與 ButtonFacade插件完全整合。這插件讓你的按鈕外觀更個性化顯示。"
L["The normal layout lets you put the icons in straight vertical or/or horizontal rows and colums. "] = "標準樣式讓你將圖示水平或垂直放置或水平的列或者行"
L["The number of degrees to spread the icons over - 180 degrees is a half circle, 360 degrees is a full circle."] = "圖示散布的角度--180度是一個半圓形，360度是一整個圓形。"
L["The radius of the circle."] = "圓形半徑"
L["The radius of the major axis of the ellipse."] = "橢圓形長軸半徑"
L["The radius of the minor axis of the ellipse."] = "橢圓形短軸半徑"
L["The sound effect to play when the sound alert trigger occurs."] = "警報音效觸發事件發生時播放的警報音"
L[ [=[The space between columns is controlled by the horizontal spacing parameter. Use the vertical spacing parameter to control the space between rows.

]=] ] = "行之間的間距由水平間距參數控制。利用垂直間距參數可以控制列之間的間距。"
L[ [=[The spread decides how far apart the icons are while the start angle determines where the first icon should be placed. You can reverse the placement direction as well.

]=] ] = "分散度決定了圖標之間的距離，同時起始角度決定了第一個圖標的位置。你也可以翻轉排列方向。"
L["The texture used for active bars."] = "已啟用符文計時條材質"
L["The time in seconds that the bar should flash when a rune becomes ready."] = "符文可用時計時條閃爍的秒數"
L["The weight used when sorting this bar. A value less than 1 means it's sorted before rune bars. A value above 6 means it's sorted after the rune bars."] = "符文計時條排序時的重要程度。小於1的數值意味著將先於符文條排列，大於6的數值意味著晚於於符文條排列。"
L[ [=[The width of the border is controlled by the edge size parameter. To add some extra padding between the border and icons you can set the padding.

]=] ] = "邊框的寬度由邊框大小參數控制。在邊框和圖示之間的圖案你可以設定填充選項。"
L["Thickness"] = "寬度"
L["Tiny horizontal bars"] = "微型水平計時條"
L["Tiny vertical bars"] = "微型垂直計時條"
L[ [=[To be able to change the border and background you need the SharedMedia and SharedMedia-Blizzard addons installed. You can find these at http://wow.curse.com/

]=] ] = "改變框架和背景你需要安裝SharedMedia和SharedMedia-Blizzard插件. 你可以在 http://www.curse.com/找到"
L[ [=[To be able to change the border and background you need the SharedMedia and SharedMedia-Blizzard addons installed. You can find these at http://www.curse.com/

]=] ] = "改變框架和背景你需要安裝SharedMedia和SharedMedia-Blizzard插件. 你可以在 http://www.curse.com/找到"
L[ [=[To configure the looks, open the ButtonFacade configuration UI using the /buttonfacade command. Select Addons => Magic Runes => Rune Bars.

]=] ] = "設定外觀，開啟ButtonFacade設定插件使用/buttonfacade command. 選擇插件 => Magic Runes => 符文條。"
L[ [=[To configure the looks, open the ButtonFacade configuration UI using the /buttonfacade command. Select Addons => MagicRunes => Icon Display.

]=] ] = "設定外觀，開啟ButtonFacade設定插件使用/buttonfacade command. 選擇插件 => Magic Runes => 圖示顯示。"
L["Toggle visibility of this bar."] = "切換計時條視覺效果"
L["Toggle whether or not to show the spark on active bars."] = "切換已啟用符文計時條是否顯示閃光"
L["Type of flashing to use to indicate imminent readiness."] = "用於即將可用符文的閃爍類型"
L["Unholy"] = "穢邪符文"
L["Unholy #1"] = "穢邪符文 #1"
L["Unholy #1 Angle"] = "穢邪符文 #1 角度"
L["Unholy #2"] = "穢邪符文 #2"
L["Unholy #2 Angle"] = "穢邪符文 #2 角度"
L[ [=[Using the width parameter you can select how many icons to put in a row. A width of 1 means you'll have a single vertical column while a width of 6 means you'll have a single horizontal row.

]=] ] = "使用寬度參數你可以選擇在一行放置幾個圖示。寬度1意味著你有一個垂直列；而寬度6意味著你有一個水平行。"
L["Vertical Radius"] = "垂直半徑"
L["Vertical Spacing"] = "垂直間距"
L["Vertical animated icons"] = "垂直動畫圖示"
L["Vertical labeled bars"] = "垂直標籤計時條"
L["When a rune cooldown is finish, flash the bar as an extra notification source."] = "當一個符文冷卻結束時，閃爍計時條作為額外的提示。"
L["When to play the alert sound: On GCD => play when the remaining cooldown of a run goes below the global cooldown. On readiness => play when a rune becomes ready for use."] = "何時播放報警音：處於公共冷卻狀態=>當一個符文的剩餘冷卻時間低於公共冷卻時間。處於可用狀態=>當一個符文變成可用狀態時播放。"
L["Width"] = "寬度"
L[ [=[You can also choose to place icons individually. This allows you to specify the exact angle to use for each rune icon. When this option is used, the start angle, icon spread, placement direction and rune order parameters aren't used.

]=] ] = "你也可以選擇單個放置圖示位置，這會允許你指定每一個符文圖標的確切角度。當這個選項選定之後，起始角度、圖標伸展、排列方向和符文序列參數將不再起作用。"
L[ [=[You can change the order of the runes using the rune order parameter.

]=] ] = "你可以利用符文序列參數改變符文的排列順序。"
L["You can find ButtonFacade and many different skins on http://wow.curse.com/"] = "你可以找到ButtonFacade和許多不同皮膚在http://wow.curse.com/"
L["You can find ButtonFacade and many different skins on http://wow.curse.com/."] = "你可以找到ButtonFacade和許多不同皮膚在http://wow.curse.com/。"
L[ [=[You control the growth direction with the horizontal and vertical growth direction toggles.

]=] ] = "你通過水平和垂直伸展方向的切換可以控制伸展方向。"
L[ [=[|cffffff00Left click|r to open the configuration screen.
|cffffff00Right click|r to toggle the Magic Target window lock.]=] ] = [=[|cffffff00左擊|r打開設定視窗
|cffffff00右擊|r切換鎖定計時條視窗]=]

