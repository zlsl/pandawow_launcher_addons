AffDots = LibStub( "AceAddon-3.0" ):NewAddon("AffDots","AceEvent-3.0")
AffDots.SharedMedia = LibStub("LibSharedMedia-3.0")

local _
local options
local playerGuid, class, spec
local timer, throttle		= 0, 0.1
local dot_damage, targets	= {},{}

AffDots.track				= {}

local in_combat				= false
local colors
local setburst				= false
local dmg_buff				= 1

AffDots.execute_percent		= 0

local corr_id = 172

if select(4, GetBuildInfo()) >= 50400 then
	corr_id = 146739
end


local spells = {
	corr			= GetSpellInfo(corr_id),
	agony			= GetSpellInfo(980),
	ua				= GetSpellInfo(30108),
	coe				= GetSpellInfo(1490),
	poison			= GetSpellInfo(93068),
	shadowflame		= GetSpellInfo(47960),
	soulleech		= GetSpellInfo(108366),
	sacpact			= GetSpellInfo(108416),
	havoc			= GetSpellInfo(80240),
	backdraft		= GetSpellInfo(117896),
	fluidity		= GetSpellInfo(138002), -- Fluidity +40%
	nutriment		= GetSpellInfo(140741), -- Primal Nutriment +100% +10% per stack
	tricks			= GetSpellInfo(57934),	-- Tricks of the Trade + 15%
	fearless		= GetSpellInfo(118977), -- Fearless + 60%
	-- twilightWard 	= GetSpellInfo(6229), -- test
	
	-- Warlock T16 Bonuses
	destructiveInfluence = GetSpellInfo(145075), -- 
	fieryWrath 			 = GetSpellInfo(146043), -- 
	emberMaster 	     = GetSpellInfo(145164), -- 
}

local DmgBuffEvents = {
	["SPELL_AURA_APPLIED"] = 1,
	["SPELL_AURA_REMOVED"] = 1,
	["SPELL_AURA_REFRESH"] = 1,
	["SPELL_AURA_APPLIED_DOSE"] = 1,
}
AffDots.tidyspells = {
	["Interface\\Icons\\Spell_Shadow_AbominationExplosion"] = { spell =	corr_id, 	pandemic =  9 },
	["Interface\\Icons\\Spell_Shadow_CurseOfSargeras"]		= { spell =	980, 		pandemic = 12 },
	["Interface\\Icons\\Spell_Shadow_UnstableAffliction_3"] = { spell = 30108, 		pandemic =  7 },
	["Interface\\Icons\\Spell_Shadow_AuraOfDarkness"]		= { spell =	603, 		pandemic = 30 },
	["Interface\\Icons\\Ability_Mage_WorldInFlames"]		= { spell = 108686, 	pandemic = 7.5 },
	["Interface\\Icons\\Spell_Fire_Immolation"]				= { spell =	348, 		pandemic = 7.5 },
}

local GetTime 				= GetTime
local GetMastery 			= GetMastery
local GetRangedHaste 		= GetRangedHaste
local GetSpellCritChance	= GetSpellCritChance
local GetSpellBonusDamage 	= GetSpellBonusDamage
local UnitDebuff 			= UnitDebuff
local UnitHealth 			= UnitHealth
local UnitHealthMax 		= UnitHealthMax
local UnitExists			= UnitExists
local UnitGUID				= UnitGUID
local UnitPower				= UnitPower
local math_floor			= math.floor

local mainFrame			= CreateFrame("Frame", "AffDotsTarget", UIParent)
local focusFrame		= CreateFrame("Frame",  "AffDotsFocus", UIParent)
local burstFrame		= CreateFrame("Frame",  "AffDotsBurst", UIParent)

burstFrame.bg	= burstFrame:CreateTexture()
burstFrame.text	= burstFrame:CreateFontString()

mainFrame:SetClampedToScreen(true)
focusFrame:SetClampedToScreen(true)
burstFrame:SetClampedToScreen(true)

mainFrame:SetFrameStrata("LOW")
focusFrame:SetFrameStrata("LOW")
burstFrame:SetFrameStrata("LOW")

local function Round(num) return math_floor(num+.5) end
local function SecondsRound(num)
	if num > 2 then return math_floor(num+.5)
	else return math_floor(num*10+.5)/10 end
end

function AffDots:CheckDmgBuffs()
	dmg_buff = 1
	local fluidity 			= UnitAura("player", spells.fluidity)
	local _,_,_,nutriment 	= UnitAura("player", spells.nutriment)
	local tricks 			= UnitAura("player", spells.tricks)
	local fearless 			= UnitAura("player", spells.fearless)
	
	local destructiveInfluence = UnitAura("player", spells.destructiveInfluence)
	local fieryWrath		   = UnitAura("player", spells.fieryWrath)
	local emberMaster		   = UnitAura("player", spells.emberMaster)
	
	if fluidity then 
		dmg_buff = 1.4
	end
	
	if nutriment then 
		dmg_buff = 2 + (nutriment-1) * 0.1 	
	end
	
	if fearless then 
		dmg_buff = 1.6
	end
	
	if tricks then 
		dmg_buff = dmg_buff * 1.15
	end
		
	if fieryWrath then
		dmg_buff = dmg_buff * 1.20
	end
	
	AffDots.GetDotDmg()
end

function AffDots:FindColor(GUID, time_left, spell, pandemic)
	if not targets[GUID..spell] or not dot_damage[spell] then
		return 7
	end
	
	local color = 5
	local current 		= dot_damage[spell][1]
	local on_target 	= targets[GUID..spell][1]
	
	if		(on_target  < current and time_left <= pandemic) then color = 1
	elseif 	(on_target == current and time_left <= pandemic) then color = 2
	elseif	(on_target  > current and time_left <= pandemic) then color = 3
	elseif	(on_target*options.color_switch < current and time_left  > pandemic) then color = 4
	elseif	(on_target  > current and time_left  > pandemic) then color = 6
	end
	
	return color
end

local function OnMouseDown(self, button)
	if button == "LeftButton" and not self.isMoving and not setburst then
		self:StartMoving()
		self.isMoving = true
	elseif self == burstFrame and button == "RightButton" and setburst then
		AffDots:BurstDefaults()
	end
end

local function OnMouseUp(self, button)
	local p, _, rp, x, y = self:GetPoint()
	
	if self == mainFrame then
		options.p = p; 
		options.rp = rp; 
		options.x = x; 
		options.y = y
	elseif self == focusFrame then
		options.focus_p = p; 
		options.focus_rp = rp;	
		options.focus_x = x; 
		options.focus_y = y
	elseif self == burstFrame then
		options.burst.p = p; 
		options.burst.rp = rp; 
		options.burst.x = x; 
		options.burst.y = y
	end
	
	if button == "LeftButton" and self.isMoving then
		self:StopMovingOrSizing()
		self:SetUserPlaced(false)
		self.isMoving = false
	end
