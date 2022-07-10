local MER, F, E, L, V, P, G = unpack(select(2, ...))
local module = MER.Modules.Skins
local S = E:GetModule('Skins')

local _G = _G

local function LoadSkin()
	if not module:CheckDB("lfg", "lfg") then
		return
	end

	local LFGParentFrame = _G.LFGParentFrame
	if LFGParentFrame.backdrop then
		LFGParentFrame.backdrop:Styling()
	end
	module:CreateBackdropShadow(LFGParentFrame)
end

S:AddCallbackForAddon("Blizzard_LookingForGroupUI", LoadSkin)