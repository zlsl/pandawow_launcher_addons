local L = LibStub("AceLocale-3.0"):NewLocale("AffDots", "enUS", true)

L["AffDots (drag here to move options frame)"] = true
L["Lock frames"] = true

--Tabs
L["General"] = true
L["Affliction"] = true
L["Demonology"] = true
L["Destruction"] = true
L["Colors"] = true
L["Layout"] = true
L["TidyPlates"] = true
L["Burst"] = true

--General
L["Hide when not in combat"] = true
L["Hide icons"] = true
L["Hide text"] = true
L["Show focus frame"] = true
L["Show CoE"] = true
L["Show HP%"] = true
L["Show Soul Leech value"] = true
L["Target frame size"] = true
L["Focus frame size"] = true
L["Text size"] = true
L["CoE/Hp text size"] = true
L["Font"] = true
L["Layout"] = true
L["Horizontal"] = true
L["Vertical"] = true
L["Bars"] = true
L["Change color of text"] = true
L["Relative values"] = true
L["Hide UI"] = true
L["Color"] = true

--Affliction
L["Show Haunt"] = true
L["Order:"] = true
L["Agony"] = true
L["Corruption"] = true
L["UA"] = true
L["Haunt"] = true
L["Enable"] = true

--Demonology
L["Show Hand of Guldan"] = true
L["Show Demonic Fury"] = true
L["Doom"] = true
L["Hand of Guldan"] = true
L["Demonic Fury"] = true
L["Demonic Fury <="] = true

--Destruction
L["Show Conflagrate"] = true
L["Show Rain of Fire"] = true
L["Show Burning Embers"] = true
L["Show Havoc"] = true
L["Show Backdraft"] = true
L["Immolate"] = true
L["Conflagrate"] = true
L["Rain of Fire"] = true
L["Burning Embers"] = true
L["Havoc"] = true
L["Backdraft"] = true
L["Burning Embers <="] = true
L["Colors for Burning Embers:"] = true


--Colors
L["Current stats are better, full Pandemic benefit"] = true
L["Current stats are same, full Pandemic benefit"] = true
L["Current stats are worse, full Pandemic benefit"] = true
L["Current stats are better, partial Pandemic benefit"] = true
L["Current stats are same, partial Pandemic benefit"] = true
L["Current stats are worse, partial Pandemic benefit"] = true
L["No dot on target"] = true
L["CoE/Hp/Haunt color"] = true
L["Text color"] = true
L["Color switch"] = true
L["When refresh will not recieve full Pandemic benefit,\nswitch color only if current stats are at least x% better"] = true
L["Transparency"] = true

--TidyPlates
L["Integrate dot colors in TidyPlates"] = true
L["Width"] = true
L["Height"] = true
L["tidydesc"] = "If you want dots to show in certain order in TidyPlates, go to 'Tidy Plates Hub: Tank' and 'Tidy Plates Hub: Damage', find 'Buffs & Debuffs' section, set 'Filter Mode' to 'Specific Auras' and write this in Aura List:\nMy 980\nMy 172\nMy 87389\nMy 30108\nAll 1490\nFirst line is Agony, second and third Corruption, fourth UA, fifth CoE. Reorder them as needed. Put other auras in list if you need them"

--Burst
L["burstdesc"] = "Compares your current damage to your baseline damage, changes color if increase is at least x% higher.\nIntended to show when you have enough damage increase effects and it is a good time to spend your resources. Set it as high as you possibly can for maximum effect.\nTo save your baseline damage, click 'Set current as baseline' button, make sure you are fully buffed (Dark Intent when solo, party buffed when in 5-man, fully buffed with food and flask in raid) and without active procs or potions. You need to click it once for each spec, when you change gear or some buffs become available or unavailable.\n\nAffliction is special and needs active dots present on target to switch colors, demonology and destruction does not have this requirement."
L["Set current as baseline"] = true
L["Damage increase needed to change color (percent)"] = true
L["Show text"] = true
L["\nTo quickly set baseline values, press the following key combination on Burst frame:"] = true
L["Key"] = true
L["Left SHIFT"] = true
L["Right SHIFT"] = true
L["Left CTRL"] = true
L["Right CTRL"] = true
L["Left ALT"] = true
L["Right ALT"] = true
L["Mouse button"] = true
L["Right mouse button"] = true
L["Burst frame for other classes: www.curse.com/addons/wow/mesmash"] = true

--Horizontal/Vertical layout
L["Icon size"] = true
L["Icon position"] = true
L["Text position"] = true

--Bars layout
L["Spacing"] = true
L["Background"] = true
L["Background color"] = true
L["Enable proportional bars"] = true
L["All bars will move at the same speed"] = true
L["Proportional bars time limit"] = true
L["Maximum numbers of seconds to display in proportional bar"] = true