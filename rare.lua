--rare 簡易稀有警報
local an, at = ...
local addon = CreateFrame("Frame")
addon.vignettes = {}

local function OnEvent(self,event,id)
if id and not self.vignettes[id] then
local x, y, name, icon = C_Vignettes.GetVignetteInfoFromInstanceID(id)
--local left, right, top, bottom = GetObjectIconTextureCoords(icon)
local ricon = GetRaidTargetIndex(8)
ricon:SetHeight(18)
ricon:SetWidth(18)
PlaySound(13363)
--local str = "|TInterface\\MINIMAP\\OBJECTICONS:0:0:0:0:256:256:"..(left*256)..":"..(right*256)..":"..(top*256)..":"..(bottom*256).."|t"
local str = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_"..ricon
RaidNotice_AddMessage(RaidWarningFrame, str..(name or "Unknown").."", ChatTypeInfo["RAID_WARNING"])
print(str..""..name,"")
self.vignettes[id] = true
end
end
addon:RegisterEvent("VIGNETTE_ADDED")
addon:SetScript("OnEvent", OnEvent)

--[[
local ricon = GameTooltip:CreateTexture("GameTooltipRaidIcon", "OVERLAY")
ricon:SetHeight(18)
ricon:SetWidth(18)
ricon:SetPoint("TOP", "GameTooltip", "TOP", 0, 10)

	local raidIndex = GetRaidTargetIndex(unit)	--標記
	if raidIndex then
	ricon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_"..raidIndex)
	end
]]