local addonName, addon = ...
local cfg = addon.cfg
local cfg = {}

cfg.PlayerBuffIconSize = 28		--圖示大小
cfg.PlayerBuffIconOffsetX = -100	--水平
cfg.PlayerBuffIconOffsetY = -120	--垂直

cfg.PlayerDebuffIconSize = 30
cfg.PlayerDebuffIconOffsetX = 0
cfg.PlayerDebuffIconOffsetY = -30

cfg.TargetBuffIconSize = 30
cfg.TargetBuffIconOffsetX = 10
cfg.TargetBuffIconOffsetY = 40

cfg.FocusBuffIconSize = 30
cfg.FocusBuffIconOffsetX = 10
cfg.FocusBuffIconOffsetY = 40

cfg.PetBuffIconSize = 20
cfg.PetBuffIconOffsetX = 0
cfg.PetBuffIconOffsetY = 40

-------------------------------------
--自身增益
local DemonHunterBuffList = {
187827,	--惡魔化身
203981,	--靈魂碎片
203819,	--惡魔尖刺
209426,	--黑暗
212800,	--殘影
218256,	--強化結界
}

local DeathknightBuffList = {
48792,	--冰固堅韌
48707,	--反魔法護罩
49039,	--巫妖之軀
51271,	--冰霜之柱
55213,	--狂血術
55233,	--血族之裔
77535,	--鮮血護盾
81256,	--符文武器幻舞
116888,	--贖魂護罩
193249,	--不滅血系
194679,	--符文轉化
195181,	--骸骨之盾
207319,	--屍盾術
206977,	--血魄之鏡
}

local DruidBuffList = {
5217,	--猛虎之怒
22812,	--樹皮術
61336,	--求生本能
102543,	--化身：叢林之王
102558,	--化身：厄索克守護者
117679,	--化身：生命之樹
135700,	--節能施法(野性專精)
192081,	--鋼鐵毛皮
102342,	--鐵樹皮術
203975,	--大地看守者
}

local HunterBuffList = {
19623,	--狂亂
34477,	--誤導
186254,	--狂野怒火
186265,	--巨龜守護
193530,	--野性守護
}

local MageBuffList = {
12042,	--秘法強化
36032,	--奧衝堆疊
113862,	--強效隱形
190319,	--燃燒
48107,	--升溫
48108,	--焦炎之痕
44544,	--冰霜之指
190446,	--腦部凍結
253257,	--極地寒風
1463,	--咒法之流
116011,	--力之符文
}

local MonkBuffList = {
101643,	--超凡入聖
116768,	--滅寂腿
115203,	--石形絕釀
120954,	--石形絕釀
122278,	--卸勁訣
122783,	--驅魔訣
122470,	--乾坤挪移
152173,	--冰心訣
195630,	--飄渺絕學
214373,	--酒沫鬍鬚
215479,	--金鐘絕釀
228563,	--滅寂連打
}

local PaladinBuffList = {
498,	--聖佑術
642,	--聖盾術
1044,	--自由祝福
6940,	--犧牲祝福
31821,	--精通光環
31850,	--忠誠防衛者
86659,	--遠古諸王守護者
105809,	--神聖復仇者
--132403,	--公正之盾(減傷)
152262,	--六翼天使
188370,	--奉獻
200025,	--美德信標
200652,	--提爾救贖
204018,	--抗咒祝福
204150,	--聖光御盾
205191,	--以眼還眼
209785,	--正義怒火
214202,	--依法而治
}

local PriestBuffList = {
17,	--盾
10060,	--注入能量
33206,	--痛苦鎮壓
47536,	--狂喜
47585,  	--影散
47788,	--守護聖靈
64843,	--神聖禮頌
64901,	--希望象徵
81782,	--真言術：壁
15286,	--吸血鬼的擁抱
194384,	--贖罪
198076,	--眾人之罪
200183,	--神化
223166,	--聖光超載
}

local RogueBuffList = {
1943,	--割裂
1966,	--佯攻
5171,	--骰子或切割
5277,	--閃避
45182,	--死亡謊言
31224,	--暗影披風
31665,	--敏銳大師
32645,	--毒化
79140,	--宿怨
212283,	--死亡符記
121471,	--暗影之刃
185311,	--赤紅藥瓶
185313,	--暗影之舞
197498,	--終結技：夜刃
197496,	--終結技：刺骨
199754,	--還擊
}

