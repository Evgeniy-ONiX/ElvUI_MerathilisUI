local MER, F, E, L, V, P, G = unpack(select(2, ...))
local MAB = MER:GetModule('MER_Actionbars')
local VB = MER:GetModule('MER_VehicleBar')

--Cache global variables
--Lua functions
local pairs, select, tonumber, type = pairs, select, tonumber, type
local format = string.format
local tinsert = table.insert
--WoW API / Variables
local GetItemInfo = GetItemInfo
local COLOR = COLOR
-- GLOBALS:

local buttonTypes = {
	["quest"] = "Quest Buttons",
	["slot"] = "Trinket Buttons",
	["usable"] = "Usable Buttons"
}

local animationsDisabled = function()
	return not E.db.mui.actionbars.vehicleBar.animations
end

local function ActionBarTable()
	local ACH = E.Libs.ACH

	E.Options.args.mui.args.modules.args.actionbars = {
		type = "group",
		name = L["ActionBars"],
		get = function(info) return E.db.mui.actionbars[ info[#info] ] end,
		set = function(info, value) E.db.mui.actionbars[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL"); end,
		args = {
			name = ACH:Header(MER:cOption(L["ActionBars"], 'orange'), 1),
			general = {
				order = 2,
				type = "group",
				name = MER:cOption(L["General"], 'orange'),
				guiInline = true,
				args = { },
			},
			specBar = {
				order = 3,
				type = "group",
				name = MER:cOption(L["Specialization Bar"], 'orange'),
				guiInline = true,
				disabled = function() return not E.private.actionbar.enable end,
				hidden = not E.Retail,
				get = function(info) return E.db.mui.actionbars.specBar[ info[#info] ] end,
				set = function(info, value) E.db.mui.actionbars.specBar[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL"); end,
				args = {
					enable = {
						order = 1,
						type = "toggle",
						name = L["Enable"],
						disabled = function() return not E.private.actionbar.enable end,
					},
					mouseover = {
						order = 2,
						type = "toggle",
						name = L["Mouseover"],
						disabled = function() return not E.private.actionbar.enable end,
					},
					size = {
						order = 3,
						type = "range",
						name = L["Button Size"],
						min = 20, max = 60, step = 1,
						disabled = function() return not E.private.actionbar.enable end,
					},
				},
			},
			equipBar = {
				order = 4,
				type = "group",
				name = MER:cOption(L["EquipSet Bar"], 'orange'),
				guiInline = true,
				disabled = function() return not E.private.actionbar.enable end,
				hidden = not E.Retail,
				get = function(info) return E.db.mui.actionbars.equipBar[ info[#info] ] end,
				set = function(info, value) E.db.mui.actionbars.equipBar[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL"); end,
				args = {
					enable = {
						order = 1,
						type = "toggle",
						name = L["Enable"],
						disabled = function() return not E.private.actionbar.enable end,
					},
					mouseover = {
						order = 2,
						type = "toggle",
						name = L["Mouseover"],
						disabled = function() return not E.private.actionbar.enable end,
					},
					size = {
						order = 3,
						type = "range",
						name = L["Button Size"],
						min = 20, max = 60, step = 1,
						disabled = function() return not E.private.actionbar.enable end,
					},
				},
			},
			vehicleBar = {
				order = 5,
				type = "group",
				name = MER:cOption(L["Vehicle Bar"], 'orange'),
				guiInline = true,
				disabled = function() return not E.private.actionbar.enable end,
				hidden = not E.Retail,
				get = function(info) return E.db.mui.actionbars.equipBar[ info[#info] ] end,
				set = function(info, value) E.db.mui.actionbars.equipBar[ info[#info] ] = value; VB:ProfileUpdate() end,
				args = {
					enable = {
						order = 1,
						type = "toggle",
						name = L["Enable"],
						disabled = function() return not E.private.actionbar.enable end,
					},
					animations = {
						order = 2,
						type = "toggle",
						name = L["Animations"],
						disabled = function() return not E.private.actionbar.enable end,
					},
					animationsMult = {
						order = 3,
						type = "range",
						name = L["Animation Speed"],
						min = 0.5, max = 2, step = 0.1,
						isPercent = true,
						disabled = function() return not E.private.actionbar.enable end or animationsDisabled,
						get = function()
							return 1 / E.db.mui.actionbars.vehicleBar.animationsMult
						end,
						set = function(_, value)
							E.db.mui.actionbars.vehicleBar.animationsMult = 1 / value
						end,
					},
				},
			},
		},
	}
end
tinsert(MER.Config, ActionBarTable)