end

mainFrame:SetScript("OnMouseDown", OnMouseDown)
mainFrame:SetScript("OnMouseUp", OnMouseUp)

focusFrame:SetScript("OnMouseDown", OnMouseDown)
focusFrame:SetScript("OnMouseUp", OnMouseUp)

burstFrame:SetScript("OnMouseDown", OnMouseDown)
burstFrame:SetScript("OnMouseUp", OnMouseUp)

function AffDots:ScaleAnimation(frame, duration)
	local w = frame.secw * duration
	
	frame.f.scaleanimation:Stop()
	
	if w > options.bars.w then
		local delay = duration - options.bars.w / frame.secw
		frame.f.scale:SetStartDelay(delay)
		w = options.bars.w
		duration = options.bars.w / frame.secw
	else
		frame.f.scale:SetStartDelay(0)
	end
	
	frame.f.statusbar:SetWidth(w)
	frame.f.statusbar:Show()
    frame.f.scale:SetDuration(duration)
    frame.f.scale:SetScale(0, 1)
	frame.f.scaleanimation:Play()
end

function AffDots:Visibility()

	if (options.hide_ui) then
		mainFrame:Hide();
		mainFrame:SetParent(nil)
	elseif(options.hide and not in_combat) then
		mainFrame:Hide(); 
		mainFrame:SetParent(nil)
		
		if options.burst.enable then burstFrame:Hide() end
	else
		mainFrame:SetParent(UIParent)
		mainFrame:Show(); 
		
		if options.burst.enable then burstFrame:Show() end
	end

	if(UnitGUID("focus") and options.focus and (in_combat or not options.hide)) then
		focusFrame:SetParent(UIParent)
		focusFrame:Show()
	else
		focusFrame:Hide()
		focusFrame:SetParent(nil)
	end

	mainFrame:SetMovable(not options.locked);
	mainFrame:EnableMouse(not options.locked)
	
	focusFrame:SetMovable(not options.locked);
	focusFrame:EnableMouse(not options.locked)
	
	burstFrame:SetMovable(not options.locked);
	burstFrame:EnableMouse(not options.locked)
end

---------------------------------------------------------------
local framepool, active_frames = {}, {}

function AffDots:ReleaseFrames()
	for i, frame in pairs(active_frames) do
		frame:Hide()
		tinsert(framepool, frame)
	end
	
	wipe(active_frames)
end

function AffDots:GetFrame(parent)
	local frame = tremove(framepool)
	if not frame then
		frame			= CreateFrame("Frame", nil, parent)
		frame.statusbar	= frame:CreateTexture(nil, "ARTWORK")
		frame.bg		= frame:CreateTexture(nil, "BACKGROUND")
		frame.tick1		= frame:CreateTexture(nil, "OVERLAY")
		frame.tick2		= frame:CreateTexture(nil, "OVERLAY")
		frame.t1		= frame:CreateFontString(nil, "OVERLAY")
		frame.t2		= frame:CreateFontString(nil, "OVERLAY")
		frame.icon		= CreateFrame("Frame", nil, frame)
		frame.icon.file	= frame.icon:CreateTexture(nil, "OVERLAY")
		frame.cd		= CreateFrame("COOLDOWN", nil, frame.icon)
		frame.statusbar:SetPoint("TOPLEFT")
		frame.bg:SetAllPoints(frame)
		frame.cd:SetAllPoints(frame.icon)
		frame.icon.file:SetAllPoints(frame.icon)
		frame.t1:SetFont("Fonts\\FRIZQT__.TTF",14,"OUTLINE")
		frame.t2:SetFont("Fonts\\FRIZQT__.TTF",14,"OUTLINE")
		frame.scaleanimation = frame.statusbar:CreateAnimationGroup()
		frame.scaleanimation:SetScript("OnFinished", function() frame.statusbar:Hide() end)
		frame.scale = frame.scaleanimation:CreateAnimation("Scale")
		frame.scale:SetOrder(1)
		frame.scale:SetOrigin("TOPLEFT", 0, 0)
	else
		frame:SetParent(parent)
	end
	tinsert(active_frames, frame)
	frame:Show()
	return frame
end
---------------------------------------------------------------

function AffDots:Track(id, update, target, duration, tick, order, active, noprop)
	if not active then return end
	local spell = {}
	local parent
	
	if target == "target" then 
		parent = AffDotsTarget 
	else 
		parent = AffDotsFocus 
	end
	
	frame = AffDots:GetFrame(parent)
	
	if id > 0 then
		local n,r,i = GetSpellInfo(id)
		
		spell["pandemic"]	= duration / 3
		spell["name"]		= n
		spell["rank"]		= r
		spell["iconfile"]	= i
		spell["spell"]		= id
		spell["timer"]		= 0
	end
	
	spell["tick"]		= tick
	spell["duration"]	= duration
	spell["f"] 			= frame
	spell["target"]		= target
	spell["order"]		= order
	spell["update"]		= update
	
	if noprop then spell["noprop"] = true end
	
	tinsert(AffDots.track, spell)
end

