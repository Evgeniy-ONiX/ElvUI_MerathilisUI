local MER, F, E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule('Skins')

local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true then return end

	hooksecurefunc('CinematicFrame_OnDisplaySizeChanged', function(s)
		if s and s.closeDialog and not s.closeDialog.__MERSkin then
			if s.closeDialog.backdrop then
				s.closeDialog.backdrop:Styling()

				s.closeDialog.__MERSkin = true
			end
		end
	end)

	hooksecurefunc('MovieFrame_PlayMovie', function(s)
		if s and s.CloseDialog and not s.CloseDialog.__MERSkin then
			if s.CloseDialog.backdrop then
				s.CloseDialog.backdrop:Styling()

				s.CloseDialog.__MERSkin = true
			end
		end
	end)

end

S:AddCallback("CinematicFrame", LoadSkin)
