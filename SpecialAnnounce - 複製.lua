﻿-- 通報系統整合
-- 來源：ShestakUI
-- 修改：houshuu
if GetLocale() == 'zhTW' then
	L_ANNOUNCE_FP_STAT = "%s 放置 %s - [%s]"
	L_ANNOUNCE_FP_PRE = "%s 擺出 %s"
	L_ANNOUNCE_FP_PRE_1 = "%s 擺出 %s ，快來領喔！"
	L_ANNOUNCE_FP_PUT = "%s 放置 %s"
	L_ANNOUNCE_FP_CAST = "%s 開啟 %s"
	L_ANNOUNCE_FP_CLICK = "%s 正在開啟 %s，請幫忙點門！"
	L_ANNOUNCE_FP_USE = "%s 使用 %s"
	L_ANNOUNCE_THX_1 = "，感謝施放"
	L_ANNOUNCE_THX_2 = " 對我施放 "
	L_ANNOUNCE_INTERRUPTED = "打斷<%s> - %s"
else
	return
end

local myName = UnitName("player")
---------------------------------
--智能頻道檢測
---------------------------------
CheckChat = function(warning)
	if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
		return "INSTANCE_CHAT"
	elseif IsInRaid(LE_PARTY_CATEGORY_HOME) then
		if warning and (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") or IsEveryoneAssistant()) then
			return "RAID_WARNING"
		else
			return "RAID"
		end
	elseif IsInGroup(LE_PARTY_CATEGORY_HOME) then
		return "PARTY"
	end
	--return "SAY"
end


---------------------------------
--特殊技能通報
---------------------------------

--機器人通報列表
AnnounceBots = {
	[22700] = true,		-- 修理機器人74A型
	[44389] = true,		-- 修理機器人110G型
	[54711] = true,		-- 廢料機器人
	[67826] = true,		-- 吉福斯
	[126459] = true,	-- 布靈登4000型
	[161414] = true,	-- 布靈登5000型
	[101527] = true,	-- 布靈登6000型
	[199109] = true,	-- 自動鐵錘
	[226241] = true,	-- 靜心寶典
}

--傳送門通報列表
AnnouncePortals = {
	--聯盟
	[10059] = true,		-- 暴風城
	[11416] = true,		-- 鐵爐堡
	[11419] = true,		-- 達納蘇斯
	[32266] = true,		-- 艾克索達
	[49360] = true,		-- 塞拉摩
	[33691] = true,		-- 撒塔斯
	[88345] = true,		-- 托巴拉德
	[132620] = true,	-- 恆春谷
	[176246] = true,	-- 暴風之盾
	--部落
	[11417] = true,		-- 奧格瑪
	[11420] = true,		-- 雷霆崖
	[11418] = true,		-- 幽暗城
	[32267] = true,		-- 銀月城
	[49361] = true,		-- 斯通納德
	[35717] = true,		-- 撒塔斯
	[88346] = true,		-- 托巴拉德
	[132626] = true,	-- 恆春谷
	[176244] = true,	-- 戰爭之矛
	--中立
	[53142] = true,		-- 達拉然
	[120146] = true,	-- 遠古達拉然
	[224871] = true,	-- 達拉然—[破碎群島]
}

local FAPframe = CreateFrame("Frame")
FAPframe:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
FAPframe:SetScript("OnEvent", function(self, event, _, subEvent, _, _, srcName, _, _, _, destName, _, _, spellID, ...)
	if not IsInGroup() or InCombatLockdown() or not subEvent or not spellID or not srcName then return end
	if not UnitInRaid(srcName) and not UnitInParty(srcName) then return end

	local srcName = srcName:gsub("%-[^|]+", "")
	if subEvent == "SPELL_CAST_SUCCESS" then
		-- 靈魂大鍋
		if spellID == 188036 then
			SendChatMessage(string.format(L_ANNOUNCE_FP_PRE, srcName, GetSpellLink(spellID)), CheckChat(true))
		-- 召喚餐桌
		elseif spellID == 190336 then
			SendChatMessage(string.format(L_ANNOUNCE_FP_PRE_1, srcName, GetSpellLink(spellID)), CheckChat(true))
		-- 召喚儀式
		elseif spellID == 698 then
			SendChatMessage(string.format(L_ANNOUNCE_FP_CLICK, srcName, GetSpellLink(spellID)), CheckChat(true))
		end
	elseif subEvent == "SPELL_SUMMON" then
		-- 修理機器人
		if AnnounceBots[spellID] then
			SendChatMessage(string.format(L_ANNOUNCE_FP_PUT, srcName, GetSpellLink(spellID)), CheckChat(true))
		end
	elseif subEvent == "SPELL_CREATE" then
		-- MOLL-E 郵箱
		if spellID == 54710 then
			SendChatMessage(string.format(L_ANNOUNCE_FP_PUT, srcName, GetSpellLink(spellID)), CheckChat(true))
		-- 靈魂之井
		elseif spellID == 29893 then
			SendChatMessage(string.format(L_ANNOUNCE_FP_PRE_1, srcName, GetSpellLink(spellID)), CheckChat(true))
		-- 傳送門
		elseif AnnouncePortals[spellID] then
			SendChatMessage(string.format(L_ANNOUNCE_FP_CAST, srcName, GetSpellLink(spellID)), CheckChat(true))
		end
	--elseif subEvent == "SPELL_AURA_APPLIED" then
		-- 火鷄羽毛 及 派對手榴彈
		--if spellID == 61781 or ((spellID == 51508 or spellID == 51510) and destName == T.name) then
			--SendChatMessage(string.format(L_ANNOUNCE_FP_USE, srcName, GetSpellLink(spellID)), CheckChat(true))
		--end
	end
end)

---------------------------------
--自動感謝
---------------------------------
--復活技能列表
local thxspells = {
	[20484] = true,		-- 復生
	[61999] = true,		-- 盟友復生
	[20707] = true,		-- 靈魂石
	[50769] = true,		-- 復活
	[2006] = true,		-- 復活術
	[7328] = true,		-- 救贖
	[2008] = true,		-- 先祖之魂
	[115178] = true,	-- 回命訣
}

local thxframe = CreateFrame("Frame")
thxframe:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
thxframe:SetScript("OnEvent", function(_, event, _, subEvent, _, _, buffer, _, _, _, player, _, _, spell, ...)
	for key, value in pairs(thxspells) do
		if spell == key and value == true and player == myName and buffer ~= myName and subEvent == "SPELL_CAST_SUCCESS" then
			--SendChatMessage(buffer:gsub("%-[^|]+", "").."，謝謝你施放"..GetSpellLink(spell).."。", "WHISPER", nil, buffer)
			SendChatMessage(buffer:gsub("%-[^|]+", "").."謝謝你", "WHISPER", nil, buffer)
			print(buffer.." 對我施放-> "..GetSpellLink(spell))
		end
	end
end)


---------------------------------
--職業技能
---------------------------------
--技能列表
AnnounceSpells = {
	--61999,	-- 盟友復生
	--20484,	-- 復生
	--20707,	-- 靈魂石
	--31821,	-- 精通光環
	--633,		-- 聖療術
	--34477,	-- 誤導
	--57934,	-- 偷天換日
}

local spaframe = CreateFrame("Frame")
spaframe:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
spaframe:SetScript("OnEvent", function(self, _, ...)	
	local _, event, _, sourceGUID, sourceName, _, _, _, destName, _, _, spellID = ...
	local spells = AnnounceSpells
	local _, _, difficultyID = GetInstanceInfo()
	if difficultyID == 0 or event ~= "SPELL_CAST_SUCCESS" then return end
	
	if sourceName then sourceName = sourceName:gsub("%-[^|]+", "") end
	if destName then destName = destName:gsub("%-[^|]+", "") end
	if not sourceName then return end

	for i, spells in pairs(spells) do
		if spellID == spells then
			if destName == nil then
				SendChatMessage(string.format(L_ANNOUNCE_FP_USE, sourceName, GetSpellLink(spellID)), CheckChat())
			else
				SendChatMessage(string.format(L_ANNOUNCE_FP_USE, sourceName, GetSpellLink(spellID).." -> "..destName), CheckChat())
			end
		end
	end
end)

---------------------------------
--打斷通告
---------------------------------
local intframe = CreateFrame("Frame")
intframe:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
intframe:SetScript("OnEvent", function(self, _, ...)
	local _, event, _, sourceGUID, _, _, _, _, destName, _, _, _, _, _, spellID = ...
	if not (event == "SPELL_INTERRUPT" and sourceGUID == UnitGUID("player")) then return end

	SendChatMessage(string.format(L_ANNOUNCE_INTERRUPTED, destName, GetSpellLink(spellID)), CheckChat())
end)