local MER, E, L, V, P, G = unpack(select(2, ...))
local MERS = MER:GetModule("muiSkins")
local S = E:GetModule("Skins")

-- Cache global variables
-- Lua functions
local _G = _G
local unpack = unpack
-- WoW API
local CreateFrame = CreateFrame
local GetContainerNumSlots = GetContainerNumSlots
local GetContainerItemLink = GetContainerItemLink
local PickupInventoryItem = PickupInventoryItem
local PickupContainerItem = PickupContainerItem
-- Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS:

local r, g, b = unpack(E["media"].rgbvaluecolor)

local function styleCharacter()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.character ~= true or E.private.muiSkins.blizzard.character ~= true then return end

	-- Hide ElvUI Backdrop
	if _G["CharacterModelFrame"].backdrop then
		_G["CharacterModelFrame"].backdrop:Hide()
	end

	_G["CharacterFrame"]:Styling()

	if _G["CharacterModelFrame"] and _G["CharacterModelFrame"].BackgroundTopLeft and _G["CharacterModelFrame"].BackgroundTopLeft:IsShown() then
		_G["CharacterModelFrame"].BackgroundTopLeft:Hide()
		_G["CharacterModelFrame"].BackgroundTopRight:Hide()
		_G["CharacterModelFrame"].BackgroundBotLeft:Hide()
		_G["CharacterModelFrame"].BackgroundBotRight:Hide()
		_G["CharacterModelFrameBackgroundOverlay"]:Hide()
		if _G["CharacterModelFrame"].backdrop then
			_G["CharacterModelFrame"].backdrop:Hide()
		end
	end

	-- Undress Button
	local E, Z, N, n
	local undress = CreateFrame("Button", MER.Title.."UndressButton", _G["PaperDollFrame"], "UIPanelButtonTemplate")
	undress:SetFrameStrata("HIGH")
	undress:SetSize(80, 20)
	undress:SetPoint("TOPLEFT", _G["CharacterWristSlot"], "BOTTOMLEFT", 0, -5)

	undress.text = MER:CreateText(undress, "OVERLAY", 12, nil)
	undress.text:SetPoint("CENTER")
	undress.text:SetText(L["Undress"])

	undress:SetScript("OnClick", function()
		E = { 16, 17, 1, 3, 5, 6, 7, 8, 9, 10 }
		Z = {}
		n = Z[1] and #Z+1 or 1
		for i = 0, 4 do
			for j = 1, GetContainerNumSlots(i) do
				if not GetContainerItemLink(i,j) and E[n] then
					Z[n]= {i,j}
					PickupInventoryItem(E[n])
					PickupContainerItem(i, j)
					n = n + 1
				end
			end
		end
	end)
	S:HandleButton(undress)
end

S:AddCallback("mUICharacter", styleCharacter)