local ShamanBuffList = {
16246,	--元素集中
53390,	--潮汐奔湧
79206,	--靈行者之賜
73685,	--釋放大地生命
98007,	--靈魂連結圖騰
108271,	--星界轉移
108281,	--先祖引導
114052,	--卓越術
191877,	--漩渦之力
194084,	--火舌
196834,	--冰封
205495,	--風暴守護者
208963,	--天怒圖騰
210714,	--冰怒
236502,	--潮汐使者
}

local WarlockBuffList = {
17962,	--焚燒
--86211,	--靈魂交換
104773,	--心志堅定
108416,	--黑暗契約
}

local WarriorBuffList = {
871,	--盾牆
2565,	--盾牌格檔
12292,	--浴血
12975,	--破釜沉舟
23920,	--法術反射
97463,	--命令之吼
118038,	--劍下亡魂
125565,	--挫志怒吼
163201,	--斬殺(武戰)
184362,	--狂怒
184364,	--狂怒恢復
190456,	--無視苦痛
197690,	--防禦姿態
202289,	--怒火重燃
--202573,	--復仇:復仇
202574,	--復仇:無視苦痛
223658,	--安全守護
}

local pro_tbl = {
  DEATHKNIGHT = DeathknightBuffList,
  DRUID = DruidBuffList,
  HUNTER = HunterBuffList,
  MAGE = MageBuffList,
  MONK = MonkBuffList,
  PALADIN = PaladinBuffList,
  PRIEST = PriestBuffList,
  ROGUE = RogueBuffList,
  SHAMAN = ShamanBuffList,
  WARLOCK = WarlockBuffList,
  WARRIOR = WarriorBuffList,
  DEMONHUNTER = DemonHunterBuffList
}

--自身減益
cfg.PlayerDebuffList = {
41425,	--hypotermia
113942,	--demonic gateway
131894,	--a murder of crows
}

-------------------------------------
--目標增益
cfg.TargetBuffList = {
--[全球]
61574,	--部落旗幟
61573,	--聯盟旌旗
--[rogue]
5277,	--閃避
199754,	--還擊
31224,	--暗影披風
--[mage]
157913,	--漸隱
--[warrior]
871,	--盾牆
118038,	--劍下亡魂
46924,	--劍刃風暴
--[druid]
22812,	--樹皮術
102342,	--鐵樹皮術
--[shaman]
98007,	--靈魂連結圖騰
157504,	--雲爆圖騰
--[dk]
48792,	--冰封之韌
48707,	--反魔法護罩
--[pala]
642,	--聖盾術
1022,	--保護祝福
6940,	--犧牲祝福
--[hunter]
19263,	--威懾
53480,	--犧牲咆哮
--[monk]
115203,	--石形絕釀
122470,	--乾坤挪移
--[priest]
33206,	--痛苦鎮壓
47788,	--守護聖靈
--[warlock]
108359,	--黑暗再生
108416,	--黑暗契約
}

--寵物
local PetBuffList = {
136,	--治療寵物
}


local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_LOGIN" then
		_, cfg.class = UnitClass("player")
		cfg.PlayerBuffList = pro_tbl[cfg.class]
		cfg.list_tbl = cfg.list_tbl or {
		PlayerBuff = cfg.PlayerBuffList,
    		PlayerDebuff = cfg.PlayerDebuffList,
    		TargetBuff = cfg.TargetBuffList,
    		FocusBuff = cfg.TargetBuffList,
    		PetBuff = cfg.PetBuffList
		}
	end
end)

-------------------------------------
--[[initialization]]
local type_tbl = {
	Buff = UnitBuff,
	Debuff = UnitDebuff
}

local size_tbl = {
	PlayerBuff = cfg.PlayerBuffIconSize,
	PlayerDebuff = cfg.PlayerDebuffIconSize,
	TargetBuff = cfg.TargetBuffIconSize,
	FocusBuff = cfg.FocusBuffIconSize,
	PetBuff = cfg.PetBuffIconSize
}

local function createIcon(spell_id, icon_size)
	local _, icon = GetSpellInfo(spell_id)
	local frame = CreateFrame("Frame")
	frame:SetSize(icon_size, icon_size)
	frame.t = frame:CreateTexture(nil, "BORDER")
	frame.t:SetAllPoints(true)
	frame.t:SetTexture(icon)
	frame.f = frame:CreateFontString(nil, "BORDER")	-- number font
	frame.f:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
	frame.f:SetPoint("BOTTOMRIGHT", 0, 0)
	frame.c = frame:CreateFontString(nil, "BORDER")	-- cooldown font
	frame.c:SetFont(STANDARD_TEXT_FONT, 15, "OUTLINE")
	frame.c:SetPoint("CENTER", 0, 0)
	return frame;
end

