--副本內收任務追蹤
local autocollapse = CreateFrame("Frame")
autocollapse:RegisterEvent("ZONE_CHANGED_NEW_AREA")
autocollapse:RegisterEvent("PLAYER_ENTERING_WORLD")
autocollapse:SetScript("OnEvent", function(self)
	if IsInInstance() then
		ObjectiveTrackerFrame.collapsed = true
		ObjectiveTracker_Collapse()
	else
		ObjectiveTrackerFrame.collapsed = nil
		ObjectiveTracker_Expand()
	end
end)


--Minimap
function GetMinimapShape() return 'SQUARE' end
Minimap:SetSize(150, 150)
Minimap:SetMaskTexture("Interface\\Buttons\\WHITE8x8")
Minimap:SetScale(1)
Minimap:SetFrameStrata("LOW")
Minimap:ClearAllPoints()
Minimap:SetPoint("TOPRIGHT"	, UIParent, -6, -22)

--Time
LoadAddOn("Blizzard_TimeManager")
select(1, TimeManagerClockButton:GetRegions()):Hide()
TimeManagerClockTicker:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
TimeManagerClockTicker:SetJustifyH("RIGHT")
TimeManagerClockTicker:SetTextColor(1, 0.82, 0.1)
TimeManagerClockTicker:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", 0, -2)
TimeManagerClockButton:ClearAllPoints()
TimeManagerClockButton:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", 0, -2)


--Mail
local mailicon = "Interface\\AddOns\\A4U\\media\\mail"
MiniMapMailFrame:ClearAllPoints()
MiniMapMailFrame:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, 5)
MiniMapMailFrame:SetSize(16,10)
MiniMapMailFrame:SetScale(0.9)
MiniMapMailIcon:SetTexture(mailicon)
MiniMapMailIcon:SetPoint("TOPLEFT", MiniMapMailFrame, "TOPLEFT", -1, 3)


-- Zone text
MinimapZoneTextButton:SetParent(Minimap)
MinimapZoneTextButton:SetPoint("CENTER", Minimap, "TOP", 0, 11)
MinimapZoneTextButton:SetFrameStrata("LOW")
MinimapZoneText:SetPoint("CENTER","MinimapZoneTextButton","CENTER", 0, 0)
MinimapZoneText:SetFont(STANDARD_TEXT_FONT, 16, "OUTLINE")
MinimapZoneText:SetJustifyH("CENTER")


--小地圖坐標
Minimap.coords = Minimap:CreateFontString(nil, 'ARTWORK') 
Minimap.coords:SetPoint("TOPLEFT", Minimap, "BOTTOMLEFT", 1, -2);
Minimap.coords:SetTextColor(1, 0.82, 0.1, 1);
Minimap.coords:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
Minimap.coords:SetJustifyH("LEFT");
Minimap:HookScript("OnUpdate", function(self, elapsed) 
    self.elapsed = (self.elapsed or 0) + elapsed
    if (self.elapsed < 0.2) then return end
    self.elapsed = 0
    local position = C_Map.GetPlayerMapPosition(MapUtil.GetDisplayableMapForPlayer(), "player")
    if (position) then
        self.coords:SetText(format("%.1f, %.1f", position.x*100, position.y*100))
    else
        self.coords:SetText("")
    end
end)


