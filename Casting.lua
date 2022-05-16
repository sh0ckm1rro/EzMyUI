--Class color 血條按職業顏色
local function colour(statusbar, unit ,name)
    if UnitIsPlayer(unit) and UnitIsConnected(unit) and unit == statusbar.unit and UnitClass(unit) then
        local _, class = UnitClass(unit)
	c = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
        statusbar:SetStatusBarColor(c.r, c.g, c.b)
    end
end

hooksecurefunc("UnitFrameHealthBar_Update", colour)
hooksecurefunc("HealthBar_OnValueChanged", function(self)
	colour(self, self.unit)
end)

function SetNameColor(frame)
	if frame.name and frame.unit then
		local color = UnitIsPlayer(frame.unit) and RAID_CLASS_COLORS[select(2, UnitClass(frame.unit))] or NORMAL_FONT_COLOR
		frame.name:SetTextColor(color.r, color.g, color.b)
	end
end
hooksecurefunc("UnitFrame_Update", function(self)
	if self.name and self.unit then
		SetNameColor(self)
	end
end)

--禁用點擊
C_NamePlate.SetNamePlateSelfClickThrough(true)


--施法圖示
CastingBarFrame.Icon:Show()
CastingBarFrame.Icon:SetHeight(24) 
CastingBarFrame.Icon:SetWidth(24)

--焦點施法條
hooksecurefunc(FocusFrameSpellBar, "Show", function()
   FocusFrameSpellBar:SetScale("2")
   FocusFrameSpellBar:ClearAllPoints()
   FocusFrameSpellBar:SetPoint("TOP", UIParent, "TOP", 0, -20)
   FocusFrameSpellBar.SetPoint = function() end 
end)
     
FocusFrameSpellBar:SetStatusBarColor(0,.45,.9)
FocusFrameSpellBar.SetStatusBarColor = function() end

--目標施法條
hooksecurefunc(TargetFrameSpellBar, "Show", function()
   TargetFrameSpellBar:SetScale("2")
   TargetFrameSpellBar:ClearAllPoints()
   TargetFrameSpellBar:SetPoint("CENTER", UIParent, "CENTER", 0, -140)
   TargetFrameSpellBar.SetPoint = function() end
end)

TargetFrameSpellBar:SetStatusBarColor(.9,.8,1.34)
TargetFrameSpellBar.SetStatusBarColor = function() end


-- Focuser v0.51 by slizen
local modifier = "shift" -- shift, alt or ctrl
local mouseButton = "1" -- 1 = left, 2 = right, 3 = middle, 4 and 5 = thumb buttons if there are any

local function SetFocusHotkey(frame)
	frame:SetAttribute(modifier.."-type"..mouseButton, "focus")
end

local function CreateFrame_Hook(type, name, parent, template)
	if name and template == "SecureUnitButtonTemplate" then
		SetFocusHotkey(_G[name])
	end
end

hooksecurefunc("CreateFrame", CreateFrame_Hook)

local f = CreateFrame("CheckButton", "FocuserButton", UIParent, "SecureActionButtonTemplate")
f:SetAttribute("type1", "macro")
f:SetAttribute("macrotext", "/focus mouseover")
SetOverrideBindingClick(FocuserButton, true, modifier.."-BUTTON"..mouseButton, "FocuserButton")

local duf = {
	PetFrame,
	PartyMemberFrame1,
	PartyMemberFrame2,
	PartyMemberFrame3,
	PartyMemberFrame4,
	PartyMemberFrame1PetFrame,
	PartyMemberFrame2PetFrame,
	PartyMemberFrame3PetFrame,
	PartyMemberFrame4PetFrame,
	PartyMemberFrame1TargetFrame,
	PartyMemberFrame2TargetFrame,
	PartyMemberFrame3TargetFrame,
	PartyMemberFrame4TargetFrame,
	TargetFrame,
	TargetFrameToT,
	TargetFrameToTTargetFrame,
}

for i, frame in pairs(duf) do
	SetFocusHotkey(frame)
end


--射程著色
hooksecurefunc("ActionButton_UpdateRangeIndicator", function(self, checksRange, inRange)
if self.action == nil then return end
local isUsable, notEnoughMana = IsUsableAction(self.action)
	if ( checksRange and not inRange ) then
		_G[self:GetName().."Icon"]:SetVertexColor(0.5, 0.1, 0.1)
	elseif isUsable ~= true or notEnoughMana == true then
		_G[self:GetName().."Icon"]:SetVertexColor(0.4, 0.4, 0.4)
	else
		_G[self:GetName().."Icon"]:SetVertexColor(1, 1, 1)
	end
end)
