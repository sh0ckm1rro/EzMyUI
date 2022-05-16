local G, F, C, L = unpack(select(2,...))
local function TestFunc()
if AddUIDB.ct ==  false  then return end

SetCVar("enableFloatingCombatText",  1)	--勾选滚动战斗记录
--LightCT by Alza. 
local frames = {} 

for i = 1, 5 do 
   local f = CreateFrame("ScrollingMessageFrame", "LightCT"..i, UIParent)
   
   f:SetShadowColor(0, 0, 0, 0) 
   f:SetFadeDuration(0.5)		--淡入淡出时间
   f:SetTimeVisible(6) 		--持续时间
   f:SetMaxLines(20) 
   f:SetSpacing(3) 			--间距
   
   if i == 1 then 
      f:SetJustifyH"LEFT" --受到躲闪招架未命中
      f:SetPoint("LEFT", UIParent, "CENTER", -250, -180) 
	  f:SetFont("fonts\\ARHei.ttf" , 28, "OUTLINE")
	  f:SetHeight(95)
	  f:SetWidth(280)
   elseif i == 2 then
      f:SetJustifyH"RIGHT" --受到治疗hot
      f:SetPoint("RIGHT", UIParent, "CENTER", 250, -180) 
	  f:SetFont("fonts\\ARHei.ttf" , 28, "OUTLINE")
	  f:SetHeight(95)
	  f:SetWidth(280)

   end 

   frames[i] = f 
end
--/dump GetCVar("floatingCombatTextCombatHealingAbsorbSelf")

local tbl = { 
   ["DAMAGE"] =             {frame = 1, prefix =  "-",       arg2 = true,    r = 1,       g = 0.1,    b = 0.1}, 	--受到伤害
   ["DAMAGE_CRIT"] =        {frame = 1, prefix = "c-",       arg2 = true,    r = 1,       g = 0.1,    b = 0.1}, 	--受到暴击伤害
   ["SPELL_DAMAGE"] =       {frame = 1, prefix =  "-",       arg2 = true,    r = 0.79,    g = 0.3,    b = 0.85}, 	--受到法术伤害
   ["SPELL_DAMAGE_CRIT"] =  {frame = 1, prefix = "c-",       arg2 = true,    r = 0.79,    g = 0.3,    b = 0.85}, 	--受到法术暴击伤害
   ["HEAL"] =               {frame = 2, prefix =  "+",       arg3 = true,    r = 0.1,    g = 1,       b = 0.1}, 	--直接治疗
   ["HEAL_CRIT"] =          {frame = 2, prefix = "c+",       arg3 = true,    r = 0.1,    g = 1,       b = 0.1}, 	--直接暴击治疗
   ["PERIODIC_HEAL"] =      {frame = 2, prefix =  "+",       arg3 = true,    r = 0.1,    g = 1,       b = 0.1}, 	--hot治疗
   ["MISS"] =               {frame = 1, prefix = COMBAT_TEXT_MISS,                r = 1,       g = 0.1,    b = 0.1}, 
   ["SPELL_MISS"] =         {frame = 1, prefix = COMBAT_TEXT_MISS,                r = 0.79,    g = 0.3,    b = 0.85}, 
   ["SPELL_REFLECT"] =      {frame = 1, prefix = COMBAT_TEXT_REFLECT,             r = 1,       g = 1,       b = 1}, 
   ["DODGE"] =              {frame = 1, prefix = COMBAT_TEXT_DODGE,                r = 1,       g = 0.1,    b = 0.1}, 
   ["PARRY"] =              {frame = 1, prefix = COMBAT_TEXT_PARRY,                r = 1,       g = 0.1,    b = 0.1}, 
   ["BLOCK"] =              {frame = 1, prefix = COMBAT_TEXT_BLOCK,     spec = true,   r = 1,       g = 0.1,    b = 0.1}, 
   ["RESIST"] =             {frame = 1, prefix = COMBAT_TEXT_RESIST,    spec = true,    r = 1,       g = 0.1,    b = 0.1}, 
   ["SPELL_RESIST"] =       {frame = 1, prefix = COMBAT_TEXT_RESIST,    spec = true,    r = 0.79,    g = 0.3,    b = 0.85}, 
   ["ABSORB"] =             {frame = 1, prefix = COMBAT_TEXT_ABSORB,    	spec = true,  r = 1,       g = 0.1,    b = 0.1},	--吸收 
   ["SPELL_ABSORB"] =       {frame = 1, prefix = COMBAT_TEXT_SPELL_ABSORB,  spec = true,  r = 0.79,    g = 0.3,    b = 0.85}, --法术吸收
   ["HEAL_ABSORB"] =        {frame = 2, prefix = "+( ",    	arg3 = true,  r = 0.1,       g = 1,    b = 0.1},	--治疗吸收盾
   ["HEAL_CRIT_ABSORB"] =   {frame = 2, prefix = "c+( ",    arg3 = true,  r = 0.1,       g = 1,    b = 0.1},	--治疗暴击吸收盾
   ["ABSORB_ADDED"] =       {frame = 2, prefix = "+( ",    	arg3 = true,  r = 0.1,       g = 1,    b = 0.1},	--吸收盾
   ["DEFLECT"] =            {frame = 1, prefix = COMBAT_TEXT_DEFLECT,   spec = true,    r = 1,       g = 0.1,    b = 0.1}, 
   ["SPELL_DEFLECT"] =      {frame = 1, prefix = COMBAT_TEXT_DEFLECT,   spec = true,    r = 0.79,    g = 0.3,    b = 0.85}, 
} 
--COMBAT_TEXT_ABSORB

ShortValue = function(value)
	if value >= 1e4 then
		return ("%.1fw"):format(value / 1e4)
	else
		return value
	end
end

local info 
local template = "-%s (%s)"

local events = CreateFrame"Frame" 
events:RegisterEvent("COMBAT_TEXT_UPDATE") 
events:RegisterEvent("ADDON_LOADED") 
events:SetScript("OnEvent", function(self, event, subev, ...) 
local arg2,arg3 = GetCurrentCombatTextEventInfo();
   if event=="ADDON_LOADED" then 
      if subev=="Blizzard_CombatText" then 
         CombatText:SetScript("OnUpdate", nil) 
         CombatText:SetScript("OnEvent", nil) 
         CombatText:UnregisterAllEvents() 
         self:UnregisterEvent("ADDON_LOADED") 
      end 
      return 
   end 
   info = tbl[subev] 
   if info then 
      local msg = info.prefix or "" 
      if info.spec then 
         if arg3 then 
            msg = template:format(ShortValue(arg2), ShortValue(arg3)) 
         end 
      else  
         if info.arg2 then msg = msg..ShortValue(arg2) end 
         if info.arg3 then msg = msg..ShortValue(arg3) end 		 
      end 
      frames[info.frame]:AddMessage(msg, info.r, info.g, info.b) 
   end 
end)

end
G:RegisterEvent("PLAYER_LOGIN",TestFunc)