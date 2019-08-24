local L = LibStub("AceLocale-3.0"):NewLocale("MagicRunes", "frFR")
if not L then return end

-- To help localize Magic Runes please enter phrase translations on the
-- following URL:
-- http://www.wowace.com/projects/magicrunes/localization/
-- This file should not be edited manually!

--[==[ L[ [=[ - All alpha level parameters.

]=] ] = "" ]==]
--[==[ L[ [=[ - Flash Mode, Alpha Flash (color flash doesn't work)
]=] ] = "" ]==]
L["Add a new bar"] = "Ajouter une nouvelle barre."
L["Alert sound effect"] = "Son d'alerte"
L["Alert sound trigger"] = "Déclenchement du son d'alerte"
-- L["All the other decorations and effects don't make sense for icons and thus don't work."] = ""
L["Alpha Flash"] = "Flash Alpha"
L["Alpha Levels"] = "Niveaux de transparence"
L["Alpha Settings"] = "Paramètres de transparence"
L["Alpha level for ready runes when out of combat."] = "Niveau de transparence des runes prêtes hors combat."
L["Alpha level of active runes when the remaining cooldown is longer than the global cooldown."] = "Niveau de transparence des runes actives lorsque le cooldown restant est supérieur au cooldown global."
L["Alpha level of active runes when the remaining cooldown is shorter the global cooldown."] = "Niveau de transparence des runes actives lorsque le cooldown restant est inférieur au cooldown global."
L["Alpha level of ready runes when in combat."] = "Niveau de transparence des runes prêtes en combat."
L["Animate icons"] = "Animer les icônes"
--[==[ L[ [=[As with the normal layout, you can specify the order of the runes using the rune order parameter.

]=] ] = "" ]==]
L["Background"] = "Arrière-plan"
-- L["Background Frame"] = ""
L["Background Texture"] = "Texture d'arrière-plan"
L["Bar #"] = "Barre #"
L["Bar Configuration"] = "Configuration de la barre"
L["Bar Layout"] = "Organisation de la barre"
L["Blood"] = "Sang"
L["Blood #1"] = "Sang #1"
-- L["Blood #1 Angle"] = ""
L["Blood #2"] = "Sang #2"
-- L["Blood #2 Angle"] = ""
-- L["Button Facade"] = ""
-- L["Circle"] = ""
-- L["Circle Layout"] = ""
L["Color Flash"] = "Flash de couleur"
-- L["Color flash does not work with these bars, nor are there any labels yet."] = ""
L["Color used for background texture."] = "Couleur utilisée pour la texture d'arrière-plan."
L["Color used for blood rune bars."] = "Couleur utilisée pour les barres de rune de sang."
L["Color used for death rune bars."] = "Couleur utilisée pour les barres de rune de la mort."
L["Color used for frost rune bars."] = "Couleur utilisée pour les barres de rune de givre."
-- L["Color used for the Blood Plague bar."] = ""
-- L["Color used for the Frost Fever bar."] = ""
L["Color used for the runic power bar."] = "Couleur utilisée pour la barre de puissance runique."
L["Color used for unholy rune bars."] = "Couleur utilisée pour les barres de rune impie."
L["Colors"] = "Couleurs"
-- L["Columns"] = ""
-- L["Cooldown Count"] = ""
L["Create a new bar."] = "Créer une nouvelle barre."
--[==[ L[ [=[Currently there's no built-in option to display cooldown count text on the icons. You can however install an addon such as OmniCC to get this feature.

]=] ] = "" ]==]
L["Death"] = "Mort"
L["Decoration and Effects"] = "Décors et effets"
L["Decorations"] = "Décors"
-- L["Documentation"] = ""
-- L["Each option comes with its own set of parameters that controls the layout. "] = ""
-- L["Ellipse"] = ""
-- L["Ellipse Layout"] = ""
-- L["Enable Icon Display"] = ""
-- L["Enable Rune Bars"] = ""
L["Enable minimap icon"] = "Afficher l'icône sur la minicarte"
L["Fade alpha from gcd to ready"] = "Alpha du fondu depuis le cooldown global jusqu'à prête"
L["Fade alpha level between the in GCD and out of GCD alpha level. This can be used to make the rune cooldown displays become incrementally more visible as the cooldown decreases."] = "Niveau d'alpha du fondu entre les niveaux d'alpha d'entrée en cooldown global et de sortie de cooldown global. Cela peut être utilisé pour rendre l'affichage du cooldown des runes plus visible au fur et à mesure que le cooldown diminue."
L["Fade alpha level of active runes"] = "Niveau d'alpha du fondu des runes actives"
L["Fade the alpha level between the GCD level and the ready level. This option is ignored if the alpha flash notification is enabled."] = "Fond le niveau d'alpha entre le niveau de cooldown global et le niveau de prêt. Cette option est ignorée si la notification de flash alpha est activée."
L["Flash mode"] = "Mode flash"
L["Flash when ready"] = "Flasher quand prêt"
-- L["Flip horizontal growth direction"] = ""
-- L["Flip vertical growth direction"] = ""
L["Font"] = "Police"
L["Font & Texture"] = "Police & texture"
L["Font and Texture"] = "Police et texture"
L["Font size"] = "Taille de police"
L["Font used on the bars"] = "Police utilisée pour les barres"
L["Frost"] = "Givre"
L["Frost #1"] = "Givre #1"
-- L["Frost #1 Angle"] = ""
L["Frost #2"] = "Givre #2"
-- L["Frost #2 Angle"] = ""
L["Hide anchor when bars are locked."] = "Masquer l'ancrage lorsque les barres sont vérouillées."
L["Hide bar"] = "Masquer la barre"
L["Hide the Blizzard rune frame"] = "Masquer les runes de Blizzard"
-- L["Horizontal Radius"] = ""
-- L["Horizontal Spacing"] = ""
L["Horizontal animated icons"] = "Icônes animés horizontallement"
-- L["Horizontal labeled bars"] = ""
-- L["Icon Display"] = ""
L["Icon Scale"] = "Echelle de l'icône"
-- L["Icon Spread"] = ""
-- L["If checked you can specify the exact location of each rune on the circle or ellipse. If unchecked you specify the start angle, spread and order of the icons instead."] = ""
L["If enabled, the icons will move with the bar. If the bar texture is hidden, you'll get a display simply showing the cooldown using icons."] = "Activé, l'icône bougera avec la barre. Si la texture de la barre est masquée, seul le cooldown utilisant l'icône sera affcihé."
-- L["If toggled, the icons will expand to the left instead of to the right."] = ""
-- L["If toggled, the icons will expand upwards instead of downwards."] = ""
-- L["In the future you'll be able to use either an external cooldown count addon or builtin text."] = ""
L["In-Combat ready rune alpha"] = "Alpha des runes prêtes en combat"
L["In-GCD active rune alpha"] = "Alpha des runes actives dans le cooldown global"
L["Individual icon placement"] = "Disposition d'icône individuel"
L["Instead showing the time elapsed on the cooldown, show the time remaining. This means that the bars will shrink as the cooldown lowers instead of grow."] = "Affiche le temps restant plutôt que le temps écoulé du cooldown. Cela signifie que les barres vont se réduire au fur et à mesure que le cooldown diminue au lieu de grandir."
-- L["Introduction"] = ""
-- L["Label"] = ""
-- L["Label used for vertical bars"] = ""
-- L["Label used on horizontal bars"] = ""
-- L["Layout"] = ""
L["Layout Options"] = "Options de présentation"
L["Layout Style"] = "Style de présentation"
L["Layout and Sorting"] = "Disposition et tri"
L["Length"] = "Longueur"
L["Load preset"] = "Préréglage de chargement"
L["Lock bar positions"] = "Verrouiller la position des barres"
L["Magic Runes"] = "Magic Runes"
-- L["Many options in the module core is used for this addon, such as alpha levels, alpha flash, ready flash and rune icon set."] = ""
-- L["Minimal 2x3 layout"] = ""
-- L["Minimal 3x2 layout"] = ""
-- L["Minimal horizontal layout"] = ""
-- L["Minimal vertical layout"] = ""
-- L["NOTE: RUNE BARS IS STILL WORK IN PROGRESS. Many features are still missing!"] = ""
L["Never"] = "Jamais"
L["None"] = "Aucun"
L["Normal"] = "Normal"
L["Normal Layout"] = "Présentation normal"
L["Normally the time is shown with one decimal place when the remaining cooldown is less than the global cooldown. If this toggled on, only seconds will be shown."] = "Normalement, la durée est affiché avec une décimal lorsque le cooldown est inférieur au cooldown global. Si ceci est activé, la durée sera uniquement affichée en seconde."
-- L["Number of columns per row."] = ""
L["Number of flashes"] = "Nombre de flash"
-- L["Number of icons per row."] = ""
L["Number of times to flash bars when the remaining is less than the GCD. Set to zero to disable flashing."] = "Nombre de fois que les barres doivent flasher quand le temps restant est inférieur au cooldown global. Régler à zéro pour désactiver le flashage."
L["On GCD"] = "En cooldown global"
L["On readiness"] = "En préparation"
L["Orientation"] = "Orientation"
L["Out of combat alpha"] = "Alpha hors de combat"
L["Out-of-GCD active rune alpha"] = "Alpha des runes actives hors du cooldown global"
L["Overall Scale"] = "Echelle globale"
-- L["Presets are primarily here to give you a few ideas on how you can configure the bars. Note that the presets do now change font, texture or color options. The global scale is also not changed."] = ""
L["Profiles"] = "Profiles"
L["Radius"] = "Rayon"
L["Ready flash duration"] = "Durée du flash quand prêt"
-- L["Regardless of layout, you can always pick the rune icon set to use and the icon scale."] = ""
L["Reverse Sorting"] = "Trie inversé"
-- L["Reverse growth direction"] = ""
L["Reverse icon placement order"] = "Inverser l'ordre de placement des icônes"
-- L["Reverse the order in which bars are added relative to the anchor."] = ""
-- L["Reverses the direction of icon placement on the circle or ellipse"] = ""
L["Rune #"] = "Rune #"
-- L["Rune Bars"] = ""
-- L["Rune Bars Introduction"] = ""
-- L["Rune Icon Set"] = ""
-- L["Rune Order"] = ""
L["Runes"] = "Runes"
L["Runic"] = "Runique"
L["Runic bar"] = "Bar runique"
L["Seconds only"] = "En secondes seulement"
-- L["Select preset to load..."] = ""
L["Shared Parameters"] = "Paramètres partagés"
-- L["Short Label"] = ""
-- L["Show Rune Icons"] = ""
L["Show an icon to open the config at the Minimap"] = "Affiche un icône sur la minicarte ouvrant la configuration"
-- L["Show configuration dialog"] = ""
-- L["Show icons"] = ""
-- L["Show labels"] = ""
-- L["Show labels on the bars indicating the rune type. Note the timer cannot be shown on the icon while labels are enabled."] = ""
-- L["Show remaining time"] = ""
-- L["Show spark"] = ""
-- L["Show the countdown timer on top of the icon instead of on the bar. This option is only available when labels are hidden."] = ""
-- L["Show timer"] = ""
-- L["Show timer on icon"] = ""
L["Some parameters are shared between layouts, while others are not. "] = "Certains paramètres sont partagés entre les dispositions, alors que d'autres ne le sont pas"
L["Sort Method"] = "Méthode de trie"
-- L["Sorting Weight"] = ""
-- L["Spacing"] = ""
-- L["Standard bars"] = ""
L["Start Angle"] = "Angle de départ"
-- L["Static icons, timer, no bars"] = ""
L["Texture"] = "Texture"
L["The Icon Display has three different layout options: Normal, Circle and Ellipse. "] = "L'icône Affichage a trois options de dispositions différentes : Normal, Cerculaire et Ellipse"
-- L["The Rune Bar module is a replacement for the built-in original rune bars. It is currently not complete but is entirely usable."] = ""
-- L["The alpha level of the frame background when out of combat and no runes are active."] = ""
L["The angle of Blood Rune #1."] = "L'angle de la rune de sang #1"
L["The angle of Blood Rune #2."] = "L'angle de la rune de sang #2"
L["The angle of Frost Rune #1."] = "L'angle de la rune de givre #1"
L["The angle of Frost Rune #2."] = "L'angle de rune de givre #2"
L["The angle of Unholy Rune #1."] = "L'angle de la rune impie #1"
L["The angle of Unholy Rune #2."] = "L'angle de rune impie #2"
L["The angle to start putting the icons on."] = "L'angle par lequel commencer à placer les icônes"
--[==[ L[ [=[The background frames allows you to set an optional backdrop behind the bars. You can configure the border and background texture and color.

]=] ] = "" ]==]
--[==[ L[ [=[The background frames allows you to set an optional backdrop behind the icons. You can configure the border and background texture and color.

]=] ] = "" ]==]
L["The background texture for the bars. ."] = "Texture d'arrière-plan des barres"
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
L["The radius of the circle."] = "Le rayon du cercle"
L["The radius of the major axis of the ellipse."] = "Le rayon de l'axe principal de l'ellipse"
L["The radius of the minor axis of the ellipse."] = "Le rayon de l'axe secondaire de l'ellipse"
L["The sound effect to play when the sound alert trigger occurs."] = "Son à jouer lorsque l'alerte sonore est déclenchée"
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
L["Unholy"] = "Impie"
L["Unholy #1"] = "Impie #1"
L["Unholy #1 Angle"] = "Angle impie #1"
L["Unholy #2"] = "Impie #2"
L["Unholy #2 Angle"] = "Angle impie #2"
--[==[ L[ [=[Using the width parameter you can select how many icons to put in a row. A width of 1 means you'll have a single vertical column while a width of 6 means you'll have a single horizontal row.

]=] ] = "" ]==]
L["Vertical Radius"] = "Rayon vertical"
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

