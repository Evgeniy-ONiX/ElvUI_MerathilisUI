local MER, E, L, V, P, G = unpack(select(2, ...))
local module = MER:NewModule("MERAzeriteButtons", "AceEvent-3.0")
local S = E:GetModule('Skins')
local LCG = LibStub('LibCustomGlow-1.0')

-- Cache global variables
-- Lua functions
local _G = _G
local unpack = unpack
-- WoW API / Variables
local CreateFrame = CreateFrame
local C_Item_DoesItemExist = C_Item.DoesItemExist
local C_AzeriteEmpoweredItem_IsAzeriteEmpoweredItem = C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItem
local C_AzeriteEmpoweredItem_HasAnyUnselectedPowers = C_AzeriteEmpoweredItem.HasAnyUnselectedPowers
local OpenAzeriteEmpoweredItemUIFromItemLocation = OpenAzeriteEmpoweredItemUIFromItemLocation
local SocketInventoryItem = SocketInventoryItem
local IsAddOnLoaded = IsAddOnLoaded
local ItemLocation = ItemLocation
local UnitLevel = UnitLevel
-- GLOBALS:

function module:Createmoduleuttons()
	if not E.db.mui.armory.azeritebtn then return end

	local function Head_OnEnter(self)
		_G.GameTooltip:SetOwner(self, 'ANCHOR_TOPLEFT', 0, 4)
		_G.GameTooltip:ClearLines()
		_G.GameTooltip:AddLine(L["Open head slot azerite powers."])
		_G.GameTooltip:Show()
	end

	local function Head_OnLeave(self)
		_G.GameTooltip:Hide()
	end

	local Hbtn = CreateFrame("Button", "MER_Hbtn", _G["PaperDollFrame"], "UIPanelButtonTemplate")
	Hbtn.text = MER:CreateText(Hbtn, "OVERLAY", 12, nil)
	Hbtn.text:SetPoint("CENTER", 1, 0)
	Hbtn.text:SetJustifyV("MIDDLE")
	Hbtn.text:SetText(L["H"])
	Hbtn:SetScript('OnEnter', Head_OnEnter)
	Hbtn:SetScript('OnLeave', Head_OnLeave)
	Hbtn:SetScript("OnClick", function() module:openHead() end)
	MER_Hbtn = Hbtn
	S:HandleButton(Hbtn)

	local function Shoulder_OnEnter(self)
		_G.GameTooltip:SetOwner(self, 'ANCHOR_TOPLEFT', 0, 4)
		_G.GameTooltip:ClearLines()
		_G.GameTooltip:AddLine(L["Open shoulder slot azerite powers."])
		_G.GameTooltip:Show()
	end

	local function Shoulder_OnLeave(self)
		_G.GameTooltip:Hide()
	end

	local Sbtn = CreateFrame("Button", "MER_Sbtn", _G["PaperDollFrame"], "UIPanelButtonTemplate")
	Sbtn.text = MER:CreateText(Sbtn, "OVERLAY", 12, nil)
	Sbtn.text:SetPoint("CENTER", 1, 0)
	Sbtn.text:SetJustifyV("MIDDLE")
	Sbtn.text:SetText(L["S"])
	Sbtn:SetScript('OnEnter', Shoulder_OnEnter)
	Sbtn:SetScript('OnLeave', Shoulder_OnLeave)
	Sbtn:SetScript("OnClick", function() module:openShoulder() end)
	MER_Sbtn = Sbtn
	S:HandleButton(Sbtn)

	local function Chest_OnEnter(self)
		_G.GameTooltip:SetOwner(self, 'ANCHOR_TOPLEFT', 0, 4)
		_G.GameTooltip:ClearLines()
		_G.GameTooltip:AddLine(L["Open chest slot azerite powers."])
		_G.GameTooltip:Show()
	end

	local function Chest_OnLeave(self)
		_G.GameTooltip:Hide()
	end

	local Cbtn = CreateFrame("Button", "MER_Cbtn", _G["PaperDollFrame"], "UIPanelButtonTemplate")
	Cbtn.text = MER:CreateText(Cbtn, "OVERLAY", 12, nil)
	Cbtn.text:SetPoint("CENTER", 1, 0)
	Cbtn.text:SetJustifyV("MIDDLE")
	Cbtn.text:SetText(L["C"])
	Cbtn:SetScript('OnEnter', Chest_OnEnter)
	Cbtn:SetScript('OnLeave', Chest_OnLeave)
	Cbtn:SetScript("OnClick", function() module:openChest() end)
	MER_Cbtn = Cbtn
	S:HandleButton(Cbtn)

	Hbtn:SetFrameStrata("HIGH")
	Hbtn:SetSize(20, 20)

	Sbtn:SetFrameStrata("HIGH")
	Sbtn:SetSize(20, 20)

	Cbtn:SetFrameStrata("HIGH")
	Cbtn:SetSize(20, 20)

	if IsAddOnLoaded("ElvUI_SLE") then
		Hbtn:SetPoint("BOTTOMLEFT", _G["CharacterHeadSlot"], "TOPLEFT", -1, 4)
		Sbtn:SetPoint("BOTTOMLEFT", _G["CharacterHeadSlot"], "TOPLEFT", 20, 4)
		Cbtn:SetPoint("BOTTOMLEFT", _G["CharacterHeadSlot"], "TOPLEFT", 41, 4)
	else
		Hbtn:SetPoint("BOTTOMLEFT", _G["CharacterHeadSlot"], "TOPLEFT", 0, 4)
		Sbtn:SetPoint("BOTTOMLEFT", _G["CharacterHeadSlot"], "TOPLEFT", 21, 4)
		Cbtn:SetPoint("BOTTOMLEFT", _G["CharacterHeadSlot"], "TOPLEFT", 42, 4)
	end

	if UnitLevel("player") <= 107 then
		Hbtn:Hide()
		Sbtn:Hide()
		Cbtn:Hide()
	end
