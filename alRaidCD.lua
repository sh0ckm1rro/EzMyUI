-- Config start
local anchor = "TOPLEFT"
local x, y = 12, -550
local width, height = 130, 14
local spacing = 5
local icon_size = 14
local font = GameFontHighlight:GetFont()
local font_size = 11
local font_style = nil
local backdrop_color = {0, 0, 0, 0.4}
local border_color = {0, 0, 0, 1}
local show_icon = true
local texture = "Interface\\TargetingFrame\\UI-StatusBar"
local show = {
	raid = true,
	party = true,
	arena = true,
	--none = true,
}
-- Config end

local spells = {
	--補
	[633] =  600,	--聖療術
	[740] = 180,	--寧靜
	[115310] = 180,	--五氣歸元
	[64843]  = 180,	--神聖禮頌
	[108280] = 180,	--治療之潮圖騰
	[15286]  = 180,	--吸血鬼的擁抱
	[108281] = 120,	--先祖引導
	[33891] = 180,	--化身：生命之樹
		
	--群體減傷
	[51052] = 120,	--反魔法領域
	[31821] = 180,	--精通光環
	[204150] = 180,	--聖光禦盾
	[62618] = 180,	--真言術：壁
	[88611] = 180,	--煙霧彈
	[98008] = 180,	--靈魂鏈接圖騰
	[97462] = 180,	--集結吶喊
	
	--單體減傷
	[116849] = 120,	--氣繭護體
	[1022] = 300,	--保護祝福
	[6940] = 120,	--犧牲祝福
	[33206] = 240,	--痛苦鎮壓
	[47536] = 120,	--狂喜
	[47788] = 240,	--守護聖靈
	[114030] = 120,	--戒備守護
	[102342] = 90,	--鐵樹皮術

	--戰術技能
	[32182] = 300,	--英勇
	[2825] = 300,	--嗜血
	[80353] = 300,	--時間扭曲
	[90355] = 300,	--遠古狂亂
	
	--戰復(非首領戰)
	[20484] = 600,	--復生
	[61999] = 600,	--復活盟友
	[20707] = 600,	--靈魂石復活
	
	--其他
	[73325] = 90,	--虔信之躍
	[114018] = 360,	--隱蔽護罩
	[106898] = 120,	--奔竄咆哮

	--[133] = 180,	--測試
}

local cfg = {}

local filter = COMBATLOG_OBJECT_AFFILIATION_RAID + COMBATLOG_OBJECT_AFFILIATION_PARTY + COMBATLOG_OBJECT_AFFILIATION_MINE
local band = bit.band
local sformat = string.format
local floor = math.floor
local currentNumResses = 0
local charges = nil
local inBossCombat = nil

local backdrop = {
	bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
	edgeFile = [=[Interface\ChatFrame\ChatFrameBackground]=], edgeSize = 1,
	insets = {top = 0, left = 0, bottom = 0, right = 0},
}

local bars = {}
local Ressesbars = {}
local anchorframe = CreateFrame("Frame", "RaidCD", UIParent)
anchorframe:SetSize(width, height)
anchorframe:SetPoint(anchor, x, y)
if UIMovableFrames then tinsert(UIMovableFrames, anchorframe) end

local FormatTime = function(time)
	if time >= 60 then
		return sformat('%.2d:%.2d', floor(time / 60), time % 60)
	else
		return sformat('%.2d', time)
	end
end

local CreateFS = CreateFS or function(frame)
	local fstring = frame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
	fstring:SetFont(font, font_size, font_style)
	fstring:SetShadowColor(0, 0, 0, 1)
	fstring:SetShadowOffset(0.5, -0.5)
	return fstring
end

local CreateBG = CreateBG or function(parent)
	local bg = CreateFrame("Frame", nil, parent)
	bg:SetPoint("TOPLEFT", parent, "TOPLEFT", -1, 1)
	bg:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 1, -1)
	bg:SetFrameStrata("LOW")
	bg:SetBackdrop(backdrop)
	bg:SetBackdropColor(unpack(backdrop_color))
	bg:SetBackdropBorderColor(unpack(border_color))
	return bg
end

