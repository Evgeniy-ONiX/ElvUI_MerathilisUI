local MER, F, E, L, V, P, G = unpack((select(2, ...)))
local T = MER:GetModule('MER_Tooltip')
local TT = E:GetModule('Tooltip')

local _G = _G
local gsub = string.gsub

local UnitClass = UnitClass
local UnitIsPlayer = UnitIsPlayer
local UnitReaction = UnitReaction
local hooksecurefunc = hooksecurefunc

local function TooltipGradientName(unit)
	if not unit then return end

	local _, classunit = UnitClass(unit)
	local reaction = UnitReaction(unit, 'player')

	local tooltipName = _G['GameTooltipTextLeft1']:GetText()
	if tooltipName and classunit and reaction then
		-- To strip the name from color sequences. Credits: ArkInventory
		if tooltipName:match('|c') or tooltipName:match('|r') then
			tooltipName = gsub(tooltipName, '|c%x%x%x%x%x%x%x%x', '')
			tooltipName = gsub(tooltipName, '|r', '')
		end

		if UnitIsPlayer(unit) and classunit then
			_G["GameTooltipTextLeft1"]:SetText(F.GradientName(tooltipName, classunit))
		else
			if reaction and reaction >= 5 then
				_G["GameTooltipTextLeft1"]:SetText(F.GradientName(tooltipName, 'NPCFRIENDLY'))
			elseif reaction and reaction == 4 then
				_G["GameTooltipTextLeft1"]:SetText(F.GradientName(tooltipName, 'NPCNEUTRAL'))
			elseif reaction and reaction == 3 then
				_G["GameTooltipTextLeft1"]:SetText(F.GradientName(tooltipName, 'NPCUNFRIENDLY'))
			elseif reaction and reaction == 2 or reaction == 1 then
				_G["GameTooltipTextLeft1"]:SetText(F.GradientName(tooltipName, 'NPCHOSTILE'))
			end
		end
	end
end

local function ApplyTooltipStyle(tt)
	if not tt then return end
	if _G.GameTooltip and _G.GameTooltip:IsForbidden() then return end

	local _, unitId= _G.GameTooltip:GetUnit()
	if unitId then
		TooltipGradientName(unitId)
	end
end

function T:Style()
	local db = E.db.mui.tooltip
	if not db and not db.gradientName then
		return
	end

	hooksecurefunc(TT, 'AddTargetInfo', ApplyTooltipStyle)
	hooksecurefunc(TT, 'GameTooltip_OnTooltipSetUnit', ApplyTooltipStyle)
end

T:AddCallback("Style")