end

function module:PLAYER_ENTERING_WORLD()
	module:buttonHightlight()
end

function module:UNIT_INVENTORY_CHANGED()
	module:buttonHightlight()
end

function module:PLAYER_EQUIPMENT_CHANGED()
	module:buttonHightlight()
end

function module:AZERITE_EMPOWERED_ITEM_SELECTION_UPDATED()
	module:buttonHightlight()
end

function module:buttonHightlight()
	local itemLocation = ItemLocation:CreateFromEquipmentSlot(1)
	if C_Item_DoesItemExist(itemLocation) and C_AzeriteEmpoweredItem_IsAzeriteEmpoweredItem(itemLocation) then
		if C_AzeriteEmpoweredItem_HasAnyUnselectedPowers(itemLocation) then
			local r, g, b = unpack(E["media"].rgbvaluecolor)
			local color = {r, g, b, 1}

			if IsAddOnLoaded("ElvUI_SLE") then
				LCG.PixelGlow_Start(MER_Hbtn, color, nil, -0.25, nil, 2)
			else
				LCG.PixelGlow_Start(MER_Hbtn, color, nil, -0.25, nil, 2)
			end
		else
			if IsAddOnLoaded("ElvUI_SLE") then
				LCG.PixelGlow_Stop(MER_Hbtn)
			else
				LCG.PixelGlow_Stop(MER_Hbtn)
			end
		end
	else
		if IsAddOnLoaded("ElvUI_SLE") then
			LCG.PixelGlow_Stop(MER_Hbtn)
		else
			LCG.PixelGlow_Stop(MER_Hbtn)
		end
	end

	local itemLocation = ItemLocation:CreateFromEquipmentSlot(3)
	if C_Item_DoesItemExist(itemLocation) and C_AzeriteEmpoweredItem_IsAzeriteEmpoweredItem(itemLocation) then
		if C_AzeriteEmpoweredItem_HasAnyUnselectedPowers(itemLocation) then
			local r, g, b = unpack(E["media"].rgbvaluecolor)
			local color = {r, g, b, 1}

			if IsAddOnLoaded("ElvUI_SLE") then
				LCG.PixelGlow_Start(MER_Sbtn, color, nil, -0.25, nil, 1)
			else
				LCG.PixelGlow_Start(MER_Sbtn, color, nil, -0.25, nil, 1)
			end
		else
			if IsAddOnLoaded("ElvUI_SLE") then
				LCG.PixelGlow_Stop(MER_Sbtn)
			else
				LCG.PixelGlow_Stop(MER_Sbtn)
			end
		end
	else
		if IsAddOnLoaded("ElvUI_SLE") then
			LCG.PixelGlow_Stop(MER_Sbtn)
		else
			LCG.PixelGlow_Stop(MER_Sbtn)
		end
	end

	local itemLocationC = ItemLocation:CreateFromEquipmentSlot(5)
	if C_Item_DoesItemExist(itemLocationC) and C_AzeriteEmpoweredItem_IsAzeriteEmpoweredItem(itemLocationC) then
		if C_AzeriteEmpoweredItem_HasAnyUnselectedPowers(itemLocationC) then
			local r, g, b = unpack(E["media"].rgbvaluecolor)
			local color = {r, g, b, 1}

			if IsAddOnLoaded("ElvUI_SLE") then
				LCG.PixelGlow_Start(MER_Cbtn, color, nil, -0.25, nil, 1)
			else
				LCG.PixelGlow_Start(MER_Cbtn, color, nil, -0.25, nil, 1)
			end
		else
			if IsAddOnLoaded("ElvUI_SLE") then
				LCG.PixelGlow_Stop(MER_Cbtn)
			else
				LCG.PixelGlow_Stop(MER_Cbtn)
			end
		end
	else
		if IsAddOnLoaded("ElvUI_SLE") then
			LCG.PixelGlow_Stop(MER_Cbtn)
		else
			LCG.PixelGlow_Stop(MER_Cbtn)
		end
	end