-- WorldMap CoordText  大地圖坐標
WorldMapFrame.playerPos = WorldMapFrame.BorderFrame:CreateFontString(nil, 'ARTWORK') 
WorldMapFrame.playerPos:SetFont(STANDARD_TEXT_FONT, 16, "OUTLINE") 
WorldMapFrame.playerPos:SetJustifyH("LEFT") 
WorldMapFrame.playerPos:SetPoint('LEFT', WorldMapFrameCloseButton, 'LEFT', -180, 0)
WorldMapFrame.playerPos:SetTextColor(1, 0.82, 0.1) 
WorldMapFrame.mousePos = WorldMapFrame.BorderFrame:CreateFontString(nil, "ARTWORK") 
WorldMapFrame.mousePos:SetFont(STANDARD_TEXT_FONT, 16, "OUTLINE") 
WorldMapFrame.mousePos:SetJustifyH("LEFT") 
WorldMapFrame.mousePos:SetPoint('LEFT', WorldMapFrame.playerPos, 'LEFT', -160, 0)
WorldMapFrame.mousePos:SetTextColor(1, 0.82, 0.1) 
WorldMapFrame:HookScript("OnUpdate", function(self, elapsed) 
    self.elapsed = (self.elapsed or 0) + elapsed
    if (self.elapsed < 0.2) then return end
    self.elapsed = 0
    --玩家座標
    local position = C_Map.GetPlayerMapPosition(MapUtil.GetDisplayableMapForPlayer(), "player")
    if (position) then
        self.playerPos:SetText(format("玩家：%.1f, %.1f", position.x*100, position.y*100))
    else
        self.playerPos:SetText("")
    end
    --游標座標
    local mapInfo = C_Map.GetMapInfo(self:GetMapID())
    if (mapInfo and mapInfo.mapType == 3) then
        local x, y = self.ScrollContainer:GetNormalizedCursorPosition()
        if (x and y and x > 0 and x < 1 and y > 0 and y < 1) then
            self.mousePos:SetText(format("游標：%.1f, %.1f", x*100, y*100))
        else
            self.mousePos:SetText("")
        end
    else
        self.mousePos:SetText("")
    end
end)


--WhoIsSpamming 誰點小地圖
local addon = CreateFrame('ScrollingMessageFrame', false, Minimap)
addon:SetSize(100,30)
addon:SetPoint('BOTTOM', Minimap, 0, 10)

addon:SetFont(STANDARD_TEXT_FONT, 15, 'OUTLINE')
addon:SetMaxLines(1)
addon:SetFading(true)
addon:SetFadeDuration(3)
addon:SetTimeVisible(5)

addon:RegisterEvent'MINIMAP_PING'
addon:SetScript('OnEvent', function(self, event, u)
local c = RAID_CLASS_COLORS[select(2,UnitClass(u))]
local name = UnitName(u)
addon:AddMessage(name, c.r, c.g, c.b)
end)


--memory
local iTimer_Start = GetTime()
if not IsAddOnLoaded("Blizzard_TimeManager") then LoadAddOn("Blizzard_TimeManager") end
local memoryval=function(val)
	return format(format("%%.%df %s",dec or 1,val > 1024 and "MB" or "KB"),val/(val > 1024 and 1024 or 1))
end

hooksecurefunc("TimeManagerClockButton_Update", function()
TimeManagerClockButton:SetScript("OnClick", function(self, button)
	UpdateAddOnMemoryUsage()
    local before = gcinfo()
    collectgarbage()
    UpdateAddOnMemoryUsage()
    local after = gcinfo()
    print("清除記憶體："..memoryval(before-after))
end)

function TimeManagerClockButton_UpdateTooltip()
	local iTimer_Now = GetTime()
	local iTimer_Past = iTimer_Now - iTimer_Start
	if iTimer_Past >= 0.5 then
	GameTooltip:ClearLines()
	--GameTooltip:SetOwner(Frames.memory, "ANCHOR_BOTTOMRIGHT",0,-5)
	local total, addons, all_mem = 0, {}, collectgarbage("count")
   collectgarbage()
    UpdateAddOnMemoryUsage()
    for i=1, GetNumAddOns(), 1 do
      if (GetAddOnMemoryUsage(i) > 0 ) then
        memory = GetAddOnMemoryUsage(i)
        entry = {name=GetAddOnInfo(i), memory = memory}
        table.insert(addons, entry)
        total = total + memory
      end
    end
    table.sort(addons, function(a, b) return a.memory > b.memory end)
	GameTooltip:AddDoubleLine("插件記憶體：", "\n", 0, .6, 1)
    i = 0
    for _, entry in pairs(addons) do
		GameTooltip:AddDoubleLine(entry.name, memoryval(entry.memory))
        i = i + 1
        if i >= 50 then  break  end
    end
    GameTooltip:AddLine("\n")
	GameTooltip:AddDoubleLine("插件：", memoryval(total), 0, .6, 1)
	GameTooltip:AddDoubleLine("系統：", memoryval(all_mem-total), 0, .6, 1)
	GameTooltip:AddDoubleLine("總佔用：", memoryval(all_mem), 0, .6, 1)
    if not UnitAffectingCombat("player") then GameTooltip:Show() end
		GameTooltip:Show()
		iTimer_Start = iTimer_Now
	end
end
end)