function AffDots:InitFrames()
	if options.layout == "bars" then 
		AffDots.FrameDraw = AffDots.Bar 
	else 
		AffDots.FrameDraw = AffDots.Box 
	end
	
	local msize, fsize = 0, 0
	local font		= AffDots.SharedMedia:Fetch("font", options.font)
	local statusbar = AffDots.SharedMedia:Fetch("statusbar", options.bg)
	
	mainFrame:ClearAllPoints();
	focusFrame:ClearAllPoints()
	mainFrame:Show(); 
	
	if options.focus then focusFrame:Show() end
	
	mainFrame:SetPoint(options.p, nil, options.rp, options.x, options.y)
	focusFrame:SetPoint(options.focus_p, nil, options.focus_rp, options.focus_x, options.focus_y)
	
	--layout
	for k,v in pairs(AffDots.track) do
		local c = AffDots.track[k]
		c.f.scaleanimation:Stop()
		c.dataold = {color = nil, bg = nil, tick = nil, t1 = nil, t2 = nil, setw = options.bars.w}
		c.datanew = {color = colors[1], bg = colors[8], tick = 0, t1 = "", t2 = "", setw = options.bars.w}
		
		if c.target == "target" then 
			c.f:SetScale(options.scale) 
		else 
			c.f:SetScale(options.focus_scale) 
		end
		
		c.f.t1:SetTextColor(unpack(options.color11))
		c.f.t2:SetTextColor(unpack(options.color11))
		
		c.f.icon:Hide();
		c.f.cd:Hide();
		
		c.f.t1:Hide();
		c.f.t2:Hide();
		
		c.f.tick1:Hide();
		c.f.tick2:Hide();
		
		c.f.statusbar:Hide();
		
		c.f:ClearAllPoints();
		
		c.f.icon:ClearAllPoints();
		c.f.t1:ClearAllPoints();
		c.f.t2:ClearAllPoints();
		
		c.f.t1:SetText("");
		c.f.t2:SetText("")
		
		c.f.bg:SetTexture(statusbar)
		c.f.bg:SetVertexColor(1, 1, 1, 1)
		
		if c.spell then
			if c.target == "target" then msize = msize + 1 else fsize = fsize + 1 end
			if options.layout == "horizontal" then
				c.f:SetSize(options.boxes_h.w,options.boxes_h.h)
				c.f:SetPoint("TOPLEFT", options.boxes_h.w*c.order, 0)
				
				c.f.icon.file:SetTexture(c.iconfile)
				c.f.icon:SetSize(options.boxes_h.icon_size,options.boxes_h.icon_size)
				c.f.icon.file:SetTexCoord(0.1,0.9,0.1,0.9)
				c.f.icon:SetPoint("TOP",0,-options.boxes_h.icon_position)
				
				c.f.t1:SetPoint("TOP",0,-options.boxes_h.text_position);
				c.f.t1:SetFont(font,options.large_text_size,"OUTLINE")
				
				if not options.hide_text then c.f.t1:Show() end
				if not options.hide_icons then c.f.icon:Show();c.f.cd:Show() end
			elseif options.layout == "vertical" then
				c.f:SetSize(options.boxes_v.w,options.boxes_v.h)
				c.f:SetPoint("TOPLEFT", 0, -options.boxes_v.h*c.order)
				
				c.f.icon.file:SetTexture(c.iconfile)
				c.f.icon:SetSize(options.boxes_v.icon_size,options.boxes_v.icon_size)
				c.f.icon.file:SetTexCoord(0.1,0.9,0.1,0.9)
				
				c.f.icon:SetPoint("LEFT",options.boxes_v.icon_position,0)
				c.f.t1:SetPoint("RIGHT",options.boxes_v.text_position-50,0);c.f.t1:SetFont(font,options.large_text_size,"OUTLINE")
				
				if not options.hide_text then c.f.t1:Show() end
				if not options.hide_icons then c.f.icon:Show();c.f.cd:Show() end
			elseif options.layout == "bars" then
				c.f:SetSize(options.bars.w,options.bars.h)
				c.f:SetPoint("TOPLEFT",0,-options.bars.h*c.order-(c.order*options.bars.margin))
				
				c.f.tick1:SetSize(1,options.bars.h)
				c.f.tick1:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
				c.f.tick1:SetVertexColor(1, 1, 1, 0.75);
				
				c.f.statusbar:SetHeight(options.bars.h)
				c.f.statusbar:SetTexture(statusbar)
				c.f.statusbar:SetVertexColor(0, 0, 0, options.transparency)
				
				if options.bars.proportional and not c.noprop then
					if c.tick > 0 and c.tick < options.bars.limit then
						c.f.tick1:SetPoint("LEFT", c.tick / options.bars.limit * options.bars.w,0)
					end
					c.secw = options.bars.w / options.bars.limit
				else
					if c.tick > 0 then
						c.f.tick1:SetPoint("LEFT", c.tick / c.duration * options.bars.w, 0)
					end
					c.secw = options.bars.w / c.duration
				end
				
				c.f.tick2:SetSize(1,options.bars.h)
				c.f.tick2:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
				c.f.tick2:SetVertexColor(1, 1, 1, 0.75);
				
				c.f.icon.file:SetTexture(c.iconfile)
				c.f.icon:SetSize(options.bars.h,options.bars.h)
				c.f.icon.file:SetTexCoord(0.1,0.9,0.1,0.9)
				c.f.icon:SetPoint("LEFT",-options.bars.h,0)
				
				c.f.t1:SetPoint("CENTER",options.bars.text_position*(options.bars.w/100),0);
				c.f.t1:SetFont(font,options.large_text_size,"OUTLINE")
				c.f.t2:SetPoint("RIGHT",-3,0);
				c.f.t2:SetFont(font,options.large_text_size,"OUTLINE")
				c.f.bg:SetVertexColor(colors[8][1],colors[8][2],colors[8][3],options.transparency)
				
				if not options.hide_text then c.f.t1:Show();c.f.t2:Show() end
				if not options.hide_icons then c.f.icon:Show(); end
				
				if c.tick > 0 then c.f.tick1:Show() end
			end
		else
			local w
			if options.layout == "horizontal" then
				w = options.boxes_h.w
			elseif	options.layout == "vertical" then
				w = options.boxes_v.w/2
			elseif	options.layout == "bars" then
				w = 40
			end
			
			c.f.statusbar:Hide()
			c.f:SetSize(w,20)
			c.f:SetPoint("TOPLEFT", 0, 22)
			
			c.f.t1:SetPoint("CENTER", 0, 0);
			c.f.t1:SetFont(font,options.small_text_size,"OUTLINE");
			c.f.t1:Show()
			
			if c.update == AffDots.Update.coe and options.hp then 
				c.f:SetPoint("TOPLEFT", w, 22) 
			end
			
			if c.update == AffDots.Update.sl then
				local position = 0
				
				if options.hp then position = position + 1 end
				if options.coe then position = position + 1 end
				
				c.f:SetPoint("TOPLEFT", w*position, 22)
			end
		end
	end

	if(options.layout == "horizontal") then
		mainFrame:SetSize(msize*options.boxes_h.w*options.scale, options.boxes_h.h*options.scale)
		focusFrame:SetSize(fsize*options.boxes_h.w*options.focus_scale, options.boxes_h.h*options.focus_scale)
	elseif(options.layout == "vertical") then
		mainFrame:SetSize(options.boxes_v.w*options.scale, msize*options.boxes_v.h*options.scale)
		focusFrame:SetSize(options.boxes_v.w*options.focus_scale, fsize*options.boxes_v.h*options.focus_scale)
	elseif(options.layout == "bars") then
		mainFrame:SetSize(options.bars.w*options.scale, msize*(options.bars.h+options.bars.margin)*options.scale)
		focusFrame:SetSize(options.bars.w*options.focus_scale, fsize*(options.bars.h+options.bars.margin)*options.focus_scale)
	end
	
	if options.burst.enable then
		burstFrame:ClearAllPoints()
		burstFrame:Show()
		burstFrame:SetSize(options.burst.w, options.burst.h)
		burstFrame:SetPoint(options.burst.p, nil, options.burst.rp, options.burst.x, options.burst.y)
		burstFrame.bg:SetAllPoints(true)
		burstFrame.text:SetPoint("CENTER",0,0)
		burstFrame.text:SetFont(font,options.large_text_size,"OUTLINE")
		burstFrame.text:SetTextColor(options.color11[1],options.color11[2],options.color11[3])
		if options.burst.text then burstFrame.text:Show() else burstFrame.text:Hide() end
	else
		burstFrame:Hide()
	end

	AffDots:Visibility()
end

