--PlateColor.lua 血條仇恨變色
hooksecurefunc("CompactUnitFrame_OnUpdate", function(frame)
   if C_NamePlate.GetNamePlateForUnit(frame.unit) ~= C_NamePlate.GetNamePlateForUnit("player") and not UnitIsPlayer(frame.unit) and not CompactUnitFrame_IsTapDenied(frame) then
	local threat = UnitThreatSituation("player", frame.unit) or 0
	local reaction = UnitReaction(frame.unit, "player")
	local name = UnitName(frame.unit)
	local A = UnitBuff(frame.unit,1)
	local B = UnitBuff(frame.unit,2)
	local C = UnitBuff(frame.unit,3)
	local D = UnitBuff(frame.unit,4)
	  
	if name == "爆炸物" then	--邪能炸藥<綠色>
		r, g, b = 0, 1, 0
	elseif A == "戈霍恩共生體" or B == "戈霍恩共生體" or C == "戈霍恩共生體"  or D == "戈霍恩共生體" then	--共生<藍色>
		r, g, b = 0, 0, 1
	elseif name == "戈霍恩之嗣" then	--共生小怪<亮粉>
		r, g, b = 1, 0, 1

	if threat == 3 then
		r, g, b = .3, 0, .6	--仇恨穩定/當前坦克<紫色>

	--[[elseif threat == 2 and GetSpecializationRole(GetSpecialization()) == "TANK" then
		r, g, b = 0, 0, 1	--非當前仇恨/當前坦克<藍色>
	elseif threat == 2 then
		r, g, b = .6, 0, .6	--快OT/非當前坦克 顏色
	elseif threat == 1 then
		r, g, b = 1, .5, 0	--當前仇恨/非當前坦克(遠程ot)<橘色>]]

	elseif threat == 1 or threat == 2 then       
		r, g, b = 1, .5, 0	--高仇恨<橘色>
	elseif UnitIsUnit(frame.displayedUnit, "target") then 
		r, g, b = 0, 1, 1	--你的目標<青色>
	elseif reaction == 4 then
		r, g, b = 1, 1, 0	--中立怪<黃色>
	else
		r, g, b = 1, 0, 0	--紅色
	end
	frame.healthBar:SetStatusBarColor(r, g, b, 1)
	end
end)