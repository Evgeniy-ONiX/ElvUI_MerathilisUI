local MER, F, E, L, V, P, G = unpack(select(2, ...))
local module = MER:GetModule('MER_Skins')
local S = E:GetModule('Skins')

local function WeakAuras_PrintProfile()
	local frame = _G.WADebugEditBox.Background

	if frame and not frame.windStyle then
		local textArea = _G.WADebugEditBoxScrollFrame:GetRegions()
		S:HandleScrollBar(_G.WADebugEditBoxScrollFrameScrollBar)

		frame:StripTextures()
		frame:CreateBackdrop("Transparent")
		module:CreateShadow(frame)

		for _, child in pairs {frame:GetChildren()} do
			if child:GetNumRegions() == 3 then
				child:StripTextures()
				local subChild = child:GetChildren()
				S:HandleCloseButton(subChild)
				subChild:ClearAllPoints()
				subChild:Point("TOPRIGHT", frame, "TOPRIGHT", 3, 7)
			end
		end

		frame.windStyle = true
	end
end

local function ProfilingWindow_UpdateButtons(frame)
	for _, button in pairs {frame.statsFrame:GetChildren()} do
		S:HandleButton(button)
	end

	for _, button in pairs {frame.titleFrame:GetChildren()} do
		if not button.MERStyle and button.GetNormalTexture then
			local normalTextureID = button:GetNormalTexture():GetTexture()
			if normalTextureID == 252125 then
				button:StripTextures()

				button.Texture = button:CreateTexture(nil, "OVERLAY")
				button.Texture:Point("CENTER")
				button.Texture:SetTexture(E.Media.Textures.ArrowUp)
				button.Texture:Size(14, 14)

				button:HookScript("OnEnter", function(self)
					if self.Texture then
						self.Texture:SetVertexColor(unpack(E.media.rgbvaluecolor))
					end
				end)

				button:HookScript("OnLeave", function(self)
					if self.Texture then
						self.Texture:SetVertexColor(1, 1, 1)
					end
				end)

				button:HookScript("OnClick", function(self)
					self:SetNormalTexture("")
					self:SetPushedTexture("")
					self.Texture:Show("")
					if self:GetParent():GetParent().minimized then
						button.Texture:SetRotation(S.ArrowRotation["down"])
					else
						button.Texture:SetRotation(S.ArrowRotation["up"])
					end
				end)

				button:SetHitRectInsets(6, 6, 7, 7)
				button:Point("TOPRIGHT", frame.titleFrame, "TOPRIGHT", -19, 3)
			else
				S:HandleCloseButton(button)
				button:ClearAllPoints()
				button:Point("TOPRIGHT", frame.titleFrame, "TOPRIGHT", 3, 5)
			end

			button.MERStyle = true
		end
	end
end

local function ApplyElvCDs(region, data)
	local cd = region.cooldown.CooldownSettings or {}
	cd.font = E.Libs.LSM:Fetch('font', E.db.cooldown.fonts.font)
	cd.fontSize = E.db.cooldown.fonts.fontSize
	cd.fontOutline = E.db.cooldown.fonts.fontOutline

	region.cooldown.CooldownSettings = cd
	region.cooldown.forceDisabled = nil

	if _G.WeakAuras.GetData( data.id ).cooldownTextDisabled then
		region.cooldown.hideText = true
		region.cooldown.noCooldownCount = true
	else
		-- We want to see CDs, but we want Elv to handle them.
		region.cooldown.hideText = false
		region.cooldown.noCooldownCount = true -- This is OK because the setting itself is in the aura data.
	end

	region.cooldown:SetHideCountdownNumbers( region.cooldown.noCooldownCount )
	E:RegisterCooldown( region.cooldown )
end

