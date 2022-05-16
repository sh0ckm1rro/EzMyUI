local locale = GetLocale()
local class = select(2, UnitClass("player"))
local selfcolor = RAID_CLASS_COLORS[class]

--自訂選單 (BLIZ保護機制,inherits表示原按鈕)
local menus = {
    { zhTW = "角色", zhCN = "角色", text = "Player", inherits = CharacterMicroButton },
    { zhTW = "法術", zhCN = "法術", text = "Spell", inherits = SpellbookMicroButton },
    { zhTW = "天賦", zhCN = "天賦", text = "Talent", inherits = TalentMicroButton, alert = true },
    { zhTW = "成就", zhCN = "成就", text = "Achi", inherits = AchievementMicroButton },
    { zhTW = "任務", zhCN = "任務", text = "Quest", inherits = QuestLogMicroButton },
    { zhTW = "公會", zhCN = "公會", text = "Guild", inherits = GuildMicroButton, notice = true },
    { zhTW = "找團", zhCN = "找團", text = "LFD", inherits = LFDMicroButton },
    { zhTW = "收藏", zhCN = "藏品", text = "Collects", inherits = CollectionsMicroButton },
    { zhTW = "指南", zhCN = "指南", text = "Guide", inherits = EJMicroButton },
    { zhTW = "商城", zhCN = "商城", text = "Shop", inherits = StoreMicroButton },
    { zhTW = "選單", zhCN = "選單", text = "Menu", inherits = MainMenuMicroButton },
    { zhTW = "背包", zhCN = "背包", text = "Bag", func = ToggleAllBags, color = FRIENDS_GRAY_COLOR },		-- NORMAL_FONT_COLOR
    --{ zhTW = "幫助", zhCN = "幫助", text = "Help", inherits = HelpMicroButton },
}

--按鈕寬度
local buttonWidth = 38

--按鈕字體大小
local buttonFontSize = locale:sub(1,2) == "zh" and 14 or 9

--按鈕點擊
local function click(self)
    if (self.func) then self.func(self) end
end

--創造按鈕
local function CreateButton(prefix, index, config)
--按鈕Template:  UIPanelButtonTemplate, GameMenuButtonTemplate, InsetFrameTemplate3, ThinGoldEdgeTemplate
    local button = CreateFrame("Button", prefix..index, _G["MenuMainFrame"] or UIParent, "ThinGoldEdgeTemplate")
    button:SetHeight(20)
    button:SetWidth(config.width or buttonWidth)
    if (config.inherits) then
        config.inherits:SetParent(button)
        config.inherits:ClearAllPoints()
        config.inherits:SetHitRectInsets(0,0,0,0)
        config.inherits:SetWidth(button:GetWidth())
        config.inherits:SetHeight(button:GetHeight())
        config.inherits:SetPoint("CENTER")
        config.inherits:SetAlpha(0)
        hooksecurefunc(config.inherits, "Disable", function(self) button:SetAlpha(0.4) end)
        hooksecurefunc(config.inherits, "Enable", function(self) self:SetAlpha(0) button:SetAlpha(1) end)
    else
        button.func = config.func
        button:RegisterForClicks("LeftButtonUp")
        button:SetScript("OnClick", click)
    end
    if (index == 1) then
        button:SetPoint("LEFT", _G["MenuMainFrame"] or UIParent, "LEFT", 0, 0)
    else
        button:SetPoint("LEFT", _G[prefix..(index-1)], "RIGHT", 1, 0)
    end
    button.text = button:CreateFontString(nil, "ARTWORK")
    button.text:SetWidth(button:GetWidth())
    button.text:SetFont(UNIT_NAME_FONT, buttonFontSize, "THINOUTLINE")
    local color = config.color or selfcolor
    local color2 = class == "PRIEST" and RED_FONT_COLOR or WHITE_FONT_COLOR
    button.text:SetTextColor(color.r, color.g, color.b)
    button.text:SetPoint("CENTER", button, "CENTER", 1, -1)
    button.text:SetJustifyH("CENTER")
    button.text:SetText(config[locale] or config.text)
    if config.alert then
		hooksecurefunc(TalentMicroButton, "EvaluateAlertVisibility", function(self)
			local alertText, alertPriority = self:HasTalentAlertToShow()
			local pvpAlertText, pvpAlertPriority = self:HasPvpTalentAlertToShow()
			if not alertText or pvpAlertPriority < alertPriority then
				alertText = pvpAlertText
			end
			if alertText then
				button.text:SetTextColor(color2.r, color2.g, color2.b)
			else
				button.text:SetTextColor(color.r, color.g, color.b)
			end
		end)
	end
    if config.notice then
		  hooksecurefunc(GuildMicroButton, "UpdateNotificationIcon", function(self)
			  if self.NotificationOverlay:IsShown() then
				  button.text:SetTextColor(color2.r, color2.g, color2.b)
			  else
				  button.text:SetTextColor(color.r, color.g, color.b)
			  end
		  end)
    end
    return button
