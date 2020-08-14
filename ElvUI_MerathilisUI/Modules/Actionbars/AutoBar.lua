local MER, E, L, V, P, G = unpack(select(2, ...))
local module = MER:NewModule("AutoButtons", "AceEvent-3.0")
local MERS = MER:GetModule("muiSkins")

--Cache global variables
--Lua functions
local _G = _G
local pairs, select, tonumber, unpack = pairs, select, tonumber, unpack
local gsub = gsub
local tinsert, tsort, twipe = table.insert, table.sort, table.wipe
--WoW API / Variables
local CreateFrame = CreateFrame
local GetAddOnEnableState = GetAddOnEnableState
local C_QuestLog_GetInfo = C_QuestLog.GetInfo
local C_QuestLog_GetNumQuestWatches = C_QuestLog.GetNumQuestWatches
local GetMinimapZoneText = GetMinimapZoneText
local GetItemCount = GetItemCount
local GetQuestLogIndexByID = GetQuestLogIndexByID
local GetQuestLogSpecialItemInfo = GetQuestLogSpecialItemInfo
local GetQuestLogSpecialItemCooldown = GetQuestLogSpecialItemCooldown
local GetQuestWatchInfo = GetQuestWatchInfo
local GetInventoryItemTexture = GetInventoryItemTexture
local GetInventoryItemID = GetInventoryItemID
local GetInventoryItemCooldown = GetInventoryItemCooldown
local GetItemCooldown = GetItemCooldown
local GetItemIcon = GetItemIcon
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local GetItemSpell = GetItemSpell
local C_Map_GetBestMapForUnit = C_Map.GetBestMapForUnit
local C_TaskQuest_GetQuestsForPlayerByMapID = C_TaskQuest.GetQuestsForPlayerByMapID
local IsItemInRange = IsItemInRange
local InCombatLockdown = InCombatLockdown
local GetBindingKey = GetBindingKey
local UIParent = UIParent
local CooldownFrame_Set = CooldownFrame_Set
-- GLOBALS:

local MasqueGroup = MER.MSQ and MER.MSQ:Group("ElvUI_MerathilisUI", "AutoButton")
local useMasque = GetAddOnEnableState(E.myname, "Masque") == 2

local QuestItemList = {}
local garrisonsmv = {118897, 118903}
local garrisonsc = {114116, 114119, 114120, 120301, 120302}

_G.BINDING_HEADER_MER_AutoSlotButton = MER.Title..L["slotAutoButtons"]
_G.BINDING_HEADER_MER_AutoQuestButton = MER.Title..L["questAutoButtons"]
_G.BINDING_HEADER_MER_AutoUsableButton = MER.Title..L["usableAutoButtons"]

for i = 1, 12 do
	_G["BINDING_NAME_CLICK AutoSlotButton"..i..":LeftButton"] = L["slotAutoButtons"]..i
	_G["BINDING_NAME_CLICK AutoQuestButton"..i..":LeftButton"] = L["questAutoButtons"]..i
	_G["BINDING_NAME_CLICK AutoUsableButton"..i..":LeftButton"] = L["usableAutoButtons"]..i
end

local function GetQuestItemList()
	twipe(QuestItemList)
	for i = 1, C_QuestLog_GetNumQuestWatches() do
		local questID, title, questLogIndex, numObjectives, requiredMoney, isComplete, startEvent, isAutoComplete, failureTime, timeElapsed, questType, isTask, isStory, isOnMap, hasLocalPOI = C_QuestLog_GetInfo(i)
		if questLogIndex then
			local link, item, charges, showItemWhenComplete = GetQuestLogSpecialItemInfo(questLogIndex)
			if link then
				local itemID = tonumber(link:match(":(%d+):"))
				QuestItemList[itemID] = {
					["isComplete"] = isComplete,
					["showItemWhenComplete"] = showItemWhenComplete,
					["questLogIndex"] = questLogIndex,
				}
			end
		end
	end

	module:ScanItem("QUEST")
end

