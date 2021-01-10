
local ADDON_NAME = "PurchaseTracker"

local PurchaseTracker = {
    internal = {
        chat = LibChatMessage(ADDON_NAME, "PuTr"),
        gettext = LibGetText(ADDON_NAME).gettext
    },
}
local chat = PurchaseTracker.internal.chat
local gettext = PurchaseTracker.internal.gettext

_G[ADDON_NAME] = PurchaseTracker

function PurchaseTracker:Initialize()
    local acctDefaults = {
        ['purchases'] = {},
    }

    self.savedVariables = ZO_SavedVars:NewAccountWide("PurchaseTrackerVars", 1, nil, acctDefaults, nil, 'PurchaseTracker')
    self:OverWriteToolTipFunction(ItemTooltip, "SetAttachedMailItem")
	self:OverWriteToolTipFunction(ItemTooltip, "SetBagItem")
	self:OverWriteToolTipFunction(ItemTooltip, "SetBuybackItem")
	self:OverWriteToolTipFunction(ItemTooltip, "SetLootItem")
	self:OverWriteToolTipFunction(ItemTooltip, "SetTradeItem")
	self:OverWriteToolTipFunction(ItemTooltip, "SetStoreItem")
	self:OverWriteToolTipFunction(ItemTooltip, "SetTradingHouseListing")
	self:OverWriteToolTipFunction(ItemTooltip, "SetWornItem")
    self:OverWriteToolTipFunction(ItemTooltip, "SetQuestReward")
    self:OverWriteToolTipFunction(ItemTooltip, "SetTradingHouseItem")

    local AwesomeGuildStore = _G["AwesomeGuildStore"]
    AwesomeGuildStore:RegisterCallback(AwesomeGuildStore.callback.ITEM_PURCHASED, function(itemData)
        local count = itemData.stackCount
        local name = itemData.name
        local itemLink = itemData.itemLink
        local seller = ZO_LinkHandler_CreateDisplayNameLink(itemData.sellerName)
        local price = ZO_Currency_FormatPlatform(CURT_MONEY, itemData.purchasePrice, ZO_CURRENCY_FORMAT_AMOUNT_ICON)    
        local guildName = itemData.guildName
        --local message = gettext("You have bought <<1>>x <<t:2>> ( <<6>> ) from <<3>> for <<4>> in <<5>>", count, name, seller, price, guildName, theIID)   
        --chat:Print(message)

        local itemId = GetItemLinkItemId(itemLink)
        local savedPurchase = {
            itemName = name,
            itemCount = count,
            itemPrice = itemData.purchasePrice,
            singlePrice = itemData.purchasePrice / count,
        }
        
        if self.savedVariables['purchases'] == nil then
            self.savedVariables['purchases'] = {}
        end
    
        if self.savedVariables['purchases'][itemId] == nil then
            self.savedVariables['purchases'][itemId] = {}
        end
    
        table.insert(PurchaseTracker.savedVariables['purchases'][itemId], savedPurchase)
    end)
end

function PurchaseTracker:OverWriteToolTipFunction(toolTipControl, functionName)
	local base = toolTipControl[functionName]
	toolTipControl[functionName] = function(control, ...)
		base(control, ...)
		self:addToolTipText(control)
	end
end

function PurchaseTracker:addToolTipText(tooltip)

    local itemLink = self:getItemLinkFromToolTip(toolTip)
        
    local itemName = zo_strformat(SI_TOOLTIP_ITEM_NAME, itemLink)
    if (itemName == nil or itemName == "") then
        return
    end

    tooltip:AddVerticalPadding(5)
    ZO_Tooltip_AddDivider(tooltip)
    local itemId = GetItemLinkItemId(itemLink)
    if (self.savedVariables['purchases'][itemId] == nil) then
        tooltip:AddLine("*** No Purchases (" .. itemId .. ") ***")
    else
        local tableLen = #PurchaseTracker.savedVariables['purchases'][itemId]
        tooltip:AddLine("*** " .. tableLen .. "Purchases (" .. itemId .. ") ***")
        local lastPurchase = PurchaseTracker.savedVariables['purchases'][itemId][tableLen]
        if (lastPurchase) then
            local lastText = "Last: " .. tonumber(string.format("%.1f", lastPurchase.singlePrice)) .. " (" .. lastPurchase.itemCount .. ")"
            if(tableLen > 1) then
                lastPurchase = PurchaseTracker.savedVariables['purchases'][itemId][tableLen-1]
                lastText = lastText .. " - " .. tonumber(string.format("%.1f", lastPurchase.singlePrice)) .. " (" .. lastPurchase.itemCount .. ")"
            end
            if(tableLen > 2) then
                lastPurchase = PurchaseTracker.savedVariables['purchases'][itemId][tableLen-2]
                lastText = lastText .. " - " .. tonumber(string.format("%.1f", lastPurchase.singlePrice)) .. " (" .. lastPurchase.itemCount .. ")"
            end            
            tooltip:AddLine(lastText)
        end

        if (lastPurchase) then
            local avgText = "Avg: "
            if(tableLen > 0) then
                local purchasesCount = 0
                local totalPrice = 0
                local totalItemCount = 0
                for i = tableLen,tableLen-4,-1 
                do 
                    if i == 0 then break end
                    lastPurchase = PurchaseTracker.savedVariables['purchases'][itemId][i]
                    purchasesCount = purchasesCount + 1
                    totalPrice = totalPrice + lastPurchase['itemPrice']
                    totalItemCount = totalItemCount + lastPurchase['itemCount']
                end
                local average = totalPrice / totalItemCount
                avgText = avgText .. "" .. tonumber(string.format("%.1f", average)) .. " (" .. purchasesCount .. "/" .. totalItemCount .. ")"
            end

            if(tableLen > 5) then
                local purchasesCount = 0
                local totalPrice = 0
                local totalItemCount = 0
                for i = tableLen,tableLen-19,-1 
                do 
                    if i == 0 then break end
                    lastPurchase = PurchaseTracker.savedVariables['purchases'][itemId][i]
                    purchasesCount = purchasesCount + 1
                    totalPrice = totalPrice + lastPurchase['itemPrice']
                    totalItemCount = totalItemCount + lastPurchase['itemCount']
                end
                local average = totalPrice / totalItemCount
                avgText = avgText .. " - " .. tonumber(string.format("%.1f", average)) .. " (" .. purchasesCount .. "/" .. totalItemCount .. ")"
            end   

            if(tableLen > 20) then
                local purchasesCount = 0
                local totalPrice = 0
                local totalItemCount = 0
                for i = tableLen,tableLen-99,-1 
                do 
                    if i == 0 then break end
                    lastPurchase = PurchaseTracker.savedVariables['purchases'][itemId][i]
                    purchasesCount = purchasesCount + 1
                    totalPrice = totalPrice + lastPurchase['itemPrice']
                    totalItemCount = totalItemCount + lastPurchase['itemCount']
                end
                local average = totalPrice / totalItemCount
                avgText = avgText .. " - " .. tonumber(string.format("%.1f", average)) .. " (" .. purchasesCount .. "/" .. totalItemCount .. ")"
            end           
            tooltip:AddLine(avgText)
        end
    end