end

do
    --創建菜單框架
    local MenuMainFrame = CreateFrame("Frame", "MenuMainFrame", UIParent)
    MenuMainFrame:SetSize(#menus*(buttonWidth+1), 20)
    MenuMainFrame:SetPoint("CENTER", UIParent, "CENTER", -12, 12)
    for i, v in ipairs(menus) do CreateButton("MenuMainFrameButton", i, v) end
    --創造菜單控制按鈕
    local MenuMainButton = CreateFrame("Button", "MenuMainButton", UIParent, "UIPanelSquareButton")	-- UIPanelSquareButton, UIPanelCloseButton
    MenuMainButton:SetWidth(20)
    MenuMainButton:SetHeight(20)
    MenuMainButton:SetPoint("TOP", UIParent, "TOP", #menus*buttonWidth/2+20, 0)
    MenuMainButton:SetFrameStrata("MEDIUM")
    MenuMainButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    MenuMainButton:SetScript("OnClick", function()
		 if IsModifierKeyDown() then
			 ReloadUI()
		 else
			 ToggleFrame(MenuMainFrame)
		 end
	 end)
    if (#menus == 0) then MenuMainButton:Hide() end
	--進出職業大廳時調整位置
	hooksecurefunc("UIParent_UpdateTopFramePositions", function()
		local inHall = OrderHallCommandBar and OrderHallCommandBar:IsShown()
		local offset = inHall and 22 or 0
		MenuMainButton:SetPoint("TOP", UIParent, "TOP", #menus*buttonWidth/2+20, - offset)
	end)
    --重設位置
    MenuMainFrame:ClearAllPoints()
    MenuMainFrame:SetParent(MenuMainButton)
    MenuMainFrame:SetPoint("TOPRIGHT", MenuMainButton, "TOPLEFT", -2, 0)
    --隱藏右下背包和菜單
    MicroButtonAndBagsBar:Hide()
	for _, bagButton in next, {
		MainMenuBarBackpackButton, 
		CharacterBag0Slot, 
		CharacterBag1Slot, 
		CharacterBag2Slot, 
		CharacterBag3Slot, 
	} do
		bagButton:SetParent(ContainerFrame1)
	end
	--右鍵點擊“公會與社區”按鈕打開傳統的公會界面或公會搜尋器（無公會時）
	GuildMicroButton:SetScript('OnClick', function(self, button)
		if button == 'RightButton' then
			if IsInGuild() then
				if not GuildFrame then GuildFrame_LoadUI() end
				if GuildFrame_Toggle then GuildFrame_Toggle() end
			else
				if not LookingForGuildFrame then LookingForGuildFrame_LoadUI() end
				if LookingForGuildFrame_Toggle then LookingForGuildFrame_Toggle() end
			end
		else
			ToggleGuildFrame()
		end
	end)
end