local function GetWorldQuestItemList(toggle)
	local mapID = C_Map_GetBestMapForUnit("player") or 0
	local taskInfo = C_TaskQuest_GetQuestsForPlayerByMapID(mapID)
	local isComplete

	if (taskInfo and #taskInfo > 0) then
		for i, info in pairs(taskInfo) do
			local questID = info.questId
			local questLogIndex = GetQuestLogIndexByID(questID)
			if questLogIndex then
				local link, item, charges, showItemWhenComplete = GetQuestLogSpecialItemInfo(questLogIndex)
				if link then
					local itemID = tonumber(link:match(":(%d+):"))
					QuestItemList[itemID] = {
						["isComplete"] = isComplete,
						["showItemWhenComplete"] = showItemWhenComplete,
						["questLogIndex"] = questLogIndex,
					}
				end
			end
		end
	end

	if (toggle ~= "init") then
		module:ScanItem("QUEST")
	end
end

local function HaveIt(num, spellName)
	if not spellName then return false end

	for i = 1, num do
		local AutoButton = _G["AutoQuestButton" .. i]
		if not AutoButton then break end
		if AutoButton.spellName == spellName then
			return false
		end
	end

	return true
end

local function IsUsableItem(itemId)
	local itemSpell = GetItemSpell(itemId)
	if not itemSpell then return false end

	return itemSpell
end

local function IsSlotItem(itemId)
	local itemSpell = IsUsableItem(itemId)
	local itemName = GetItemInfo(itemId)

	return itemSpell
end

local function AutoButtonHide(AutoButton)
	if not AutoButton then return end

	AutoButton:SetAlpha(0)
	if not InCombatLockdown() then
		AutoButton:EnableMouse(false)
	else
		AutoButton:RegisterEvent("PLAYER_REGEN_ENABLED")
		AutoButton:SetScript("OnEvent", function(self, event)
			if event == "PLAYER_REGEN_ENABLED" then
				self:EnableMouse(false)
				self:UnregisterEvent("PLAYER_REGEN_ENABLED")
			end
		end)
	end
end

local function HideAllButton(event)
	local i, k = 1, 1

	for i = k, 12 do
		AutoButtonHide(_G["AutoQuestButton" .. i])
	end

	for i = 1, 12 do
		AutoButtonHide(_G["AutoSlotButton" .. i])
	end

	for i = 1, 12 do
		AutoButtonHide(_G["AutoUsableButton" .. i])
	end
end

local function AutoButtonShow(AutoButton)
	if not AutoButton then return end

	AutoButton:SetAlpha(1)
	AutoButton:SetScript("OnEnter", function(self)
		if self:GetParent() == E.ActionBars.fadeParent then
			if(not E.ActionBars.fadeParent.mouseLock) then
				E:UIFrameFadeIn(E.ActionBars.fadeParent, 0.2, E.ActionBars.fadeParent:GetAlpha(), 1)
			end
		end
		if InCombatLockdown() then return end
		_G.GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 0, -2)
		_G.GameTooltip:ClearLines()
		if self.slotID then
			_G.GameTooltip:SetInventoryItem("player", self.slotID)
		else
			_G.GameTooltip:SetItemByID(self.itemID)
		end
		_G.GameTooltip:Show()
	end)
	AutoButton:SetScript("OnLeave", function(self)
		if self:GetParent() == E.ActionBars.fadeParent then
			if(not E.ActionBars.fadeParent.mouseLock) then
				E:UIFrameFadeOut(E.ActionBars.fadeParent, 0.2, E.ActionBars.fadeParent:GetAlpha(), 1 - E.ActionBars.db.globalFadeAlpha)
			end
		end
		_G.GameTooltip:Hide()
	end)

	if not InCombatLockdown() then
		AutoButton:EnableMouse(true)
		if AutoButton.slotID then
			AutoButton:SetAttribute("type", "macro")
			AutoButton:SetAttribute("macrotext", "/use " .. AutoButton.slotID)
		elseif AutoButton.itemName then
			AutoButton:SetAttribute("type", "item")
			AutoButton:SetAttribute("item", AutoButton.itemName)
		end
	else
		AutoButton:RegisterEvent("PLAYER_REGEN_ENABLED")
		AutoButton:SetScript("OnEvent", function(self, event)
			if event == "PLAYER_REGEN_ENABLED" then
				self:EnableMouse(true)
				if self.slotID then
					self:SetAttribute("type", "macro")
					self:SetAttribute("macrotext", "/use " .. self.slotID)
				elseif self.itemName then
					self:SetAttribute("type", "item")
					self:SetAttribute("item", self.itemName)
				end
				self:UnregisterEvent("PLAYER_REGEN_ENABLED")
			end
		end)
	end