end

function module:openHead()
	local itemLocation = ItemLocation:CreateFromEquipmentSlot(1)
	if C_Item_DoesItemExist(itemLocation) then
		if C_AzeriteEmpoweredItem_IsAzeriteEmpoweredItem(itemLocation) then
			OpenAzeriteEmpoweredItemUIFromItemLocation(itemLocation)
		else
			MER:Print(L["Equipped head is not an Azerite item."])
			SocketInventoryItem(1)
		end
	else
		MER:Print(L["No head item is equipped."])
	end
end

function module:openShoulder()
	local itemLocation = ItemLocation:CreateFromEquipmentSlot(3)
	if C_Item_DoesItemExist(itemLocation) then
		if C_AzeriteEmpoweredItem_IsAzeriteEmpoweredItem(itemLocation) then
			OpenAzeriteEmpoweredItemUIFromItemLocation(itemLocation)
		else
			MER:Print(L["Equipped shoulder is not an Azerite item."])
			SocketInventoryItem(3)
		end
	else
		MER:Print(L["No shoulder item is equipped."])
	end
end

function module:openChest()
	local itemLocation = ItemLocation:CreateFromEquipmentSlot(5)
	if C_Item_DoesItemExist(itemLocation) then
		if C_AzeriteEmpoweredItem_IsAzeriteEmpoweredItem(itemLocation) then
			OpenAzeriteEmpoweredItemUIFromItemLocation(itemLocation)
		else
			MER:Print(L["Equipped chest is not an Azerite item."])
			SocketInventoryItem(5)
		end
	else
		MER:Print(L["No chest item is equipped."])
	end
end

function module:Initialize()
	if E.db.mui.armory.azeritebtn ~= true or E.private.skins.blizzard.character ~= true or E.db.general.itemLevel.displayCharacterInfo ~= true then return end

	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("UNIT_INVENTORY_CHANGED")
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	self:RegisterEvent("AZERITE_EMPOWERED_ITEM_SELECTION_UPDATED")

	self:Createmoduleuttons()
end

MER:RegisterModule(module:GetName())