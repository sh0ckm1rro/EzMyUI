---------------------------------
-- CloudyUnitInfo, by Cloudyfa 專精裝等
---------------------------------
--- Variables ---
local GearDB, SpecDB, currentUNIT, currentGUID = {}, {}
local nextInspectRequest, lastInspectRequest = 0, 0
local gearPrefix = STAT_AVERAGE_ITEM_LEVEL..": ".."|cffA0A0A0"	--|cff70C0F5
local specPrefix = SPECIALIZATION..": ".."|cffA0A0A0"	--|cff70C0F5
local NO_TALENTS = "|cffB5B5B5"..NONE.."|r"

--- Create Frame ---
local f = CreateFrame("Frame", nil)
f:RegisterEvent("UNIT_INVENTORY_CHANGED")
f:RegisterEvent("INSPECT_READY")

--- Set Unit Info ---
local function SetUnitInfo(gear, spec)
	if (not gear) and (not spec) then return end
	local _, unit = GameTooltip:GetUnit()
	if (not unit) or (UnitGUID(unit) ~= currentGUID) then return end

	local gearLine, specLine
	for i = 2, GameTooltip:NumLines() do
		local line = _G["GameTooltipTextLeft" .. i]
		local text = line:GetText()
		if text and strfind(text, gearPrefix) then
			gearLine = line
		elseif text and strfind(text, specPrefix) then
			specLine = line
		end
	end

	if spec then
		spec = specPrefix..spec
		if specLine then
			specLine:SetText(spec)
		else
			GameTooltip:AddLine(spec)
		end
	end

	if gear then
		gear = gearPrefix..gear
		if gearLine then
			gearLine:SetText(gear)
		else
			GameTooltip:AddLine(gear)
		end
	end

	GameTooltip:Show()
end

--- Scan Item Level ---
local lvlPattern = _G["ITEM_LEVEL"]:gsub("%%d", "(%%d+)")
local ItemDB, scanTip = {}
local function scanItemLevel(link, quality)
	if ItemDB[link] and quality ~= 6 and not IsShiftKeyDown() then return ItemDB[link] end	--need reviewed

	if not scanTip then
		scanTip = CreateFrame("GameTooltip", "NDuiScantip", nil, "GameTooltipTemplate")
 		scanTip:SetOwner(UIParent, "ANCHOR_NONE")
	end
	scanTip:ClearLines()
 	scanTip:SetHyperlink(link)

	for i = 2, scanTip:NumLines() do
		local textLine = _G["NDuiScantipTextLeft"..i]
		if textLine and textLine:GetText() then
			local level = strmatch(textLine:GetText(), lvlPattern)
			if level then
				ItemDB[link] = tonumber(level)
				return ItemDB[link]
			end
		end
	end
end

--- Unit Gear Info ---
local function UnitGear(unit)
	if (not unit) or (UnitGUID(unit) ~= currentGUID) then return end
	local class = select(2, UnitClass(unit))
	local ilvl, boa, total, haveWeapon, twohand = 0, 0, 0, 0, 0
	local delay, mainhand, offhand, hasArtifact
	local weapon = {0, 0}

	for i = 1, 17 do
		if (i ~= 4) then
			local itemTexture = GetInventoryItemTexture(unit, i)

			if itemTexture then
				local itemLink = GetInventoryItemLink(unit, i)

				if (not itemLink) then
					delay = true
				else
					local _, _, quality, level, _, _, _, _, slot = GetItemInfo(itemLink)
					if (not quality) or (not level) then
						delay = true
					else
						if quality == 7 then
							boa = boa + 1
						end

						local currentLevel = scanItemLevel(itemLink, quality) or level
						if i < 16 then
							total = total + currentLevel
						end

						if i == 16 then
							if quality == 6 then hasArtifact = true end

							weapon[1] = currentLevel
							haveWeapon = haveWeapon + 1
							if slot == "INVTYPE_2HWEAPON" or slot == "INVTYPE_RANGED" or (slot == "INVTYPE_RANGEDRIGHT" and class == "HUNTER") then
								mainhand = currentLevel
								twohand = twohand + 1
							end
						end
						if i == 17 then
							weapon[2] = currentLevel
							haveWeapon = haveWeapon + 1
							if slot == "INVTYPE_2HWEAPON" then
								offhand = currentLevel
								twohand = twohand + 1
							end
						end
					end
				end
			end
		end
	end

	if (not delay) then
		if hasArtifact or twohand == 2 then
			local higher = math.max(weapon[1], weapon[2])
			total = total + higher*2
		elseif twohand == 1 and haveWeapon == 1 then
			total = total + weapon[1]*2 + weapon[2]*2
		elseif twohand == 1 and haveWeapon == 2 then
			if mainhand then
				if mainhand >= weapon[2] then
					total = total + mainhand*2
				else
					total = total + mainhand + weapon[2]
				end
			elseif offhand then
				if offhand >= weapon[1] then
					total = total + offhand*2
				else
					total = total + offhand + weapon[1]
				end
			end
		else
			total = total + weapon[1] + weapon[2]
		end
		ilvl = total / 16	--it do scan for player anyway

		if (ilvl > 0) then ilvl = string.format("%.1f", ilvl) end
		if (boa > 0) then ilvl = ilvl.." |cff00ccff("..HEIRLOOMS.."x"..boa..")" end
	else
		ilvl = nil
	end

	return ilvl
