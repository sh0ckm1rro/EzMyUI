----------------
--  鼠標提示  --
----------------
local unpack = unpack
local _, ns = ...
local cfg = {
	scale = 1.1,
	combathideALL = 0,	--戰鬥隱藏
	
    backdrop = {
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 18,
        edgeSize = 15,
        insets = { left = 0, right = 0, top = 0, bottom = 0 },
    },
	bgcolor = {.08, .08, .08, .9 },
	bdrcolor = { .3, .3, .3, 1 },
	gcolor = {.6, .6, .6 },
	deadcolor = {.5,.5,.5},
	font = STANDARD_TEXT_FONT,
	fontflag = "OUTLINE",
	statusbar = "Interface\\TargetingFrame\\UI-StatusBar",
}

local function TooltipOnShow(frame, unit, elapsed)
	frame:SetScale(cfg.scale)
	frame:SetBackdrop(cfg.backdrop)
	frame:SetBackdropColor(unpack(cfg.bgcolor))
	frame:SetBackdropBorderColor(unpack(cfg.bdrcolor))

	local itemName, itemLink = GameTooltip:GetItem()
	if itemLink then
		local _, _, itemRarity = GetItemInfo(itemLink)
		if itemRarity then
			frame:SetBackdropBorderColor(GetItemQualityColor(itemRarity))
		end
	end
	local unit = select(2, GameTooltip:GetUnit())
	if UnitExists(unit) and unit then	--邊框職業顏色
		frame:SetBackdropBorderColor(GameTooltip_UnitColor(unit))
		GameTooltipStatusBar:SetStatusBarColor(GameTooltip_UnitColor(unit))
	end
end
GameTooltip:HookScript("OnUpdate", TooltipOnShow)

local extra = {
	"ShoppingTooltip1",
	"ShoppingTooltip2",
	"ShoppingTooltip3",
	"ItemRefShoppingTooltip1",
	"ItemRefShoppingTooltip2",
	"ItemRefShoppingTooltip3",
	"WorldMapCompareTooltip1",
	"WorldMapCompareTooltip2",
	"WorldMapCompareTooltip3",
	"IMECandidatesFrame",
}

local tooltips = {
	"GameTooltip",
	"ItemRefTooltip",
	"WorldMapTooltip",
	"DropDownList1MenuBackdrop",
	"DropDownList2MenuBackdrop",
	"DropDownList3MenuBackdrop",
	"AutoCompleteBox",
	"FriendsTooltip",
	"FloatingBattlePetTooltip",
	"FloatingGarrisonFollowerTooltip",
	"QuestScrollFrame.StoryTooltip",
}


local frameload = CreateFrame("Frame")
frameload:RegisterEvent("PLAYER_ENTERING_WORLD")
frameload:SetScript("OnEvent", function(self)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")

	local function hook(tip)
		frame:HookScript("OnShow", function(self)
			if(cfg.combathideALL and InCombatLockdown()) then	--戰鬥隱藏
				return self:Hide()
			end
			TooltipOnShow(self)
		end)
	end

	for i, tip in ipairs(tooltips) do
		frame = _G[tip]
		if(frame) then
			hook(frame)
		end
	end
	for i, tip in ipairs(extra) do
		frame = _G[tip]
		if(frame) then
			hook(frame)
			frame.shopping = true
		end
	end
end)

--跟隨游標
hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip, parent)
if UnitExists("mouseover") then
	tooltip:SetOwner(parent, "ANCHOR_CURSOR_RIGHT", 40, -135)	--錨點
	end
end)


--陣營圖
local ficon = GameTooltip:CreateTexture("UnitFactionGroup", "OVERLAY")
ficon:SetSize(60,60)
ficon:SetAlpha(.4)
ficon:SetPoint("TOPRIGHT", "GameTooltip", "TOPRIGHT", 0, -15)

GameTooltip:HookScript("OnHide", function(self)
	ficon:SetTexture(nil)
end)


--func GetHexColor ID染色
local function GetHexColor(color)
  return ("%.2x%.2x%.2x"):format(color.r*255, color.g*255, color.b*255)
end
local classColors, reactionColors = {}, {}

for class, color in pairs(RAID_CLASS_COLORS) do
  classColors[class] = GetHexColor(RAID_CLASS_COLORS[class])
end

for i = 1, #FACTION_BAR_COLORS do
  reactionColors[i] = GetHexColor(FACTION_BAR_COLORS[i])
end

local hex = function(r, g, b)
	if (r and not b) then
		r, g, b = r.r, r.g, r.b
	end
	return (b and format('|cff%02x%02x%02x', r * 255, g * 255, b * 255))
end
ns.hex = hex


local function GetTarget(unit)
  if UnitIsUnit(unit, "player") then
    return ("|cffff0000%s|r"):format(">你<")
  elseif UnitIsPlayer(unit, "player")then
    local _, class = UnitClass(unit)
    return ("|cff%s%s|r"):format(classColors[class], UnitName(unit))
  elseif UnitReaction(unit, "player") then
    return ("|cff%s%s|r"):format(reactionColors[UnitReaction(unit, "player")], UnitName(unit))
  else
    return ("|cffffffff%s|r"):format(UnitName(unit))
  end
