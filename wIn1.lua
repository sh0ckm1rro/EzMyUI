--自動清記憶體
local eventcount = 0
local a = CreateFrame("Frame")
a:RegisterAllEvents()
a:SetScript("OnEvent", function(self, event)
   eventcount = eventcount + 1
   if InCombatLockdown() then return end
   if eventcount > 6000 or event == "PLAYER_ENTERING_WORLD" then
      collectgarbage("collect")
      eventcount = 0
   end
end)
--脫戰清記憶體
local F = CreateFrame("Frame")
   F:RegisterEvent("PLAYER_ENTERING_WORLD")
   F:RegisterEvent("PLAYER_REGEN_ENABLED")
   F:SetScript("OnEvent", function() _G.collectgarbage("collect") end)

--介面改團框大小
local n,w,h="CompactUnitFrameProfilesGeneralOptionsFrame"
	h=_G[n.."HeightSlider"]
	w=_G[n.."WidthSlider"]
	h:SetMinMaxValues(10,150)
	w:SetMinMaxValues(10,150)


--[[ Slash commands 命令 ]]
print("|cff3399ffw|rIn1 已加載")
