local L = LibStub("AceLocale-3.0"):NewLocale("AffDots", "ruRU")
if not L then return end

L["AffDots (drag here to move options frame)"] = "AffDots (кликните сюда чтобы передвигать окно настроек)"
L["Lock frames"] = "Зафиксировать фреймы"

--Tabs
L["General"] = "Основные"
L["Affliction"] = "Колдовство"
L["Demonology"] = "Демонология"
L["Destruction"] = "Разрушение"
L["Colors"] = "Цвета"
L["Layout"] = "Расположение"

--General
L["Hide when not in combat"] = "Показывать только в бою"
L["Hide icons"] = "Спрятать иконки"
L["Hide text"] = "Спрятать текст"
L["Show focus frame"] = "Показывать фокус-цель"
L["Show CoE"] = "Показывать Проклятие стихий"
L["Show HP%"] = "Показывать %хп"
L["Show Soul Leech value"] = "Показывать значение Поглощения Души"
L["Target frame size"] = "Размер фрейма цели"
L["Focus frame size"] = "Размер фрейма фокуса"
L["Text size"] = "Размер текста"
L["CoE/Hp text size"] = "Размер текста для проклятия стихий/хп"
L["Font"] = "Фонт"
L["Horizontal"] = "Горизонтальное"
L["Vertical"] = "Вертикальное"
L["Bars"] = "Полоски"
L["Change color of text"] = "Менять цвет текста"
L["Relative values"] = "Относительные значения"
L["Color"] = "Цвет"

--Affliction
L["Show Haunt"] = "Показывать Блуждающий дух"
L["Order:"] = "Порядок:"
L["Agony"] = "Агония"
L["Corruption"] = "Порча"
L["UA"] = "Нестабильное колдовство"
L["Haunt"] = "Блуждающий дух"
L["Enable"] = "Включать"

--Demonology
L["Show Hand of Guldan"] = "Показывать Руку Гулдана"
L["Show Demonic Fury"] = "Показывать Демоническую ярость"
L["Doom"] = "Рок"
L["Hand of Guldan"] = "Рука Гулдана"
L["Demonic Fury"] = "Демоническая ярость"
L["Demonic Fury <="] = "Демоническая ярость <="

--Destruction
L["Show Conflagrate"] = "Показывать Поджигание"
L["Show Rain of Fire"] = "Показывать Огненный ливень"
L["Show Burning Embers"] = "Показывать Раскаленные угли"
L["Show Havoc"] = "Показывать Хаос"
L["Show Backdraft"] = "Показывать Обратный поток"
L["Immolate"] = "Жертвенный огонь"
L["Conflagrate"] = "Поджигание"
L["Rain of Fire"] = "Огненный ливень"
L["Burning Embers"] = "Раскаленные угли"
L["Havoc"] = "Хаос"
L["Backdraft"] = "Обратный поток"
L["Burning Embers <="] = "Раскаленные угли <="
L["Colors for Burning Embers:"] = "Цвета для Раскаленных углей"

--Colors
L["Current stats are better, full Pandemic benefit"] = "Текущие параметры лучше, полный бонус Пандемии"
L["Current stats are same, full Pandemic benefit"] = "Текущие параметры такие же, полный бонус Пандемии"
L["Current stats are worse, full Pandemic benefit"] = "Текущие параметры хуже, полный бонус Пандемии"
L["Current stats are better, partial Pandemic benefit"] = "Текущие параметры лучше, частичный бонус Пандемии"
L["Current stats are same, partial Pandemic benefit"] = "Текущие параметры такие же, частичный полный бонус Пандемии"
L["Current stats are worse, partial Pandemic benefit"] = "Текущие параметры хуже, частичный бонус Пандемии"
L["No dot on target"] = "Нет дота на цели"
L["CoE/Hp/Haunt color"] = "Цвет для проклятия стихий/хп"
L["Text color"] = "Цвет текста"
L["Color switch"] = "Смена цвета"
L["When refresh will not recieve full Pandemic benefit,\nswitch color only if current stats are at least x% better"] = "Когда обновление дотов не получит полный бонус Пандемии, менять цвет только если параметры лучше на х%"
L["Transparency"] = "Прозрачность"

--TidyPlates
L["Integrate dot colors in TidyPlates"] = "Интегрировать цвета дотов в TidyPlates"
L["Width"] = "Ширина"
L["Height"] = "Высота"
L["tidydesc"] = "If you want dots to show in certain order in TidyPlates, go to 'Tidy Plates Hub: Tank' and 'Tidy Plates Hub: Damage', find 'Buffs & Debuffs' section, set 'Filter Mode' to 'Specific Auras' and write this in Aura List:\nMy 980\nMy 172\nMy 87389\nMy 30108\nAll 1490\nFirst line is Agony, second and third Corruption, fourth UA, fifth CoE. Reorder them as needed. Put other auras in list if you need them"

--Burst
L["burstdesc"] = "Compares your current damage to your baseline damage, changes color if increase is at least x% higher.\nIntended to show when you have enough damage increase effects and it is a good time to spend your resources. Set it as high as you possibly can for maximum effect.\nTo save your baseline damage, click 'Set current as baseline' button, make sure you are fully buffed (Dark Intent when solo, party buffed when in 5-man, fully buffed with food and flask in raid) and without active procs or potions. You need to click it once for each spec, when you change gear or some buffs become available or unavailable.\n\nAffliction is special and needs active dots present on target to switch colors, demonology and destruction does not have this requirement."

--Horizontal/Vertical layout
L["Icon size"] = "Размер иконок"
L["Icon position"] = "Положение иконок"
L["Text position"] = "Положение текста"

--Bars layout
L["Spacing"] = "Интервал между полосками"
L["Background"] = "Фон"
L["Background color"] = "Цвет фона"
L["Enable proportional bars"] = "Пропорциональные полосы"
L["All bars will move at the same speed"] = "Скорость одинакова для всех полос"
L["Proportional bars time limit"] = "Количество секунд для пропорциональных полос "