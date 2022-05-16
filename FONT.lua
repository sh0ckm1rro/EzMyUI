local cfg = {
font = STANDARD_TEXT_FONT,
}
QuestTitleFont:SetFont(cfg.font,18)		--任務名稱
QuestFont:SetFont(cfg.font, 18)		--任務敘述
QuestFontNormalSmall:SetFont(cfg.font, 16)	--完成目標
MailTextFontNormal:SetFont(cfg.font, 18)	--信件內文

--字體大小描邊
local function SetFont(obj, optSize)
local fontName, _,fontFlags  = obj:GetFont()
	obj:SetFont(fontName,optSize,"OUTLINE")
	obj:SetShadowOffset(0, 0)
end
--SetFont(GameFontNormalSmall, 16)		--ID&快捷列&聊天分頁&聊天&公會新聞&預組
SetFont(GameFontNormal, 17)			--任務欄&技能
SetFont(SystemFont_LargeNamePlateFixed,14)
SetFont(SystemFont_NamePlateFixed,14)
SetFont(ErrorFont, 18)
