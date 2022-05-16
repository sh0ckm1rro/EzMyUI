--DressingRoomFunctions 塑型脫光/切換種族
local function Noop() end
local _backgroundList = {
   [1] = "Human",
   [2] = "Orc",
   [3] = "Dwarf",
   [4] = "NightElf",
   [5] = "Scourge",
   [6] = "Tauren",
   [7] = "Gnome",
   [8] = "Troll",
   [9] = "Goblin",
   [10] = "BloodElf",
   [11] = "Draenei",
   [22] = "Worgen",
   [24] = "Pandaren"
};

DRF_Version = GetAddOnMetadata("DressingRoomFunctions","Version")

local DRF_button1 = CreateFrame("Button","DRF_UndressButton",DressUpFrame,"UIPanelButtonTemplate")
local DRF_button2 = CreateFrame("Button","DRF_TargetButton",DressUpFrame,"UIPanelButtonTemplate")
local DRF_button3 = CreateFrame("Button","DRF_RaceButton",DressUpFrame,"UIPanelButtonTemplate")
local DRF_menu1 = CreateFrame("FRAME","DRF_RaceMenu",DRF_button3,"UIDropDownMenuTemplate")

DRF_button1:SetPoint("Bottom",DressUpFrame,"Left",30,-268)
DRF_button1:SetSize(50,22)
DRF_button1.text = _G["DRF_UndressButton"]
DRF_button1.text:SetText("脱光")
DRF_button1:SetScript("OnClick",function(self,event,arg1) 
   DressUpModel:Undress()
end);

DRF_button2:SetPoint("Center",DRF_UndressButton,"Center",52,0)
DRF_button2:SetSize(50,22)
DRF_button2.text = _G["DRF_TargetButton"]
DRF_button2.text:SetText("目標")
DRF_button2:SetScript("OnClick",function(self,event,arg1)
   local race, fileName = UnitRace("target")

   if ( UnitIsPlayer("target") ) then
      DressUpModel:SetUnit("target")
      SetDressUpBackground(DressUpFrame, fileName)
   else
      race, fileName = UnitRace("player")
      DressUpModel:SetUnit("player")
      SetDressUpBackground(DressUpFrame, fileName)
   end
end);


DRF_button3:SetPoint("Center",DRF_UndressButton,"Center",102,0)
DRF_button3:SetSize(50,22)
DRF_button3.text = _G["DRF_RaceButton"];
DRF_button3.text:SetText("種族")

local function DRF_SetArbitraryRace(id,gender)
   DressUpModel:SetCustomRace(id,gender)
   SetDressUpBackground(DressUpFrame, _backgroundList[id])
   DressUpModel:TryOn(23323)
end

local function DRF_menu1_OnClick(self, arg1, arg2, checked)
   DRF_SetArbitraryRace(arg1,arg2)
end

DRF_menu1:SetPoint("CENTER")
UIDropDownMenu_Initialize(DRF_menu1, function(self, level, menuList)
   local info = UIDropDownMenu_CreateInfo()
   if level == 1 then
      info.checked = false
      info.text = "男性";
      info.menuList, info.hasArrow = 0, true;
      UIDropDownMenu_AddButton(info, level)
      info.text = "女性";
      info.menuList, info.hasArrow = 1, true;
      UIDropDownMenu_AddButton(info, level)
   else
      info.checked = false;
      info.func = DRF_menu1_OnClick;
      info.arg2 = menuList;
      info.text, info.arg1 = "人類", 1;
      UIDropDownMenu_AddButton(info, level)
      info.text, info.arg1 = "獸人", 2;
      UIDropDownMenu_AddButton(info, level)
      info.text, info.arg1 = "矮人", 3;
      UIDropDownMenu_AddButton(info, level)
      info.text, info.arg1 = "夜精靈", 4;
      UIDropDownMenu_AddButton(info, level)
      info.text, info.arg1 = "不死族", 5;
      UIDropDownMenu_AddButton(info, level)
      info.text, info.arg1 = "牛頭人", 6;
      UIDropDownMenu_AddButton(info, level)
      info.text, info.arg1 = "地精", 7;
      UIDropDownMenu_AddButton(info, level)
      info.text, info.arg1 = "食人妖", 8;
      UIDropDownMenu_AddButton(info, level)
      info.text, info.arg1 = "哥布林", 9;
      UIDropDownMenu_AddButton(info, level)
      info.text, info.arg1 = "血精靈", 10;
      UIDropDownMenu_AddButton(info, level)
      info.text, info.arg1 = "德萊尼", 11;
      UIDropDownMenu_AddButton(info, level)
      info.text, info.arg1 = "狼人", 22;
      UIDropDownMenu_AddButton(info, level)
      info.text, info.arg1 = "熊貓人", 24;
      UIDropDownMenu_AddButton(info, level)
   end
end, "MENU");

DressUpFrameResetButton:SetScript("OnClick",function(self,event,arg1)
   local race, fileName = UnitRace("player")

   DressUpModel:SetUnit("player")
   DressUpModel:Dress()
   SetDressUpBackground(DressUpFrame, fileName)
   PlaySound("798")
end)

DRF_button3:SetScript("OnClick",function(self,event,arg1)
   ToggleDropDownMenu(1, nil, DRF_menu1, "cursor", 3, -3)
end)
