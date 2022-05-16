--Interrupt 斷法提示
local Interrupt = CreateFrame("frame")
Interrupt:SetScript("OnEvent",function(self, event, ...)

local EventType, SourceName, DestName, SpellID, ExtraskillID = select(2, ...), select(5, ...), select(9, ...), select(12, ...), select(15, ...)
local icon = GetSpellTexture(SpellID)
local ExtraskillID = GetSpellLink(ExtraskillID)

	if EventType=="SPELL_INTERRUPT" then
	if SourceName==UnitName("player") then
		m = GetSpellLink(SpellID).."打斷 ["..DestName.."] 的"..ExtraskillID
		if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and IsInInstance() then
			SendChatMessage(m, "INSTANCE_CHAT")
		elseif IsInRaid() then
			SendChatMessage(m, "RAID")
		elseif GetNumSubgroupMembers() ~= nil and GetNumSubgroupMembers() > 0 then
			SendChatMessage(m, "PARTY")
		end
	end
	RaidNotice_AddMessage(RaidWarningFrame,"|cffFFFF00"..SourceName.."|r"..ACTION_SPELL_INTERRUPT.."".."|cffFF1111"..DestName.."|r的".."\124T"..icon..":17:17:0:0:64:64:5:59:5:59\124t\124cff71d5ff\124Hspell:"..SpellID.."\124h"..ExtraskillID.."\124h\124r!",{g=1,b=1})
	end
end)
Interrupt:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")