local UpdatePositions = function()
	if charges and Ressesbars[1] then
		Ressesbars[1]:SetPoint("TOPLEFT", anchorframe, 0, 0)
		Ressesbars[1].id = 1
		for i = 1, #bars do
			bars[i]:ClearAllPoints()
			if i == 1 then
				bars[i]:SetPoint("TOPLEFT", Ressesbars[1], "BOTTOMLEFT", 0, -spacing)
			else
				bars[i]:SetPoint("TOPLEFT", bars[i-1], "BOTTOMLEFT", 0, -spacing)
			end
			bars[i].id = i
		end
	else
		for i = 1, #bars do
			bars[i]:ClearAllPoints()
			if i == 1 then
				bars[i]:SetPoint("TOPLEFT", anchorframe, 0, 0)
			else
				bars[i]:SetPoint("TOPLEFT", bars[i-1], "BOTTOMLEFT", 0, -spacing)
			end
			bars[i].id = i
		end	
	end
end

local StopTimer = function(bar)
	bar:SetScript("OnUpdate", nil)
	bar:Hide()
	if bar.isResses then
		tremove(Ressesbars, bar.id)
	else
		tremove(bars, bar.id)
	end
	UpdatePositions()
end

local UpdateCharges = function(bar)
	local curCharges, maxCharges, start, duration = GetSpellCharges(20484)
	if curCharges == maxCharges then
		bar.startTime = 0
		bar.endTime = GetTime()
	else
		bar.startTime = start
		bar.endTime = start + duration
	end
	if curCharges ~= currentNumResses then
		currentNumResses = curCharges
		bar.left:SetText(bar.name.." : "..currentNumResses)
	end
end

local BarUpdate = function(self, elapsed)
	local curTime = GetTime()
	if self.endTime < curTime then
		if self.isResses then
			UpdateCharges(self)
		else
			StopTimer(self)
			return
		end
	end
	self.status:SetValue(100 - (curTime - self.startTime) / (self.endTime - self.startTime) * 100)
	self.right:SetText(FormatTime(self.endTime - curTime))
end

