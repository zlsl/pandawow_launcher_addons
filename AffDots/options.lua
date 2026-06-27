local L = LibStub("AceLocale-3.0"):GetLocale("AffDots")

function AffDots:DefaultOptions()
	self.db = LibStub("AceDB-3.0"):New("AffDotsDB",
		{
			profile =
			{
				p = "CENTER", x = 0, y = 0, rp = "CENTER",
				focus_p = "CENTER", focus_x = 0, focus_y = -150, focus_rp = "CENTER",
				locked		= false,
				hide 		= false,
				layout 		= "horizontal",
				reltext 	= true,
				hide_text	= false,
				hide_icons	= false,
				hide_duration = false,
				focus 		= false,
				coe 		= false,
				hp 			= false,
				sl 			= false,
				color1		= {0,0.5,0},		--better, full pandemic benefit
				color2 		= {0.5,0.5,0},		--same, full pandemic benefit
				color3 		= {0.5,0.5,0},		--worse, full pandemic benefit
				color4 		= {0.2,0.2,1},		--better
				color5 		= {0.5,0,0},		--same
				color6		= {0.5,0,0},		--worse
				color7		= {0,0,0},			--no dot on target
				color8		= {0.2,0.2,0.2},	--bar background
				color9		= {0,0.5,0},		--coe/hp/haunt
				color10		= {0.5,0.5,0.5},	--tick/pandemic indicator
				color11		= {1,0.8,0},		--text color
				scale 		= 1,
				focus_scale = 0.8,
				color_switch= 1.2,
				transparency= 0.5,
				font		= "Fonts\\FRIZQT__.TTF",
				bg			= "Interface\\TARGETINGFRAME\\UI-StatusBar",
				large_text_size = 14,
				small_text_size = 10,
				color_text		= false,
				hide_ui			= false,
				aff			= {
					enabled			= true,
					show_haunt		= true,
					agony			= 0,
					corr			= 1,
					ua				= 2,
					haunt			= 3,
				},
				demo		= {
					enabled		= true,
					color1		= {0.1,0.1,0.1},
					color2		= {0.5,0.5,0},
					color3		= {0.5,0.5,0},
					color4		= {0,0,0.5},
					color5		= {0,0.5,0},
					switch1		= 200,
					switch2		= 400,
					switch3		= 600,
					switch4		= 800,
					switch5		= 1000,
					show_df		= true,
					show_hog	= true,
					corr		= 0,
					doom		= 1,
					hog			= 2,
					df			= 3,
				},
				destro		= {
					enabled		= true,
					immo		= 0,
					conflag		= 1,
					rof			= 2,
					embers		= 3,
					havoc		= 4,
					backdraft	= 5,
					show_embers	= true,
					show_conflag= true,
					show_rof	= true,
					show_havoc		= true,
					show_backdraft	= true,
					color1		= {0.1,0.1,0.1},
					color2		= {0.5,0.5,0},
					color3		= {0,0,0.5},
					color4		= {0,0.5,0},
					switch1		= 10,
					switch2		= 20,
					switch3		= 30,
					switch4		= 40,
				},
				boxes_v		= {
					icon_size		= 30,
					icon_position	=  5,
					text_position	= 45,
					h				= 40,
					w				= 80,
				},
				boxes_h		= {
					icon_size		= 30,
					icon_position	= 35,
					text_position	= 12,
					h				= 70,
					w				= 40,
				},
				bars		= {
					h				= 20,
					w				= 200,
					margin			= 1,
					pandemic		= 1,
					text_position	= 0,
					proportional	= true,
					limit			= 24,
				},
				tidyplates	= {
					enable			= false,
					w				= 20,
					h				= 20,
					transparency	= 0.8,
				},
				burst		= {
					p = "CENTER", x = 0, y = 150, rp = "CENTER",
					enable			= false,
					default			= {100, 100, 100},
					switch			= 1.25,
					color			= {0,1,0},
					text			= true,
					h				= 20,
					w				= 80,
					key				= "LALT",
					mousekey		= "RightButton",
				},
			}
		}
	)
end

