local MER, F, E, L, V, P, G = unpack(select(2, ...))
local module = MER.Modules.Skins

local _G = _G

function module:Blizzard_GuildRecruitmentUI()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.guild ~= true then return end

	local rolesFrame = _G.CommunitiesGuildRecruitmentFrameRecruitment.RolesFrame
	F.ReskinRole(rolesFrame.TankButton, "TANK")
	F.ReskinRole(rolesFrame.HealerButton, "HEALER")
	F.ReskinRole(rolesFrame.DamagerButton, "DPS")
end

module:AddCallbackForAddon("Blizzard_GuildRecruitmentUI")
