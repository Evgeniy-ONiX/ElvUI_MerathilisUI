local MER, F, E, L, V, P, G = unpack(select(2, ...))
local module = MER.Modules.Skins

local _G = _G
local ipairs = ipairs

function module:Blizzard_CovenantSanctum()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.covenantSanctum) or E.private.mui.skins.blizzard.covenantSanctum ~= true then return end

	local frame = _G.CovenantSanctumFrame

	frame:HookScript('OnShow', function()
		if not frame.IsStyled then
			frame:Styling()
			MER:CreateBackdropShadow(frame)

			local UpgradesTab = frame.UpgradesTab
			local TalentList = frame.UpgradesTab.TalentsList

			frame.LevelFrame.Background:SetAlpha(0)
			UpgradesTab.Background:SetAlpha(0)
			TalentList.Divider:SetAlpha(0)
			TalentList.BackgroundTile:SetAlpha(0)

			for _, frame in ipairs(UpgradesTab.Upgrades) do
				if frame.RankBorder then
					frame.RankBorder:SetAlpha(0)
				end
			end

			frame.IsStyled = true
		end
	end)
end

module:AddCallbackForAddon('Blizzard_CovenantSanctum')
