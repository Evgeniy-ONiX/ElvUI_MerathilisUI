local MER, F, E, L, V, P, G = unpack(select(2, ...))
local module = MER.Modules.DataTexts
local DT = E:GetModule('DataTexts')

local _G = _G

local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

local PANEL_HEIGHT = 22

local ChatTabFrame = CreateFrame("Frame", "MER_RightChatTopDT", _G.RightChatPanel)
ChatTabFrame:Height(PANEL_HEIGHT)
ChatTabFrame:Width(411)
ChatTabFrame:SetFrameStrata("BACKGROUND")
ChatTabFrame:Hide()
E.FrameLocks["MER_RightChatTopDT"] = true

function module:LoadDataTexts()
	if not E.db.mui.datatexts.RightChatDataText then return end

	MER_RightChatTopDT:Point("TOPRIGHT", _G.RightChatTab, "TOPRIGHT", 0, E.mult)
	MER_RightChatTopDT:Point("BOTTOMLEFT", _G.RightChatTab, "BOTTOMLEFT", 0, E.mult)
end

function module:Initialize()
	module.db = E.db.mui.datatexts

	self:LoadDataTexts()
end

MER:RegisterModule(module:GetName())
