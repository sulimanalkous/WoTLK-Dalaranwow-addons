local L = LibStub("AceLocale-3.0"):NewLocale("MagicRunes", "ruRU")
if not L then return end

-- To help localize Magic Runes please enter phrase translations on the
-- following URL:
-- http://www.wowace.com/projects/magicrunes/localization/
-- This file should not be edited manually!

L[ [=[ - All alpha level parameters.

]=] ] = "- Все параметры прозрачности."
L[ [=[ - Flash Mode, Alpha Flash (color flash doesn't work)
]=] ] = "- Функция вспышки, прозрачность (цветная вспышка не работает)"
L["Add a new bar"] = "Добавить новую полосу"
L["Alert sound effect"] = "Звуковой сигнал"
L["Alert sound trigger"] = "Триггер звукового сигнала"
L["All the other decorations and effects don't make sense for icons and thus don't work."] = "Все другие декорации и эффекты не имеют смысла для иконок и таким образом не работают."
L["Alpha Flash"] = "Мерцание прозрачности"
L["Alpha Levels"] = "Прозрачность"
L["Alpha Settings"] = "Настройки прозрачности"
L["Alpha level for ready runes when out of combat."] = "Прозрачности готовых рун вне боя."
L["Alpha level of active runes when the remaining cooldown is longer than the global cooldown."] = "Прозрачность активных рун, если время восстановления больше глобального."
L["Alpha level of active runes when the remaining cooldown is shorter the global cooldown."] = "Прозрачность активных рун, если время восстановления меньше глобального."
L["Alpha level of ready runes when in combat."] = "Прозрачность готовых рун в бою."
L["Animate icons"] = "Анимация иконок"
L[ [=[As with the normal layout, you can specify the order of the runes using the rune order parameter.

]=] ] = "Как с нормальным расположением, Вы можете указать порядок рун, используя параметр порядка рун."
L["Background"] = "Фон"
L["Background Frame"] = "Фоновая Рамка"
L["Background Texture"] = "Текстура фона"
L["Bar #"] = "Полоса #"
L["Bar Configuration"] = "Настройки полосы"
L["Bar Layout"] = "Вывод полосы"
L["Blood"] = "Кровь"
L["Blood #1"] = "Кровь №1"
L["Blood #1 Angle"] = "Кровь №1 Угол"
L["Blood #2"] = "Кровь №2"
L["Blood #2 Angle"] = "Кровь №2 Угол"
L["Button Facade"] = "Button Facade"
L["Circle"] = "Круг"
L["Circle Layout"] = "Положение круга"
L["Color Flash"] = "Цвет вспышки"
L["Color flash does not work with these bars, nor are there any labels yet."] = "Цветная вспышка не работает с этими полосами, и вдобавок нету ярлыков."
L["Color used for background texture."] = "Цвет текстуры фона."
L["Color used for blood rune bars."] = "Цвет полосы кровавых рун"
L["Color used for death rune bars."] = "Цвет полосы рун смерти."
L["Color used for frost rune bars."] = "Цвет полосы рун льда."
L["Color used for the Blood Plague bar."] = "Цвет полосы Кровавой Чумы."
L["Color used for the Frost Fever bar."] = "Цвет полосы Озноба."
L["Color used for the runic power bar."] = "Цвет полосы рунической силы."
L["Color used for unholy rune bars."] = "Цвет полосы рун нечестивости."
L["Colors"] = "Цвета"
-- L["Columns"] = ""
L["Cooldown Count"] = "Подсчет перезарядок"
L["Create a new bar."] = "Создать новую полосу."
L[ [=[Currently there's no built-in option to display cooldown count text on the icons. You can however install an addon such as OmniCC to get this feature.

]=] ] = "В настоящее время нет никакой встроенной опции для показа текста подсчета перезарядок на изображениях. Однако, Вы можете установить аддон, такой как OmniCC, чтобы получить эту особенность."
L["Death"] = "Смерть"
L["Decoration and Effects"] = "Декорация и Эффекты"
L["Decorations"] = "Декорации"
L["Documentation"] = "Документация"
L["Each option comes with its own set of parameters that controls the layout. "] = "Каждая опция идёт со своим набором параметров, который управляет расположением."
L["Ellipse"] = "Эллипс"
L["Ellipse Layout"] = "Положение эллипса"
L["Enable Icon Display"] = "Включить отображение иконки"
L["Enable Rune Bars"] = "Включить Полосы Рун"
L["Enable minimap icon"] = "Иконка на мини-карте"
L["Fade alpha from gcd to ready"] = "Спад прозрачности с глобального отката до готовности"
L["Fade alpha level between the in GCD and out of GCD alpha level. This can be used to make the rune cooldown displays become incrementally more visible as the cooldown decreases."] = "Спад прозрачности между глобальным откатом и уровнем отката. Может использоваться, чтобы облегчить выделение руны при откате."
L["Fade alpha level of active runes"] = "Спад прозрачности активных рун"
L["Fade the alpha level between the GCD level and the ready level. This option is ignored if the alpha flash notification is enabled."] = "Спад прозрачности между глобальным откатом и уровнем готовности. Эта опция игнорируется если включено мерцание прозрачности."
L["Flash mode"] = "Функция вспышки"
L["Flash when ready"] = "Вспышка при готовности"
L["Flip horizontal growth direction"] = "Щелчок горизонтального увеличения направления"
L["Flip vertical growth direction"] = "Щелчок вертикального увеличения направления"
L["Font"] = "Шрифт"
L["Font & Texture"] = "Шрифт и текстура"
L["Font and Texture"] = "Шрифт и Текстура"
L["Font size"] = " Размер шрифта"
L["Font used on the bars"] = "Шрифт на полосах"
L["Frost"] = "Лед"
L["Frost #1"] = "Лед №1"
L["Frost #1 Angle"] = "Лед №1 Угол"
L["Frost #2"] = "Лед №2"
L["Frost #2 Angle"] = "Лед №2 Угод"
L["Hide anchor when bars are locked."] = "Прятать при зафиксированных полосах"
L["Hide bar"] = "Спрятать полосу"
L["Hide the Blizzard rune frame"] = "Спрятать рамку рун Blizzard "
L["Horizontal Radius"] = "Горизонтальный радиус"
L["Horizontal Spacing"] = "Горизонтальный интервал"
L["Horizontal animated icons"] = "Горизонтальные анимационные иконки"
L["Horizontal labeled bars"] = "Горизонтальные маркированные полосы"
L["Icon Display"] = "Отображение иконки"
L["Icon Scale"] = "Масштаб иконок"
L["Icon Spread"] = "Распространение иконки"
L["If checked you can specify the exact location of each rune on the circle or ellipse. If unchecked you specify the start angle, spread and order of the icons instead."] = "Если включено, Вы можете определить точное местоположение каждой руны на круге или эллипсе. Если отключено, Вы указываете угол начала, распространение и порядок иконок."
L["If enabled, the icons will move with the bar. If the bar texture is hidden, you'll get a display simply showing the cooldown using icons."] = "Если включено, иконки будут двигаться с полосой. Если текстура полосы спрятана, вы получите простой откат с помощью иконок."
L["If toggled, the icons will expand to the left instead of to the right."] = "Если переключено, иконки расширятся налево, а не направо."
L["If toggled, the icons will expand upwards instead of downwards."] = "Если переключено, иконки расширятся вверх, а не вниз."
L["In the future you'll be able to use either an external cooldown count addon or builtin text."] = "В будущем Вы сможете использовать или внешнее добавление подсчета перезарядок или встроенный текст."
L["In-Combat ready rune alpha"] = "Прозрачность готовых рун в бою"
L["In-GCD active rune alpha"] = "Прозрачность активных рун при ГКД"
L["Individual icon placement"] = "Отдельное размещение иконок"
L["Instead showing the time elapsed on the cooldown, show the time remaining. This means that the bars will shrink as the cooldown lowers instead of grow."] = "Показывать оставшееся время восстановления, вместо пройденного. Это означает, что полоса будет уменьшаться вместо роста."
L["Introduction"] = "Введение"
L["Label"] = "Метка"
L["Label used for vertical bars"] = "Метка для вертикальной полосы"
L["Label used on horizontal bars"] = "Метка для горизонтальной полосы"
L["Layout"] = "Расположение"
L["Layout Options"] = "Опции расположения"
L["Layout Style"] = "Стиль расположения"
L["Layout and Sorting"] = "Расстановка и Сортировка"
L["Length"] = "Длина"
L["Load preset"] = "Загрузить набор параметров"
L["Lock bar positions"] = "Зафиксировать позицию бара"
L["Magic Runes"] = "Magic Runes"
L["Many options in the module core is used for this addon, such as alpha levels, alpha flash, ready flash and rune icon set."] = "Много вариантов в ядре модуля используются для этого аддона, таких как прозрачность, вспышка, готовая вспышка и набор иконок рун."
-- L["Minimal 2x3 layout"] = ""
-- L["Minimal 3x2 layout"] = ""
-- L["Minimal horizontal layout"] = ""
-- L["Minimal vertical layout"] = ""
L["NOTE: RUNE BARS IS STILL WORK IN PROGRESS. Many features are still missing!"] = "ПРИМЕЧАНИЕ: ПОЛОСЫ РУН ЕЩЁ ДОРАБАТЫВАЮТСЯ. Многие функции по-прежнему отсутствуют."
L["Never"] = "Никогда"
L["None"] = "Нет"
L["Normal"] = "Нормальный"
L["Normal Layout"] = "Нормальное расположение"
L["Normally the time is shown with one decimal place when the remaining cooldown is less than the global cooldown. If this toggled on, only seconds will be shown."] = "Если включено, то время отката будет округлятся до секунд, а не до десятых долей."
-- L["Number of columns per row."] = ""
L["Number of flashes"] = "Количество вспышек"
L["Number of icons per row."] = "Количество иконок за ряд."
L["Number of times to flash bars when the remaining is less than the GCD. Set to zero to disable flashing."] = "Количество вспышек полосы при откате меньше, чем ГКД. Введите ноль для отключения."
L["On GCD"] = "По ГКД"
L["On readiness"] = "По готовности"
L["Orientation"] = "Ориентация"
L["Out of combat alpha"] = "Прозрачность вне боя"
L["Out-of-GCD active rune alpha"] = "Прозрачность активной руны вне ГКД"
L["Overall Scale"] = "Общий масштаб"
L["Presets are primarily here to give you a few ideas on how you can configure the bars. Note that the presets do now change font, texture or color options. The global scale is also not changed."] = "Наборы параметров должны дать Вам несколько идей того, как Вы можете настроить свои полосы. Наборы параметров меняют шрифт, текстуры и опции цвета. Общий масштаб не меняется."
L["Profiles"] = "Профили"
L["Radius"] = "Радиус"
L["Ready flash duration"] = "Время вспышки при готовности"
L["Regardless of layout, you can always pick the rune icon set to use and the icon scale."] = "Независимо от расположения, Вы всегда можете выбрать набор иконок рун и масштаб иконок."
L["Reverse Sorting"] = "Обратная сортировка"
L["Reverse growth direction"] = "Обратный рост направления"
L["Reverse icon placement order"] = "Обратный порядок размещения иконок"
L["Reverse the order in which bars are added relative to the anchor."] = "Обратный порядок, в котором полосы добавлены относительно якоря."
L["Reverses the direction of icon placement on the circle or ellipse"] = "Обратное направление размещения иконок на круге или эллипсе"
L["Rune #"] = "Руна №"
L["Rune Bars"] = "Полосы Рун"
L["Rune Bars Introduction"] = "Введение Полос Рун"
L["Rune Icon Set"] = "Набор иконок рун"
L["Rune Order"] = "Порядок Руны"
L["Runes"] = "Руны"
L["Runic"] = "Руническая"
L["Runic bar"] = "Руническая полоса"
L["Seconds only"] = "Только секунды"
-- L["Select preset to load..."] = ""
L["Shared Parameters"] = "Общие параметры"
L["Short Label"] = "Короткое название"
-- L["Show Rune Icons"] = ""
L["Show an icon to open the config at the Minimap"] = "Показать иконку, чтобы открыть настройки возле Мини-карты."
L["Show configuration dialog"] = "Показать диалог настроек"
L["Show icons"] = "Показать иконки"
L["Show labels"] = "Показать названия"
L["Show labels on the bars indicating the rune type. Note the timer cannot be shown on the icon while labels are enabled."] = "Показывать название типа руны. Таймер не может быть показан на иконке, пока названия включены."
L["Show remaining time"] = "Показывать оставшееся время"
L["Show spark"] = "Показывать искру"
L["Show the countdown timer on top of the icon instead of on the bar. This option is only available when labels are hidden."] = "Показывать откат сверху иконки вместо полосы. Эта функция доступна, только если метки отключены."
L["Show timer"] = "Показывать таймер."
L["Show timer on icon"] = "Показывать иконку таймера"
L["Some parameters are shared between layouts, while others are not. "] = "Некоторые параметры разделены между расположениями, в то время как другие нет."
L["Sort Method"] = "Метод сортировки"
L["Sorting Weight"] = "Сортировка Значения"
L["Spacing"] = "Расстояние"
-- L["Standard bars"] = ""
L["Start Angle"] = "Начало угла"
L["Static icons, timer, no bars"] = "Статические иконки, таймер, без полос"
L["Texture"] = "Текстура"
L["The Icon Display has three different layout options: Normal, Circle and Ellipse. "] = "У иконок есть три различных варианта вывода: Нормальный, Круг и Эллипс."
L["The Rune Bar module is a replacement for the built-in original rune bars. It is currently not complete but is entirely usable."] = "Модуль Полос Рун заменяет оригинальные полосы рун. Это в настоящее время не доделано, но полностью готово к использованию."
L["The alpha level of the frame background when out of combat and no runes are active."] = "Прозрачность рамки фона вне боя и при неактивных рунах."
L["The angle of Blood Rune #1."] = "Угол Кровавой Руны №1."
L["The angle of Blood Rune #2."] = "Угол Кровавой Руны №2."
L["The angle of Frost Rune #1."] = "Угол Руны Льда №1."
L["The angle of Frost Rune #2."] = "Угол Руны Льда №2."
L["The angle of Unholy Rune #1."] = "Угол Руны Нечестивости №1."
L["The angle of Unholy Rune #2."] = "Угол Руны Нечестивости №2."
L["The angle to start putting the icons on."] = "Угол начала смещения иконок."
L[ [=[The background frames allows you to set an optional backdrop behind the bars. You can configure the border and background texture and color.

]=] ] = "Фоновые рамки позволяют Вам устанавливать дополнительный фон за полосами. Вы можете настраивать границу и текстуру фона, и цвет."
L[ [=[The background frames allows you to set an optional backdrop behind the icons. You can configure the border and background texture and color.

]=] ] = "Фоновые рамки позволяют Вам устанавливать дополнительный фон за полосами. Вы можете настраивать границу и текстуру фона, и цвет."
L["The background texture for the bars. ."] = "Текстура полос"
L[ [=[The circle layout will place the icons around an invisible circle. This is done using a radius, starting angle and icon spread parameters.

]=] ] = "Круговое расположение поместит иконки вокруг невидимого круга. Это делается с помощью радиуса, начального угла и параметра распространения иконки."
L[ [=[The ellipse is identical to circle layout except it allows you to specify both horizontal and vertical radius. These two parameters are used to determine the size and shape of the ellipse.

]=] ] = "Эллипс идентичен расположению круга, кроме этого он позволяет Вам указывать горизонтальный и вертикальный радиус. Эти два параметра используются, чтобы определить размер и форму эллипса."
L[ [=[The icon display is fully integrated with the ButtonFacade addon. This addon lets you skin the buttons for a more personalized display.

]=] ] = "Иконки полностью интегрированы с аддоном ButtonFacade. Этот аддон позволяет Вам изменять кнопки для более персонального отображения."
L[ [=[The icon display uses the addon global settings for decorations. The following decorations and effects works for icons: 

]=] ] = "Иконки используют глобальные настройки аддона для декораций. Следующие декорации и эффекты работают для иконок:"
L[ [=[The icons are fully integrated with the ButtonFacade addon. This addon lets you skin the buttons for a more personalized display.

]=] ] = "Иконки полностью интегрированы с аддоном ButtonFacade. Этот аддон позволяет Вам изменять кнопки для более персонального отображения."
L["The normal layout lets you put the icons in straight vertical or/or horizontal rows and colums. "] = "Нормальное расположение позволяет Вам помещать иконки в прямые вертикальные или/или горизонтальные ряды и колонки."
L["The number of degrees to spread the icons over - 180 degrees is a half circle, 360 degrees is a full circle."] = "Количество степеней распространения иконок свыше - 180 градусов с половиной круга, 360 градусов полный круг."
L["The radius of the circle."] = "Радиус круга."
L["The radius of the major axis of the ellipse."] = "Радиус главной оси эллипса."
L["The radius of the minor axis of the ellipse."] = "Радиус простой оси эллипса."
L["The sound effect to play when the sound alert trigger occurs."] = "Играть звуковой эффект, когда происходит триггер звукового сигнала."
L[ [=[The space between columns is controlled by the horizontal spacing parameter. Use the vertical spacing parameter to control the space between rows.

]=] ] = "Пространство между колонками управляется горизонтальным параметром интервала. Используйте вертикальный параметр интервала, чтобы управлять пространством между рядами."
L[ [=[The spread decides how far apart the icons are while the start angle determines where the first icon should be placed. You can reverse the placement direction as well.

]=] ] = "Распространение решает, как далеко друг от друга иконки, а начальный угол определяет, где должна быть помещена первая иконка. Вы также можете полностью изменить направление размещения."
L["The texture used for active bars."] = "Текстура активных полос."
L["The time in seconds that the bar should flash when a rune becomes ready."] = "Время в секундах, которые должна высветить полоса, когда руна становится готовой."
L["The weight used when sorting this bar. A value less than 1 means it's sorted before rune bars. A value above 6 means it's sorted after the rune bars."] = "Значение используемое для сортировки этой полосы. Ценность меньше 1 - сортирует перед полосами рун. Ценность выше 6 - сортирует после полос рун."
L[ [=[The width of the border is controlled by the edge size parameter. To add some extra padding between the border and icons you can set the padding.

]=] ] = "Ширина границы управляется параметром размера края. Чтобы добавить некоторое дополнительное дополнение между границей и изображениями, Вы можете установить дополнение."
L["Thickness"] = "Толщина"
L["Tiny horizontal bars"] = "Крошечные горизонтальные полосы"
L["Tiny vertical bars"] = "Крошечные вертикальные полосы"
L[ [=[To be able to change the border and background you need the SharedMedia and SharedMedia-Blizzard addons installed. You can find these at http://wow.curse.com/

]=] ] = "Чтобы изменить границу и фон, Вам нужны аддоны SharedMedia и SharedMedia-Blizzard. Вы можете найти их на http://wow.curse.com/"
L[ [=[To be able to change the border and background you need the SharedMedia and SharedMedia-Blizzard addons installed. You can find these at http://www.curse.com/

]=] ] = "Чтобы изменить границу и фон, Вам нужны аддоны SharedMedia и SharedMedia-Blizzard. Вы можете найти их на http://wow.curse.com/"
L[ [=[To configure the looks, open the ButtonFacade configuration UI using the /buttonfacade command. Select Addons => Magic Runes => Rune Bars.

]=] ] = "Чтобы настроить внешний вид, командой /buttonfacade откройте параметры UI ButtonFacade. Выбор аддона => Magic Runes => Rune Bars."
L[ [=[To configure the looks, open the ButtonFacade configuration UI using the /buttonfacade command. Select Addons => MagicRunes => Icon Display.

]=] ] = "Чтобы настроить внешний вид, командой /buttonfacade откройте параметры UI ButtonFacade. Выбор аддона => Magic Runes => Rune Bars."
L["Toggle visibility of this bar."] = "Переключить видимость этой полосы."
L["Toggle whether or not to show the spark on active bars."] = "Переключить или нет показ искры на активных полосах."
L["Type of flashing to use to indicate imminent readiness."] = "Тип вспышки для указания неизбежной готовности."
L["Unholy"] = "Нечестивость"
L["Unholy #1"] = "Нечестивость №1"
L["Unholy #1 Angle"] = "Нечестивость №1 Угол"
L["Unholy #2"] = "Нечестивость №2"
L["Unholy #2 Angle"] = "Нечестивость №2 Угол"
L[ [=[Using the width parameter you can select how many icons to put in a row. A width of 1 means you'll have a single vertical column while a width of 6 means you'll have a single horizontal row.

]=] ] = "Используя параметр ширины Вы можете выбрать сколько изображений поместить в ряд. Ширина 1 значения - у Вас будет единственная вертикальная колонка, в то время как ширина 6 значений - Вы будете иметь горизонтальный ряд."
L["Vertical Radius"] = "Вертикальный радиус"
L["Vertical Spacing"] = "Вертикальный интервал"
L["Vertical animated icons"] = "Вертикальные анимационные иконки"
L["Vertical labeled bars"] = "Вертикальные маркированные полосы"
L["When a rune cooldown is finish, flash the bar as an extra notification source."] = "Когда руна восстанавливается, высветить полосу как дополнительный источник уведомления."
L["When to play the alert sound: On GCD => play when the remaining cooldown of a run goes below the global cooldown. On readiness => play when a rune becomes ready for use."] = "Когда должен играть предупреждающий звук: По ГКД => играть, когда оставшееся восстановление ниже глобального восстановления. По готовности => играть, когда руна становится готовой к использованию."
L["Width"] = "Ширина"
L[ [=[You can also choose to place icons individually. This allows you to specify the exact angle to use for each rune icon. When this option is used, the start angle, icon spread, placement direction and rune order parameters aren't used.

]=] ] = "Вы также можете разместить иконки в индивидуальном порядке. Это позволяет Вам определять точный угол для каждой иконки рун. Когда этот выбор используется, угол начала, распространение иконки, направление размещения и параметры порядка руны не используются."
L[ [=[You can change the order of the runes using the rune order parameter.

]=] ] = "Вы можете изменить порядок рун, используя параметр порядка руны."
L["You can find ButtonFacade and many different skins on http://wow.curse.com/"] = "Вы можете найти ButtonFacade и множество других шкурок на http://wow.curse.com/"
L["You can find ButtonFacade and many different skins on http://wow.curse.com/."] = "Вы можете найти ButtonFacade и множество других шкурок на http://wow.curse.com/"
L[ [=[You control the growth direction with the horizontal and vertical growth direction toggles.

]=] ] = "Вы управляете направление роста с горизонтальным и вертикальным переключением направления роста."
L[ [=[|cffffff00Left click|r to open the configuration screen.
|cffffff00Right click|r to toggle the Magic Target window lock.]=] ] = [=[|cffffff00Левый щелчок|r для открытия экрана настроек.
|cffffff00Правый щелчок|r для закрепления Магической Цели.]=]