local function createList(unit, _type)
	for i, spell_id in ipairs(cfg.list_tbl[unit.._type]) do
		_G[unit.._type.."Icon"..i] = _G[unit.._type.."Icon"..i] or createIcon(spell_id, size_tbl[unit.._type])
		_G[unit.._type.."Icon"..i]:Hide()
	end
end


-------------------------------------
icon_setting_tbl = {
  PlayerBuff = function ()
  	return cfg.PlayerBuffIconOffsetX, cfg.PlayerBuffIconOffsetY, cfg.PlayerBuffIconSize, UIParent, "CENTER", "CENTER"
  end,
  PlayerDebuff = function ()
  	return cfg.PlayerDebuffIconOffsetX, cfg.PlayerDebuffIconOffsetY, cfg.PlayerDebuffIconSize, UIParent, "CENTER","CENTER"
end,
  TargetBuff = function ()
  	return cfg.TargetBuffIconOffsetX, cfg.TargetBuffIconOffsetY, cfg.TargetBuffIconSize, TargetFrame, "LEFT", "RIGHT"
end,
  FocusBuff = function ()
  	return cfg.FocusBuffIconOffsetX, cfg.FocusBuffIconOffsetY, cfg.FocusBuffIconSize, FocusFrame, "LEFT", "RIGHT"
end,
  PetBuff = function ()
  	return cfg.PetBuffIconOffsetX, cfg.PetBuffIconOffsetY, cfg.PetBuffIconSize, PlayerFrame, "LEFT", "RIGHT"
end
}

local function showIcon(unit, _type, spell_id, Icons, i, row)
	local offsetX, offsetY, icon_size, iconParent, anchor, targetAnchor
	= icon_setting_tbl[unit.._type]()
	local name, _, _, count = type_tbl[_type](unit, GetSpellInfo(spell_id))
	
	if name then
		_G[Icons..i]:Show()
		_G[Icons..i]:SetPoint(anchor, iconParent, targetAnchor, offsetX + (icon_size + 4) * (row - 1), offsetY)
		if(count > 1)then
			_G[Icons..i].f:SetText(count)
		else
			_G[Icons..i].f:SetText("")
		end
		row = row + 1
	else
		_G[Icons..i]:Hide()
	end
	return row
end

local function setIcons(unit, _type)
	local Icons = unit.._type.."Icon"
	local row = 1;
	for i, spell_id in ipairs(cfg.list_tbl[unit.._type])do
		_G[Icons..i]:Hide()
		row = showIcon(unit, _type, spell_id, Icons, i, row)
	end
end

-------------------------------------
--[[set the cooldown timer of buff icons]]
local function setTimer(unit, _type)
	for i, spell_id in ipairs(cfg.list_tbl[unit.._type])do
		local name, _, _, _, _, _, expires = type_tbl[_type](unit, GetSpellInfo(spell_id))
		if name then
			local vt = math.floor(expires - GetTime() + 1)
			if (vt >= 60)then
				vt = math.ceil(vt / 60)
				_G[unit.._type.."Icon"..i].c:SetText(vt.."分")
			elseif vt >= 0 then
				_G[unit.._type.."Icon"..i].c:SetText(vt.."")
			end
		end
	end
end

-------------------------------------

local BuffFrame = CreateFrame("Frame")
BuffFrame:RegisterEvent("PLAYER_LOGIN")
BuffFrame:RegisterEvent("UNIT_AURA")
BuffFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
BuffFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")

BuffFrame:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_LOGIN" then
		_,Class = UnitClass("player")
		createList("Player", "Buff")
		createList("Player", "Debuff")
		createList("Target", "Buff")
		createList("Focus", "Buff")
		if cfg.class == "HUNTER" then
			createList("Pet", "Buff")
		end
	elseif event == "UNIT_AURA" then
		setIcons("Player", "Buff")
		setIcons("Player", "Debuff")
		setIcons("Target", "Buff")
		setIcons("Focus", "Buff")
		if cfg.class == "HUNTER" then
			setIcons("Pet", "Buff")
		end
	elseif event == "PLAYER_TARGET_CHANGED" then
		setIcons("Target", "Buff")
	elseif event == "PLAYER_FOCUS_CHANGED" then
		setIcons("Focus", "Buff")
	end
end)
BuffFrame:SetScript("OnUpdate", function()
	setTimer("Player", "Buff")
	setTimer("Player", "Debuff")
	setTimer("Target", "Buff")
	setTimer("Focus", "Buff")
	if cfg.class == "HUNTER" then
		setTimer("Pet", "Buff")
	end
end)