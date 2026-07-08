

local DugisGuideViewer = DugisGuideViewer
--local L = DugisGuideViewer.Locale
local L = DugisLocals
-- Hidden scanning tooltip

do
local tquests = {}

	local fTGSTt = CreateFrame( "GameTooltip", "_TGScanningTooltip" )
	fTGSTt.TtTextFS = fTGSTt:CreateFontString( "$parentTextLeft1", nil, "GameTooltipText" )
	fTGSTt:AddFontStrings(
		fTGSTt.TtTextFS,
		fTGSTt:CreateFontString( "$parentTextRight1", nil, "GameTooltipText" ) )


	function DugisGuideViewer:TranslateQuests()
		local questid, action
		local fails = 0
		fTGSTt:SetOwner( WorldFrame, "ANCHOR_NONE" )

		tquests = DugisGuideViewer.quests1
		
		
		if DUGIS_LOCALIZE == 0 then return fails end
		
		for i,_ in pairs(tquests) do
			action = DugisGuideViewer.actions[i]
			if (action == "A" or action == "C" or action == "T") then
				questid = DugisGuideViewer:ReturnTag("QID", i)
    	    	if questid then
					fTGSTt:ClearLines()
					fTGSTt:SetHyperlink("quest:"..questid)
					if fTGSTt:IsShown() then
						local questpartnum = tquests[i]:match(L.PART_MATCH)
						local locquest = fTGSTt.TtTextFS:GetText() -- may be fail if not cached
						if locquest then
							if questpartnum then
								locquest = locquest.." ("..L.PART_TEXT.." "..questpartnum..")"
							end
							tquests[i] = locquest
						else 
							--DebugPrint("FAIL"..fails)
							fails = fails + 1
						end
						
					else
						fails = fails + 1
						--DebugPrint("FAIL-"..fails)
					end
				end
			else
				locquest = DugisGuideViewer:localize(tquests[i], "ZONE")
				if locquest then
					tquests[i] = locquest
				end
			end
		end
		DugisGuideViewer.quests1L = tquests
		return fails
	end
end
-- Background quest's tooltip scanning

do
	local fTGBgScan = CreateFrame( "Frame", "_TGBackgroundScan" )
	local TicksCounter = 0
	local Reiterations = 0

	function fTGBgScan:OnUpdate( Elapsed )
		TicksCounter = TicksCounter + Elapsed;
		if ( TicksCounter > 2 ) then
			TicksCounter = 0;
			Reiterations = Reiterations + 1
			local fails = DugisGuideViewer:TranslateQuests()
			if fails == 0 then 
			
				fTGBgScan:Hide() 
				

				for i =1 , #DugisGuideViewer.actions do 
					DugisGuideViewer:SetQuestText(i)
				end
				DugisGuideViewer:PopulateSmallFrame(CurrentQuestIndex)
				
			end
			
			LocalizePrint ( "Translating guide:  Try:"..Reiterations.."Fails".. fails)
			if Reiterations > 9 then
				fTGBgScan:Hide()
				Reiterations = 0
			end
		end
	end

	fTGBgScan:SetScript( "OnUpdate", fTGBgScan.OnUpdate );
	fTGBgScan:Hide()

	function DugisGuideViewer:QuestsBackgroundTranslator()
		fTGBgScan:Show()
	end
end

--English to local
function DugisGuideViewer:GuideTitleTranslator(GuideTitle)
	local tmp = DUGIS_LOCALIZE
	
	if DUGIS_LOCALIZE == 1 and GuideTitle then
		local _, _, guidetitle, guidetitlelevels = GuideTitle:find("(.+)(%s%([%d%-]+.+%))")
		--if guidetitle then DebugPrint("G:"..guidetitle) end
		
		if DugisGuideViewer.BZL[guidetitle] then
			guidetitle = DugisGuideViewer.BZL[guidetitle]
            return guidetitle..guidetitlelevels			
		end
	end
	LocalizePrint("ERROR localizing"..GuideTitle)
	return GuideTitle
end

--local to English
function DugisGuideViewer:RevGuideTitleTranslator(GuideTitle)
	local tmp = DUGIS_LOCALIZE
	
	if DUGIS_LOCALIZE == 1 and GuideTitle then
		local _, _, guidetitle, guidetitlelevels = GuideTitle:find("(.+)(%s%([%d%-]+.+%))")
		--if guidetitle then DebugPrint("G:"..guidetitle) end
		
		if DugisGuideViewer.RBZL[guidetitle] then
			guidetitle = DugisGuideViewer.RBZL[guidetitle]
            return guidetitle..guidetitlelevels			
		end
	end
	LocalizePrint("ERROR localizing"..GuideTitle)
	return GuideTitle
end



