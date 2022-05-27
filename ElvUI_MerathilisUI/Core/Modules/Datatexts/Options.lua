local MER, F, E, _, V, P, G = unpack(select(2, ...))
local L = E.Libs.ACL:GetLocale('ElvUI', E.global.general.locale or 'enUS')
local options = MER.options.modules.args

options.datatexts = {
	type = "group",
	name = F.cOption(L["DataTexts"], 'orange'),
	get = function(info) return E.db.mui.datatexts[ info[#info] ] end,
	set = function(info, value) E.db.mui.datatexts[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL"); end,
	args = {
		header = {
			order = 1,
			type = "header",
			name = F.cOption(L["DataTexts"], 'orange'),
		},
		general = {
			order = 2,
			type = "group",
			name = F.cOption(L["General"], 'orange'),
			guiInline = true,
			args = {
				RightChatDataText = {
					order = 1,
					type = "toggle",
					name = L["Right Chat DataText"],
				},
			},
		},
	},
}