end

GameTooltipHeaderText:SetFont(cfg.font, 19, cfg.fontflag)
GameTooltipText:SetFont(cfg.font, 16, cfg.fontflag)
Tooltip_Small:SetFont(cfg.font, 16, cfg.fontflag)


local classification = {
	elite = ("|cffFFCC00 精英|r"),
	rare = ("|cff999999 稀有|r"),
	rareelite = ("|cffCC00FF 稀有精英|r"),
	worldboss = ("|cffFF0000?? 首領|r")
}

--名字染色
function GameTooltip_UnitColor(unit)
	local r, g, b
	local reaction = UnitReaction(unit, "player")
		if reaction then
			r = FACTION_BAR_COLORS[reaction].r
			g = FACTION_BAR_COLORS[reaction].g
			b = FACTION_BAR_COLORS[reaction].b
		else
			r = 1.0
			g = 1.0
			b = 1.0
		end

		if UnitIsPlayer(unit) then
		local class = select(2, UnitClass(unit))
			r = RAID_CLASS_COLORS[class].r
			g = RAID_CLASS_COLORS[class].g
			b = RAID_CLASS_COLORS[class].b
		end
		return r, g, b
end

--[[OnShow背景色不變
local function TooltipOnShow(self, elapsed)
    self:SetScale(cfg.scale)
    self:SetBackdrop(cfg.backdrop)
	self:SetBackdropColor(unpack(cfg.bgcolor))
    self:SetBackdropBorderColor(unpack(cfg.bdrcolor))
	local itemName, itemLink = self:GetItem()
	if itemLink then
		local _, _, itemRarity = GetItemInfo(itemLink)
		if itemRarity then
			self:SetBackdropBorderColor(GetItemQualityColor(itemRarity))
		end
	end
	local _, unit = self:GetUnit()
	if UnitExists(unit) and unit then	--邊框職業顏色
		self:SetBackdropBorderColor(GameTooltip_UnitColor(unit))
		GameTooltipStatusBar:SetStatusBarColor(GameTooltip_UnitColor(unit))
	end
end
GameTooltip:HookScript("OnUpdate", TooltipOnShow)]]

--[[OnHide
local function TooltipOnHide(self)
  self:SetBackdropColor(unpack(cfg.bgcolor))
  self:SetBackdropBorderColor(unpack(cfg.bdrcolor))
end]]


