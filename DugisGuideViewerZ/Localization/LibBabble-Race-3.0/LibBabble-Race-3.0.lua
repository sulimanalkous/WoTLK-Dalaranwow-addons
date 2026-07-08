--[[
Name: LibBabble-Race-3.0
Revision: $Rev: 18 $
Maintainers: ckknight, nevcairiel, Ackis
Website: http://www.wowace.com/projects/libbabble-race-3-0/
Dependencies: None
License: MIT
Locales: enUS, deDE, frFR, zhCN, zhTW, koKR, esES, esMX, ruRU
]]

local MAJOR_VERSION = "LibBabble-Race-3.0"
local MINOR_VERSION = 90000 + tonumber(("$Rev: 18 $"):match("%d+"))

if not LibStub then error(MAJOR_VERSION .. " requires LibStub.") end
local lib = LibStub("LibBabble-3.0"):New(MAJOR_VERSION, MINOR_VERSION)
if not lib then return end

local GAME_LOCALE = GetLocale()

lib:SetBaseTranslations {
	["Blood Elf"] = "Blood Elf",
	["Draenei"] = "Draenei",
	["Dwarf"] = "Dwarf",
	["Gnome"] = "Gnome",
	["Human"] = "Human",
	["Night Elf"] = "Night Elf",
	["Orc"] = "Orc",
	["Tauren"] = "Tauren",
	["Troll"] = "Troll",
	["Undead"] = "Undead",

	["BLOOD ELF"] = "Blood Elf",
	["DRAENEI"] = "Draenei",	
	["DWARF"] = "Dwarf",
	["GNOME"] = "Gnome",	
	["HUMAN"] = "Human",
	["NIGHT ELF"] = "Night Elf",
	["ORC"] = "Orc",
	["TAUREN"] = "Tauren",
	["TROLL"] = "Troll",
	["UNDEAD"] = "Undead",	
}


if GAME_LOCALE == "enUS" then
	lib:SetCurrentTranslations(true)
