-- ForteXorcist v1.965.3 by Xus 05-10-2010 for 3.3.5 & 4.0.1
-- Module by Lurosara
-- Shamelessly cribbed from Xus' Forte Warrior module.

--[[
"frFR": French
"deDE": German
"esES": Spanish
"enUS": American english
"enGB": British english
"zhCN": Simplified Chinese
"zhTW": Traditional Chinese
"ruRU": Russian
"koKR": Korean

!! Make sure to keep this saved as UTF-8 format !!

]]

--[[>> still needs translating]]

if FW.CLASS == "DRUID" then
	local FWL = FW.L;
	FWL.BERSERK = GetSpellInfo(50334);
	
	-- THESE ARE INTERFACE STRINGS ONLY AND TRANSLATING THEM IS OPTIONAL
	
	-- French
	if GetLocale() == "frFR" then
	--[[>>]]FWL._FERAL = " (Feral)";
		
	-- Russian
	elseif GetLocale() == "ruRU" then
	--[[>>]]FWL._FERAL = " (Feral)";

	-- DE
	elseif GetLocale() == "deDE" then
	--[[>>]]FWL._FERAL = " (Feral)";
	
	-- SPANISH
	elseif GetLocale() == "esES" then
	--[[>>]]FWL._FERAL = " (Feral)";
	
	-- Simple Chinese
	elseif GetLocale() == "zhCN" then
	--[[>>]]FWL._FERAL = " (Feral)";
	
	-- tradition Chinese
	elseif GetLocale() == "zhTW" then
	--[[>>]]FWL._FERAL = " (Feral)";
	
	-- Korea
	elseif GetLocale() == "koKR" then
	--[[>>]]FWL._FERAL = " (Feral)";
	
	-- ENGLISH
	else
		FWL._FERAL = " (Feral)";
	end

	FWL.BERSERK_FERAL = FWL.BERSERK..FWL._FERAL;
end