GameTooltip:HookScript("OnTooltipSetUnit", function(self, unit)
	--[[local _, unit = self:GetUnit()
	if (not unit) then return end]]
	local unit = (select(2, self:GetUnit())) or nil
	if unit == "npc" then unit = "mouseover" end
	if (not unit) then return end
	
	--陣營圖
	if UnitFactionGroup(unit)=="Neutral" then
	ficon:SetTexture(nil)
	elseif UnitIsPlayer(unit) then
		local icon = 'Interface\\FriendsFrame\\PlusManz-'..select(1, UnitFactionGroup(unit))..'.blp'
		ficon:SetTexture(icon)
	end
	
	--標記
	local ricon = GetRaidTargetIndex(unit)
	if (ricon) then
		local text = GameTooltipTextLeft1:GetText()
		GameTooltipTextLeft1:SetFormattedText(("%s %s"), ICON_LIST[ricon].."12|t", text)
	end

	if (UnitExists(unit .. "target")) then --目標職業顏色
		self:AddDoubleLine("目標："..GetTarget(unit.."target") or "Unknown")
	end
	
	--清除PVP陣營字樣
	tip, text, levelline, foundpvp, foundfact, tmp, tmp2 = nil
	local pvplinenum,factlinenum=nil
	trueNum = GameTooltip:NumLines()
	lastlinenum = trueNum
	
	for i = 2, trueNum do
		text = _G[GameTooltip:GetName().."TextLeft"..i]
		tip = text:GetText()
		if tip then
			if not levelline and (strfind(tip, LEVEL)) then
				levelline = i
			elseif tip == FACTION_ALLIANCE or tip == FACTION_HORDE then	--陣營
				text:SetText()
				foundfact = true
				factlinenum = i
				lastlinenum = lastlinenum - 1
			elseif tip == PVP then	--PVP
				text:SetText()
				pvplinenum = i
				lastlinenum = lastlinenum - 1
			end
		end
	end

	
	local unitGuild = GetGuildInfo(unit)	--公會染色
	local text = GameTooltipTextLeft2:GetText()
	if unitGuild and text and text:find("^"..unitGuild) then
		GameTooltipTextLeft2:SetText("<"..text..">")
		GameTooltipTextLeft2:SetTextColor(unpack(cfg.gcolor))
	end
	
	local isBattlePet = UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit)
	local level = isBattlePet and UnitBattlePetLevel(unit) or UnitLevel(unit)
	
	if (level) then
		local levelLine
		for i = (isInGuild and 3) or 2, self:NumLines() do
			local line = _G["GameTooltipTextLeft"..i]
			local text = line:GetText()
			if (text and strfind(text, LEVEL)) then
				levelLine = line
				break
			end
		end
	
	if (levelLine) then
	local isPlayer = UnitIsPlayer(unit)
	local creature = not isPlayer and UnitCreatureType(unit)
	local race = player and player.race or UnitRace(unit)
	local dead = isDead and unpack(cfg.deadcolor)..CORPSE.."|r"
	local classify = UnitClassification(unit)

	
	local class = player and hex(UnitColor(unit))..(player.class or "").."|r"
		if (isBattlePet) then
			class = ("|cff80ACEF%s|r"):format(_G["BATTLE_PET_NAME_"..UnitBattlePetType(unit)])
		elseif creature then
			class = ("|cffFFFFFF%s|r"):format(UnitCreatureType(unit))
		else
			class = UnitClass(unit) or ""
		end
		

		local lvltxt, diff
		if (level == -1) then
			level = classification.worldboss
			lvltxt = level
		else
			level = ("%d"):format(level)
			diff = GetQuestDifficultyColor(level)
			lvltxt = ("%s%s|r%s"):format(hex(diff) , level, (classify and classification[classify] or ""))
		end


		if (dead) then
			levelLine:SetFormattedText("%s %s", lvltxt, dead)
		else
			if (race and UnitIsEnemy(unit, "player")) then race = hex(FACTION_BAR_COLORS[2])..race.."|r" end
			levelLine:SetFormattedText("%s %s", lvltxt, race or "")
		end

		if (class) then
			lvltxt = levelLine:GetText()
			levelLine:SetFormattedText("%s %s", lvltxt, class)
		end

		if (UnitIsPVP(unit) and UnitCanAttack("player", unit)) then
			lvltxt = levelLine:GetText()
			levelLine:SetFormattedText("%s |cff00FF00(%s)|r", lvltxt, PVP)
		end

		if not (isPlayer or isBattlePet) then
		-- 1 憎恨 2 敵對 3 冷淡 4 中立 5 友好 6 尊敬 7 崇敬/崇拜
		--local reaction = {}
		--for i = 1, _G.MAX_REPUTATION_REACTION do
		--reaction[i] = _G.GetText("FACTION_STANDING_LABEL" .. i,"player")
		--end
	
		local reaction = UnitReaction(unit, "player")
		local colors = FACTION_BAR_COLORS[reaction] or nilColor
		reaction = _G["FACTION_STANDING_LABEL"..reaction]
			if (reaction) then
				reaction = hex(colors)..reaction.."|r"
				lvltxt = levelLine:GetText()
				--reaction[_G.MAX_REPUTATION_REACTION + 1] = {r = 0, g = 0.5, b = 0.9}
				--reaction = hex(FACTION_BAR_COLORS[UnitReaction(unit, "player")])..reaction.."|r"
				levelLine:SetFormattedText("%s %s", lvltxt, reaction)
				
			end
		end
	local status = (UnitIsAFK(unit) and CHAT_FLAG_AFK) or (UnitIsDND(unit) and CHAT_FLAG_DND) or (not UnitIsConnected(unit) and "<離線>")
	if (status) then
	self:AppendText((" |cff00DDDD%s|r"):format(status))
    end
		
		end
	end
end)

--[[loop over tooltips
local tooltips = { GameTooltip, ItemRefTooltip, ShoppingTooltip1, ShoppingTooltip2, ShoppingTooltip3, WorldMapTooltip, SmallTextTooltip,FriendsTooltip, QueueStatusFrame,
ItemRefShoppingTooltip1,
ItemRefShoppingTooltip2,
WorldMapCompareTooltip1,
WorldMapCompareTooltip2,}
for idx, tooltip in ipairs(tooltips) do
  tooltip:SetBackdrop(cfg.backdrop)
  tooltip:SetScale(cfg.scale)
  tooltip:HookScript("OnShow", TooltipOnShow)
  tooltip:HookScript("OnHide", TooltipOnHide)
end]]

--GameTooltipStatusBar
local numberize = function(val)
		if (val >= 1e8) then
			return ("%.2f億"):format(val / 1e8)
		elseif (val >= 1e4) then
			return ("%.1f萬"):format(val / 1e4)
		else
			return ("%d"):format(val)
		end
end

local function UpdateHP(self, value)
	local _, unit = GameTooltip:GetUnit()
	if (UnitExists(unit)) then
		if (not value) then return end
		local vMin, vMax = self:GetMinMaxValues()
		if (value < vMin or value > vMax) then return end

		if (not self.text) then
			self.text = self:CreateFontString(nil, "OVERLAY")
			self.text:SetPoint("CENTER", GameTooltipStatusBar, 0, 0)
			self.text:SetFont(cfg.font, 14, cfg.fontflag)
		end

		local hp = numberize(self:GetValue()).."("..("%.0f%%"):format(self:GetValue() * 100 / vMax)..")"
		self.text:SetText(hp)
	end
end
GameTooltipStatusBar:SetStatusBarTexture(cfg.statusbar)
GameTooltipStatusBar:HookScript("OnValueChanged", UpdateHP)