elseif GAME_LOCALE == "deDE" then
	lib:SetCurrentTranslations {
	["Blood Elf"] = "Blutelf",
	["Draenei"] = "Draenei",
	["Dwarf"] = "Zwerg",
	["Gnome"] = "Gnom",
	["Human"] = "Mensch",
	["Night Elf"] = "Nachtelf",
	["Orc"] = "Orc",
	["Tauren"] = "Tauren",
	["Troll"] = "Troll",
	["Undead"] = "Untoter",
	
	["BLOOD ELF"] = "Blutelfe",
	["DRAENEI"] = "Draenei",
	["DWARF"] = "Zwerg",
	["GNOME"] = "Gnom",
	["HUMAN"] = "Mensch",
	["NIGHT ELF"] = "Nachtelfe",
	["ORC"] = "Orc",
	["TAUREN"] = "Tauren",
	["TROLL"] = "Troll",
	["UNDEAD"] = "Untote",
	
	--Other
	["Blood elves"] = "Blutelfen",
	Draenei_PL = "Draenei",
	Dwarves = "Zwerge",
	Felguard = "Teufelswache",
	Felhunter = "Teufelsjäger",
	Gnomes = "Gnome",
	Humans = "Menschen",
	Imp = "Wichtel",
	["Night elves"] = "Nachtelfen",
	Orcs = "Orcs",
	Succubus = "Sukkubus",
	Tauren_PL = "Tauren",
	Trolls = "Trolle",
	Undead_PL = "Untote",
	Voidwalker = "Leerwandler",
}
elseif GAME_LOCALE == "frFR" then
	lib:SetCurrentTranslations {
	["Blood Elf"] = "Elfe de sang",
	["Draenei"] = "Draeneï",
	["Dwarf"] = "Nain",
	["Gnome"] = "Gnome",
	["Human"] = "Humain",
	["Night Elf"] = "Elfe de la nuit",
	["Orc"] = "Orc",
	["Tauren"] = "Tauren",
	["Troll"] = "Troll",
	["Undead"] = "Mort-vivant",
		
	["BLOOD ELF"] = "Elfe de sang",
	["DRAENEI"] = "Draeneï",
	["DWARF"] = "Naine",
	["GNOME"] = "Gnome",
	["HUMAN"] = "Humaine",
	["NIGHT ELF"] = "Elfe de la nuit",
	["ORC"] = "Orque",
	["TAUREN"] = "Taurène",
	["TROLL"] = "Trollesse",
	["UNDEAD"] = "Morte-vivante",	
	
	--Other
	["Blood elves"] = "Elfes de sang",
	Draenei_PL = "Draeneï",
	Dwarves = "Nains",
	Felguard = "Gangregarde",
	Felhunter = "Chasseur corrompu",
	Gnomes = "Gnomes",
	Humans = "Humains",
	Imp = "Diablotin",
	["Night elves"] = "Elfes de la nuit",
	Orcs = "Orcs",
	Succubus = "Succube",
	Tauren_PL = "Taurens",
	Trolls = "Trolls",
	Undead_PL = "Morts-vivants",
	Voidwalker = "Marcheur du Vide",
}
elseif GAME_LOCALE == "koKR" then
	lib:SetCurrentTranslations {
	["Blood Elf"] = "블러드 엘프",
	["Blood elves"] = "블러드 엘프",
	Draenei = "드레나이",
	Draenei_PL = "드레나이",
	Dwarf = "드워프",
	Dwarves = "드워프",
	Felguard = "지옥수호병",
	Felhunter = "지옥사냥개",
	Gnome = "노움",
	Gnomes = "노움",
	Human = "인간",
	Humans = "인간",
	Imp = "임프",
	["Night Elf"] = "나이트 엘프",
	["Night elves"] = "나이트 엘프",
	Orc = "오크",
	Orcs = "오크",
	Succubus = "서큐버스",
	Tauren = "타우렌",
	Tauren_PL = "타우렌",
	Troll = "트롤",
	Trolls = "트롤",
	Undead = "언데드",
	Undead_PL = "언데드",
	Voidwalker = "보이드워커",
}
elseif GAME_LOCALE == "esES" then
	lib:SetCurrentTranslations {
	["Blood Elf"] = "Elfo de sangre",
	["Draenei"] = "Draenei",
	["Dwarf"] = "Enano",
	["Gnome"] = "Gnomo",
	["Human"] = "Humano",
	["Night Elf"] = "Elfo de la noche",
	["Orc"] = "Orco",
	["Tauren"] = "Tauren",
	["Troll"] = "Trol",
	["Undead"] = "No-muerto",
	
	["BLOOD ELF"] = "Elfa de sangre",
	["DRAENEI"] = "Draenei",	
	["DWARF"] = "Enana",
	["GNOME"] = "Gnoma",	
	["HUMAN"] = "Humana",
	["NIGHT ELF"] = "Elfa de la noche",
	["ORC"] = "Orco",
	["TAUREN"] = "Tauren",
	["TROLL"] = "Trol",
	["UNDEAD"] = "No-muerta",	

	--Other
	["Blood elves"] = "Elfos de sangre",
	Draenei_PL = "Draenei",
	Dwarves = "Enanos",
	Felguard = "Guardia vil",
	Felhunter = "Manáfago",
	Gnomes = "Gnomos",
	Humans = "Humanos",
	Imp = "Diablillo",
	["Night elves"] = "Elfos de la noche",
	Orcs = "Orcos",
	Succubus = "Súcubo",
	Tauren_PL = "Tauren",
	Trolls = "Trols",
	Undead_PL = "No-muertos",
	Voidwalker = "Abisario",
}
elseif GAME_LOCALE == "esMX" then
	lib:SetCurrentTranslations {
	["Blood Elf"] = "Elfo de sangre",
	["Draenei"] = "Draenei",
	["Dwarf"] = "Enano",
	["Gnome"] = "Gnomo",
	["Human"] = "Humano",
	["Night Elf"] = "Elfo de la noche",
	["Orc"] = "Orco",
	["Tauren"] = "Tauren",
	["Troll"] = "Trol",
	["Undead"] = "No-muerto",
	
	["BLOOD ELF"] = "Elfa de sangre",
	["DRAENEI"] = "Draenei",	
	["DWARF"] = "Enana",
	["GNOME"] = "Gnoma",	
	["HUMAN"] = "Humana",
	["NIGHT ELF"] = "Elfa de la noche",
	["ORC"] = "Orco",
	["TAUREN"] = "Tauren",
	["TROLL"] = "Trol",
	["UNDEAD"] = "No-muerta",	
	
	--Other
	["Blood elves"] = "Elfos de sangre",
	Draenei_PL = "draenei",
	Dwarves = "Enanos",
	Felguard = "Guardia vil",
	Felhunter = "Manáfago",
	Gnomes = "gnomos",
	Humans = "Humanos",
	Imp = "Diablillo",
	["Night elves"] = "Elfos de la noche",
	Orcs = "Orcos",
	Succubus = "Súcubo",
	Tauren_PL = "Tauren",
	Trolls = "trols",
	Undead_PL = "no-muertos",
	Voidwalker = "Abisario",
}
elseif GAME_LOCALE == "ruRU" then
	lib:SetCurrentTranslations {
	["Blood Elf"] = "Эльф крови",
	["Blood elves"] = "Эльфы крови",
	Draenei = "Дреней",
	Draenei_PL = "Дренеи",
	Dwarf = "Дворф",
	Dwarves = "Дворфы",
	Felguard = "Страж Скверны",
	Felhunter = "Охотник Скверны",
	Gnome = "Гном",
	Gnomes = "Гномы",
	Human = "Человек",
	Humans = "Люди",
	Imp = "Бес",
	["Night Elf"] = "Ночной эльф",
	["Night elves"] = "Ночные эльфы",
	Orc = "Орк",
	Orcs = "Орки",
	Succubus = "Суккуб",
	Tauren = "Таурен",
	Tauren_PL = "Таурены",
	Troll = "Тролль",
	Trolls = "Тролли",
	Undead = "Нежить",
	Undead_PL = "Нежить",
	Voidwalker = "Демон Бездны",
}
elseif GAME_LOCALE == "zhCN" then
	lib:SetCurrentTranslations {
	["Blood Elf"] = "血精灵",
	["Blood elves"] = "血精灵",
	Draenei = "德莱尼",
	Draenei_PL = "德莱尼",
	Dwarf = "矮人",
	Dwarves = "矮人",
	Felguard = "恶魔卫士",
	Felhunter = "地狱猎犬",
	Gnome = "侏儒",
	Gnomes = "侏儒",
	Human = "人类",
	Humans = "人类",
	Imp = "小鬼",
	["Night Elf"] = "暗夜精灵",
	["Night elves"] = "暗夜精灵",
	Orc = "兽人",
	Orcs = "兽人",
	Succubus = "魅魔",
	Tauren = "牛头人",
	Tauren_PL = "牛头人",
	Troll = "巨魔",
	Trolls = "巨魔",
	Undead = "亡灵",
	Undead_PL = "亡灵",
	Voidwalker = "虚空行者",
}
elseif GAME_LOCALE == "zhTW" then
	lib:SetCurrentTranslations {
	["Blood Elf"] = "血精靈",
	["Blood elves"] = "血精靈",
	Draenei = "德萊尼",
	Draenei_PL = "德萊尼",
	Dwarf = "矮人",
	Dwarves = "矮人",
	Felguard = "惡魔守衛",
	Felhunter = "惡魔獵犬",
	Gnome = "地精",
	Gnomes = "地精",
	Human = "人類",
	Humans = "人類",
	Imp = "小鬼",
	["Night Elf"] = "夜精靈",
	["Night elves"] = "夜精靈",
	Orc = "獸人",
	Orcs = "獸人",
	Succubus = "魅魔",
	Tauren = "牛頭人",
	Tauren_PL = "牛頭人",
	Troll = "食人妖",
	Trolls = "食人妖",
	Undead = "不死族",
	Undead_PL = "不死族",
	Voidwalker = "虛無行者",
}

else
	error(("%s: Locale %q not supported"):format(MAJOR_VERSION, GAME_LOCALE))
end
