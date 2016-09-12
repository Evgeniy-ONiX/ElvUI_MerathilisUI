local E, L, V, P, G = unpack(ElvUI);
local MER = E:GetModule('MerathilisUI');
local LSM = LibStub('LibSharedMedia-3.0');
local S = E:GetModule('Skins');

-- Cache global variables
-- Lua functions
local _G = _G
local pairs, unpack = pairs, unpack
-- WoW API / Variables
local CreateFrame = CreateFrame
local IsAddOnLoaded = IsAddOnLoaded
local ObjectiveTrackerFrame = _G["ObjectiveTrackerFrame"]
local ScenarioStageBlock = _G["ScenarioStageBlock"]
local GetNumQuestWatches = GetNumQuestWatches
local GetQuestDifficultyColor = GetQuestDifficultyColor
local GetQuestLogTitle = GetQuestLogTitle
local GetQuestLogSpecialItemInfo = GetQuestLogSpecialItemInfo
local GetQuestIndexForWatch = GetQuestIndexForWatch
local GetQuestWatchInfo = GetQuestWatchInfo
local GetScreenHeight = GetScreenHeight
local GetScreenWidth = GetScreenWidth
local LE_QUEST_FREQUENCY_DAILY = LE_QUEST_FREQUENCY_DAILY
local LE_QUEST_FREQUENCY_WEEKLY = LE_QUEST_FREQUENCY_WEEKLY
local UIParentLoadAddOn = UIParentLoadAddOn

-- Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS: hooksecurefunc, QUEST_TRACKER_MODULE, ScenarioTrackerProgressBar_PlayFlareAnim, C_Scenario, Bar
-- GLOBALS: BonusObjectiveTrackerProgressBar_PlayFlareAnim, ObjectiveTracker_Initialize, ScenarioProvingGroundsBlock
-- GLOBALS: ScenarioProvingGroundsBlockAnim, GameTooltip, UIParent

local classColor = E.myclass == 'PRIEST' and E.PriestColors or (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[E.myclass] or RAID_CLASS_COLORS[E.myclass])

local height = 450 -- overall height
local width = 188 -- overall width

-- Blizzard Frames
local otf = _G["ObjectiveTrackerFrame"]