end

--- Unit Specialization ---
local function UnitSpec(unit)
	if (not unit) or (UnitGUID(unit) ~= currentGUID) then return end

	local specName
	if (unit == "player") then
		local specIndex = GetSpecialization()
		if specIndex then
			specName = select(2, GetSpecializationInfo(specIndex))
		end
	else
		local specID = GetInspectSpecialization(unit)
		if specID and (specID > 0) then
			specName = select(2, GetSpecializationInfoByID(specID))
		end
	end

	return specName
end

--- Scan Current Unit ---
local function ScanUnit(unit, forced)
	local cachedGear, cachedSpec

	if UnitIsUnit(unit, "player") then
		cachedGear = UnitGear("player")
		cachedSpec = UnitSpec("player")
		SetUnitInfo(cachedGear or LFG_LIST_LOADING, cachedSpec or LFG_LIST_LOADING)
	else
		if (not unit) or (UnitGUID(unit) ~= currentGUID) then return end
		cachedGear = GearDB[currentGUID]
		cachedSpec = SpecDB[currentGUID]

		if cachedGear or forced then
			SetUnitInfo(cachedGear or LFG_LIST_LOADING, cachedSpec)
		end

		if not (IsShiftKeyDown() or forced) then
			if cachedGear and cachedSpec then return end
			if UnitAffectingCombat("player") then return end
		end

		if not UnitIsVisible(unit) then return end
		if UnitIsDeadOrGhost("player") or UnitOnTaxi("player") then return end
		if InspectFrame and InspectFrame:IsShown() then return end

		SetUnitInfo(LFG_LIST_LOADING, cachedSpec or LFG_LIST_LOADING)

		local timeSinceLastInspect = GetTime() - lastInspectRequest
		if (timeSinceLastInspect >= 1.5) then
			nextInspectRequest = 0
		else
			nextInspectRequest = 1.5 - timeSinceLastInspect
		end
		f:Show()
	end
end

--- Handle Events ---
f:SetScript("OnEvent", function(self, event, ...)
	if (event == "UNIT_INVENTORY_CHANGED") then
		local unit = ...
		if (UnitGUID(unit) == currentGUID) then
			ScanUnit(unit, true)
		end
	elseif (event == "INSPECT_READY") then
		local guid = ...
		if (guid ~= currentGUID) then return end

		local gear = UnitGear(currentUNIT)
		GearDB[currentGUID] = gear

		local spec = UnitSpec(currentUNIT)
		SpecDB[currentGUID] = spec

		if (not gear) or (not spec) then
			ScanUnit(currentUNIT, true)
		else
			SetUnitInfo(gear, spec)
		end
	end
end)

f:SetScript("OnUpdate", function(self, elapsed)
	nextInspectRequest = nextInspectRequest - elapsed
	if (nextInspectRequest > 0) then return end
	self:Hide()

	if currentUNIT and (UnitGUID(currentUNIT) == currentGUID) then
		lastInspectRequest = GetTime()
		NotifyInspect(currentUNIT)
	end
end)

GameTooltip:HookScript("OnTooltipSetUnit", function(self)
	local _, unit = self:GetUnit()
	if (not unit) or (not CanInspect(unit)) then return end

	currentUNIT, currentGUID = unit, UnitGUID(unit)
	ScanUnit(unit)
end)