function AffDots:OptionsTable()
	local o = {
		type = "group",name = L["AffDots (drag here to move options frame)"],
		args = {
			lock = {
				order = 1,name = L["Lock frames"],type = "toggle",
				set = function(info,val) self.db.profile.locked = not self.db.profile.locked; AffDots:Visibility() end,
				get = function() return self.db.profile.locked end
			},
			general={
				order = 1,name = L["General"],type = "group",
				args={
					hide = {
						order = 1,name = L["Hide when not in combat"],type = "toggle", width = "full",
						set = function(info,val) self.db.profile.hide = not self.db.profile.hide; AffDots:InitFrames() end,
						get = function(info) return self.db.profile.hide end
					},
					focus = {
						order = 2,name = L["Show focus frame"],type = "toggle", width = "full",
						set = function(info,val) self.db.profile.focus = not self.db.profile.focus; AffDots:InitSpec() end,
						get = function(info) return self.db.profile.focus end
					},
					coe = {
						order = 3,name = L["Show CoE"],type = "toggle",
						set = function(info,val) self.db.profile.coe = not self.db.profile.coe; AffDots:InitSpec() end,
						get = function(info) return self.db.profile.coe end
					},
					hp = {
						order = 4,name = L["Show HP%"],type = "toggle",
						set = function(info,val) self.db.profile.hp = not self.db.profile.hp; AffDots:InitSpec() end,
						get = function(info) return self.db.profile.hp end
					},
					sl = {
						order = 5,name = L["Show Soul Leech value"],type = "toggle",
						set = function(info,val) self.db.profile.sl = not self.db.profile.sl; AffDots:InitSpec() end,
						get = function(info) return self.db.profile.sl end
					},
					spacer1 = {
						order = 6,type = "description",name="",width="full",
					},
					target_size = {
						order = 7,name = L["Target frame size"],type = "range",
						min = 0.3,max = 3,step = 0.1,softMin = 0.3,softMax=3,
						set = function(info,val) self.db.profile.scale = val; AffDots:InitFrames() end,
						get = function(info) return self.db.profile.scale end
					},
					focus_size = {
						order = 8,name = L["Focus frame size"],type = "range",
						min = 0.3,max = 3,step = 0.1,softMin = 0.3,softMax=3,
						set = function(info,val) self.db.profile.focus_scale = val; AffDots:InitFrames() end,
						get = function(info) return self.db.profile.focus_scale end
					},
					hide_icons = {
						order = 9,name = L["Hide icons"],type = "toggle",
						set = function(info,val) self.db.profile.hide_icons = not self.db.profile.hide_icons; AffDots:InitFrames() end,
						get = function(info) return self.db.profile.hide_icons end
					},
					hide_text = {
						order = 10,name = L["Hide text"],type = "toggle",
						set = function(info,val) self.db.profile.hide_text = not self.db.profile.hide_text; AffDots:InitFrames() end,
						get = function(info) return self.db.profile.hide_text end
					},
					duration = {
						order = 11,
						name = "Hide Duration",
						type = "toggle",
						
						set = function(info, value)
							self.db.profile.hide_duration = not self.db.profile.hide_duration
							AffDots:InitSpec()
						end,
						
						get = function(info) return self.db.profile.hide_duration end
					},
					spacer2 = {
						order = 12, type = "description", name = "", width = "full",
					},
					large_text = {
						order = 13, name = L["Text size"], type = "range",
						min = 10, max = 30, step = 1, softMin = 10, softMax=30,
						set = function(info,val) self.db.profile.large_text_size = val; AffDots:InitFrames() end,
						get = function(info) return self.db.profile.large_text_size end
					},
					small_text = {
						order = 14,name = L["CoE/Hp text size"],type = "range",
						min = 10,max = 30,step = 1,softMin = 10,softMax=30,
						set = function(info,val) self.db.profile.small_text_size = val; AffDots:InitFrames() end,
						get = function(info) return self.db.profile.small_text_size end
					},
					font = {
						order = 15,name = L["Font"],type = 'select',
						dialogControl = 'LSM30_Font',
						values = AffDots.SharedMedia:HashTable("font"),
						set = function(self,key) AffDots.db.profile.font = key; AffDots:InitFrames() end,
						get = function() return AffDots.db.profile.font end,
					},
					spacer3 = {
						order = 16,type = "description",name="",width="full",
					},
					color_text = {
						order = 17,name = L["Change color of text"],type = "toggle",
						set = function(info,val) self.db.profile.color_text = not self.db.profile.color_text; AffDots:InitFrames() end,
						get = function(info) return self.db.profile.color_text end
					},
					text_type = {
						order = 18,name = L["Relative values"],type = "toggle",
						set = function(info,val) self.db.profile.reltext = not self.db.profile.reltext end,
						get = function(info) return self.db.profile.reltext end
					},
					hide_ui = {
						order = 19,name = L["Hide UI"],type = "toggle",
						set = function(info,val) 
							self.db.profile.hide_ui = not self.db.profile.hide_ui; 
							AffDots:InitFrames() 
						end,
						get = function(info) 
							return self.db.profile.hide_ui 
						end
					},
				}
			},
			spec={
				order = 2,name = "Specialization",type = "group",
				args={}
			},
			colors={
				order = 3,name = L["Colors"],type = "group",
				args={
					color1 = {
						order = 1,width = "full",name = L["Current stats are better, full Pandemic benefit"],type = "color",
						set = function(info,r,g,b) self.db.profile.color1={r,g,b}; self:SaveColors() end,
						get = function(info) return self.db.profile.color1[1],self.db.profile.color1[2],self.db.profile.color1[3],1 end
					},
					color2 = {
						order = 2,width = "full",name = L["Current stats are same, full Pandemic benefit"],type = "color",
						set = function(info,r,g,b) self.db.profile.color2={r,g,b}; self:SaveColors()  end,
						get = function(info) return self.db.profile.color2[1],self.db.profile.color2[2],self.db.profile.color2[3],1 end
					},
					color3 = {
						order = 3,width = "full",name = L["Current stats are worse, full Pandemic benefit"],type = "color",
						set = function(info,r,g,b) self.db.profile.color3={r,g,b}; self:SaveColors()  end,
						get = function(info) return self.db.profile.color3[1],self.db.profile.color3[2],self.db.profile.color3[3],1 end
					},
					color4 = {
						order = 4,width = "full",name = L["Current stats are better, partial Pandemic benefit"],type = "color",
						set = function(info,r,g,b) self.db.profile.color4={r,g,b}; self:SaveColors()  end,
						get = function(info) return self.db.profile.color4[1],self.db.profile.color4[2],self.db.profile.color4[3],1 end
					},
					color5 = {
						order = 5,width = "full",name = L["Current stats are same, partial Pandemic benefit"],type = "color",
						set = function(info,r,g,b) self.db.profile.color5={r,g,b}; self:SaveColors()  end,
						get = function(info) return self.db.profile.color5[1],self.db.profile.color5[2],self.db.profile.color5[3],1 end
					},
					color6 = {
						order = 6,width = "full",name = L["Current stats are worse, partial Pandemic benefit"],type = "color",
						set = function(info,r,g,b) self.db.profile.color6={r,g,b}; self:SaveColors()  end,
						get = function(info) return self.db.profile.color6[1],self.db.profile.color6[2],self.db.profile.color6[3],1 end
					},
					color7 = {
						order = 7,width = "full",name = L["No dot on target"],type = "color",
						set = function(info,r,g,b) self.db.profile.color7={r,g,b}; self:SaveColors()  end,
						get = function(info) return self.db.profile.color7[1],self.db.profile.color7[2],self.db.profile.color7[3],1 end
					},
					color9 = {
						order = 8,width = "full",name = L["CoE/Hp/Haunt color"],type = "color",
						set = function(info,r,g,b) self.db.profile.color9={r,g,b}; self:SaveColors()  end,
						get = function(info) return self.db.profile.color9[1],self.db.profile.color9[2],self.db.profile.color9[3],1 end
					},
					text_color = {
						order = 9,width = "full",name = L["Text color"],type = "color",
						set = function(info,r,g,b) self.db.profile.color11={r,g,b} end,
						get = function(info) return self.db.profile.color11[1],self.db.profile.color11[2],self.db.profile.color11[3],1 end
					},
					color_switch = {
						order = 10,name = L["Color switch"],type = "range",
						desc = L["When refresh will not recieve full Pandemic benefit,\nswitch color only if current stats are at least x% better"],
						min = 0,max = 40,step = 1,softMin = 0,softMax=40,
						set = function(info,val) self.db.profile.color_switch = 1+val/100 end,
						get = function(info) return (self.db.profile.color_switch-1)*100 end
					},
					transparency = {
						order = 11,name = L["Transparency"],type = "range",
						min = 0,max = 1,step = 0.1,softMin = 0,softMax=1,
						set = function(info,val) self.db.profile.transparency = val; AffDots:InitFrames() end,
						get = function(info) return self.db.profile.transparency end
					},
				}
			},
			layout={
				order = 4,name = L["Layout"],type = "group",
				args={}
			},
			tidy_plates={
				order = 5,name = L["TidyPlates"],type = "group",
				args={
					enable = {
						order = 1,name = L["Integrate dot colors in TidyPlates"],type = "toggle",width = "full",
						set = function(info,val) self.db.profile.tidyplates.enable = not self.db.profile.tidyplates.enable end,
						get = function(info) return self.db.profile.tidyplates.enable end
					},
					width = {
						order = 2,name = L["Width"],type = "range",width = "full",
						min = 10,max = 30,step = 1,softMin = 10,softMax=30,
						set = function(info,val) self.db.profile.tidyplates.w = val end,
						get = function(info) return self.db.profile.tidyplates.w end
					},
					heigth = {
						order = 5,name = L["Height"],type = "range",width = "full",
						min = 10,max = 30,step = 1,softMin = 10,softMax=30,
						set = function(info,val) self.db.profile.tidyplates.h = val end,
						get = function(info) return self.db.profile.tidyplates.h end
					},
					transparency = {
						order = 7,name = L["Transparency"],type = "range",width = "full",
						min = 0,max = 100,step = 10,softMin = 0,softMax=100,
						set = function(info,val) self.db.profile.tidyplates.transparency = val/100 end,
						get = function(info) return self.db.profile.tidyplates.transparency*100 end
					},
					desc = {
						order = 8,name = L["tidydesc"],type = "description",fontSize="medium"
					},
				}
			},
			burst={
				order = 6, name = L["Burst"], type = "group",
				args={
					desc = {
						order = 1,name = L["burstdesc"],type = "description",fontSize="medium"
					},
					enable = {
						order = 2,name = L["Enable"],type = "toggle",width = "full",
						set = function(info,val) self.db.profile.burst.enable = not self.db.profile.burst.enable;  AffDots:InitFrames() end,
						get = function(info) return self.db.profile.burst.enable end
					},
					current = {
						order = 3,name = L["Set current as baseline"],type = "execute",width = "full",
						func = function()
							AffDots:BurstDefaults()
						end,
					},
					switch = {
						order = 4,name = L["Damage increase needed to change color (percent)"],type = "range",width = "full",
						min = 10,max = 100,step = 1,softMin = 10,softMax=100,
						set = function(info,val) self.db.profile.burst.switch = 1+val/100; AffDots:InitFrames() end,
						get = function(info) return (self.db.profile.burst.switch-1)*100 end
					},
					color = {
						order = 5,name = L["Color"],type = "color",
						set = function(info,r,g,b) self.db.profile.burst.color={r,g,b} end,
						get = function(info) return self.db.profile.burst.color[1],self.db.profile.burst.color[2],self.db.profile.burst.color[3],1 end
					},
					text = {
						order = 6,name = L["Show text"],type = "toggle",
						set = function(info,val) self.db.profile.burst.text = not self.db.profile.burst.text; AffDots:InitFrames() end,
						get = function(info) return self.db.profile.burst.text end
					},
					height = {
						order = 7,name = L["Height"],type = "range",
						min = 10,max = 100,step = 1,softMin = 10,softMax=100,
						set = function(info,val) self.db.profile.burst.h = val; AffDots:InitFrames() end,
						get = function(info) return self.db.profile.burst.h end
					},
					width = {
						order = 8,name = L["Width"],type = "range",
						min = 10,max = 200,step = 1,softMin = 10,softMax=200,
						set = function(info,val) self.db.profile.burst.w = val; AffDots:InitFrames() end,
						get = function(info) return self.db.profile.burst.w end
					},
					desc2 = {
						order = 9,name = L["\nTo quickly set baseline values, press the following key combination on Burst frame:"],type = "description",fontSize="medium"
					},
					key = {
						order = 10,name = L["Key"],type = "select",
						values = {LSHIFT=L["Left SHIFT"],RSHIFT = L["Right SHIFT"],LCTRL = L["Left CTRL"],RCTRL = L["Right CTRL"],LALT = L["Left ALT"],RALT = L["Right ALT"]},
						set = function(info, val) self.db.profile.burst.key = val end,
						get = function(info) return self.db.profile.burst.key end
					},
					mousekey = {
						order = 11,name = L["Mouse button"],type = "select",
						values = {RightButton = L["Right mouse button"]},
						set = function(info, val) self.db.profile.burst.mousekey = val end,
						get = function(info) return self.db.profile.burst.mousekey end
					},
					desc3 = {
						order = 12,name = L["Burst frame for other classes: www.curse.com/addons/wow/mesmash"],type = "description",fontSize="medium"
					},
				}
			},
			profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db),
		}
	}
	return o
