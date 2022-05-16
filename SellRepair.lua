--自動賣灰修裝
local sellgrays	= 1
local autorepair	= 1
local UseGuildBank	= 0

local f = CreateFrame("Frame")
f:RegisterEvent("MERCHANT_SHOW")
f:SetScript("OnEvent", function()
	if sellgrays then
	c = 0
		for bag = 0, 4 do
			for slot = 1, GetContainerNumSlots(bag) do
			if GetContainerItemLink(bag, slot) then
			_, link, iRarity, _,_,_,_,_,_,_, iPrice = GetItemInfo(GetContainerItemLink(bag, slot))
				if iRarity==0 then
				_, iCount = GetContainerItemInfo(bag, slot)
				c = c + (iPrice * iCount)
					print(link.." > "..GetCoinTextureString(iPrice * iCount))
					UseContainerItem(bag, slot)
				end
			end
			end
		end
		if c~=0 then
			print("|cffffff00共售出：|r" ..GetCoinTextureString(c))
		end
	end

	if (autorepair and CanMerchantRepair()) then
		cost, repair = GetRepairAllCost()
		if cost>0 then
			if repair then
			local str = GetMoneyString(cost)
			if UseGuildBank == 1 and IsInGuild() and CanGuildBankRepair() and (GetGuildBankWithdrawMoney() >= cost) and (GetGuildBankMoney() >= cost) then
				RepairAllItems(1)
				str = "公款修理："..str
			elseif GetMoney() >= cost then
				RepairAllItems()
				str = "自費修理："..str
			else
				str = "餘額不足！需要："..str
			end
			print("|cffffff00"..str.."|r")
			end
		end
	end
end)