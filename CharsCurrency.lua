--Currency ±`¥Î³f¹ô
local F, Currency = CreateFrame("Frame"), {1220,1273,1533}
   F.icon = {}
   for i = 1, 6 do
      local icon = CreateFrame("Frame", nil, UIParent)
      --icon:SetPoint("BOTTOMRIGHT", _G["Minimap"], "BOTTOMLEFT", 3, 20*i+2*(i-1)-10)
      icon:SetPoint("TOPRIGHT", _G["Minimap"], "BOTTOMRIGHT", 10, -20*i+2*(i-1)-10)
      icon:SetSize(16, 16)
      icon.texture = icon:CreateTexture(nil, "ARTWORK")
      icon.texture:SetAllPoints(icon)
      icon.texture:SetTexCoord(.1, .9, .1, .9)
      icon.text = icon:CreateFontString()
      icon.text:SetPoint("RIGHT", icon, "LEFT", -1, 0)
      icon.text:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
      icon.text:SetShadowOffset(0, 0)
      icon.text:SetShadowColor(0,0,0,.8)
      F.icon[i] = icon
   end

local GetCurrencyInfo, select, sub = GetCurrencyInfo, select, string.sub
   for i = 1, #Currency do
      local label, _, icon = GetCurrencyInfo(Currency[i])
      F.icon[i].texture:SetTexture(icon)
      F.icon[i]:SetScript("OnEnter", function()
         _G["GameTooltip"]:ClearLines()
         _G["GameTooltip"]:SetOwner(F.icon[i], "ANCHOR_LEFT")
         _G["GameTooltip"]:AddLine(sub(label, 1, 24))
         _G["GameTooltip"]:Show()
      end)
      F.icon[i]:SetScript("OnLeave", function()
         _G["GameTooltip"]:Hide()
      end)
   end

   F:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
   F:SetScript("OnEvent", function()
      for i = 1, #Currency do
         F.icon[i].text:SetText(select(2, GetCurrencyInfo(Currency[i])))
      end
   end)