-- PercentNameplates 血條顯示血量%數
CreateFrame('frame'):SetScript('OnUpdate', function(self, elapsed)
	for index = 1, select('#', WorldFrame:GetChildren()) do
	local f = select(index, WorldFrame:GetChildren())
	if (f:IsForbidden()==false) then
		if f:GetName() and f:GetName():find('NamePlate%d') then
		f.h = select(1, select(1, f:GetChildren()):GetChildren())
			if f.h then
				if not f.h.v then
				f.h.v = f.h:CreateFontString(nil, "ARTWORK")  
				f.h.v:SetPoint("RIGHT")
				f.h.v:SetFont(STANDARD_TEXT_FONT, 10, 'OUTLINE')
				else
				local _, maxh = f.h:GetMinMaxValues()
				local val = f.h:GetValue()
				f.h.v:SetText(string.format(math.floor((val/maxh)*100)).." %")
				end
			end
		end
	end
	end
end)

--TargetPercentText 目標血量百分比
do
local t_hpFrame = CreateFrame("Frame", "TargetPercent", TargetFrameHealthBar)
t_hpFrame:SetPoint("LEFT", TargetFrameHealthBar, "right", 67, 14)	--78, 32
t_hpFrame:SetWidth(45)
t_hpFrame:SetHeight(20)
t_hpFrame.text = t_hpFrame:CreateFontString("TargetPercentText")	--, "OVERLAY"
t_hpFrame.text:SetAllPoints(t_hpFrame)
t_hpFrame.text:SetFontObject(TextStatusBarText)
t_hpFrame.text:SetJustifyH("RIGHT")
t_hpFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
t_hpFrame:RegisterEvent("UNIT_HEALTH")
t_hpFrame:SetScript("OnEvent", function(frame, _, unit)
if unit and not UnitIsUnit(unit, "target") then return end
local hp = UnitHealth("target")
if hp > 0 then
hp = hp / UnitHealthMax("target") * 100
frame.text:SetFormattedText("%.0f%%", hp)
else
frame.text:SetText("0%")
end
end)
end

--血條字體描邊+職業著色
local instanceType
local restricted = {
	party = true,
	raid = true,
}

local f = CreateFrame("Frame")
function f:OnEvent(event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		instanceType = select(2, IsInInstance())
	elseif event == "ZONE_CHANGED_NEW_AREA" then
		C_Timer.After(4, function() instanceType = select(2, IsInInstance()) end)
	elseif event == "ADDON_LOADED" then
		if ... == "EzMyUI" then
			-- need to be able to toggle bars, dirty hack because lazy af at the moment
			C_Timer.After(1, function()
				if GetCVar("nameplateShowOnlyNames") == "1" then
					SetCVar("nameplateShowOnlyNames", 0)
					if not InCombatLockdown() then
						NamePlateDriverFrame:UpdateNamePlateOptions()            -- taints
					end
				end
			end)
			self:SetupNameplates()
			self:UnregisterEvent(event)
		end
	end
end

local function colorize(color, text)
	return ("%s%s|r"):format(ConvertRGBtoColorString(color), text)
end

local CompactUnitFrame = CreateFrame("Frame")
hooksecurefunc("CompactUnitFrame_UpdateName", function(frame)
	if frame:IsForbidden() then return end

	if ShouldShowName(frame) then
		if frame.optionTable.colorNameBySelection then
			local name = GetUnitName(frame.unit)
			local isFriend = UnitIsFriend("player", frame.unit)
			if UnitIsPlayer(frame.unit) then
				local _, class = UnitClass(frame.unit)
				local color = RAID_CLASS_COLORS[class]
				if not CompactUnitFrame_IsTapDenied(frame) and isFriend and class then
					name = colorize(color, name)
				end
			end
			local level = UnitLevel(frame.unit)
			if level and level >= 1 then
				local lcolor = not isFriend and GetCreatureDifficultyColor(level) or NORMAL_FONT_COLOR
				name = colorize(lcolor, level) .. " " .. name
			end
			frame.name:SetText(name)
		end
	end
end)