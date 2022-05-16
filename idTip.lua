--	Spell/Item IDs(idTip by Silverwind)
local hooksecurefunc, select, UnitBuff, UnitDebuff, UnitAura, UnitGUID,
      GetGlyphSocketInfo, tonumber, strfind
    = hooksecurefunc, select, UnitBuff, UnitDebuff, UnitAura, UnitGUID,
      GetGlyphSocketInfo, tonumber, strfind
local types = {
	spell = "法術ID:",
	item  = "物品ID:"
}

local function addLine(tooltip, id, type)
	local found = false

	-- Check if we already added to this tooltip. Happens on the talent frame
	for i = 1,15 do
		local frame = _G[tooltip:GetName() .. "TextLeft" .. i]
		local text
		if frame then text = frame:GetText() end
		if text and text == type then found = true break end
	end

	if not found then
		tooltip:AddDoubleLine(type, "|cffffffff" .. id)
		tooltip:Show()
	end
end

-- All types, primarily for detached tooltips
local function onSetHyperlink(self, link)
	local type, id = string.match(link,"^(%a+):(%d+)")
	if not type or not id then return end
	if type == "spell" or type == "enchant" or type == "trade" then
		addLine(self, id, types.spell)
	elseif type == "item" then
		addLine(self, id, types.item)
	end
end

hooksecurefunc(ItemRefTooltip, "SetHyperlink", onSetHyperlink)
hooksecurefunc(GameTooltip, "SetHyperlink", onSetHyperlink)

-- Spells
hooksecurefunc(GameTooltip, "SetUnitBuff", function(self, ...)
	local id = select(11, UnitBuff(...))
	if id then addLine(self, id, types.spell) end
end)

hooksecurefunc(GameTooltip, "SetUnitDebuff", function(self,...)
	local id = select(11, UnitDebuff(...))
	if id then addLine(self, id, types.spell) end
end)

hooksecurefunc(GameTooltip, "SetUnitAura", function(self,...)
	local id = select(11, UnitAura(...))
	if id then addLine(self, id, types.spell) end
end)

hooksecurefunc("SetItemRef", function(link, ...)
	local id = tonumber(link:match("spell:(%d+)"))
	if id then addLine(ItemRefTooltip, id, types.spell) end
end)

GameTooltip:HookScript("OnTooltipSetSpell", function(self)
	local id = select(3, self:GetSpell())
	if id then addLine(self, id, types.spell) end
end)

-- Items
local function attachItemTooltip(self)
	local link = select(2, self:GetItem())
	if link then
		local id = string.match(link, "item:(%d*)")
		if (id == "" or id == "0") and TradeSkillFrame ~= nil and TradeSkillFrame:IsVisible() and GetMouseFocus().reagentIndex then
			local selectedRecipe = TradeSkillFrame.RecipeList:GetSelectedRecipeID()
			for i = 1, 8 do
				if GetMouseFocus().reagentIndex == i then
					id = C_TradeSkillUI.GetRecipeReagentItemLink(selectedRecipe, i):match("item:(%d+):") or nil
					break
				end
			end
		end
		if id and id ~= "" then
			addLine(self, id, types.item)
		end
	end
end

GameTooltip:HookScript("OnTooltipSetItem", attachItemTooltip)
ItemRefTooltip:HookScript("OnTooltipSetItem", attachItemTooltip)
ItemRefShoppingTooltip1:HookScript("OnTooltipSetItem", attachItemTooltip)
ItemRefShoppingTooltip2:HookScript("OnTooltipSetItem", attachItemTooltip)
ShoppingTooltip1:HookScript("OnTooltipSetItem", attachItemTooltip)
ShoppingTooltip2:HookScript("OnTooltipSetItem", attachItemTooltip)


--CastBy
local cc = {}
local CUSTOM_CLASS_COLORS = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS
do
	for class, c in pairs(CUSTOM_CLASS_COLORS) do
		cc[class] = format('|cff%02x%02x%02x', c.r*255, c.g*255, c.b*255)
	end
end

local function SetCaster(self, unit, index, filter)
	local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable = UnitAura(unit, index, filter)
	if unitCaster then
		local uname, urealm = UnitName(unitCaster)
		local _, uclass = UnitClass(unitCaster)
		if urealm then uname = uname..'-'..urealm end
		self:AddDoubleLine('by: ',(cc[uclass] or '|cffffffff') ..uname ..'')
		self:Show()
	end
end
hooksecurefunc(GameTooltip, 'SetUnitAura', SetCaster)