end

local function CreateButton(name, size)
	if _G[name] then
		_G[name]:SetSize(size, size)
		_G[name].Count:FontTemplate(nil, module.db.countFontSize, "OUTLINE")
		_G[name].HotKey:FontTemplate(nil, module.db.bindFontSize, "OUTLINE")

		return _G[name]
	end

	local AutoButton = CreateFrame("Button", name, E.UIParent, "SecureActionButtonTemplate")
	AutoButton:SetSize(size, size)
	AutoButton:StyleButton()
	if not useMasque then
		AutoButton:CreateBackdrop()
	end
	AutoButton:SetClampedToScreen(true)
	AutoButton:SetAttribute("type", "item")
	AutoButton:SetAlpha(0)
	AutoButton:EnableMouse(false)
	AutoButton:RegisterForClicks("AnyUp")

	AutoButton.Texture = AutoButton:CreateTexture(nil, "OVERLAY", nil)
	AutoButton.Texture:SetPoint("TOPLEFT", AutoButton, "TOPLEFT", 2, -2)
	AutoButton.Texture:SetPoint("BOTTOMRIGHT", AutoButton, "BOTTOMRIGHT", -2, 2)
	AutoButton.Texture:SetTexCoord(unpack(E.TexCoords))

	AutoButton.Count = AutoButton:CreateFontString(nil, "OVERLAY")
	AutoButton.Count:FontTemplate(nil, module.db.countFontSize, "OUTLINE")
	AutoButton.Count:SetTextColor(1, 1, 1, 1)
	AutoButton.Count:SetPoint("BOTTOMRIGHT", AutoButton, "BOTTOMRIGHT", 0, 0)
	AutoButton.Count:SetJustifyH("CENTER")

	AutoButton.HotKey = AutoButton:CreateFontString(nil, "OVERLAY")
	AutoButton.HotKey:FontTemplate(nil, module.db.bindFontSize, "OUTLINE")
	AutoButton.HotKey:SetTextColor(1, 1, 1)
	AutoButton.HotKey:SetPoint("TOPRIGHT", AutoButton, "TOPRIGHT", 0, 0)
	AutoButton.HotKey:SetJustifyH("RIGHT")

	AutoButton.Cooldown = CreateFrame("Cooldown", nil, AutoButton, "CooldownFrameTemplate")
	AutoButton.Cooldown:SetPoint("TOPLEFT", AutoButton, "TOPLEFT", 2, -2)
	AutoButton.Cooldown:SetPoint("BOTTOMRIGHT", AutoButton, "BOTTOMRIGHT", -2, 2)
	AutoButton.Cooldown:SetSwipeColor(1, 1, 1, 1)
	AutoButton.Cooldown:SetDrawBling(false)

	AutoButton.Cooldown.CooldownOverride = 'actionbar'
	E:RegisterCooldown(AutoButton.Cooldown)
	E.FrameLocks[name] = true

	-- Needed for Masque
	local AutoButtonData = {
		FloatingBG = nil,
		Icon = AutoButton.Texture,
		Cooldown = AutoButton.Cooldown,
		Flash = nil,
		Pushed = nil,
		Normal = nil,
		Disabled = nil,
		Checked = nil,
		Border = nil,
		AutoCastable = nil,
		Highlight = nil,
		HotKey = AutoButton.HotKey,
		Count = false,
		Name = nil,
		Duration = false,
		AutoCast = nil,
	}

	if MER.MSQ then
		MasqueGroup:AddButton(AutoButton, AutoButtonData)
	end

	return AutoButton
end

