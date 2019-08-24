﻿
local L = Panda.locale
local panel = Panda.panel.panels[2]

panel:RegisterFrame(L["BC Unc/Rare"], Panda.PanelFactory(25229,
[[23077 23094 23095 23097 23096 28595   0   35945   0   24027 24028 24029 24030 24031 24032 24036 23436
  21929 23098 23099 23100 23101 31866 31869   0     0   24058 24059 24060 24061 31867 31868 35316 23439
  23112 23113 23114 23115 23116 28290 31860   0   24047 24048 24050 24051 24052 24053 31861 35315 23440
  23079 23103 23104 23105 23106   0     0     0     0     0   24062 24065 24066 24067 33782 35318 23437
  23117 23118 23119 23120 23121   0     0   24478 24479   0     0     0   24033 24035 24037 24039 23438
  23107 23108 23109 23110 23111 31862 31864 32833 32836 24054 24055 24056 24057 31863 31865 35707 23441]]))


panel:RegisterFrame(L["BC Epic/Meta"], Panda.PanelFactory(25229,
[[32227 32193 32194 32195 32196 32197 32198 32199
  32231 32217 32218 32219 32220 32221 32222 35760
  32229 32204 32205 32206 32207 32208 32209 32210 35761
  32249 32223 32224 32225 32226 35758 35759
  32228 32200 32201 32202 32203   0     0     0     0   25896 25897 25898 25899 25901 32409 35501 25867
  32230 32211 32212 32213 32214 32215 32216   0     0   25890 25893 25894 25895 32410 34220 35503 25868]]))


panel:RegisterFrame(L["Wrath Unc"], Panda.PanelFactory(25229,
[[36917 39900 39905 39906 39907 39908 39909 39910 39911   0     0   39962 39963 39964 39965 39966 39967
  36929 39946 39947 39948 39949 39950 39951 39952 39953 39954 39955 39956 39957 39958 39959 39960 39961
  36920 39912 39914 39915 39916 39917 39918
  36932 39982 39968 39974 39975 39976 39977 39978 39979 39980 39981 39983 39984 39985 39986 39988 39989
  36923 39919 39920 39927 39932   0     0     0     0     0     0     0     0     0   39990 39991 39992
  36926 39933 39934 39935 39936 39937 39938 39939 39940 39941 39942 39943 39944 39945]]))


panel:RegisterFrame(L["Wrath Unc |cffff8000(by stat)"], Panda.PanelFactory(25229,
[[36917        0           0         0         0          0         0       0 36929 0   0           0         0         0          0         0       36917
  39909:APEN   0           0         0         0          0         0       0   0   0   0           0         0         0          0       39964     39907:DOD
  39900:STR  39951       39950     39948     39947        0         0       0   0   0   0           0         0         0          0       39965     39908:PARRY
  39905:AGI  39955       39954     39953     39952        0         0       0   0   0   0           0       39966       0          0       39967     39910:EXP
  39906:AP   39963       39962     39961     39960        0         0       0   0   0 39959       39958     39957     39956      39946       0       39911:SP
    0        39918:HASTE 39917:RES 39915:HIT 39914:CRIT 39912:INT 39916:DEF 0 36920 0 39918:HASTE 39917:RES 39915:HIT 39914:CRIT 39912:INT 39916:DEF
]]))


panel:RegisterFrame(L["Wrath Unc |cff1eff00(by stat)"], Panda.PanelFactory(25229,
[[36923        0           0         0         0          0         0         36932
  39932:SPEN 39992         0       39991     39990
  39920:SPI  39983       39982     39981     39980      39979
  39927:MPR  39989       39988     39986     39985      39984
  39919:STA  39978       39977     39975     39974      39968     39976
    0        39918:HASTE 39917:RES 39915:HIT 39914:CRIT 39912:INT 39916:DEF 36920
]]))


panel:RegisterFrame(L["Wrath Unc |cffa335ee(by stat)"], Panda.PanelFactory(25229,
[[
  36923        0        0         0        0         0         0           0          0       36926
  39932:SPEN 39945
  39920:SPI  39941
  39927:MPR  39943    39942     39944
  39919:STA  39936    39935     39937    39934     39938     39939       39933      39940
    0        39911:SP 39905:AGI 39906:AP 39900:STR 39907:DOD 39908:PARRY 39909:APEN 39910:EXP 36917
]]))


panel:RegisterFrame(L["Wrath Rare"], Panda.PanelFactory(25229,
[[36918 39996 39997 39998 39999 40000 40001 40002 40003   0     0   40054 40055 40056 40057 40058 40059
  36930 40037 40038 40039 40040 40041 40043 40044 40045 40046 40047 40048 40049 40050 40051 40052 40053
  36921 40012 40016 40017 40014 40013 40015
  36933 40085 40086 40088 40089 40090 40091 40092 40094 40095 40096 40098 40099 40100 40101 40102 40103
  36924 40008 40009 40010 40011   0     0     0     0     0     0     0     0     0   40104 40105 40106
  36927 40022 40023 40024 40025 40026 40027 40028 40029 40030 40031 40032 40033 40034   0     0   44943]]))


panel:RegisterFrame(L["Wrath Epic"], Panda.PanelFactory(25229,
[[36919 40111 40112 40113 40114 40115 40116 40117 40118   0     0   40158 40159 40160 40161 40162 40163
  36931 40142 40143 40144 40145 40146 40147 40148 40149 40150 40151 40152 40153 40154 40155 40156 40157
  36922 40123 40124 40125 40126 40127 40128
  36934 40164 40165 40166 40167 40168 40169 40170 40171 40172 40173 40174 40175 40176 40177 40178 40179
  36925 40119 40120 40121 40122   0     0     0     0     0     0     0     0     0   40180 40181 40182
  36928 40129 40130 40131 40132 40133 40134 40135 40136 40137 40138 40139 40140 40141]]))


panel:RegisterFrame(L["Wrath Meta"], Panda.PanelFactory(25229,
[[41334 41380 41381 41382 41385 41389 41395 41396 41397 41398 41401
  41266 41285 41307 41333 41335 41339 41375 41376 41377 41378 41379 41400]]))