end

function AffDots:GetLayoutOptions()
	if self.db.profile.layout == "horizontal" then
		self.options.args.layout.args = {
				layout = {
					order = 1,name = L["Layout"],type = "select",
					values = {horizontal = L["Horizontal"], vertical = L["Vertical"], bars = L["Bars"]},
					set = function(info,val) self.db.profile.layout = val; AffDots:InitFrames(); AffDots:GetLayoutOptions() end,
					get = function(info) return self.db.profile.layout end
				},
				spacer1 = {
					order = 2,type = "description",name="",width="full",
				},
				icon_size = {
					order = 3,name = L["Icon size"],type = "range",
					min = 10,max = 60,step = 1,softMin = 10,softMax=60,
					set = function(info,val) self.db.profile.boxes_h.icon_size = val; AffDots:InitFrames() end,
					get = function(info) return self.db.profile.boxes_h.icon_size end
				},
				icon_position = {
					order = 4,name = L["Icon position"],type = "range",
					min = 0,max = 60,step = 1,softMin = 0,softMax=60,
					set = function(info,val) self.db.profile.boxes_h.icon_position = val; AffDots:InitFrames() end,
					get = function(info) return self.db.profile.boxes_h.icon_position end
				},
				x_size = {
					order = 5,name = L["Height"],type = "range",
					min = 20,max = 100,step = 1,softMin = 20,softMax=100,
					set = function(info,val) self.db.profile.boxes_h.h = val; AffDots:InitFrames() end,
					get = function(info) return self.db.profile.boxes_h.h end
				},
				y_size = {
					order = 6,name = L["Width"],type = "range",
					min = 20,max = 100,step = 1,softMin = 20,softMax=100,
					set = function(info,val) self.db.profile.boxes_h.w = val; AffDots:InitFrames() end,
					get = function(info) return self.db.profile.boxes_h.w end
				},
				text_position = {
					order = 7,name = L["Text position"],type = "range",
					min = 0,max = 100,step = 1,softMin = 0,softMax=100,
					set = function(info,val) self.db.profile.boxes_h.text_position = val; AffDots:InitFrames() end,
					get = function(info) return self.db.profile.boxes_h.text_position end
				},
			}
	elseif self.db.profile.layout == "vertical" then
		self.options.args.layout.args = {
				layout = {
					order = 1,name = L["Layout"],type = "select",
					values = {horizontal = L["Horizontal"], vertical = L["Vertical"], bars = L["Bars"]},
					set = function(info,val) self.db.profile.layout = val; AffDots:InitFrames(); AffDots:GetLayoutOptions() end,
					get = function(info) return self.db.profile.layout end
				},
				spacer1 = {
					order = 2,type = "description",name="",width="full",
				},
				icon_size = {
					order = 3,name = L["Icon size"],type = "range",
					min = 10,max = 60,step = 1,softMin = 10,softMax=60,
					set = function(info,val) self.db.profile.boxes_v.icon_size = val; AffDots:InitFrames() end,
					get = function(info) return self.db.profile.boxes_v.icon_size end
				},
				icon_position = {
					order = 4,name = L["Icon position"],type = "range",
					min = 0,max = 60,step = 1,softMin = 0,softMax=60,
					set = function(info,val) self.db.profile.boxes_v.icon_position = val; AffDots:InitFrames() end,
					get = function(info) return self.db.profile.boxes_v.icon_position end
				},
				text_position = {
					order = 6,name = L["Text position"],type = "range",
					min = 0,max = 100,step = 1,softMin = 0,softMax=100,
					set = function(info,val) self.db.profile.boxes_v.text_position = val; AffDots:InitFrames() end,
					get = function(info) return self.db.profile.boxes_v.text_position end
				},
				x_size = {
					order = 7,name = L["Width"],type = "range",
					min = 20,max = 100,step = 1,softMin = 20,softMax=100,
					set = function(info,val) self.db.profile.boxes_v.h = val; AffDots:InitFrames() end,
					get = function(info) return self.db.profile.boxes_v.h end
				},
				y_size = {
					order = 8,name = L["Height"],type = "range",
					min = 20,max = 100,step = 1,softMin = 20,softMax=100,
					set = function(info,val) self.db.profile.boxes_v.w = val; AffDots:InitFrames() end,
					get = function(info) return self.db.profile.boxes_v.w end
				},
			}
	elseif self.db.profile.layout == "bars" then
		self.options.args.layout.args = {
				layout = {
					order = 1,name = L["Layout"],type = "select",
					values = {horizontal = L["Horizontal"], vertical = L["Vertical"], bars = L["Bars"]},
					set = function(info,val) self.db.profile.layout = val; AffDots:InitFrames(); AffDots:GetLayoutOptions() end,
					get = function(info) return self.db.profile.layout end
				},
				spacer1 = {
					order = 2,type = "description",name="",width="full",
				},
				text_position = {
					order = 5,name = L["Text position"],type = "range",
					min = -50,max = 50,step = 1,softMin = -50,softMax=50,
					set = function(info,val) self.db.profile.bars.text_position = val; AffDots:InitFrames() end,
					get = function(info) return self.db.profile.bars.text_position end
				},
				bar_height = {
					order = 7,name = L["Height"],type = "range",
					min = 10,max = 100,step = 1,softMin = 10,softMax=100,
					set = function(info,val) self.db.profile.bars.h = val; AffDots:InitFrames() end,
					get = function(info) return self.db.profile.bars.h end
				},
				bar_width = {
					order = 8,name = L["Width"],type = "range",
					min = 100,max = 500,step = 1,softMin = 100,softMax=500,
					set = function(info,val) self.db.profile.bars.w = val; AffDots:InitFrames() end,
					get = function(info) return self.db.profile.bars.w end
				},
				margin = {
					order = 9,name = L["Spacing"],type = "range",
					min = 0,max = 10,step = 1,softMin = 0,softMax=10,
					set = function(info,val) self.db.profile.bars.margin = val; AffDots:InitFrames() end,
					get = function(info) return self.db.profile.bars.margin end
				},
				bg = {
					order = 10,type = 'select',name = L["Background"],
					dialogControl = 'LSM30_Statusbar',
					values = AffDots.SharedMedia:HashTable("statusbar"),
					set = function(self,key) AffDots.db.profile.bg = key; AffDots:InitFrames() end,
					get = function() return AffDots.db.profile.bg end,
				},
				color8 = {
					order = 11,name = L["Background color"],type = "color",
					set = function(info,r,g,b) self.db.profile.color8={r,g,b}; self:SaveColors(); AffDots:InitFrames() end,
					get = function(info) return self.db.profile.color8[1],self.db.profile.color8[2],self.db.profile.color8[3],1 end
				},
				proportional = {
					order = 13,name = L["Enable proportional bars"],type = "toggle",width = "full",
					desc = L["All bars will move at the same speed"],
					set = function(info,val) self.db.profile.bars.proportional = not self.db.profile.bars.proportional; AffDots:InitFrames() end,
					get = function(info) return self.db.profile.bars.proportional end
				},
				proportional_limit = {
					order = 14,name = L["Proportional bars time limit"],type = "range",
					desc = L["Maximum numbers of seconds to display in proportional bar"],
					min = 20,max = 40,step = 1,softMin = 20,softMax=40,
					set = function(info,val) self.db.profile.bars.limit = val; AffDots:InitFrames() end,
					get = function(info) return self.db.profile.bars.limit end
				},
			}
	else
		self.options.args.layout.args = {}
	end
