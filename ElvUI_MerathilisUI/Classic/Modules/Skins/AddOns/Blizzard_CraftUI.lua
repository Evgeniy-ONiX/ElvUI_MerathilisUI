local MER, F, E, L, V, P, G = unpack(select(2, ...))
local module = MER.Modules.Skins
local S = E:GetModule('Skins')

local _G = _G

local function LoadSkin()
	if not module:CheckDB("craft", "craft") then
		return
	end

	local CraftFrame = _G.CraftFrame
	if CraftFrame.backdrop then
		CraftFrame.backdrop:Styling()
	end
	MER:CreateBackdropShadow(CraftFrame)
end

S:AddCallbackForAddon("Blizzard_CraftUI", LoadSkin)
