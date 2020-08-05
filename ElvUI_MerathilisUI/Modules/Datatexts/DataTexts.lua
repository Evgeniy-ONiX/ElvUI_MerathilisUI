local MER, E, L, V, P, G = unpack(select(2, ...))
local DT = E:GetModule('DataTexts')

--Cache global variables
--Lua functions
local _G = _G
--WoW API / Variables
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
-- GLOBALS:

local PANEL_HEIGHT = 22

local ChatTabFrame = CreateFrame("Frame", "MER_RightChatTopDT", _G.RightChatPanel)
ChatTabFrame:SetHeight(PANEL_HEIGHT)
ChatTabFrame:SetWidth(411)
ChatTabFrame:SetFrameStrata("LOW")
E.FrameLocks["MER_RightChatTopDT"] = true
DT:RegisterPanel(ChatTabFrame, 3, "ANCHOR_TOPLEFT", 3, 4)

function MER:InitDataTexts()
	MER_RightChatTopDT:SetPoint("TOPRIGHT", _G.RightChatTab, "TOPRIGHT", 0, E.mult)
	MER_RightChatTopDT:SetPoint("BOTTOMLEFT", _G.RightChatTab, "BOTTOMLEFT", 0, E.mult)

	hooksecurefunc(DT, "UpdatePanelInfo", function(DT, panelName, panel)
		if not panel then return end
		local db = panel.db or P.datatexts.panels[panelName] and DT.db.panels[panelName]
		if not db then return end

		-- Need to find a way to hide my styling if changing the option from a panel
		if panel and not panel.styled then
			if db.backdrop then
				panel:Styling()
			end
			panel.styled = true
		end
	end)
end