end

function PurchaseTracker:getItemLinkFromToolTip(toolTip)
    local skMoc = moc()
    -- Make sure we don't double-add stats or try to add them to nothing
    -- Since we call this on Update rather than Show it gets called a lot
    -- even after the tip appears
    if (not skMoc or not skMoc:GetParent()) then
      return
    end
  
    local itemLink = nil
    local mocParent = skMoc:GetParent():GetName()
  
    -- Store screen
    if mocParent == 'ZO_StoreWindowListContents' then itemLink = GetStoreItemLink(skMoc.index)
    -- Store buyback screen
    elseif mocParent == 'ZO_BuyBackListContents' then itemLink = GetBuybackItemLink(skMoc.index)
    -- Guild store posted items
    elseif mocParent == 'ZO_TradingHousePostedItemsListContents' then
      local mocData = skMoc.dataEntry and skMoc.dataEntry.data or nil
      if not mocData then return end
      itemLink = GetTradingHouseListingItemLink(mocData.slotIndex)
    -- Guild store search
    elseif mocParent == 'ZO_TradingHouseItemPaneSearchResultsContents' then
      local rData = skMoc.dataEntry and skMoc.dataEntry.data or nil
      -- The only thing with 0 time remaining should be guild tabards, no
      -- stats on those!
      if not rData or rData.timeRemaining == 0 then return end
      itemLink = GetTradingHouseSearchResultItemLink(rData.slotIndex)
    -- Guild store item posting
    elseif mocParent == 'ZO_TradingHouseLeftPanePostItemFormInfo' then
      if skMoc.slotIndex and skMoc.bagId then itemLink = GetItemLink(skMoc.bagId, skMoc.slotIndex) end
    -- Player bags (and bank) (and crafting tables)
    elseif mocParent == 'ZO_PlayerInventoryBackpackContents' or
           mocParent == 'ZO_PlayerInventoryListContents' or
           mocParent == 'ZO_CraftBagListContents' or
           mocParent == 'ZO_QuickSlotListContents' or
           mocParent == 'ZO_PlayerBankBackpackContents' or
           mocParent == 'ZO_HouseBankBackpackContents' or
           mocParent == 'ZO_SmithingTopLevelImprovementPanelInventoryBackpackContents' or
           mocParent == 'ZO_SmithingTopLevelDeconstructionPanelInventoryBackpackContents' or
           mocParent == 'ZO_SmithingTopLevelRefinementPanelInventoryBackpackContents' or
           mocParent == 'ZO_EnchantingTopLevelInventoryBackpackContents' or
           mocParent == 'ZO_GuildBankBackpackContents' then
           if skMoc and skMoc.dataEntry then
              local rData = skMoc.dataEntry.data
              itemLink = GetItemLink(rData.bagId, rData.slotIndex)
           end
    -- Worn equipment
    elseif mocParent == 'ZO_Character' then itemLink = GetItemLink(skMoc.bagId, skMoc.slotIndex)
    -- Loot window if autoloot is disabled
    elseif mocParent == 'ZO_LootAlphaContainerListContents' then itemLink = GetLootItemLink(skMoc.dataEntry.data.lootId)
    elseif mocParent == 'ZO_MailInboxMessageAttachments' then itemLink = GetAttachedItemLink(MAIL_INBOX:GetOpenMailId(), skMoc.id, LINK_STYLE_DEFAULT)
    elseif mocParent == 'ZO_MailSendAttachments' then itemLink = GetMailQueuedAttachmentLink(skMoc.id, LINK_STYLE_DEFAULT)
    elseif mocParent == 'IIFA_GUI_ListHolder' then itemLink = moc().itemLink
    elseif mocParent == 'ZO_TradingHouseBrowseItemsRightPaneSearchResultsContents' then
      local rData = skMoc.dataEntry and skMoc.dataEntry.data or nil
      -- The only thing with 0 time remaining should be guild tabards, no
      -- stats on those!
      if not rData or rData.timeRemaining == 0 then return end
      itemLink = GetTradingHouseSearchResultItemLink(rData.slotIndex)
    end

    return itemLink
end

local function OnAddonLoaded()
    PurchaseTracker:Initialize()
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)





