local Guide = DugisGuideViewer:RegisterModule("DugisGuide_Dungeons_Horde_En_15_16_Ragefire_Chasm")
function Guide:Initialize()
	function Guide:Load()DugisGuideViewer:RegisterGuide("|cfff0c502Azeroth|r", "213(15-16)", "291(15-17)", "Horde", nil, "I", nil, function()
return [[

R Ragefire Chasm |N|Queue/Zone into Ragefire Chasm in Orgrimmar, Cleft of Shadow (70.0, 49.0)| |Z|86| |I| |QID|26858| |F|213|
A Taragaman the Hungerer |N|(npc:44217) (68.4, 11.5)| |QID|26858| |NPC|44217|
A Repel the Invasion |N|(npc:44217) (68.4, 11.5)| |QID|26856| |NPC|44217|
A Elemental Tampering |N|(npc:44216) (69.9, 11.4)| |QID|26862| |NPC|44216|

K (npc:11517) |N|Kill (npc:11517) (69.8, 64.6)| |QID|26856.3| |NPC|11517|
C Elemental Tampering |N|Collect 6 (item:60499) from Molten Elementals. (64.2, 69.7) (60.1, 67.3) (59.9, 33.0) (53.4, 29.5) (51.8, 44.8) (53.0, 29.0)| |QID|26862| |NPC|11321|
K Taragaman the Hungerer |N|Kill (npc:11520) (41.4, 58.0) and collect (item:14540)| |QID|26858.4| |NPC|11520|
C Taragaman the Hungerer |N|Kill 4 (npc:11322), 4 (npc:11323) and 2 (npc:11324) (32.9, 67.9)| |QID|26858| |NPC|11322, 11323, 11324|
K Jergosh the Invoker |N|Kill (npc:11518) (32.9, 67.9) (34.2, 85.0)| |QID|26856.1| |NPC|11518|
K Bazzalan |N|Kill Bazzalan (32.9, 67.9) (31.8, 54.7) (26.8, 68.9) (26.9, 85) (35.6, 90.8) (41.2, 86.4), the final boss| |QID|26856.2| |NPC|11519|

T Repel the Invasion |N|(npc:44217) (68.4, 11.5)| |QID|26856| |NPC|44217|
T Taragaman the Hungerer |N|(npc:44217) (68.4, 11.5)| |QID|26858| |NPC|44217|
T Elemental Tampering |N|(npc:44216) (69.9, 11.4)| |QID|26862| |NPC|44216|

N Guide Complete

]]
end)
	end
	
	function Guide:Unload()
	end
end