function AffDots:Tidy()
	local TidyPlates = TidyPlates
	local time_left, icon, spell, pandemic, GUID, c
	for plate in pairs(TidyPlates.NameplatesByVisible) do
		if not plate.extended.widgets.DebuffWidget then return false end
		GUID = plate.extended.unit.guid
		if GUID then
			for id,frame in pairs(plate.extended.widgets.DebuffWidget.AuraIconFrames) do
				icon = frame.Icon:GetTexture()
				if AffDots.tidyspells[icon] then
					spell = AffDots.tidyspells[icon].spell; pandemic = AffDots.tidyspells[icon].pandemic
					time_left = tonumber(frame.TimeLeft:GetText())
				end
				if not frame.affdots then
					frame.Icon:SetDrawLayer("ARTWORK")
					frame.Border:SetDrawLayer("BACKGROUND")
					frame.Border:SetSize(options.tidyplates.w,options.tidyplates.h)
					frame.Border:SetPoint("CENTER", 0, 0)
					frame.affdots = true
				end
				if spell and time_left then
					c = AffDots:FindColor(GUID,time_left,spell,pandemic)
					frame.Border:SetTexture(colors[c][1],colors[c][2],colors[c][3],options.tidyplates.transparency)
				else
					frame.Border:SetTexture(0,0,0,options.tidyplates.transparency)
				end
			end
		end
	end
end

function AffDots:Bar(frame)
	if frame.dataold.color ~= frame.datanew.color then
		if options.color_text then
			frame.f.t1:SetTextColor(frame.datanew.color[1], frame.datanew.color[2], frame.datanew.color[3])
		end
		frame.f.statusbar:SetVertexColor(frame.datanew.color[1],frame.datanew.color[2],frame.datanew.color[3],options.transparency)
		frame.dataold.color = frame.datanew.color
	end
	
	if frame.dataold.bg ~= frame.datanew.bg then
		frame.f.bg:SetVertexColor(frame.datanew.bg[1], frame.datanew.bg[2], frame.datanew.bg[3], options.transparency)
		frame.dataold.bg = frame.datanew.bg
	end
	
	if frame.dataold.t1 ~= frame.datanew.t1 then
		frame.f.t1:SetText(frame.datanew.t1)
		frame.dataold.t1 = frame.datanew.t1
	end
	
	if frame.dataold.t2 ~= frame.datanew.t2 then
		frame.f.t2:SetText(frame.datanew.t2)
		frame.dataold.t2 = frame.datanew.t2
	end
	
	if frame.dataold.tick ~= frame.datanew.tick then		
		if frame.datanew.tick > 0 and frame.secw * frame.datanew.tick < options.bars.w then
			frame.f.tick2:SetPoint("LEFT", frame.secw * frame.datanew.tick, 0); 
			frame.f.tick2:Show()
		else
			frame.f.tick2:Hide()
		end
		
		frame.dataold.tick = frame.datanew.tick
	end
	
	if frame.datanew.setcd then
		local duration = frame.datanew.expires - GetTime()
		AffDots:ScaleAnimation(frame, duration)
		frame.datanew.setcd = false
	end
	
	if frame.datanew.hidecd then
		frame.f.statusbar:Hide()
		frame.datanew.hidecd = false
	end
	
	if frame.dataold.setw ~= frame.datanew.setw then
		frame.f.statusbar:Show()
		frame.f.statusbar:SetWidth(frame.datanew.setw)
		frame.dataold.setw = frame.datanew.setw
	end
end

function AffDots:Box(frame)
	if frame.dataold.color ~= frame.datanew.color then
		if options.color_text then
			frame.f.t1:SetTextColor(frame.datanew.color[1],frame.datanew.color[2],frame.datanew.color[3])
		end
		frame.f.bg:SetTexture(frame.datanew.color[1],frame.datanew.color[2],frame.datanew.color[3],options.transparency)
		frame.dataold.color = frame.datanew.color
	end
	if frame.dataold.t1 ~= frame.datanew.t1 then
		frame.f.t1:SetText(frame.datanew.t1)
		frame.dataold.t1 = frame.datanew.t1
	end

	if frame.datanew.setcd and not options.hide_icons then
		frame.f.cd:Show()

		if (not options.hide_duration) then
			frame.f.cd:SetCooldown(frame.datanew.expires - frame.datanew.duration, frame.datanew.duration)
		end
		frame.datanew.setcd = false
	end
	if frame.datanew.hidecd then
		frame.f.cd:Hide()
		frame.datanew.hidecd = false
	end
end

local function onUpdate(self,elapsed)
    timer = timer + elapsed;
    if timer >= throttle then
		for k,v in pairs(AffDots.track) do
			AffDots.track[k].update(AffDots.track[k])
			AffDots:FrameDraw(AffDots.track[k])
		end
		
		if options.tidyplates.enable and TidyPlates then 
			AffDots:Tidy() 
		end
		
		if options.burst.enable then 
			AffDots.Update.burst() 
		end

        timer = 0
    end
end

SLASH_AFFDOTS1 = '/affdots'
function AffDotsHandler(msg, editBox)
	AffDots:GetLayoutOptions()
	AffDots:GetSpecOptions(class..spec)
	LibStub("AceConfigDialog-3.0"):Open("AffDots")
end
SlashCmdList["AFFDOTS"] = AffDotsHandler

function AffDots:MODIFIER_STATE_CHANGED(event,key,state)
	if key == options.burst.key and state == 1 then
		burstFrame:EnableMouse(true)
		setburst = true
	else
		burstFrame:EnableMouse(not options.locked)
		setburst = false
	end
end

function AffDots:PLAYER_REGEN_ENABLED()
	in_combat = false; 
	AffDots:Visibility()
	local t = GetTime()
	for k,v in pairs(targets) do
		if targets[k][2] < t-120 then targets[k]=nil end
	end
end

function AffDots:PLAYER_REGEN_DISABLED()
	in_combat = true; 
	AffDots:Visibility()
end

function AffDots:PLAYER_FOCUS_CHANGED()
	AffDots:Visibility()
end

function AffDots:SaveColors()
	options = self.db.profile
	colors = { 
		options.color1, 
		options.color2,
		options.color3,
		options.color4,
		options.color5,
		options.color6,
		options.color7,
		options.color8,
		options.color9,
		options.color10,
		options.color11
	}
end

function AffDots:BurstDefaults()
	if spec == 1 then
		options.burst.default[1] = dot_damage[corr_id][1] + dot_damage[980][1] + dot_damage[30108][1]
	elseif spec == 2 then
		options.burst.default[2] = dot_damage[corr_id][1]
	elseif spec == 3 then
		options.burst.default[3] = dot_damage[348][1]
	end
end

