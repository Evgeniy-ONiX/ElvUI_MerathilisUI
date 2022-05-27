local MER, F, E, L, V, P, G = unpack(select(2, ...))
local module = MER.Modules.Skins

local _G = _G
local select, unpack = select, unpack

function module:Blizzard_ItemSocketingUI()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.socket ~= true or E.private.mui.skins.blizzard.socket ~= true then return end

	local ItemSocketingFrame = _G["ItemSocketingFrame"]
	ItemSocketingFrame:Styling()
	MER:CreateBackdropShadow(ItemSocketingFrame)

	ItemSocketingFrame:DisableDrawLayer("ARTWORK")

	local title = select(18, ItemSocketingFrame:GetRegions())
	title:ClearAllPoints()
	title:SetPoint("TOP", 0, -5)

	for i = 1, _G.MAX_NUM_SOCKETS do
		local bu = _G["ItemSocketingSocket"..i]
		local shine = _G["ItemSocketingSocket"..i.."Shine"]

		_G["ItemSocketingSocket"..i.."BracketFrame"]:Hide()
		_G["ItemSocketingSocket"..i.."Background"]:SetAlpha(0)
		select(2, bu:GetRegions()):Hide()

		bu:SetPushedTexture("")
		bu:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		bu.icon:SetTexCoord(unpack(E.TexCoords))

		shine:ClearAllPoints()
		shine:SetPoint("TOPLEFT", bu)
		shine:SetPoint("BOTTOMRIGHT", bu, 1, 0)

		bu.bg = module:CreateBDFrame(bu, .25)
	end
end

module:AddCallbackForAddon("Blizzard_ItemSocketingUI")