end

function AffDots:GetSpecOptions(spec)
	if spec == "WARLOCK1" then
		self.options.args.spec.name = L["Affliction"]
		self.options.args.spec.args = {
			affliction = {
				order = 1,name = L["Enable"],type = "toggle",
				set = function(info,val) self.db.profile.aff.enabled = not self.db.profile.aff.enabled; AffDots:InitClass() end,
				get = function() return self.db.profile.aff.enabled end
			},
			show_haunt = {
				order = 2,name = L["Show Haunt"],type = "toggle",width = "full",
				set = function(info,val) self.db.profile.aff.show_haunt = not self.db.profile.aff.show_haunt; AffDots:InitSpec() end,
				get = function(info) return self.db.profile.aff.show_haunt end
			},
			desc = {
				order = 3,name = L["Order:"],type = "description",fontSize="medium"
			},
			agony = {
				order = 4,name = L["Agony"],type = "range",
				min = 1,max = 4,step = 1,softMin = 1,softMax=4,
				set = function(info,val) self.db.profile.aff.agony = val - 1; AffDots:InitSpec() end,
				get = function(info) return self.db.profile.aff.agony + 1 end
			},
			corr = {
				order = 5,name = L["Corruption"],type = "range",
				min = 1,max = 4,step = 1,softMin = 1,softMax=4,
				set = function(info,val) self.db.profile.aff.corr = val - 1; AffDots:InitSpec() end,
				get = function(info) return self.db.profile.aff.corr + 1 end
			},
			ua = {
				order = 6,name = L["UA"],type = "range",
				min = 1,max = 4,step = 1,softMin = 1,softMax=4,
				set = function(info,val) self.db.profile.aff.ua = val - 1; AffDots:InitSpec() end,
				get = function(info) return self.db.profile.aff.ua + 1 end
			},
			haunt = {
				order = 7,name = L["Haunt"],type = "range",
				min = 1,max = 4,step = 1,softMin = 1,softMax=4,
				set = function(info,val) self.db.profile.aff.haunt = val - 1; AffDots:InitSpec() end,
				get = function(info) return self.db.profile.aff.haunt + 1 end
			},
		}
	elseif spec == "WARLOCK2" then
		self.options.args.spec.name = L["Demonology"]
		self.options.args.spec.args = {
			demonology = {
					order = 1,name = L["Enable"],type = "toggle",
					set = function(info,val) self.db.profile.demo.enabled = not self.db.profile.demo.enabled; AffDots:InitClass() end,
					get = function() return self.db.profile.demo.enabled end
				},
			hog = {
				order = 2,name = L["Show Hand of Guldan"],type = "toggle",width = "full",
				set = function(info,val) self.db.profile.demo.show_hog = not self.db.profile.demo.show_hog; AffDots:InitSpec() end,
				get = function(info) return self.db.profile.demo.show_hog end
			},
			df = {
				order = 3,name = L["Show Demonic Fury"],type = "toggle",width = "full",
				set = function(info,val) self.db.profile.demo.show_df = not self.db.profile.demo.show_df; AffDots:InitSpec() end,
				get = function(info) return self.db.profile.demo.show_df end
			},
			desc = {
				order = 4,name = L["Order:"],type = "description",fontSize="medium"
			},
			corr = {
				order = 5,name = L["Corruption"],type = "range",
				min = 1,max = 4,step = 1,softMin = 1,softMax=4,
				set = function(info,val) self.db.profile.demo.corr = val - 1; AffDots:InitSpec() end,
				get = function(info) return self.db.profile.demo.corr + 1 end
			},
			doom = {
				order = 6,name = L["Doom"],type = "range",
				min = 1,max = 4,step = 1,softMin = 1,softMax=4,
				set = function(info,val) self.db.profile.demo.doom = val - 1; AffDots:InitSpec() end,
				get = function(info) return self.db.profile.demo.doom + 1 end
			},
			show_hog = {
				order = 7,name = L["Hand of Guldan"],type = "range",
				min = 1,max = 4,step = 1,softMin = 1,softMax=4,
				set = function(info,val) self.db.profile.demo.hog = val - 1; AffDots:InitSpec() end,
				get = function(info) return self.db.profile.demo.hog + 1 end
			},
			show_df = {
				order = 8,name = L["Demonic Fury"],type = "range",
				min = 1,max = 4,step = 1,softMin = 1,softMax=4,
				set = function(info,val) self.db.profile.demo.df = val - 1; AffDots:InitSpec() end,
				get = function(info) return self.db.profile.demo.df + 1 end
			},
			switch1 = {
				order = 9,name = L["Demonic Fury <="],type = "range",
				min = 1,max = 1000,step = 1,softMin = 1,softMax=1000,
				set = function(info,val) self.db.profile.demo.switch1=val end,
				get = function(info) return self.db.profile.demo.switch1 end
			},
			color1 = {
				order = 10,name = "",type = "color",
				set = function(info,r,g,b) self.db.profile.demo.color1={r,g,b} end,
				get = function(info) return self.db.profile.demo.color1[1],self.db.profile.demo.color1[2],self.db.profile.demo.color1[3],1 end
			},
			switch2 = {
				order = 11,name = L["Demonic Fury <="],type = "range",
				min = 1,max = 1000,step = 1,softMin = 1,softMax=1000,
				set = function(info,val) self.db.profile.demo.switch2=val end,
				get = function(info) return self.db.profile.demo.switch2 end
			},
			color2 = {
				order = 12,name = "",type = "color",
				set = function(info,r,g,b) self.db.profile.demo.color2={r,g,b} end,
				get = function(info) return self.db.profile.demo.color2[1],self.db.profile.demo.color2[2],self.db.profile.demo.color2[3],1 end
			},
			switch3 = {
				order = 13,name = L["Demonic Fury <="],type = "range",
				min = 1,max = 1000,step = 1,softMin = 1,softMax=1000,
				set = function(info,val) self.db.profile.demo.switch3=val end,
				get = function(info) return self.db.profile.demo.switch3 end
			},
			color3 = {
				order = 14,name = "",type = "color",
				set = function(info,r,g,b) self.db.profile.demo.color3={r,g,b} end,
				get = function(info) return self.db.profile.demo.color3[1],self.db.profile.demo.color3[2],self.db.profile.demo.color3[3],1 end
			},
			switch4 = {
				order = 15,name = L["Demonic Fury <="],type = "range",
				min = 1,max = 1000,step = 1,softMin = 1,softMax=1000,
				set = function(info,val) self.db.profile.demo.switch4=val end,
				get = function(info) return self.db.profile.demo.switch4 end
			},
			color4 = {
				order = 16,name = "",type = "color",
				set = function(info,r,g,b) self.db.profile.demo.color4={r,g,b} end,
				get = function(info) return self.db.profile.demo.color4[1],self.db.profile.demo.color4[2],self.db.profile.demo.color4[3],1 end
			},
			switch5 = {
				order = 17,name = L["Demonic Fury <="],type = "range",
				min = 1,max = 1000,step = 1,softMin = 1,softMax=1000,
				set = function(info,val) self.db.profile.demo.switch5=val end,
				get = function(info) return self.db.profile.demo.switch5 end
			},
			color5 = {
				order = 18,name = "",type = "color",
				set = function(info,r,g,b) self.db.profile.demo.color5={r,g,b} end,
				get = function(info) return self.db.profile.demo.color5[1],self.db.profile.demo.color5[2],self.db.profile.demo.color5[3],1 end
			},
		}
	elseif spec == "WARLOCK3" then
		self.options.args.spec.name = L["Destruction"]
		self.options.args.spec.args = {
			destruction = {
				order = 1,name = L["Enable"],type = "toggle",
				set = function(info,val) self.db.profile.destro.enabled = not self.db.profile.destro.enabled; AffDots:InitClass() end,
				get = function() return self.db.profile.destro.enabled end
			},
			show_conflag = {
				order = 2,name = L["Show Conflagrate"],type = "toggle",width = "full",
				set = function(info,val) self.db.profile.destro.show_conflag = not self.db.profile.destro.show_conflag; AffDots:InitSpec() end,
				get = function(info) return self.db.profile.destro.show_conflag end
			},
			show_rof = {
				order = 3,name = L["Show Rain of Fire"],type = "toggle",width = "full",
				set = function(info,val) self.db.profile.destro.show_rof = not self.db.profile.destro.show_rof; AffDots:InitSpec() end,
				get = function(info) return self.db.profile.destro.show_rof end
			},
			show_embers = {
				order = 4,name = L["Show Burning Embers"],type = "toggle",width = "full",
				set = function(info,val) self.db.profile.destro.show_embers = not self.db.profile.destro.show_embers; AffDots:InitSpec() end,
				get = function(info) return self.db.profile.destro.show_embers end
			},
			show_havoc = {
				order = 5,name = L["Show Havoc"],type = "toggle",width = "full",
				set = function(info,val) self.db.profile.destro.show_havoc = not self.db.profile.destro.show_havoc; AffDots:InitSpec() end,
				get = function(info) return self.db.profile.destro.show_havoc end
			},
			show_backdraft = {
				order = 6,name = L["Show Backdraft"],type = "toggle",width = "full",
				set = function(info,val) self.db.profile.destro.show_backdraft = not self.db.profile.destro.show_backdraft; AffDots:InitSpec() end,
				get = function(info) return self.db.profile.destro.show_backdraft end
			},
			desc1 = {
				order = 7, name = L["Order:"],type = "description",fontSize="medium"
			},
			immo = {
				order = 8,name = L["Immolate"],type = "range",
				min = 1,max = 6,step = 1,softMin = 1,softMax=6,
				set = function(info,val) self.db.profile.destro.immo = val - 1; AffDots:InitSpec() end,
				get = function(info) return self.db.profile.destro.immo + 1 end
			},
			conflag = {
				order = 9,name = L["Conflagrate"],type = "range",
				min = 1,max = 6,step = 1,softMin = 1,softMax=6,
				set = function(info,val) self.db.profile.destro.conflag = val - 1; AffDots:InitSpec() end,
				get = function(info) return self.db.profile.destro.conflag + 1 end
			},
			rof = {
				order = 10,name = L["Rain of Fire"],type = "range",
				min = 1,max = 6,step = 1,softMin = 1,softMax=6,
				set = function(info,val) self.db.profile.destro.rof = val - 1; AffDots:InitSpec() end,
				get = function(info) return self.db.profile.destro.rof + 1 end
			},
			embers = {
				order = 11,name = L["Burning Embers"],type = "range",
				min = 1,max = 6,step = 1,softMin = 1,softMax=6,
				set = function(info,val) self.db.profile.destro.embers = val - 1; AffDots:InitSpec() end,
				get = function(info) return self.db.profile.destro.embers + 1 end
			},
			havoc = {
				order = 12,name = L["Havoc"],type = "range",
				min = 1,max = 6,step = 1,softMin = 1,softMax=6,
				set = function(info,val) self.db.profile.destro.havoc = val - 1; AffDots:InitSpec() end,
				get = function(info) return self.db.profile.destro.havoc + 1 end
			},
			backdraft = {
				order = 13,name = L["Backdraft"],type = "range",
				min = 1,max = 6,step = 1,softMin = 1,softMax=6,
				set = function(info,val) self.db.profile.destro.backdraft = val - 1; AffDots:InitSpec() end,
				get = function(info) return self.db.profile.destro.backdraft + 1 end
			},
			desc2 = {
				order = 14,name = L["Colors for Burning Embers:"],type = "description",fontSize="medium",width="full",
			},
			switch1 = {
				order = 15,name = L["Burning Embers <="],type = "range",
				min = 1,max = 40,step = 1,softMin = 1,softMax=40,
				set = function(info,val) self.db.profile.destro.switch1=val end,
				get = function(info) return self.db.profile.destro.switch1 end
			},
			color1 = {
				order = 16,name = "",type = "color",
				set = function(info,r,g,b) self.db.profile.destro.color1={r,g,b} end,
				get = function(info) return self.db.profile.destro.color1[1],self.db.profile.destro.color1[2],self.db.profile.destro.color1[3],1 end
			},
			switch2 = {
				order = 17,name = L["Burning Embers <="],type = "range",
				min = 1,max = 40,step = 1,softMin = 1,softMax=40,
				set = function(info,val) self.db.profile.destro.switch2=val end,
				get = function(info) return self.db.profile.destro.switch2 end
			},
			color2 = {
				order = 18,name = "",type = "color",
				set = function(info,r,g,b) self.db.profile.destro.color2={r,g,b} end,
				get = function(info) return self.db.profile.destro.color2[1],self.db.profile.destro.color2[2],self.db.profile.destro.color2[3],1 end
			},
			switch3 = {
				order = 19,name = L["Burning Embers <="],type = "range",
				min = 1,max = 40,step = 1,softMin = 1,softMax=40,
				set = function(info,val) self.db.profile.destro.switch3=val end,
				get = function(info) return self.db.profile.destro.switch3 end
			},
			color3 = {
				order = 20,name = "",type = "color",
				set = function(info,r,g,b) self.db.profile.destro.color3={r,g,b} end,
				get = function(info) return self.db.profile.destro.color3[1],self.db.profile.destro.color3[2],self.db.profile.destro.color3[3],1 end
			},
			switch4 = {
				order = 21,name = L["Burning Embers <="],type = "range",
				min = 1,max = 40,step = 1,softMin = 1,softMax=40,
				set = function(info,val) self.db.profile.destro.switch4=val end,
				get = function(info) return self.db.profile.destro.switch4 end
			},
			color4 = {
				order = 22,name = "",type = "color",
				set = function(info,r,g,b) self.db.profile.destro.color4={r,g,b} end,
				get = function(info) return self.db.profile.destro.color4[1],self.db.profile.destro.color4[2],self.db.profile.destro.color4[3],1 end
			},
		}
	else
		self.options.args.spec.name = "Specialization"
		self.options.args.spec.args = {
			spacer1 = {
				order = 1,type = "description",name="Specialization not supported, AffDots deactivated", width="full",
			},
		}
	end