AffDots.Update = {
	dot	= function(f)
		local guid = UnitGUID(f.target)
		local _,_,_,_,_,duration,expires = UnitDebuff(f.target,f.name,f.rank,"player")
		
		if duration and guid and targets[guid..f.spell] then

			if(math.abs(expires - f.timer) > 1) then
				if f.spell == 980 then
					if targets[guid..f.spell][4] == 0 then
						targets[guid.."980"][4] = expires
					elseif expires - targets[guid..f.spell][4] > 1 then
						targets[guid.."980"][4] = expires
						targets[guid.."980"][1] = dot_damage[980][1]
						targets[guid.."980"][3] = dot_damage[980][2]
					end
				end

				f.datanew.expires = expires
				f.datanew.duration = duration
				f.datanew.setcd = true
				f.timer = expires
			end
			f.datanew.color = colors[AffDots:FindColor(guid,expires - GetTime(),f.spell,f.pandemic)]
			f.datanew.tick = targets[guid..f.spell][3]
			f.datanew.t2 = SecondsRound(f.timer-GetTime())
			if options.reltext then
				f.datanew.t1 = Round(dot_damage[f.spell][1]*100/targets[guid..f.spell][1])
			elseif options.layout == "bars" then
				f.datanew.t1 = dot_damage[f.spell][1].."/"..targets[guid..f.spell][1]
			else
				f.datanew.t1 = dot_damage[f.spell][1].."\n"..targets[guid..f.spell][1]
			end
		else
			f.datanew.color = colors[7]
			f.datanew.t1 = 0
			f.datanew.t2 = ""
			f.datanew.tick = 0
			f.timer = 0
			f.datanew.hidecd = true
		end
	end,
	doom	= function(f)
		local guid = UnitGUID(f.target)
		local _,_,_,_,_,duration,expires = UnitDebuff(f.target,f.name,f.rank,"player")
		if duration and guid and targets[guid..f.spell] then
			if(math.abs(expires-f.timer)>1) then
				f.datanew.expires = expires
				f.datanew.duration = duration
				f.datanew.setcd = true
				f.timer = expires
			end
			f.datanew.color = colors[AffDots:FindColor(guid,expires - GetTime(),f.spell,f.pandemic)]
			f.datanew.tick = targets[guid..f.spell][3]
			f.datanew.t2 = SecondsRound(f.timer-GetTime())
			if options.reltext then
				f.datanew.t1 = Round(dot_damage[f.spell][1]*100/targets[guid..f.spell][1])..targets[guid..f.spell][4]
			elseif options.layout == "bars" then
				f.datanew.t1 = dot_damage[f.spell][1].."/"..targets[guid..f.spell][1]..targets[guid..f.spell][4]
			else
				f.datanew.t1 = dot_damage[f.spell][1].."\n"..targets[guid..f.spell][1]..targets[guid..f.spell][4]
			end
		else
			f.datanew.color = colors[7]
			f.datanew.t1 = 0
			f.datanew.t2 = ""
			f.datanew.tick = 0
			f.timer = 0
			f.datanew.hidecd = true
		end
	end,
	haunt = function(f)
		local shards = UnitPower("player", 7)
		local _,_,_,_,_,duration,expires = UnitDebuff(f.target, f.name,"","player")
		f.datanew.t1 = shards
		if not expires then
			if shards > 3 then
				f.datanew.color = colors[4]; f.datanew.bg = colors[4]
			else
				f.datanew.color = colors[7]; f.datanew.bg = colors[8]
			end
			f.datanew.hidecd = true
			f.datanew.t2 = ""
			f.timer = 0
		else
			f.datanew.color = colors[9]
			f.datanew.bg = colors[8]
			if(expires-f.timer>1) then
				f.datanew.expires = expires
				f.datanew.duration = duration
				f.datanew.setcd = true
				f.timer = expires
			end
			f.datanew.t2 = SecondsRound(f.timer-GetTime())
		end
	end,
	coe = function(f)
		local _,_,_,_,_,_,expires1 = UnitDebuff(f.target, spells.coe)
		local _,_,_,_,_,_,expires2 = UnitDebuff(f.target, spells.poison)
		local expires = expires1 or expires2
		if expires then
			local time_remaining = expires - GetTime()
			if 		time_remaining>60 	then f.datanew.t1 = (math_floor(time_remaining/60)+1).."m"
			elseif 	time_remaining>10	then f.datanew.t1 = "0:" ..math_floor(time_remaining)
			else 							 f.datanew.t1 = "0:0"..math_floor(time_remaining)
			end
			f.datanew.color = colors[9]; f.datanew.bg = colors[9]
		else
			f.datanew.t1 = ""
			f.datanew.color = colors[7]; f.datanew.bg = colors[8]
		end
	end,
	hp = function(f)
		f.datanew.color = colors[7]; f.datanew.bg = colors[8]
		if UnitExists(f.target) then
			local hp = Round(UnitHealth(f.target)*100/UnitHealthMax(f.target))
			f.datanew.t1 = hp
			if AffDots.execute_percent >= hp then
				f.datanew.color = colors[9]; f.datanew.bg = colors[9]
			end
		end
	end,
	sl = function(f)
		local _,_,_,_,_,_,_,_,_,_,_,_,_,_,sl = UnitAura("player", spells.soulleech)
		local _,_,_,_,_,_,_,_,_,_,_,_,_,_,sp = UnitAura("player", spells.sacpact)
		local bubble = 0
		if sl and sl > 0 then bubble = bubble + sl end
		if sp and sp > 0 then bubble = bubble + sp end
		if bubble > 0 then
			f.datanew.color = colors[9]; f.datanew.bg = colors[9]
			f.datanew.t1 = Round(bubble/1000).."k"
		else
			f.datanew.color = colors[7]; f.datanew.bg = colors[8]
			f.datanew.t1 = ""
		end
	end,
	burst = function()
		local current = 0
		local target = UnitGUID("target")
			
		if spec == 1 and target then
			local _,_,_,_,_,_,expires1 = UnitDebuff("target", spells.corr,nil,"player")
			local _,_,_,_,_,_,expires2 = UnitDebuff("target", spells.agony,nil,"player")
			local _,_,_,_,_,_,expires3 = UnitDebuff("target", spells.ua,nil,"player")
			if expires1 and targets[target..corr_id] then current = current + targets[target..corr_id][1] end
			if expires2 and targets[target.."980"] then current = current + targets[target.."980"][1] end
			if expires3 and targets[target.."30108"] then current = current + targets[target.."30108"][1] end
		elseif spec == 2 then
			current = dot_damage[corr_id][1]
		elseif spec == 3 then
			current = dot_damage[348][1]
		end
		local damage = current/options.burst.default[spec]
		if damage > options.burst.switch then
			burstFrame.bg:SetTexture(options.burst.color[1],options.burst.color[2],options.burst.color[3],options.transparency)
		else
			burstFrame.bg:SetTexture(colors[7][1],colors[7][2],colors[7][3],options.transparency)
		end
		burstFrame.text:SetText(Round(damage*100))
	end,
	df = function(f)
		local power = UnitPower("player", 15)
		local color = 1
		if 		power <= options.demo.switch1 then color = 1
		elseif 	power <= options.demo.switch2 then color = 2
		elseif 	power <= options.demo.switch3 then color = 3
		elseif 	power <= options.demo.switch4 then color = 4
		elseif 	power <= options.demo.switch5 then color = 5
		end
		f.datanew.setw = options.bars.w*power/1000
		f.datanew.t1 = power
		f.datanew.color = options.demo["color"..color]
	end,
	hog = function(f)
		local currentCharges, maxCharges, timeLastCast, cooldownDuration = GetSpellCharges(105174)
		f.datanew.color = colors[7]; f.datanew.bg = colors[8]
		if currentCharges == maxCharges then
			f.datanew.t1 = currentCharges
			f.datanew.color = colors[9]; f.datanew.bg = colors[9]
		else
			local t = cooldownDuration-GetTime()+timeLastCast
			f.datanew.t1 = currentCharges.."/"..SecondsRound(t)
			if currentCharges == maxCharges - 1 and t < 5 then
				f.datanew.color = colors[9]; f.datanew.bg = colors[9]
			end
		end
		local _,_,_,_,_,_,expires = UnitDebuff("target", spells.shadowflame,nil,"player")
		if expires then
			if options.layout == "bars" then f.datanew.color = colors[1] end
			f.datanew.t2 = SecondsRound(expires-GetTime())
			f.datanew.expires = expires
			f.datanew.duration = duration
			f.datanew.setcd = true
		else
			f.datanew.t2 = ""
			f.datanew.hidecd = true
		end
	end,
	immo = function(f)
		local guid = UnitGUID(f.target)
		local _,_,_,_,_,duration,expires,_,_,_,id = UnitDebuff(f.target,f.name,f.rank,"player")
		if duration and guid and targets[guid..id] then
			if id == 348 and f.iconfile == spells.fnbImmoIcon then
				f.iconfile = spells.immoIcon
				f.f.icon.file:SetTexture(f.iconfile)
			elseif id == 108686 and f.iconfile == spells.immoIcon then
				f.iconfile = spells.fnbImmoIcon
				f.f.icon.file:SetTexture(f.iconfile)
			end
			if(math.abs(expires-f.timer)>1) then
				f.datanew.expires = expires
				f.datanew.duration = duration
				f.datanew.setcd = true
				f.timer = expires
			end
			f.datanew.color = colors[AffDots:FindColor(guid,expires - GetTime(),id,f.pandemic)]
			f.datanew.tick = targets[guid..id][3]
			f.datanew.t2 = SecondsRound(f.timer-GetTime())
			if options.reltext then
				f.datanew.t1 = Round(dot_damage[id][1]*100/targets[guid..id][1])
			elseif options.layout == "bars" then
				f.datanew.t1 = dot_damage[id][1].."/"..targets[guid..id][1]
			else
				f.datanew.t1 = dot_damage[id][1].."\n"..targets[guid..id][1]
			end
		else
			if f.iconfile ~= spells.immoIcon then
				f.iconfile = spells.immoIcon
				f.f.icon.file:SetTexture(f.iconfile)
			end
			f.datanew.color = colors[7]
			f.datanew.t1 = 0
			f.datanew.t2 = ""
			f.datanew.tick = 0
			f.timer = 0
			f.datanew.hidecd = true
		end
	end,
	embers = function(f)	
		local power = UnitPower("player", 14, true)
		local color = 1
		if 		power <= options.destro.switch1 then color = 1
		elseif 	power <= options.destro.switch2 then color = 2
		elseif 	power <= options.destro.switch3 then color = 3
		elseif 	power <= options.destro.switch4 then color = 4
		end
		f.datanew.setw = options.bars.w*power/40
		f.datanew.t1 = power
		f.datanew.color = options.destro["color"..color]
	end,
	conflag = function(f)
		local currentCharges, maxCharges, timeLastCast, cooldownDuration = GetSpellCharges(17962)
		f.datanew.bg = colors[8]
		if options.layout == "bars" then f.datanew.color = colors[3] else f.datanew.color = colors[7] end
		if currentCharges == maxCharges then
			f.datanew.color = colors[9]; f.datanew.bg = colors[9]
			f.datanew.t2 = ""
			f.datanew.hidecd = true
		else
			f.datanew.expires = timeLastCast+cooldownDuration
			f.datanew.duration = cooldownDuration
			f.datanew.setcd = true
			f.datanew.t2 = SecondsRound(cooldownDuration-GetTime()+timeLastCast)
		end
		f.datanew.t1 = currentCharges
	end,
	rof = function(f)
		local _,_,_,_,_,duration,expires = UnitAura("player",f.name,nil,"player")
		if expires then
			f.datanew.color = colors[9]
			f.datanew.t2 = SecondsRound(expires-GetTime())
			f.datanew.expires = expires
			f.datanew.duration = duration
			f.datanew.setcd = true
		else
			f.datanew.color = colors[7]
			f.datanew.t2 = ""
			f.datanew.hidecd = true
		end
	end,
	havoc = function(f)
		local _,_,_,count,_,duration,expires = UnitAura("player",spells.havoc)
		local cdstart, cdduration, cdenabled = GetSpellCooldown(spells.havoc)
		if count then
			f.datanew.t1 = count
			f.datanew.color = colors[9]
		else
			f.datanew.t1 = 0
			f.datanew.color = colors[7]
		end
		if(cdstart > 0 and cdduration > 1.5) then
			f.datanew.t2 = SecondsRound(cdstart + cdduration - GetTime())
			f.datanew.expires = cdstart + cdduration
			f.datanew.duration = cdduration
			f.datanew.setcd = true
		else
			f.datanew.color = colors[9]
			f.datanew.t2 = "Ready"
			f.datanew.hidecd = true
			f.datanew.setw = options.bars.w
		end
	end,
	draft = function(f)
		local _,_,_,count = UnitAura("player",spells.backdraft)
		if count then
			f.datanew.t1 = count
			f.datanew.color = colors[9]
			f.datanew.setw = options.bars.w*count/6
		else
			f.datanew.t1 = 0
			f.datanew.color = colors[7]
			f.datanew.hidecd = true
		end
	end,
}