local function ObjectiveTrackerReskin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.objectiveTracker ~= true or E.private.muiSkins.blizzard.objectivetracker.enable ~= true then return end

	if not otf.initialized then
		ObjectiveTracker_Initialize(otf)
	end

	-- Skin Quest Items
	local function skinQuestObjectiveFrameItems(self)
		if self and not self.skinned then
			MER:BU(self)
			MER:BUElements(self)
			self.skinned = true
		end
	end

	-- Implement
	local qitime = 0
	local qiinterval = 1
	hooksecurefunc('QuestObjectiveItem_OnUpdate', function(self, elapsed)
		qitime = qitime + elapsed
		if qitime > qiinterval then
			skinQuestObjectiveFrameItems(self)
			qitime = 0
		end
	end)

	if E.private.muiSkins.blizzard.objectivetracker.autoHide then
		-- Collaps ObjectiveTrackerFrame
		local collapse = CreateFrame("Frame")
		collapse:RegisterEvent("PLAYER_REGEN_DISABLED")
		collapse:RegisterEvent("PLAYER_REGEN_ENABLED")
		collapse:SetScript("OnEvent", function(self, event)
			if event == "PLAYER_REGEN_DISABLED" then
				ObjectiveTracker_Collapse()
			-- Expand the frame after combat
			elseif event == "PLAYER_REGEN_ENABLED" then
				ObjectiveTracker_Expand()
			end
		end)
	end

	-- Underlines, Header text, backdrop
	if otf and otf:IsShown() then
		if otf.MODULES then
			for i = 1, #otf.MODULES do
				local module = otf.MODULES[i]
				if E.private.muiSkins.blizzard.objectivetracker.underlines then
					module.Header.Underline = MER:Underline(otf.MODULES[i].Header, true, 1)
				end
				module.Header.Text:SetFont(LSM:Fetch("font", "Merathilis Roboto-Black"), 12, "OUTLINE")
				module.Header.Text:SetVertexColor(classColor.r, classColor.g, classColor.b)

				if E.private.muiSkins.blizzard.objectivetracker.backdrop then
					module.Header:CreateBackdrop("Transparent")
					module.Header.backdrop:Point("TOPLEFT", -3, 0)
				end
			end
		end
	end

	-- Scenario LevelUp Display
	_G["LevelUpDisplayScenarioFrame"].level:SetVertexColor(classColor.r, classColor.g, classColor.b)

	-- Bonus Objectives Banner Frame
	_G["ObjectiveTrackerBonusBannerFrame"].Title:SetVertexColor(classColor.r, classColor.g, classColor.b)
	_G["ObjectiveTrackerBonusBannerFrame"].BonusLabel:SetVertexColor(1, 1, 1)

	local AddObjective = function(self, block, key)
		local header = block.HeaderText
		local line = block.lines[key]

		if header then
			header:SetFont(LSM:Fetch('font', 'Merathilis Roboto-Black'), 10, nil)
			header:SetShadowOffset(.7, -.7)
			header:SetShadowColor(0, 0, 0, 1)
			header:SetWidth(width)
			header:SetWordWrap(true)
			if header:GetNumLines() > 1 then header:SetHeight(15) end
		end

		line.Text:SetWidth(width)

		if line.Dash and line.Dash:IsShown() then
			line.Dash:SetText('• ')
		end
		
	end

	-- General ProgressBars
	local AddProgressBar = function(self, block, line)
		local progressBar = line.ProgressBar
		local bar = progressBar.Bar

		bar:StripTextures()
		bar:SetStatusBarTexture(E["media"].MuiFlat)
		bar:SetStatusBarColor(classColor.r, classColor.g, classColor.b)
		bar:CreateBackdrop("Transparent")
		bar.backdrop:Point("TOPLEFT", Bar, -1, 1)
		bar.backdrop:Point("BOTTOMRIGHT", Bar, 1, -1)
	end

	-- Scenario ProgressBars
	local AddProgressBar1 = function(self, block, line, criteriaIndex)
		local progressBar = self.usedProgressBars[block] and self.usedProgressBars[block][line];

		progressBar.Bar:StripTextures()
		progressBar.Bar:SetStatusBarTexture(E["media"].MuiFlat)
		progressBar.Bar:SetStatusBarColor(classColor.r, classColor.g, classColor.b)
		progressBar.Bar:CreateBackdrop("Transparent")
		progressBar.Bar.backdrop:Point("TOPLEFT", Bar, -1, 1)
		progressBar.Bar.backdrop:Point("BOTTOMRIGHT", Bar, 1, -1)

		progressBar.Bar.Icon:Kill()
		progressBar.Bar.IconBG:Kill()
		progressBar.Bar.BarGlow:Kill()
	end

	local AddTimerBar = function(self, block, line, duration, startTime)
		local bar = self.usedTimerBars[block] and self.usedTimerBars[block][line]

		bar:SetStatusBarColor(classColor.r, classColor.g, classColor.b)

		if not bar.styled then
			local bg = CreateFrame('Frame', nil, bar)
			bg:SetPoint('TOPLEFT', bar)
			bg:SetPoint('BOTTOMRIGHT', bar)
			bg:SetFrameLevel(0)
			bar.styled = true
		end

		bar.Label:SetFont(LSM:Fetch('font', 'Merathilis Roboto-Black'), 11, 'THINOUTLINE')
		bar.Label:SetShadowOffset(0, -0)
		bar.Label:ClearAllPoints()
		bar.Label:SetPoint('CENTER', bar, 'BOTTOM', 1, -2)
		bar.Label:SetDrawLayer('OVERLAY', 7)
	end

	--Set tooltip depending on position
	local function IsFramePositionedLeft(frame)
		local x = frame:GetCenter()
		local screenWidth = GetScreenWidth()
		local screenHeight = GetScreenHeight()
		local positionedLeft = false

		if x and x < (screenWidth / 2) then
			positionedLeft = true
		end

		return positionedLeft
	end

	hooksecurefunc("BonusObjectiveTracker_ShowRewardsTooltip", function(block)
		if IsFramePositionedLeft(ObjectiveTrackerFrame) then
			GameTooltip:ClearAllPoints()
			GameTooltip:SetPoint("TOPLEFT", block, "TOPRIGHT", 0, 0)
		end
	end)

	-- Scenario buttons
	local function SkinScenarioButtons()
		local block = ScenarioStageBlock
		local _, currentStage, numStages, flags = C_Scenario.GetInfo()

		-- pop-up artwork
		block.NormalBG:Hide()

		-- pop-up final artwork
		block.FinalBG:Hide()

		-- pop-up glow
		block.GlowTexture:SetSize(width+20, 75)
	end

	-- Proving grounds
	local function SkinProvingGroundButtons()
		local block = ScenarioProvingGroundsBlock
		local sb = block.StatusBar
		local anim = ScenarioProvingGroundsBlockAnim

		block.MedalIcon:SetSize(42, 42)
		block.MedalIcon:ClearAllPoints()
		block.MedalIcon:SetPoint("TOPLEFT", block, 20, -10)

		block.WaveLabel:ClearAllPoints()
		block.WaveLabel:SetPoint("LEFT", block.MedalIcon, "RIGHT", 3, 0)

		block.BG:Hide()
		block.BG:SetSize(width + 21, 75)

		block.GoldCurlies:Hide()
		block.GoldCurlies:ClearAllPoints()
		block.GoldCurlies:SetPoint("TOPLEFT", block.BG, 6, -6)
		block.GoldCurlies:SetPoint("BOTTOMRIGHT", block.BG, -6, 6)

		anim.BGAnim:Hide()
		anim.BGAnim:SetSize(width + 45, 85)
		anim.BorderAnim:SetSize(width + 21, 75)
		anim.BorderAnim:Hide()
		anim.BorderAnim:ClearAllPoints()
		anim.BorderAnim:SetPoint("TOPLEFT", block.BG, 8, -8)
		anim.BorderAnim:SetPoint("BOTTOMRIGHT", block.BG, -8, 8)

		-- Timer
		sb:StripTextures()
		sb:CreateBackdrop('Transparent')
		sb.backdrop:Point('TOPLEFT', sb, -1, 1)
		sb.backdrop:Point('BOTTOMRIGHT', sb, 1, -1)
		sb:SetStatusBarTexture(E["media"].MuiFlat)
		sb:SetStatusBarColor(classColor.r, classColor.g, classColor.b)
		sb:ClearAllPoints()
		sb:SetPoint('TOPLEFT', block.MedalIcon, 'BOTTOMLEFT', -4, -5)
		sb:SetSize(200, 15)
	end

	local function OnClick(self)
		local textObject = self.text
		local text = textObject:GetText()

		if (text and text == "-") then
			textObject:SetText("+")
		else
			textObject:SetText("-")
		end
	end

	local minimizeButton = ObjectiveTrackerFrame.HeaderMenu.MinimizeButton
	minimizeButton:ClearAllPoints()
	minimizeButton:SetPoint("RIGHT", ObjectiveTrackerFrame.HeaderMenu, "LEFT", 0, -1)
	S:HandleButton(minimizeButton)
	minimizeButton:Size(16, 14)
	minimizeButton.text = minimizeButton:CreateFontString(nil, "OVERLAY")
	minimizeButton.text:FontTemplate()
	minimizeButton.text:Point("CENTER", minimizeButton, "CENTER", 0, 0)
	minimizeButton.text:SetText("-")
	minimizeButton.text:SetJustifyH("CENTER")
	minimizeButton.text:SetJustifyV("MIDDLE")
	minimizeButton:HookScript('OnClick', OnClick)

	-- Acts as quest difficulty/daily indicator
	local Dash = function(block)
	for i = 1, GetNumQuestWatches() do
			local questIndex = GetQuestIndexForWatch(i)
			if questIndex then
				local id = GetQuestWatchInfo(i)
				local block = QUEST_TRACKER_MODULE:GetBlock(id)
				local title, level, _, _, _, _, frequency = GetQuestLogTitle(questIndex)
				if block.lines then
					for key, line in pairs(block.lines) do
						if frequency == LE_QUEST_FREQUENCY_DAILY then
							local red, green, blue = 1/4, 6/9, 1
							line.Dash:SetVertexColor(red, green, blue)
						elseif frequency == LE_QUEST_FREQUENCY_WEEKLY then
							local red, green, blue = 0, 252/255, 177/255
							line.Dash:SetVertexColor(red, green, blue)
						else
							local col = GetQuestDifficultyColor(level)
							line.Dash:SetVertexColor(col.r, col.g, col.b)
						end
					end
				end
			end
		end
	end

	local QuestOnEnter = function()
		for i = 1, GetNumQuestWatches() do
			local id = GetQuestWatchInfo(i)
			if not id then break end
			local block = QUEST_TRACKER_MODULE:GetBlock(id)
			Dash()
		end
	end

	-- Hooks
	for i = 1, #otf.MODULES do
		local module = otf.MODULES[i]
		hooksecurefunc(module, "AddObjective", AddObjective)
		hooksecurefunc(module, "AddProgressBar", AddProgressBar)
		hooksecurefunc(module, "AddTimerBar", AddTimerBar)
		hooksecurefunc(_G["SCENARIO_TRACKER_MODULE"], "AddProgressBar", AddProgressBar1)
	end

	if IsAddOnLoaded('Blizzard_ObjectiveTracker') then
		hooksecurefunc(QUEST_TRACKER_MODULE, 'Update', Dash)
		hooksecurefunc(QUEST_TRACKER_MODULE, 'OnBlockHeaderEnter', QuestOnEnter)
		hooksecurefunc(QUEST_TRACKER_MODULE, 'OnBlockHeaderLeave', QuestOnEnter)
		hooksecurefunc(SCENARIO_CONTENT_TRACKER_MODULE, "Update", SkinScenarioButtons)
		hooksecurefunc("ScenarioBlocksFrame_OnLoad", SkinScenarioButtons)
		hooksecurefunc("Scenario_ProvingGrounds_ShowBlock", SkinProvingGroundButtons)
	end
end
S:RegisterSkin('ElvUI', ObjectiveTrackerReskin)
