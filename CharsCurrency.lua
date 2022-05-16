--Currency ±`¥Î³f¹ô
local token = {1813, 1828, 1820, 1767, 1191}
local GetCurrencyInfo, select, tip = C_CurrencyInfo.GetCurrencyInfo, select, GameTooltip
local font = GameTooltipTextLeft1:GetFont()

local function OnEvent(self)
	for i = 1, #token do
		local info = GetCurrencyInfo(token[i])
		if info.discovered then
			self[i].text:SetText(info.quantity)
		else
			self[i].text:SetText("--")
		end
	end
end

local tokens = CreateFrame('Frame')
tokens:RegisterEvent('CURRENCY_DISPLAY_UPDATE')
tokens:SetScript('OnEvent', OnEvent)

local function OnEnter(self)
	tip:ClearLines()
	tip:SetOwner(self, 'ANCHOR_RIGHT')
	tip:SetHyperlink(self.link)
	tip:Show()
end

for i = 1, #token do
	local id = token[i]
	local info = GetCurrencyInfo(id)
	local t = CreateFrame('Frame', nil, Minimap)
	t:SetPoint('BOTTOMLEFT', UIParent, 'BOTTOMRIGHT', -78, 92+22*(i-1))
	t:SetSize(16, 16)
	t.texture = t:CreateTexture(nil, 'ARTWORK')
	t.texture:SetAllPoints(t)
	t.texture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	t.texture:SetTexture(info.iconFileID)
	t.text = t:CreateFontString()
	t.text:SetPoint('LEFT', t, 'RIGHT', 4, 0)
	t.text:SetFont(font, 16, "OUTLINE")
	t.text:SetShadowOffset(1, 1)
	t.text:SetShadowColor(0, 0, 0, 0.4)
	t.link = '|Hcurrency:'..id
	t:SetScript('OnEnter', OnEnter)
	t:SetScript('OnLeave', GameTooltip_Hide)
	tokens[i] = t
end