local GetDotDmg = {
	function()
		local mastery, haste, crit, spd = GetMastery(), UnitSpellHaste("player"), GetSpellCritChance(6), GetSpellBonusDamage(6)
		if crit > 100 then crit = 100 end
	
		damage_bonus 		= (1 + crit / 100) * (1 + (mastery * 3.1) /100)
		tick_every 			= 2 / (1 + (haste / 100))

		ticks 				= Round(24 / tick_every)
		duration 			= ticks * tick_every
		damage				= ticks * (280 + spd * 0.26) * damage_bonus *dmg_buff
		dps					= Round(damage / duration)
		dot_damage[980]		= {Round(dps / 100) / 10, tick_every}

		ticks 				= Round(18 / tick_every)
		duration 			= ticks * tick_every
		damage		 		= (1926 + ticks * spd * 0.2) * damage_bonus * dmg_buff
		dps					= Round(damage / duration)
		dot_damage[corr_id]	= { Round(dps / 100) / 10, tick_every }

		ticks 				= Round(14 / tick_every)
		duration 			= ticks * tick_every
		damage 				= (1792 + ticks * spd * 0.24) * damage_bonus * dmg_buff
		dps		 			= Round(damage / duration)
		dot_damage[30108]	= { Round(dps / 100) / 10, tick_every }
	end,
	function()
		local mastery, haste, crit, spd = GetMastery(), UnitSpellHaste("player"), GetSpellCritChance(6), GetSpellBonusDamage(6)
		if crit > 100 then crit = 100 end
	
		damage_bonus 		= (1 + crit / 100) * (1 + (mastery) / 100)
		bonus				= (1 + crit / 100) * (1 + (mastery * 3) /100)

		tick_every 			= 2 / (1 + (haste / 100))
		ticks 				= Round(18 / tick_every)
		duration 			= ticks * tick_every
		damage		 		= (1926 + ticks * spd * 0.2) * damage_bonus * dmg_buff
		dps					= Round(damage / duration)
		dot_damage[corr_id]	= { Round(dps / 100) / 10, tick_every }

		tick_every 			= 15 / (1 + (haste / 100))
		ticks 				= Round(60 / tick_every)
		duration 			= ticks * tick_every
		damage		 		= (5340 / ticks + spd * 1.25) * bonus * ticks * dmg_buff
		dps					= Round(damage / duration)
		
		local c
		if crit == 100 then 
			c = "c" 
		else 
			c = "" 
		end
		
		dot_damage[603]		= { Round(dps / 100) / 10, tick_every, c }
	end,
	function()
		local mastery, haste, crit, spd = GetMastery(), UnitSpellHaste("player"), GetSpellCritChance(6), GetSpellBonusDamage(6)
		if crit > 100 then crit = 100 end
	
		damage_bonus 		= (1 + crit / 100) * (1 + (mastery + 1) / 100)
		bonus				= (100 + mastery * 3) * 0.35 / 100

		tick_every 			= 3 / (1 + (haste / 100))
		ticks 				= Round(15 / tick_every)
		duration 			= ticks * tick_every
		damage		 		= (1980 + ticks * spd * 0.371) * damage_bonus * dmg_buff
		dps					= Round(damage / duration)
		dot_damage[348]		= { Round(dps / 100) / 10, tick_every }
		dot_damage[108686]	= { Round(dps * bonus / 100) / 10, tick_every }
	end,
}

