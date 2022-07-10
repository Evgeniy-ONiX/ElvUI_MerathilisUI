local MER, F, E, L, V, P, G = unpack(select(2, ...))
local module = MER.Modules.Skins
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

local function HandleScrollChild(self)
	for i = 1, self.ScrollTarget:GetNumChildren() do
		local child = select(i, self.ScrollTarget:GetChildren())
		local icon = child and child.Icon
		if icon and not icon.IsChanged then
			if child and child.backdrop then
				child.backdrop:SetTemplate('Transparent')
				module:CreateGradient(child.backdrop)
			end
			icon.IsChanged = true
		end
	end
end

local function LoadSkin()
	if not module:CheckDB("binding", "binding") then
		return
	end

	local frame = _G.ClickBindingFrame
	frame:Styling()

	hooksecurefunc(frame.ScrollBox, 'Update', HandleScrollChild)
end

S:AddCallbackForAddon("Blizzard_ClickBindingUI", LoadSkin)