function module:ScanItem(event)
	local db = E.db.mui.actionbars.autoButtons

	HideAllButton(event)
	--GetWorldQuestItemList("init")

	local questItemIDList = {}
	local usableItemIDList = {}
	local minimapZoneText = GetMinimapZoneText()

	-- Garrison related
	if minimapZoneText == L["Alliance Mine"] or minimapZoneText == L["Horde Mine"] then
		for i = 1, #garrisonsmv do
			local count = GetItemCount(garrisonsmv[i])
			if count and (count > 0) and (not db.blackList[garrisonsmv[i]]) then
				tinsert(questItemIDList, garrisonsmv[i])
			end
		end
	elseif minimapZoneText == L["Salvage Yard"] then
		for i = 1, #garrisonsc do
			local count = GetItemCount(garrisonsc[i])
			if count and (count > 0) and (not db.blackList[garrisonsc[i]]) then
				tinsert(questItemIDList, garrisonsc[i])
			end
		end
	end

	-- Quest Items
	for k, v in pairs(QuestItemList) do
		if (not QuestItemList[k].isComplete) or (QuestItemList[k].isComplete and QuestItemList[k].showItemWhenComplete) then
			if not db.blackList[k] then
				tinsert(questItemIDList, k)
			end
		end
	end

	-- Usable Items
	for k, v in pairs(db.whiteList) do
		local count = GetItemCount(k)
		if count and (count > 0) and v and (not db.blackList[k]) then
			tinsert(usableItemIDList, k)
		end
	end

	if GetItemCount(123866) and (GetItemCount(123866) >= 5) and (not db.blackList[123866]) and (C_Map_GetBestMapForUnit("player") == 945) then
		tinsert(usableItemIDList, 123866)
	end

	-- Sort our tables
	tsort(questItemIDList, function(v1, v2)
		local itemType1 = select(7, GetItemInfo(v1))
		local itemType2 = select(7, GetItemInfo(v2))
		if itemType1 and itemType2 then
			return itemType1 > itemType2
		else
			return v1 > v2
		end
	end)

	tsort(usableItemIDList, function(v1, v2)
		local itemType1 = select(7, GetItemInfo(v1))
		local itemType2 = select(7, GetItemInfo(v2))
		if itemType1 and itemType2 then
			return itemType1 > itemType2
		else
			return v1 > v2
		end
	end)

	if db.questAutoButtons["enable"] == true and db.questAutoButtons["questNum"] > 0 then
		for i = 1, #questItemIDList do
			local itemID = questItemIDList[i]
			local itemName, _, rarity = GetItemInfo(itemID)

			if i > db.questAutoButtons["questNum"] then break end

			local AutoButton = _G["AutoQuestButton" .. i]
			local count = GetItemCount(itemID, nil, 1)
			local itemIcon = GetItemIcon(itemID)

			if not AutoButton then break end
			AutoButton.Texture:SetTexture(itemIcon)
			AutoButton.itemName = itemName
			AutoButton.itemID = itemID
			AutoButton.ap = false
			AutoButton.questLogIndex = QuestItemList[itemID] and QuestItemList[itemID].questLogIndex or -1
			AutoButton.spellName = IsUsableItem(itemID)
			AutoButton.backdrop:SetBackdropBorderColor(nil)

			if db.questAutoButtons["questBBColorByItem"] then
				if rarity and rarity > Enum.ItemQuality.Common then
					local r, g, b = GetItemQualityColor(rarity)
					AutoButton.backdrop:SetBackdropBorderColor(r, g, b)
				else
					AutoButton.backdrop:SetBackdropBorderColor(1, 1, 1)
				end
			else
				local colorDB = db.questAutoButtons["questBBColor"]
				local r, g, b = colorDB.r, colorDB.g, colorDB.b
				AutoButton.backdrop:SetBackdropBorderColor(r, g, b)
			end

			if count and count > 1 then
				AutoButton.Count:SetText(count)
			else
				AutoButton.Count:SetText("")
			end

			AutoButton:SetScript("OnUpdate", function(self, elapsed)
				local start, duration, enable
				if self.questLogIndex > 0 then
					start, duration, enable = GetQuestLogSpecialItemCooldown(self.questLogIndex)
				else
					start, duration, enable = GetItemCooldown(self.itemID)
				end
				CooldownFrame_Set(self.Cooldown, start, duration, enable)
				if (duration and duration > 0 and enable and enable == 0) then
					self.Texture:SetVertexColor(0.4, 0.4, 0.4)
				elseif IsItemInRange(itemID, "target") == 0 then
					self.Texture:SetVertexColor(1, 0, 0)
				else
					self.Texture:SetVertexColor(1, 1, 1)
				end
			end)
			AutoButtonShow(AutoButton)
		end
	end

	local num = 0
	if db.slotAutoButtons["enable"] == true and db.slotAutoButtons["slotNum"] > 0 then
		for w = 1, 18 do
			local slotID = GetInventoryItemID("player", w)
			if slotID and IsSlotItem(slotID) and not db.blackList[slotID] then
				local itemName, _, rarity = GetItemInfo(slotID)
				local itemIcon = GetInventoryItemTexture("player", w)
				num = num + 1
				if num > db.slotAutoButtons["slotNum"] then break end

				local AutoButton = _G["AutoSlotButton" .. num]
				if not AutoButton then break end

				AutoButton.backdrop:SetBackdropBorderColor(nil)

				local r, g, b, colorDB
				if db.slotAutoButtons["slotBBColorByItem"] then
					if rarity then
						r, g, b = GetItemQualityColor(rarity)
						AutoButton.backdrop:SetBackdropBorderColor(r, g, b)
						AutoButton.ignoreBorderColors = true
					end
				else
					colorDB = db.slotAutoButtons["slotBBColor"]
					r, g, b = colorDB.r, colorDB.g, colorDB.b
					AutoButton.backdrop:SetBackdropBorderColor(r, g, b)
					AutoButton.ignoreBorderColors = true
				end

				AutoButton.Texture:SetTexture(itemIcon)
				AutoButton.Count:SetText("")
				AutoButton.slotID = w
				AutoButton.itemID = slotID
				AutoButton.spellName = IsUsableItem(slotID)

				AutoButton:SetScript("OnUpdate", function(self, elapsed)
					local cd_start, cd_finish, cd_enable = GetInventoryItemCooldown("player", self.slotID)
					CooldownFrame_Set(AutoButton.Cooldown, cd_start, cd_finish, cd_enable)
				end)
				AutoButtonShow(AutoButton)
			end
		end
	end

	if db.usableAutoButtons["enable"] == true and db.usableAutoButtons["usableNum"] > 0 then
		for i = 1, #usableItemIDList do
			local itemID = usableItemIDList[i]
			local itemName, _, rarity = GetItemInfo(itemID)

			if i > db.usableAutoButtons["usableNum"] then break end

			local AutoButton = _G["AutoUsableButton" .. i]
			local count = GetItemCount(itemID, nil, 1)
			local itemIcon = GetItemIcon(itemID)

			if not AutoButton then break end
			AutoButton.Texture:SetTexture(itemIcon)
			AutoButton.itemName = itemName
			AutoButton.itemID = itemID
			AutoButton.spellName = IsUsableItem(itemID)
			AutoButton.backdrop:SetBackdropBorderColor(nil)

			if db.usableAutoButtons["usableBBColorByItem"] then
				if rarity and rarity > Enum.ItemQuality.Common then
					local r, g, b = GetItemQualityColor(rarity)
					AutoButton.backdrop:SetBackdropBorderColor(r, g, b)
				else
					AutoButton.backdrop:SetBackdropBorderColor(1, 1, 1)
				end
			else
				local colorDB = db.usableAutoButtons["usableBBColor"]
				local r, g, b = colorDB.r, colorDB.g, colorDB.b
				AutoButton.backdrop:SetBackdropBorderColor(r, g, b)
			end

			if count and count > 1 then
				AutoButton.Count:SetText(count)
			else
				AutoButton.Count:SetText("")
			end

			AutoButton:SetScript("OnUpdate", function(self, elapsed)
				local start, duration, enable
				start, duration, enable = GetItemCooldown(self.itemID)
				CooldownFrame_Set(self.Cooldown, start, duration, enable)
				if (duration and duration > 0 and enable and enable == 0) then
					self.Texture:SetVertexColor(0.4, 0.4, 0.4)
				elseif IsItemInRange(itemID, "target") == 0 then
					self.Texture:SetVertexColor(1, 0, 0)
				else
					self.Texture:SetVertexColor(1, 1, 1)
				end
			end)
			AutoButtonShow(AutoButton)
		end
	end
