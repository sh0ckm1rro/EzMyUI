local function defaultcvar()
--玩家名條染色
SetCVar("ShowClassColorInFriendlyNameplate", 1)
SetCVar("ShowClassColorInNameplate", 1)
C_NamePlate.SetNamePlateSelfClickThrough(true)			--禁點自身資源條
SetCVar("alwaysCompareItems", 1)						--自動裝備對比
SetCVar("cameraDistanceMaxZoomFactor", 2.6)				--最大視角
SetCVar("autoQuestWatch", 1)							--任務
SetCVar("showQuestTrackingTooltips", 1)					--任務進度游標提示
--SetCVar("floatingCombatTextCombatDamageDirectionalScale", 2)		--傷害數字顯示在血條上方,改數字0123456789
SetCVar("cameraSmoothTrackingStyle", 0)				--引導技能不轉視角
--SetCVar("nameplateOtherAtBase", 1)						--血條位置，預設0頭上，1頭上但離怪近，2腳下
SetCVar("xpBarText", 1) 								--經驗條
SetCVar("nameplateOverlapH", 0.3)	--名條堆疊水平百分比，預設0.8
SetCVar("nameplateOverlapV", 0.5)	--名條堆疊垂直百分比，預設1.1
SetCVar("nameplateShowFriendlyNPCs", 0)	--關閉友方NPC名條
end 
local frame = CreateFrame("FRAME", "defaultcvar") 
   frame:RegisterEvent("PLAYER_ENTERING_WORLD") 
local function eventHandler(self, event, ...) 
         defaultcvar() 
end 
frame:SetScript("OnEvent", eventHandler)

BossBanner:SetScale(0.8)		--縮小BOSS掉落物