local OnEnter = function(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:AddLine(self.spell)
	GameTooltip:SetClampedToScreen(true)
	GameTooltip:Show()
end

local OnLeave = function(self)
	GameTooltip:Hide()
end

local OnMouseDown = function(self, button)
	if button == "LeftButton" then
		if self.isResses then
			SendChatMessage(sformat("團隊戰復剩餘: %d次 下次可用時間: %s", currentNumResses, self.right:GetText()), "SAY")
		else
			SendChatMessage(sformat("團隊技能冷卻時間 %s %s: %s", self.left:GetText(), self.spell, self.right:GetText()), "RAID")
		end
	elseif button == "RightButton" then
		StopTimer(self)
	end
end

local CreateBar = function()
	local bar = CreateFrame("Frame", nil, UIParent)
	bar:SetSize(width, height)
	bar.status = CreateFrame("Statusbar", nil, bar)
	bar.icon = CreateFrame("button", nil, bar)
	bar.icon:SetSize(icon_size, icon_size)
	bar.icon:SetPoint("BOTTOMLEFT", 0, 0)
	bar.status:SetPoint("BOTTOMLEFT", bar.icon, "BOTTOMRIGHT", 5, 0)
	bar.status:SetPoint("BOTTOMRIGHT", 0, 0)
	bar.status:SetHeight(height)
	bar.status:SetStatusBarTexture(texture)
	bar.status:SetMinMaxValues(0, 100)
	bar.status:SetFrameLevel(bar:GetFrameLevel()-1)
	bar.left = CreateFS(bar)
	bar.left:SetPoint('LEFT', bar.status, 2, 1)
	bar.left:SetJustifyH('LEFT')
	bar.right = CreateFS(bar)
	bar.right:SetPoint('RIGHT', bar.status, -2, 1)
	bar.right:SetJustifyH('RIGHT')
	CreateBG(bar.icon)
	CreateBG(bar.status)
	return bar
end

local StartTimer = function(name, spellId)
	local spell, rank, icon = GetSpellInfo(spellId)
	if charges and spellId == 20484 then
		--團隊首領戰中戰復技能計時特殊處理
		for _, v in pairs(Ressesbars) do
			UpdateCharges(v)
			return
		end
	end
	for _, v in pairs(bars) do
		if v.name == name and v.spell == spell then
			--發現重複計時事件時重置計時條,適應戰復以外充能技能
			StopTimer(v)
		end
	end
	local bar = CreateBar()
	local color
	if charges and spellId == 20484 then
		--初始化戰復技能計時條
		local curCharges, _, _, duration = GetSpellCharges(20484)
		currentNumResses = curCharges
		bar.endTime = GetTime() + duration
		bar.left:SetText(name.." : "..curCharges)
		bar.right:SetText(FormatTime(duration))
		bar.isResses = true
		color = RAID_CLASS_COLORS[select(2, UnitClass("player"))]
		bar.startTime = GetTime()
		bar.name = name
		bar.spell = spell
		bar.spellId = spellId
		if icon and bar.icon then
			bar.icon:SetNormalTexture(icon)
			bar.icon:GetNormalTexture():SetTexCoord(0.07, 0.93, 0.07, 0.93)
		end
		bar:Show()
		bar.status:SetStatusBarColor(color.r, color.g, color.b)
		bar:SetScript("OnUpdate", BarUpdate)
		bar:EnableMouse(true)
		bar:SetScript("OnEnter", OnEnter)
		bar:SetScript("OnLeave", OnLeave)
		bar:SetScript("OnMouseDown", OnMouseDown)
		tinsert(Ressesbars, bar)
	else
		bar.endTime = GetTime() + spells[spellId]
		bar.left:SetText(name)
		bar.right:SetText(FormatTime(spells[spellId]))
		bar.isResses = false
		color = RAID_CLASS_COLORS[select(2, UnitClass(name))]
		bar.startTime = GetTime()
		bar.name = name
		bar.spell = spell
		bar.spellId = spellId
		if icon and bar.icon then
			bar.icon:SetNormalTexture(icon)
			bar.icon:GetNormalTexture():SetTexCoord(0.07, 0.93, 0.07, 0.93)
		end
		bar:Show()
		bar.status:SetStatusBarColor(color.r, color.g, color.b)
		bar:SetScript("OnUpdate", BarUpdate)
		bar:EnableMouse(true)
		bar:SetScript("OnEnter", OnEnter)
		bar:SetScript("OnLeave", OnLeave)
		bar:SetScript("OnMouseDown", OnMouseDown)
		tinsert(bars, bar)
	end
	UpdatePositions()
end

local OnEvent = function(self, event, ...)
	if event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
		if select(2, IsInInstance()) == "raid" then
			self:RegisterEvent("SPELL_UPDATE_CHARGES")
		else
			self:UnregisterEvent("SPELL_UPDATE_CHARGES")
			charges = nil
			inBossCombat = nil
			currentNumResses = 0
			Ressesbars = {}
		end
	end
	if event == "SPELL_UPDATE_CHARGES" then
		charges = select(1, GetSpellCharges(20484))
		if charges then
			if not inBossCombat then
				for _, v in pairs(bars) do
					StopTimer(v)
				end
				inBossCombat = true
			end
			StartTimer("戰鬥復活", 20484)
		elseif not charges and inBossCombat then
			inBossCombat = nil
			currentNumResses = 0
			for _, v in pairs(Ressesbars) do
				StopTimer(v)
			end
		end
	end
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local timestamp, eventType, _, sourceGUID, sourceName, sourceFlags = ...
		if band(sourceFlags, filter) == 0 then return end
		if (eventType == "SPELL_RESURRECT" and not charges) or eventType == "SPELL_CAST_SUCCESS" or eventType == "SPELL_AURA_APPLIED" then
			local spellId = select(12, ...)
			if sourceName then
				sourceName = sourceName:gsub("-.+", "")
			else
				return
			end
			if spells[spellId] and show[select(2, IsInInstance())] then
				StartTimer(sourceName, spellId)
			end
		end
	elseif event == "ZONE_CHANGED_NEW_AREA" and select(2, IsInInstance()) == "arena" then
		for _, v in pairs(Ressesbars) do
			StopTimer(v)
		end
		for _, v in pairs(bars) do
			StopTimer(v)
		end
	end
end

local addon = CreateFrame("frame")
addon:SetScript('OnEvent', OnEvent)
--addon:RegisterEvent("PLAYER_ENTERING_WORLD")
addon:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
addon:RegisterEvent("ZONE_CHANGED_NEW_AREA")

SlashCmdList["RaidCD"] = function(msg) 
	StartTimer(UnitName('player'), 20484)
	StartTimer(UnitName('player'), 740)
	StartTimer(UnitName('player'), 20707)
end
SLASH_RaidCD1 = "/raidcd"
SLASH_RaidCD1 = "/rcd"