end

local lastUpdate = 0
function module:ScanItemCount(elapsed)
	local db = E.db.mui.actionbars.autoButtons
	lastUpdate = lastUpdate + elapsed

	if lastUpdate < 0.5 then
		return
	end

	lastUpdate = 0
	for i = 1, db.questAutoButtons["questNum"] do
		local f = _G["AutoQuestButton" .. i]
		if f and f.itemName then
			local count = GetItemCount(f.itemID, nil, 1)

			if count and count > 1 then
				f.Count:SetText(count)
			else
				f.Count:SetText("")
			end
		end
	end

	for i = 1, db.usableAutoButtons["usableNum"] do
		local f = _G["AutoUsableButton" .. i]
		if f and f.itemName then
			local count = GetItemCount(f.itemID, nil, 1)

			if count and count > 1 then
				f.Count:SetText(count)
			else
				f.Count:SetText("")
			end
		end
	end
end

function module:UpdateBind()
	if not module.db then return end

	if module.db.questAutoButtons["enable"] == true then
		for i = 1, module.db.questAutoButtons["questNum"] do
			local bindButton = "CLICK AutoQuestButton" .. i .. ":LeftButton"
			local button = _G["AutoQuestButton" .. i]
			local bindText = GetBindingKey(bindButton)
			if not bindText then
				bindText = ""
			else
				bindText = gsub(bindText, "SHIFT--", "S")
				bindText = gsub(bindText, "CTRL--", "C")
				bindText = gsub(bindText, "ALT--", "A")
			end

			if button then button.HotKey:SetText(bindText) end
		end
	end

	if module.db.slotAutoButtons["enable"] == true then
		for i = 1, module.db.slotAutoButtons["slotNum"] do
			local bindButton = "CLICK AutoSlotButton" .. i .. ":LeftButton"
			local button = _G["AutoSlotButton" .. i]
			local bindText = GetBindingKey(bindButton)
			if not bindText then
				bindText = ""
			else
				bindText = gsub(bindText, "SHIFT--", "S")
				bindText = gsub(bindText, "CTRL--", "C")
				bindText = gsub(bindText, "ALT--", "A")
			end

			if button then button.HotKey:SetText(bindText) end
		end
	end

	if module.db.usableAutoButtons["enable"] == true then
		for i = 1, module.db.usableAutoButtons["usableNum"] do
			local bindButton = "CLICK AutoUsableButton" .. i .. ":LeftButton"
			local button = _G["AutoUsableButton" .. i]
			local bindText = GetBindingKey(bindButton)
			if not bindText then
				bindText = ""
			else
				bindText = gsub(bindText, "SHIFT--", "S")
				bindText = gsub(bindText, "CTRL--", "C")
				bindText = gsub(bindText, "ALT--", "A")
			end

			if button then button.HotKey:SetText(bindText) end
		end
	end
