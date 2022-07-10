local MER, F, E, L, V, P, G = unpack(select(2, ...))
local LSM = E.Libs.LSM
local module = MER.Modules.Skins
local WS = module.Widgets
local S = E.Skins

function WS:HandleSliderFrame(_, slider)
	if not self:IsReady() then
		self:RegisterLazyLoad(slider, function()
			self:HandleSliderFrame(nil, slider)
		end)
		return
	end

	local db = E.private.mui.skins.widgets.slider

	if not slider or not db or not db.enable then
		return
	end

	if not slider.MERSkinned then
		slider:SetThumbTexture(LSM:Fetch("statusbar", db.texture) or E.media.normTex)
		slider.SetThumbTexture = E.noop
		slider.MERSkinned = true
	end

	F.SetVertexColorDB(slider:GetThumbTexture(), db.classColor and module.ClassColor or db.color)
end

WS:SecureHook(S, "HandleSliderFrame")