--------------------------
-- SyDurGlow.lua
-- Date: 2017/4/3
--------------------------
local  q, vl
local _G = getfenv(0)
local SlotDurStrs = {}
local items = {
	"Head 1",
	"Neck",
	"Shoulder 2",
	"Shirt",
	"Chest 3",
	"Waist 4",
	"Legs 5",
	"Feet 6",
	"Wrist 7",
	"Hands 8",
	"Finger0",
	"Finger1",
	"Trinket0",
	"Trinket1",
	"Back",
	"MainHand 9",
	"SecondaryHand 10",
	"Tabard",
}

-------------------------------- Durability show ---------------------------------

local tooltip = CreateFrame("GameTooltip")
tooltip:SetOwner(WorldFrame, "ANCHOR_NONE")

PaperDollFrame:CreateFontString("SyDurRepairCost", "ARTWORK", "NumberFontNormal")
SyDurRepairCost:SetPoint("BOTTOMLEFT", "PaperDollFrame", "BOTTOMLEFT", 8, 13)

local function GetDurStrings(name)
	if(not SlotDurStrs[name]) then
		local slot = _G["Character" .. name .. "Slot"]
		SlotDurStrs[name] = slot:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
		SlotDurStrs[name]:SetPoint("CENTER", slot, "TOP", 0, -10)
	end
	return SlotDurStrs[name]
end

local function UpdateDurability()
	local durcost = 0

	for id, vl in pairs(items) do
		local slot, index = string.split(" ", vl)
		if index then
			local has, _, cost = tooltip:SetInventoryItem("player", id);
			local value, max = GetInventoryItemDurability(id)
			local SlotDurStr = GetDurStrings(slot)
			if(has and value and max and max ~= 0) then
				local percent = value / max				
				SlotDurStr:SetText('')
				if(ceil(percent * 100) < 100)then
					SlotDurStr:SetTextColor(1 - percent, percent, 0)
					SlotDurStr:SetText(ceil(percent * 100) .. "%")
				end
				durcost = durcost + cost
			else
				 SlotDurStr:SetText("")
			end
		end
	end

	SyDurRepairCost:SetText(GetMoneyString(durcost))
end


--裝等顯示 (觀察視窗)
local slot = {"Head","Neck","Shoulder","Shirt","Chest","Waist","Legs","Feet","Wrist","Hands","Finger0","Finger1","Trinket0","Trinket1","Back","MainHand","SecondaryHand","Tabard"}

local ilv = {}

local function createIlvText(slotName)
   if not ilv[slotName] then
      local fs = _G[slotName]:CreateFontString(nil, "OVERLAY")
      fs:SetPoint("BOTTOMLEFT", _G[slotName], "BOTTOMLEFT", 0, 0)
      fs:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
      ilv[slotName] = fs
   end
end

for k, v in pairs(slot) do createIlvText("Character"..v.."Slot") end

local function checkItem(unit, frame)
   if unit then
      for k, v in pairs(slot) do
         local itemLink = GetInventoryItemLink(unit, k)
         if itemLink then
            local _,_,itemQuality,itemLv = GetItemInfo(itemLink)
            local r,g,b = GetItemQualityColor(itemQuality)
            ilv[frame..v.."Slot"]:SetText(itemLv)
            ilv[frame..v.."Slot"]:SetTextColor(r,g,b)
         else
            ilv[frame..v.."Slot"]:SetText()
         end
      end
   end
end

_G["CharacterFrame"]:HookScript("OnShow", function(self)
   checkItem("player", "Character")
   self:RegisterEvent("UNIT_MODEL_CHANGED")
end)

_G["CharacterFrame"]:HookScript("OnHide", function(self)
   self:UnregisterEvent("UNIT_MODEL_CHANGED")
end)

_G["CharacterFrame"]:HookScript("OnEvent", function(self, event)
   if event == "UNIT_MODEL_CHANGED" then checkItem("player", "Character") end
end)

local F = CreateFrame("Frame")
   F:RegisterEvent("ADDON_LOADED")
   F:SetScript("OnEvent", function(self, event, addon)
      if addon == "Blizzard_InspectUI" then
         self:UnregisterEvent("ADDON_LOADED")
         self:SetScript("OnEvent", nil)

         for k, v in pairs(slot) do createIlvText("Inspect"..v.."Slot") end
         checkItem(_G["InspectFrame"].unit, "Inspect")

         _G["InspectFrame"]:HookScript("OnShow", function()
            self:RegisterEvent("INSPECT_READY")
            self:RegisterEvent("UNIT_MODEL_CHANGED")
            self:RegisterEvent("PLAYER_TARGET_CHANGED")
            self:SetScript("OnEvent", function() checkItem(_G["InspectFrame"].unit, "Inspect") end)
         end)

         _G["InspectFrame"]:HookScript("OnHide", function()
            self:UnregisterEvent("PLAYER_TARGET_CHANGED")
            self:UnregisterEvent("UNIT_MODEL_CHANGED")
            self:UnregisterEvent("INSPECT_READY")
            self:SetScript("OnEvent", nil)
         end)

      end
   end)


----------------------------------- Event --------------------------------------
local f = CreateFrame("Frame")
f:Hide()
f:RegisterEvent("UNIT_INVENTORY_CHANGED")
f:RegisterEvent("UPDATE_INVENTORY_DURABILITY")

f:SetScript("OnEvent", function(self, event, ...)
	if event == "UPDATE_INVENTORY_DURABILITY" then
		UpdateDurability()
	elseif event == "UNIT_INVENTORY_CHANGED" then
		UpdateDurability()
	end
end)