end

function module:ToggleAutoButton()
	if module.db["enable"] then
		self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", "ScanItem")
		self:RegisterEvent("UNIT_INVENTORY_CHANGED", "ScanItem")
		self:RegisterEvent("ZONE_CHANGED", "ScanItem")
		self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "ScanItem")
		self:RegisterEvent("UPDATE_BINDINGS", "UpdateBind")
		self:RegisterEvent("QUEST_WATCH_LIST_CHANGED", GetQuestItemList)
		self:RegisterEvent("QUEST_LOG_UPDATE", GetQuestItemList)
		--self:RegisterEvent("QUEST_ACCEPTED", GetWorldQuestItemList)
		--self:RegisterEvent("QUEST_TURNED_IN", GetWorldQuestItemList)

		if not module.Update then module.Update = CreateFrame("Frame") end
		self.Update:SetScript("OnUpdate", module.ScanItemCount)
		self:ScanItem("FIRST")
		self:UpdateBind()
	else
		HideAllButton()
		self:UnregisterEvent("PLAYER_SPECIALIZATION_CHANGED")
		self:UnregisterEvent("UNIT_INVENTORY_CHANGED")
		self:UnregisterEvent("ZONE_CHANGED")
		self:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
		self:UnregisterEvent("UPDATE_BINDINGS")
		self:UnregisterEvent("QUEST_WATCH_LIST_CHANGED")
		self:UnregisterEvent("QUEST_LOG_UPDATE")
		if self.Update then self.Update:SetScript("OnUpdate", nil) end
	end
end