local CombatLog = {
	function(_,_,_,event,_,source_GUID,_,_,_,dest_GUID,_,_,_, ...)
		if dest_GUID == playerGuid and DmgBuffEvents[event] then AffDots:CheckDmgBuffs() end
		if(source_GUID ~= playerGuid or (event ~= "SPELL_AURA_REFRESH" and event ~= "SPELL_AURA_APPLIED" and event ~= "SPELL_DAMAGE")) then return end

		spell = select(1, ...)
		
		if(event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REFRESH") then
			if(spell == 30108) then
				targets[dest_GUID.."30108"] = { dot_damage[30108][1], GetTime(), dot_damage[30108][2] }
			elseif(spell == corr_id or spell == 87389) then
				targets[dest_GUID..corr_id] = { dot_damage[corr_id][1], GetTime(), dot_damage[corr_id][2] }
			elseif(spell == 980) then
				targets[dest_GUID.."980"] = { dot_damage[980][1], GetTime(), dot_damage[980][2], 0 }
			end
		end
	end,
	
	function(_,_,_,event,_,source_GUID,_,_,_,dest_GUID,_,_,_, ...)
		if dest_GUID == playerGuid and DmgBuffEvents[event] then AffDots:CheckDmgBuffs() end
		if(source_GUID ~= playerGuid or (event ~= "SPELL_AURA_REFRESH" and event ~= "SPELL_AURA_APPLIED" and event ~= "SPELL_DAMAGE")) then return end

		spell = select(1, ...)
		if(event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REFRESH") then
			if(spell == corr_id) then
				targets[dest_GUID..corr_id] = {dot_damage[corr_id][1],GetTime(),dot_damage[corr_id][2]}
			elseif(spell == 603) then
				targets[dest_GUID.."603"] = {dot_damage[603][1],GetTime(),dot_damage[603][2],dot_damage[603][3]}
			end
		elseif(event == "SPELL_DAMAGE" and spell == 103964) then
			targets[dest_GUID..corr_id] = {dot_damage[corr_id][1],GetTime(),dot_damage[corr_id][2]}
		end
	end,
	
	function(_,_,_,event,_,source_GUID,_,_,_,dest_GUID,_,_,_, ...)
		if dest_GUID == playerGuid and DmgBuffEvents[event] then AffDots:CheckDmgBuffs() end
		if(source_GUID ~= playerGuid or (event ~= "SPELL_AURA_REFRESH" and event ~= "SPELL_AURA_APPLIED" and event ~= "SPELL_DAMAGE")) then return end

		spell = select(1, ...)
		if(event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REFRESH") then
			if(spell == 348) then
				targets[dest_GUID.."348"] = {dot_damage[348][1],GetTime(),dot_damage[348][2]}
			elseif(spell == 108686) then
				targets[dest_GUID.."108686"] = {dot_damage[108686][1],GetTime(),dot_damage[108686][2]}
			end
		end
	end,
}

function AffDots:InitSpec()
	local extend = 1

	AffDots:ReleaseFrames()
	wipe(AffDots.track)

	if spec == 1 then
		AffDots.execute_percent = 20;

		AffDots:Track(corr_id, AffDots.Update.dot, "target", 27 * extend, 9 * extend, options.aff.corr, true)
		AffDots:Track(980, AffDots.Update.dot, "target", 36 * extend, 12 * extend, options.aff.agony, true)
		AffDots:Track(30108, AffDots.Update.dot, "target", 21 * extend, 7 * extend, options.aff.ua, true)
		AffDots:Track(48181, AffDots.Update.haunt, "target", 8, 1.5, options.aff.haunt, options.aff.show_haunt)
		AffDots:Track(0, AffDots.Update.hp, "target", 0, 0, 0, options.hp)
		AffDots:Track(0, AffDots.Update.coe, "target", 0, 0, 1, options.coe)
		AffDots:Track(0, AffDots.Update.sl, "target", 0, 0, 2, options.sl)
		
		if options.focus then
			AffDots:Track(corr_id, AffDots.Update.dot, "focus", 27 * extend, 9 * extend, options.aff.corr, true)
			AffDots:Track(980, AffDots.Update.dot, "focus", 36 * extend, 12 * extend, options.aff.agony, true)
			AffDots:Track(30108, AffDots.Update.dot, "focus", 21 * extend, 7 * extend, options.aff.ua, true)
			AffDots:Track(0, AffDots.Update.hp, "focus", 0, 0, 0, options.hp)
			AffDots:Track(0, AffDots.Update.coe, "focus", 0, 0, 1, options.coe)
		end
	elseif spec == 2 then
		AffDots.execute_percent = 25;
		
		AffDots:Track(corr_id, AffDots.Update.dot, "target",	27*extend, 9*extend, options.demo.corr, true)
		AffDots:Track(603, AffDots.Update.doom, "target",	90*extend, 30*extend, options.demo.doom, true)
		AffDots:Track(105174, AffDots.Update.hog, "target", 6, 2, options.demo.hog, options.demo.show_hog)
		AffDots:Track(104315, AffDots.Update.df, "target", 0, 0, options.demo.df, options.demo.show_df, true)
		AffDots:Track(0, AffDots.Update.hp, "target", 0, 0, 0, options.hp)
		AffDots:Track(0, AffDots.Update.coe, "target", 0, 0, 1, options.coe)
		AffDots:Track(0, AffDots.Update.sl, "target", 0, 0, 2, options.sl)

		if options.focus then
			AffDots:Track(corr_id, AffDots.Update.dot, "focus", 27*extend, 9*extend, options.demo.corr, true)
			AffDots:Track(603, AffDots.Update.doom, "focus", 90*extend, 30*extend, options.demo.doom, true)
			AffDots:Track(0, AffDots.Update.hp, "focus", 0, 0, 0, options.hp)
			AffDots:Track(0, AffDots.Update.coe, "focus", 0, 0, 1, options.coe)
		end
	elseif spec == 3 then
		AffDots.execute_percent = 20;

		AffDots:Track(348, AffDots.Update.immo, "target", 22.5, 7.5, options.destro.immo, true)
		AffDots:Track(17962, AffDots.Update.conflag, "target", 12, 0, options.destro.conflag, options.destro.show_conflag)
		AffDots:Track(108647, AffDots.Update.embers, "target", 40, 0, options.destro.embers, options.destro.show_embers, true)
		AffDots:Track(5740, AffDots.Update.rof, "target", 7, 0, options.destro.rof, options.destro.show_rof)
		AffDots:Track(80240, AffDots.Update.havoc, "target", 25, 10,	options.destro.havoc, options.destro.show_havoc, true)
		AffDots:Track(117896, AffDots.Update.draft, "target", 0, 0, options.destro.backdraft, options.destro.show_backdraft, true)
		AffDots:Track(0, AffDots.Update.hp, "target", 0, 0, 0, options.hp)
		AffDots:Track(0, AffDots.Update.coe, "target", 0, 0, 1, options.coe)
		AffDots:Track(0, AffDots.Update.sl, "target", 0, 0, 2, options.sl)

		if options.focus then
			AffDots:Track(348, AffDots.Update.immo, "focus", 22.5, 7.5, options.destro.immo, true)
			AffDots:Track(0, AffDots.Update.hp, "focus", 0, 0, 0, options.hp)
			AffDots:Track(0, AffDots.Update.coe, "focus", 0, 0, 1, options.coe)
		end
	end

	AffDots:InitFrames()
end

function AffDots:InitializeClass()
	spells.immoIcon		= select(3, GetSpellInfo(348))
	spells.fnbImmoIcon	= select(3, GetSpellInfo(108686))

	AffDots:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	AffDots:UnregisterEvent("COMBAT_RATING_UPDATE")
	AffDots:UnregisterEvent("SPELL_POWER_CHANGED")
	AffDots:UnregisterEvent("UNIT_STATS")
	AffDots:UnregisterEvent("PLAYER_DAMAGE_DONE_MODS")
	AffDots:UnregisterEvent("PLAYER_REGEN_ENABLED")
	AffDots:UnregisterEvent("PLAYER_REGEN_DISABLED")
	AffDots:UnregisterEvent("PLAYER_FOCUS_CHANGED")
	AffDots:UnregisterEvent("MODIFIER_STATE_CHANGED")
	
	AffDotsTarget:SetScript("OnUpdate", nil)
	
	AffDotsTarget:Hide(); 
	AffDotsFocus:Hide(); 
	AffDotsBurst:Hide()
	
	spec = GetSpecialization() or ""

	if (spec == 1 and options.aff.enabled) or (spec == 2 and options.demo.enabled) or (spec == 3 and options.destro.enabled) then
		AffDots.GetDotDmg = GetDotDmg[spec]
		AffDots.CombatLog = CombatLog[spec]
		AffDots:GetDotDmg()
		
		AffDots:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "CombatLog")
		AffDots:RegisterEvent("COMBAT_RATING_UPDATE", "GetDotDmg")
		AffDots:RegisterEvent("SPELL_POWER_CHANGED", "GetDotDmg")
		AffDots:RegisterEvent("UNIT_STATS", "GetDotDmg")
		AffDots:RegisterEvent("PLAYER_DAMAGE_DONE_MODS", "GetDotDmg")
		AffDots:RegisterEvent("PLAYER_REGEN_ENABLED")
		AffDots:RegisterEvent("PLAYER_REGEN_DISABLED")
		AffDots:RegisterEvent("PLAYER_FOCUS_CHANGED")
		AffDots:RegisterEvent("MODIFIER_STATE_CHANGED")
		
		AffDotsTarget:SetScript("OnUpdate", onUpdate)
		
		AffDots:InitSpec()
	end
end

function AffDots:OnInitialize()
	playerGuid = UnitGUID("player")
	
	AffDots:DefaultOptions()
	
	self.db.RegisterCallback(self, "OnProfileChanged", "OnInitialize")
    self.db.RegisterCallback(self, "OnProfileCopied", "OnInitialize")
    self.db.RegisterCallback(self, "OnProfileReset", "OnInitialize")

	self.options = self:OptionsTable()
	
    LibStub('LibDualSpec-1.0'):EnhanceDatabase(self.db, "AffDots")
    LibStub('LibDualSpec-1.0'):EnhanceOptions(self.options.args.profile, self.db)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("AffDots", self.options)
	
	self:MigrateOptions()
	options = self.db.profile
	
	colors = { options.color1, options.color2, options.color3, options.color4, options.color5, options.color6, options.color7, options.color8, options.color9, options.color10, options.color11 }

	class = select(2, UnitClass("player"))
	spec = GetSpecialization() or ""
	
	if class ~= "WARLOCK" then
		local loaded = LoadAddOn("AffDots"..class)
		if loaded then
			AffDots:InitializeClass()
		end
	else
		AffDots:RegisterEvent("PLAYER_TALENT_UPDATE", "InitializeClass")
		AffDots:InitializeClass()
	end
end

function AffDots:OnEnable() 
	AffDots:OnInitialize()
end

function AffDots:OnDisable() 
end

function AffDots.FrameDraw() 
end

AffDots.targets = targets
AffDots.dot_damage = dot_damage