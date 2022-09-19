local MER, F, E, L, V, P, G = unpack(select(2, ...))
local module = MER:GetModule('MER_UnitFrames')
local UF = E:GetModule('UnitFrames')
local AB = E:GetModule('ActionBars')

local hooksecurefunc = hooksecurefunc

function module:ADDON_LOADED(event, addon)
	if addon ~= "ElvUI_Config" then return end

	module:UnregisterEvent(event)
end

function module:CreateHighlight(frame)
	if not frame then return end
	if not E.db.mui.unitframes.highlight then return end

	local hl = frame:CreateTexture(nil, "BACKGROUND")
	hl:SetAllPoints()
	hl:SetTexture("Interface\\PETBATTLES\\PetBattle-SelectedPetGlow")
	hl:SetTexCoord(0, 1, .5, 1)
	hl:SetVertexColor(1, 1, .6)
	hl:SetBlendMode("ADD")
	hl:Hide()
	frame.Highlight = hl

	frame:HookScript("OnEnter", function()
		frame.Highlight:Show()
	end)
	frame:HookScript("OnLeave", function()
		frame.Highlight:Hide()
	end)
end

function module:CreateAnimatedBars(frame)
	if not frame then return end
	if not E.db.unitframe.units.player.power.enable then return end -- only Player for now

	local db = E.db.mui.unitframes.power

	if db and db.enable then
		if not frame.__MERAnim then
			frame.__MERAnim = CreateFrame("FRAME", nil, frame) -- Main Frame

			if not frame.animation then
				local animation = CreateFrame("PlayerModel", "MER_PowerBarEffect", frame.__MERAnim)

				if db.type == "DEFAULT" then
					animation:SetModel(1715069)
					animation:MakeCurrentCameraCustom()
					animation:SetTransform(-0.035, 0, 0, rad(270), 0, 0, 0.580)
					animation:SetPortraitZoom(1)
					animation:SetAlpha(0.65)
				elseif db.type == "CUSTOM" then
					animation:SetModel(db.model)
				end

				animation:SetKeepModelOnHide(true)
				animation:SetInside(frame:GetStatusBarTexture(), 0, 0)

				frame.animation = animation
			end

			if not frame.sparkle then
				local sparkle = CreateFrame("PlayerModel", nil, frame.__MERAnim)
				sparkle:SetKeepModelOnHide(true)
				sparkle:SetModel(1630153)
				sparkle:ClearTransform()
				sparkle:SetPosition(4, 0.32, 1.85, 0)

				local h = frame:GetHeight()
				sparkle:SetPoint("RIGHT", frame.__MERAnim)
				sparkle:SetInside(frame:GetStatusBarTexture(), 0, 0)
				sparkle:SetSize(h*2, h)
				sparkle:SetAlpha(0.2)

				frame.sparkle = sparkle
			end

			if not frame.full then
				local full = CreateFrame("StatusBar", nil, frame.__MERAnim, "FullResourcePulseFrame")
				frame.full = full

				local w, h = frame:GetWidth(), frame:GetHeight()
				frame.full:ClearAllPoints()
				frame.full:SetPoint("Right", frame, "RIGHT")
				frame.full:SetSize(w, h)

				frame.full.SpikeFrame:SetSize(w, h)
				frame.full.PulseFrame:SetSize(w, h)
				frame.full.SpikeFrame.AlertSpikeStay:SetSize(w / 4, h * 2)
				frame.full.PulseFrame.YellowGlow:SetSize(w / 4, h * 3)
				frame.full.PulseFrame.SoftGlow:SetSize(w / 4, h * 3)

				frame.full:Initialize(true)
				frame.full:SetMaxValue(UnitPowerMax("player"))
				frame.full.currValue = UnitPower("player")

				frame.full:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
				frame.full:RegisterUnitEvent("UNIT_MAXPOWER", "player")
				frame.full:SetScript("OnEvent", function(self, event, ...)
					if event == "UNIT_MAXPOWER" then
						self:SetMaxValue(UnitPowerMax("player"))
					end
					if event == "UNIT_POWER_FREQUENT" then
						local currValue = UnitPower("player")
						self:StartAnimIfFull(self.currValue, currValue)
						self.currValue = currValue
					end
				end)
			end

			frame.__MERAnim:SetAllPoints(frame:GetStatusBarTexture())
			frame.__MERAnim:Show()
		else
			frame.__MERAnim:Hide()
		end

		frame.__MERAnim:RegisterEvent("PLAYER_ENTERING_WORLD")
		frame.__MERAnim:RegisterEvent("PORTRAITS_UPDATED")
		frame.__MERAnim:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	end
end

function module:CreateUFShadows()
	self:SecureHook(UF, "UpdateNameSettings", "UnitFrames_UpdateNameSettings")
	self:SecureHook(UF, "Configure_Threat", "UnitFrames_Configure_Threat")
	self:SecureHook(UF, "Configure_Power", "UnitFrames_Configure_Power")
	self:SecureHook(UF, "Configure_ClassBar", "UnitFrames_Configure_ClassBar")
end

function module:LoadUnits()
	local db = E.db.mui.unitframes
	-- Player
	hooksecurefunc(UF, "Update_PlayerFrame", module.Update_PlayerFrame)
	-- Target
	hooksecurefunc(UF, "Update_TargetTargetFrame", module.Update_TargetTargetFrame)
	-- Pet
	hooksecurefunc(UF, "Update_PetFrame", module.Update_PetFrame)
	-- Focus
	hooksecurefunc(UF, "Update_FocusFrame", module.Update_FocusFrame)
	-- FocusTarget
	hooksecurefunc(UF, "Update_FocusTargetFrame", module.Update_FocusTargetFrame)
	-- Party
	hooksecurefunc(UF, "Update_PartyFrames", module.Update_PartyFrames)
	-- Raid
	hooksecurefunc(UF, "Update_RaidFrames", module.Update_RaidFrames)
	-- Boss
	hooksecurefunc(UF, "Update_BossFrames", module.Update_BossFrames)
	-- Castbar
	hooksecurefunc(UF, "Configure_Castbar", module.Configure_Castbar)
	-- Power
	hooksecurefunc(UF, "Configure_Power", module.Configure_Power)
	-- Power Textures
	module:ChangePowerBarTexture()
	hooksecurefunc(UF, 'Update_StatusBars', module.ChangePowerBarTexture)
	hooksecurefunc(UF, 'Update_AllFrames', module.ChangeUnitPowerBarTexture)
	hooksecurefunc(AB, 'StyleShapeShift', module.ChangeUnitPowerBarTexture)
	-- RaidIcons
	hooksecurefunc(UF, "Configure_RaidIcon", module.Configure_RaidIcon)
	-- Auras
	if db.auras then
		module:SecureHook(UF, "PostUpdateAura", "ElvUI_PostUpdateDebuffs")
	end
	-- RoleIcons
	module:Configure_RoleIcons()
	-- Shadows
	module:CreateUFShadows()
end

function module:Initialize()
	if not E.private.unitframe.enable then
		return
	end

	hooksecurefunc(UF, "LoadUnits", module.LoadUnits)

	self:RegisterEvent("ADDON_LOADED")
end

MER:RegisterModule(module:GetName())
