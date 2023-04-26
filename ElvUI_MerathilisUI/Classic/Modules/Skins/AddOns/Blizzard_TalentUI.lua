local MER, F, E, L, V, P, G = unpack(ElvUI_MerathilisUI)
local module = MER.Modules.Skins
local S = E:GetModule('Skins')

local _G = _G

local function LoadSkin()
	if not module:CheckDB("talent", "talent") then
		return
	end

	local PlayerTalentFrame = _G.PlayerTalentFrame
	if PlayerTalentFrame.backdrop then
		PlayerTalentFrame.backdrop:Styling()
	end
	module:CreateBackdropShadow(_G.PlayerTalentFrame)
end

S:AddCallbackForAddon("Blizzard_TalentUI", LoadSkin)