local buttonTypes = { "quest", "slot", "usable" }
function module:UpdateAutoButton()
	local i = 0
	local lastButton, lastColumnButton, buttonsPerRow

	for index, btype in pairs(buttonTypes) do
		local db = module.db[btype.."AutoButtons"]
		local buttonName = "Auto"..E:StringTitle(btype).."Button"
		if db["enable"] == true then
			for i = 1, db[btype.."Num"] do
				local f = CreateButton(buttonName .. i, db[btype.."Size"])
				buttonsPerRow = db[btype.."PerRow"]
				lastButton = _G[buttonName .. i - 1]
				lastColumnButton = _G[buttonName .. i - buttonsPerRow]

				if db[btype.."Num"] < db[btype.."PerRow"] then
					buttonsPerRow = db[btype.."Num"]
				end
				f:ClearAllPoints()

				if i == 1 then
					f:SetPoint("LEFT", _G["AutoButtonAnchor"..index], "LEFT", 0, 0)
				elseif (i - 1) % buttonsPerRow == 0 then
					f:SetPoint("TOP", lastColumnButton, "BOTTOM", 0, -3)
				else
					if db[btype.."Direction"] == "RIGHT" then
						f:SetPoint("LEFT", lastButton, "RIGHT", db[btype.."Space"], 0)
					elseif db[btype.."Direction"] == "LEFT" then
						f:SetPoint("RIGHT", lastButton, "LEFT", -(db[btype.."Space"]), 0)
					end
				end

				if db["inheritGlobalFade"] == true then
					f:SetParent(E.ActionBars.fadeParent)
				else
					f:SetParent(E.UIParent)
				end
			end
		end
	end

	self:ToggleAutoButton()
end

function module:Initialize()
	module.db = E.db.mui.actionbars.autoButtons
	if module.db.enable ~= true then return end

	MER:RegisterDB(self, "autoButtons")

	function module:ForUpdateAll()
		module.db = E.db.mui.actionbars.autoButtons
	end

	self:ForUpdateAll()

	local AutoButtonAnchor1 = CreateFrame("Frame", "AutoButtonAnchor1", UIParent)
	AutoButtonAnchor1:SetClampedToScreen(true)
	AutoButtonAnchor1:SetPoint("BOTTOMLEFT", _G.RightChatPanel or _G.LeftChatPanel, "TOPLEFT", 0, 90)
	AutoButtonAnchor1:SetSize(module.db.questAutoButtons.questNum > 0 and module.db.questAutoButtons.questSize * module.db.questAutoButtons.questNum or 260, module.db.questAutoButtons.questNum > 0 and module.db.questAutoButtons.questSize or 40)
	E:CreateMover(AutoButtonAnchor1, "MER_AutoButtonAnchor1Mover", L["AutoButton Quest"], nil, nil, nil, "ALL,ACTIONBARS,MERATHILISUI", function() return module.db.enable end, 'mui,modules,actionbars,autoButtons')

	local AutoButtonAnchor2 = CreateFrame("Frame", "AutoButtonAnchor2", UIParent)
	AutoButtonAnchor2:SetClampedToScreen(true)
	AutoButtonAnchor2:SetPoint("BOTTOMLEFT", _G.RightChatPanel or _G.LeftChatPanel, "TOPLEFT", 0, 48)
	AutoButtonAnchor2:SetSize(module.db.slotAutoButtons.slotNum > 0 and module.db.slotAutoButtons.slotSize * module.db.slotAutoButtons.slotNum or 260, module.db.slotAutoButtons.slotNum > 0 and module.db.slotAutoButtons.slotSize or 40)
	E:CreateMover(AutoButtonAnchor2, "MER_AutoButtonAnchor2Mover", L["AutoButton Inventory"], nil, nil, nil, "ALL,ACTIONBARS,MERATHILISUI", function() return module.db["enable"] end, 'mui,modules,actionbars,autoButtons')

	local AutoButtonAnchor3 = CreateFrame("Frame", "AutoButtonAnchor3", UIParent)
	AutoButtonAnchor3:SetClampedToScreen(true)
	AutoButtonAnchor3:SetPoint("BOTTOMLEFT", _G.RightChatPanel or _G.LeftChatPanel, "TOPLEFT", 0, 4)
	AutoButtonAnchor3:SetSize(module.db.usableAutoButtons.usableNum > 0 and module.db.usableAutoButtons.usableSize * module.db.usableAutoButtons.usableNum or 260, module.db.usableAutoButtons.usableNum > 0 and module.db.usableAutoButtons.usableSize or 40)
	E:CreateMover(AutoButtonAnchor3, "MER_AutoButtonAnchor3Mover", L["AutoButton Usables"], nil, nil, nil, "ALL,ACTIONBARS,MERATHILISUI", function() return module.db["enable"] end, 'mui,modules,actionbars,autoButtons')

	self:UpdateAutoButton()
end

MER:RegisterModule(module:GetName())