local function Skin_WeakAuras(f, fType)
	-- Modified from NDui WeakAuras Skins
	if fType == "icon" then
		if not f.MERStyle then
			f.icon.SetTexCoordOld_Changed = f.icon.SetTexCoord
			f.icon.SetTexCoord = function(self, ULx, ULy, LLx, LLy, URx, URy, LRx, LRy)
				local cLeft, cRight, cTop, cDown
				if URx and URy and LRx and LRy then
					cLeft, cRight, cTop, cDown = ULx, LRx, ULy, LRy
				else
					cLeft, cRight, cTop, cDown = ULx, ULy, LLx, LLy
				end

				local left, right, top, down = unpack(E.TexCoords)
				if cLeft == 0 or cRight == 0 or cTop == 0 or cDown == 0 then
					local width, height = cRight - cLeft, cDown - cTop
					if width == height then
						self:SetTexCoordOld_Changed(left, right, top, down)
					elseif width > height then
						self:SetTexCoordOld_Changed(left, right, top + cTop * (right - left), top + cDown * (right - left))
					else
						self:SetTexCoordOld_Changed(left + cLeft * (down - top), left + cRight * (down - top), top, down)
					end
				else
					self:SetTexCoordOld_Changed(cLeft, cRight, cTop, cDown)
				end
			end
			f.icon:SetTexCoord(f.icon:GetTexCoord())
			f:CreateBackdrop()
			module:CreateBackdropShadow(f, true)
			f.backdrop.Center:StripTextures()
			f.backdrop:SetFrameLevel(0)
			f.backdrop.icon = f.icon
			f.backdrop:HookScript("OnUpdate", function(self)
				self:SetAlpha(self.icon:GetAlpha())
				if self.shadow then
					self.shadow:SetAlpha(self.icon:GetAlpha())
				end
			end)

			f.MERStyle = true
		end
	elseif fType == "aurabar" then
		if not f.MERStyle then
			f:CreateBackdrop()
			f.backdrop.Center:StripTextures()
			f.backdrop:SetFrameLevel(0)
			module:CreateBackdropShadow(f, true)
			f.icon:SetTexCoord(unpack(E.TexCoords))
			f.icon.SetTexCoord = E.noop
			f.iconFrame:SetAllPoints(f.icon)
			f.iconFrame:CreateBackdrop()
			hooksecurefunc(f.icon, "Hide", function()
				f.iconFrame.backdrop:SetShown(false)
			end)

			hooksecurefunc(f.icon, "Show", function()
				f.iconFrame.backdrop:SetShown(true)
			end)

			f.MERStyle = true
		end
	end
end

local function LoadSkin()
	if not E.private.mui.skins.addonSkins.enable or not E.private.mui.skins.addonSkins.wa then
		return
	end

	-- Handle the options region type registration
	if _G.WeakAuras and _G.WeakAuras.RegisterRegionOptions then
		module:RawHook(_G.WeakAuras, "RegisterRegionOptions", "WeakAuras_RegisterRegionOptions")
	end

	local regionTypes = _G.WeakAuras.regionTypes
	local Create_Icon, Modify_Icon = regionTypes.icon.create, regionTypes.icon.modify
	local Create_AuraBar, Modify_AuraBar = regionTypes.aurabar.create, regionTypes.aurabar.modify

	regionTypes.icon.create = function(parent, data)
		local region = Create_Icon(parent, data)
		Skin_WeakAuras(region, "icon")
		ApplyElvCDs(region, data)
		return region
	end

	regionTypes.aurabar.create = function(parent)
		local region = Create_AuraBar(parent)
		Skin_WeakAuras(region, "aurabar")
		return region
	end

	regionTypes.icon.modify = function(parent, region, data)
		Modify_Icon(parent, region, data)
		ApplyElvCDs(region, data)
		Skin_WeakAuras(region, "icon")
	end

	regionTypes.aurabar.modify = function(parent, region, data)
		Modify_AuraBar(parent, region, data)
		Skin_WeakAuras(region, "aurabar")
	end

	for weakAura, regions in pairs(_G.WeakAuras.regions) do
		if regions.regionType == "icon" or regions.regionType == "aurabar" then
			Skin_WeakAuras(regions.region, regions.regionType)
		end
	end

	local profilingWindow = _G.WeakAuras.frames["RealTime Profiling Window"]
	if profilingWindow then
		module:CreateShadow(profilingWindow)
		module:SecureHook(profilingWindow, "UpdateButtons", ProfilingWindow_UpdateButtons)
		module:SecureHook(_G.WeakAuras, "PrintProfile", WeakAuras_PrintProfile)
	end
end

module:AddCallbackForAddon("WeakAuras", LoadSkin)