end

function AffDots:MigrateOptions()
	--Delete this function after a couple of versions
	if not AffDotsOptions110 or AffDotsOptions110.settings_copied or AffDotsOptions110.version_num ~= 12004 then return end
	
	if AffDotsOptions110.p then
	self.db.profile.p						= AffDotsOptions110.p
	self.db.profile.x						= AffDotsOptions110.x
	self.db.profile.y						= AffDotsOptions110.y
	self.db.profile.rp						= AffDotsOptions110.rp
	end
	if AffDotsOptions110.focus_p then
	self.db.profile.focus_p					= AffDotsOptions110.focus_p
	self.db.profile.focus_x					= AffDotsOptions110.focus_x
	self.db.profile.focus_y					= AffDotsOptions110.focus_y
	self.db.profile.focus_rp				= AffDotsOptions110.focus_rp
	end
	if AffDotsOptions110.burst.p then
	self.db.profile.burst.p					= AffDotsOptions110.burst.p
	self.db.profile.burst.x					= AffDotsOptions110.burst.x
	self.db.profile.burst.y					= AffDotsOptions110.burst.y
	self.db.profile.burst.rp				= AffDotsOptions110.burst.rp
	end
	
	self.db.profile.locked					= AffDotsOptions110.locked
	self.db.profile.aff.enabled				= AffDotsOptions110.affliction
	self.db.profile.demo.enabled 			= AffDotsOptions110.demonology
	self.db.profile.destro.enabled			= AffDotsOptions110.destruction
	self.db.profile.hide 					= AffDotsOptions110.hide
	self.db.profile.layout 					= AffDotsOptions110.layout
	self.db.profile.reltext 				= AffDotsOptions110.reltext
	self.db.profile.hide_text 				= AffDotsOptions110.hide_text
	self.db.profile.hide_icons 				= AffDotsOptions110.hide_icons
	self.db.profile.focus 					= AffDotsOptions110.focus
	self.db.profile.coe 					= AffDotsOptions110.coe
	self.db.profile.hp 						= AffDotsOptions110.hp
	self.db.profile.color1			 		= AffDotsOptions110.color1
	self.db.profile.color2 					= AffDotsOptions110.color2
	self.db.profile.color3 					= AffDotsOptions110.color3
	self.db.profile.color4 					= AffDotsOptions110.color4
	self.db.profile.color5 					= AffDotsOptions110.color5
	self.db.profile.color6 					= AffDotsOptions110.color6
	self.db.profile.color7 					= AffDotsOptions110.color7
	self.db.profile.color8 					= AffDotsOptions110.color8
	self.db.profile.color9 					= AffDotsOptions110.color9
	self.db.profile.color10					= AffDotsOptions110.color10
	self.db.profile.color11 				= AffDotsOptions110.text_color
	self.db.profile.scale 					= AffDotsOptions110.scale
	self.db.profile.focus_scale 			= AffDotsOptions110.focus_scale
	self.db.profile.color_switch			= AffDotsOptions110.color_switch
	self.db.profile.transparency			= AffDotsOptions110.transparency
	self.db.profile.font 					= AffDotsOptions110.font
	self.db.profile.bg 						= AffDotsOptions110.bg
	self.db.profile.large_text_size 		= AffDotsOptions110.large_text_size
	self.db.profile.small_text_size 		= AffDotsOptions110.small_text_size
	self.db.profile.color_text				= AffDotsOptions110.color_text
	self.db.profile.aff.show_haunt 			= AffDotsOptions110.aff.show_haunt
	self.db.profile.aff.agony 				= AffDotsOptions110.aff.agony
	self.db.profile.aff.corr				= AffDotsOptions110.aff.corr
	self.db.profile.aff.ua 					= AffDotsOptions110.aff.ua
	self.db.profile.aff.haunt 				= AffDotsOptions110.aff.haunt
	self.db.profile.demo.color1 			= AffDotsOptions110.demo.color1
	self.db.profile.demo.color2				= AffDotsOptions110.demo.color2
	self.db.profile.demo.color3				= AffDotsOptions110.demo.color3
	self.db.profile.demo.color4				= AffDotsOptions110.demo.color4
	self.db.profile.demo.color5				= AffDotsOptions110.demo.color5
	self.db.profile.demo.switch1 			= AffDotsOptions110.demo.switch1
	self.db.profile.demo.switch2 			= AffDotsOptions110.demo.switch2
	self.db.profile.demo.switch3 			= AffDotsOptions110.demo.switch3
	self.db.profile.demo.switch4 			= AffDotsOptions110.demo.switch4
	self.db.profile.demo.switch5 			= AffDotsOptions110.demo.switch5
	self.db.profile.demo.show_df 			= AffDotsOptions110.demo.show_df
	self.db.profile.demo.show_hog 			= AffDotsOptions110.demo.show_hog
	self.db.profile.demo.corr 				= AffDotsOptions110.demo.corr
	self.db.profile.demo.doom 				= AffDotsOptions110.demo.doom
	self.db.profile.demo.hog 				= AffDotsOptions110.demo.hog
	self.db.profile.demo.df					= AffDotsOptions110.demo.df
	self.db.profile.destro.immo				= AffDotsOptions110.destro.immo
	self.db.profile.destro.conflag 			= AffDotsOptions110.destro.conflag
	self.db.profile.destro.rof 				= AffDotsOptions110.destro.rof
	self.db.profile.destro.embers 			= AffDotsOptions110.destro.embers
	self.db.profile.destro.show_embers 		= AffDotsOptions110.destro.show_embers
	self.db.profile.destro.show_conflag 	= AffDotsOptions110.destro.show_conflag
	self.db.profile.destro.show_rof			= AffDotsOptions110.destro.show_rof
	self.db.profile.destro.color1 			= AffDotsOptions110.destro.color1
	self.db.profile.destro.color2 			= AffDotsOptions110.destro.color2
	self.db.profile.destro.color3 			= AffDotsOptions110.destro.color3
	self.db.profile.destro.color4 			= AffDotsOptions110.destro.color4
	self.db.profile.destro.switch1 			= AffDotsOptions110.destro.switch1
	self.db.profile.destro.switch2 			= AffDotsOptions110.destro.switch2
	self.db.profile.destro.switch3 			= AffDotsOptions110.destro.switch3
	self.db.profile.destro.switch4 			= AffDotsOptions110.destro.switch4
	self.db.profile.boxes_v.icon_size 		= AffDotsOptions110.boxes_v.icon_size
	self.db.profile.boxes_v.icon_position	= AffDotsOptions110.boxes_v.icon_position
	self.db.profile.boxes_v.text_position 	= AffDotsOptions110.boxes_v.text_position
	self.db.profile.boxes_v.h 				= AffDotsOptions110.boxes_v.h
	self.db.profile.boxes_v.w 				= AffDotsOptions110.boxes_v.w
	self.db.profile.boxes_h.icon_size 		= AffDotsOptions110.boxes_h.icon_size
	self.db.profile.boxes_h.icon_position 	= AffDotsOptions110.boxes_h.icon_position
	self.db.profile.boxes_h.text_position 	= AffDotsOptions110.boxes_h.text_position
	self.db.profile.boxes_h.h 				= AffDotsOptions110.boxes_h.h
	self.db.profile.boxes_h.w 				= AffDotsOptions110.boxes_h.w
	self.db.profile.bars.h 					= AffDotsOptions110.bars.h
	self.db.profile.bars.w 					= AffDotsOptions110.bars.w
	self.db.profile.bars.margin 			= AffDotsOptions110.bars.margin
	self.db.profile.bars.pandemic 			= AffDotsOptions110.bars.pandemic
	self.db.profile.bars.text_position		= AffDotsOptions110.bars.text_position
	self.db.profile.bars.proportional 		= AffDotsOptions110.bars.proportional
	self.db.profile.bars.limit 				= AffDotsOptions110.bars.limit
	self.db.profile.tidyplates.enable 		= AffDotsOptions110.tidyplates.enable
	self.db.profile.tidyplates.w 			= AffDotsOptions110.tidyplates.w
	self.db.profile.tidyplates.h 			= AffDotsOptions110.tidyplates.h
	self.db.profile.tidyplates.transparency	= AffDotsOptions110.tidyplates.transparency
	self.db.profile.burst.enable 			= AffDotsOptions110.burst.enable
	self.db.profile.burst.default			= AffDotsOptions110.burst.default
	self.db.profile.burst.switch			= AffDotsOptions110.burst.switch
	self.db.profile.burst.color 			= AffDotsOptions110.burst.color
	self.db.profile.burst.text 				= AffDotsOptions110.burst.text
	self.db.profile.burst.h 				= AffDotsOptions110.burst.h
	self.db.profile.burst.w 				= AffDotsOptions110.burst.w
	self.db.profile.burst.key 				= AffDotsOptions110.burst.key
	self.db.profile.burst.mousekey 			= AffDotsOptions110.burst.mousekey

	AffDotsOptions110.settings_copied = true
end