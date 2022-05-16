--PlateColor.lua ��������ܦ�
hooksecurefunc("CompactUnitFrame_OnUpdate", function(frame)
   if C_NamePlate.GetNamePlateForUnit(frame.unit) ~= C_NamePlate.GetNamePlateForUnit("player") and not UnitIsPlayer(frame.unit) and not CompactUnitFrame_IsTapDenied(frame) then
	local threat = UnitThreatSituation("player", frame.unit) or 0
	local reaction = UnitReaction(frame.unit, "player")
	local name = UnitName(frame.unit)
	local A = UnitBuff(frame.unit,1)
	local B = UnitBuff(frame.unit,2)
	local C = UnitBuff(frame.unit,3)
	local D = UnitBuff(frame.unit,4)
	  
	if name == "�z����" then	--���ଵ��<���>
		r, g, b = 0, 1, 0
	elseif A == "���N���@����" or B == "���N���@����" or C == "���N���@����"  or D == "���N���@����" then	--�@��<�Ŧ�>
		r, g, b = 0, 0, 1
	elseif name == "���N������" then	--�@�ͤp��<�G��>
		r, g, b = 1, 0, 1

	if threat == 3 then
		r, g, b = .3, 0, .6	--����í�w/��e�Z�J<����>

	--[[elseif threat == 2 and GetSpecializationRole(GetSpecialization()) == "TANK" then
		r, g, b = 0, 0, 1	--�D��e����/��e�Z�J<�Ŧ�>
	elseif threat == 2 then
		r, g, b = .6, 0, .6	--��OT/�D��e�Z�J �C��
	elseif threat == 1 then
		r, g, b = 1, .5, 0	--��e����/�D��e�Z�J(���{ot)<���>]]

	elseif threat == 1 or threat == 2 then       
		r, g, b = 1, .5, 0	--������<���>
	elseif UnitIsUnit(frame.displayedUnit, "target") then 
		r, g, b = 0, 1, 1	--�A���ؼ�<�C��>
	elseif reaction == 4 then
		r, g, b = 1, 1, 0	--���ߩ�<����>
	else
		r, g, b = 1, 0, 0	--����
	end
	frame.healthBar:SetStatusBarColor(r, g, b, 1)
	end
end)