--[[	*** DataStore_Mails ***
Written by : Thaoky, EU-Marécages de Zangar
July 16th, 2009
--]]
if not DataStore then return end

local addonName, addon = ...
local thisCharacter
local allCharacters
local options

local DataStore = DataStore
local TableInsert, TableSort, format, strsplit, pairs, type, tonumber, time, date = table.insert, table.sort, format, strsplit, pairs, type, tonumber, time, date
local GetSendMailItemLink, GetInboxItemLink, GetSendMailMoney, GetInboxNumItems, GetInboxHeaderInfo, GetInboxText, GetItemInfo = GetSendMailItemLink, GetInboxItemLink, GetSendMailMoney, GetInboxNumItems, GetInboxHeaderInfo, GetInboxText, GetItemInfo

local commPrefix = "DS_Mails"
local isRetail = (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE)

local L = AddonFactory:GetLocale(addonName)
local bit64 = LibStub("LibBit64")

local MAIL_EXPIRY = 30		-- Mails expire after 30 days

-- Message types
local MSG_SENDMAIL_INIT							= 1
local MSG_SENDMAIL_END							= 2
local MSG_SENDMAIL_ATTACHMENT					= 3
local MSG_SENDMAIL_BODY							= 4

local ICON_COIN = "Interface\\Icons\\INV_Misc_Coin_01"
local ICON_NOTE = "Interface\\Icons\\INV_Misc_Note_01"

-- *** Utility functions ***
local function GetIDFromLink(link)
	return tonumber(link:match("item:(%d+)"))
end

local function GetMailTable(character, index)
	-- depending on the index passed, returns the right mail entry either from the "Mails" table or the "MailCache" table
	-- The assumption is that the MailCache entries come after the Mails entries
	-- This function is pure utility, and is not made public to client addons
	
	if index <= #character.Mails then
		return character.Mails[index]
	else
		index = index - #character.Mails
		return character.MailCache[index]
	end
end

local function SendGuildMail(recipient, subject, body, index)
	local player = DataStore:GetNameOfMain(recipient)
	if not player then return end
		
	-- this mail is sent to "player", but is for alt  "recipient"
	DataStore:GuildWhisper(commPrefix, player, MSG_SENDMAIL_INIT, recipient)
	
	-- send attachments
	local isSentMail = (index == nil) and true or false
	local item, icon, count, link, itemID
	
	for attachmentIndex = 1, ATTACHMENTS_MAX_SEND do		-- mandatory, loop through all 12 slots, since attachments could be anywhere (ex: slot 4,5,8)
		if isSentMail then
			item, itemID, icon, count = GetSendMailItem(attachmentIndex)
			link = GetSendMailItemLink(attachmentIndex)
		else
			item, itemID, icon, count = GetInboxItem(index, attachmentIndex)
			link = GetInboxItemLink(index, attachmentIndex)
		end
		
		if item then
			DataStore:GuildWhisper(commPrefix, player, MSG_SENDMAIL_ATTACHMENT, icon, link, count)
		end
	end
			
	-- .. then save the mail itself + gold if any
	local money = GetSendMailMoney()
	body = body or ""
	if (money > 0) or (strlen(body) > 0) then
		DataStore:GuildWhisper(commPrefix, player, MSG_SENDMAIL_BODY, subject, body, money)
	end
	DataStore:GuildWhisper(commPrefix, player, MSG_SENDMAIL_END)
end

-- *** Scanning functions ***
local function SaveAttachments(character, index, sender, days, wasReturned)
	-- saves attachments of a given mail index into a given character mailbox
	
	-- index nil = sent mail => different methods
	local isSentMail = (index == nil) and true or false
	
	local item, icon, count, link, itemID
	
	for attachmentIndex = 1, ATTACHMENTS_MAX_SEND do		-- mandatory, loop through all 12 slots, since attachments could be anywhere (ex: slot 4,5,8)
		if isSentMail then
			item, itemID, icon, count = GetSendMailItem(attachmentIndex)
			link = GetSendMailItemLink(attachmentIndex)
		else
			item, itemID, icon, count = GetInboxItem(index, attachmentIndex)
			link = GetInboxItemLink(index, attachmentIndex)
		end
		
		if item then
			TableInsert(character.Mails, {
				["icon"] = icon,
				["itemID"] = itemID,
				["count"] = count,
				["sender"] = sender,
				["link"] = link,
				lastCheck = time(),
				daysLeft = days,
				returned = wasReturned,
			} )
		end
	end
end

local function ScanMailbox()
	local char = thisCharacter
	wipe(char.Mails)
	wipe(char.MailCache)	-- fully clear the mail cache, since the mailbox will now be properly scanned
	
	local numItems = GetInboxNumItems()
	if numItems == 0 then
		return
	end
	
	for i = 1, numItems do
		local _, stationaryIcon, mailSender, mailSubject, mailMoney, _, days, numAttachments, _, wasReturned = GetInboxHeaderInfo(i)
		if numAttachments then	-- treat attachments as separate entries
			SaveAttachments(char, i, mailSender, days, wasReturned)
		end

		local inboxText
		if options.ScanMailBody then
			inboxText = GetInboxText(i)					-- this marks the mail as read
		end
		
		if (mailMoney > 0) or inboxText then			-- if there's money or text .. save the entry
			local mailIcon
			if mailMoney > 0 then
				mailIcon = ICON_COIN
			else
				mailIcon = stationaryIcon
			end
			TableInsert(char.Mails, {
				icon = mailIcon,
				money = mailMoney,
				text = inboxText,
				subject = mailSubject,
				sender = mailSender,
				lastCheck = time(),
				daysLeft = days,
				returned = wasReturned,
			} )
		end
	end
	
	-- show mails with the lowest expiry first
	TableSort(char.Mails, function(a, b) return a.daysLeft < b.daysLeft end)
	
	AddonFactory:Broadcast("DATASTORE_MAILBOX_UPDATED")
end


-- *** Event Handlers ***
local function OnBagUpdate(event, bag)
	if addon.isOpen then	-- if a bag is updated while the mailbox is opened, this means an attachment has been taken.
		ScanMailbox()		-- I could not hook TakeInboxItem because mailbox content is not updated yet
	end
end

local function OnMailInboxUpdate()
	-- process only one occurence of the event, right after MAIL_SHOW
	addon:StopListeningTo("MAIL_INBOX_UPDATE")
	ScanMailbox()
end

local function OnMailClosed()
	addon.isOpen = nil
	addon:StopListeningTo("PLAYER_INTERACTION_MANAGER_FRAME_HIDE")
	
	ScanMailbox()
	
	local char = thisCharacter
	char.lastUpdate = time()
	char.lastVisitDate = date("%Y/%m/%d %H:%M")	-- in YYYY MM DD  hh:mm, for external apps
	
	addon:StopListeningTo("MAIL_SEND_INFO_UPDATE")
end

local function OnManagerFrameHide(eventName, ...)
	local paneType = ...
	if paneType ==  Enum.PlayerInteractionType.MailInfo then 
		OnMailClosed()
	end
end

local function OnMailShow()
	-- the event may be triggered multiple times, exit if the mailbox is already open
	if addon.isOpen then return end	
	
	CheckInbox()

	addon:ListenTo("PLAYER_INTERACTION_MANAGER_FRAME_HIDE", OnManagerFrameHide)
	addon:ListenTo("MAIL_INBOX_UPDATE", OnMailInboxUpdate)

	-- create a temporary table to hold the attachments that will be sent, keep it local since the event is rare
	addon.isOpen = true
end

local function OnManagerFrameShow(eventName, ...)
	local paneType = ...
	if paneType ==  Enum.PlayerInteractionType.MailInfo then 
		OnMailShow()
	end
end

-- ** Mixins **
local function _GetMailboxLastVisit(character)
	return character.lastUpdate or 0
end

local function _GetMailItemCount(character, searchedID)
	local count = 0
	for _, v in pairs (character.Mails) do
		if v.itemID and (v.itemID == searchedID) then	-- added in 7.0
			count = count + (v.count or 1)
		else															-- .. remove link comparison soon
			local link = v.link
			if link and (GetIDFromLink(link) == searchedID) then
				count = count + (v.count or 1)
			end
		end
	end
	
	for _, v in pairs (character.MailCache) do
		if v.itemID and (v.itemID == searchedID) then	-- added in 7.0
			count = count + (v.count or 1)
		else															-- .. remove link comparison soon
			local link = v.link
			if link and (GetIDFromLink(link) == searchedID) then
				count = count + (v.count or 1)
			end
		end
	end
	return count
end

local function _GetNumMails(character)
	return #character.Mails + #character.MailCache
end

local function _GetMailInfo(character, index)
	local data = GetMailTable(character, index)
	return data.icon, data.count, data.link, data.money, data.text, data.returned
end

local function _IterateMails(character, callback)
	for index = 1, _GetNumMails(character) do
		callback(_GetMailInfo(character, index))
		
		-- Sample:
		-- DataStore:IterateMails(character, function(icon, count, itemLink, money, text, returned) 
		-- end)
	end
end

local function _GetMailSender(character, index)
	local data = GetMailTable(character, index)
	return data.sender
end

local function _GetMailExpiry(character, index)
	local data = GetMailTable(character, index)

	-- return the mail expiry, expressed in days and in seconds
	local diff = time() - data.lastCheck
	local days = data.daysLeft - (diff / 86400)
	local seconds = (data.daysLeft * 86400) - diff
	
	return days, seconds
end

local function _GetMailSubject(character, index)
	local data = GetMailTable(character, index)
	
	if data.subject then			-- if there's a subject, use it
		return data.subject
	end
	-- otherwise, return the name of the item
	
	local name
	local link = data.link
	
	if link then
		local id = GetIDFromLink(link)
		name = C_Item.GetItemInfo(id)
	end
	
	return name
end

local function _GetNumExpiredMails(character, threshold)
	local count = 0
	
	for i = 1, _GetNumMails(character) do
		if _GetMailExpiry(character, i) < threshold then
			count = count + 1
		end
	end
	
	return count
end

local function _GetNumReturnsOnExpiry(character)
	local count = 0
	
	for i = 1, _GetNumMails(character) do
		local data = GetMailTable(character, i)
		local seconds = select(2, _GetMailExpiry(character, i))
		
		if seconds >= 0 and not data.returned then
			count = count + 1
		end
	end
	
	return count
end

local function _GetClosestReturnsOnExpiry(character)
	local closest
	
	for i = 1, _GetNumMails(character) do
		local data = GetMailTable(character, i)
		local seconds = select(2, _GetMailExpiry(character, i))
		
		if seconds >= 0 and not data.returned then
			if not closest then
				closest = seconds
			else
				if seconds < closest then
					closest = seconds
				end
			end
		end
	end
	
	return closest
end

local function _GetNumDeletionOnExpiry(character)
	local count = 0
	
	for i = 1, _GetNumMails(character) do
		local data = GetMailTable(character, i)
		local seconds = select(2, _GetMailExpiry(character, i))
		
		if seconds >= 0 and data.returned then
			count = count + 1
		end
	end
	
	return count
end

local function _GetClosestDeletionOnExpiry(character)
	local closest
	
	for i = 1, _GetNumMails(character) do
		local data = GetMailTable(character, i)
		local seconds = select(2, _GetMailExpiry(character, i))
		
		if seconds >= 0 and data.returned then
			if not closest then
				closest = seconds
			else
				if seconds < closest then
					closest = seconds
				end
			end
		end
	end
	
	return closest
end

local function _SaveMailToCache(character, mailMoney, mailBody, mailSubject, mailSender)
	local mailIcon = (mailMoney > 0) and ICON_COIN or ICON_NOTE
	
	TableInsert(character.MailCache, {
		money = mailMoney,
		icon = mailIcon,
		text = mailBody,
		subject = mailSubject,
		sender = mailSender,
		lastCheck = time(),
		daysLeft = MAIL_EXPIRY,
	} )
end

local function _SaveMailAttachmentToCache(character, mailIcon, mailLink, mailCount, mailSender)
	TableInsert(character.MailCache, {
		icon = mailIcon,
		link = mailLink,
		count = mailCount,
		sender = mailSender,
		lastCheck = time(),
		daysLeft = MAIL_EXPIRY,
	} )
end

local function _IsMailBoxOpen()
	return addon.isOpen
end

local function _ClearMailboxEntries(character)
	wipe(character.Mails)
	wipe(character.MailCache)
end

-- *** Guild Comm ***
local guildMailRecipient			-- name of the alt who receives a mail from a guildmate
local guildMailRecipientKey		-- key of the alt who receives a mail from a guildmate

local commCallbacks = {
	[MSG_SENDMAIL_INIT] = function(sender, recipient)
			guildMailRecipient = recipient
			guildMailRecipientKey = format("%s.%s.%s", DataStore.ThisAccount, DataStore.ThisRealm, recipient)
		end,
	[MSG_SENDMAIL_END] = function(sender)
			if guildMailRecipient then
				AddonFactory:Broadcast("DATASTORE_GUILD_MAIL_RECEIVED", sender, guildMailRecipient)
			end
			guildMailRecipient = nil
			guildMailRecipientKey = nil
		end,
	[MSG_SENDMAIL_ATTACHMENT] = function(sender, icon, link, count)
			local id = addon:GetCharacterID(guildMailRecipientKey)
			local recipientTable = allCharacters[id]
			
			if recipientTable then
				_SaveMailAttachmentToCache(recipientTable, icon, link, count, sender)
			end
		end,
	[MSG_SENDMAIL_BODY] = function(sender, subject, body, money)
			local id = addon:GetCharacterID(guildMailRecipientKey)
			local recipientTable = allCharacters[id]

			if recipientTable then
				_SaveMailToCache(recipientTable, money, body, subject, sender)
			end
		end,
}

local function CheckExpiries()
	local allAccounts = options.CheckMailExpiryAllAccounts
	local allRealms = options.CheckMailExpiryAllRealms
	local threshold = options.MailWarningThreshold
	local expiryFound
	
	local account, realm, charName
	
	DataStore:IterateCharacters(function(key, id)
		account, realm, charName = strsplit(".", key)
		
		if allAccounts or ((allAccounts == false) and (account == DataStore.ThisAccount)) then		-- all accounts, or only current and current was found
			if allRealms or ((allRealms == false) and (realm == DataStore.ThisRealm)) then			-- all realms, or only current and current was found
				local character = allCharacters[id]
				
				if character then
					-- detect return vs delete
					local numExpiredMails = _GetNumExpiredMails(character, threshold)
					if numExpiredMails > 0 then
						expiryFound = true
						
						-- if the option is active, report the name of the character to chat, one line per alt.
						if options.ReportExpiredMailsToChat then
							addon:Print(format(L["EXPIRED_EMAILS_WARNING"], charName, realm))
						end
						AddonFactory:Broadcast("DATASTORE_MAIL_EXPIRY", character, key, threshold, numExpiredMails)
					end
				end
			end
		end
	end)
	
	if expiryFound then
		-- global expiry message, register this one if your addon just wants to know that at least one mail has expired, and you don't care which.
		AddonFactory:Broadcast("DATASTORE_GLOBAL_MAIL_EXPIRY", threshold)
	end
end

AddonFactory:OnAddonLoaded(addonName, function()
	DataStore:RegisterModule({
		addon = addon,
		addonName = addonName,
		rawTables = {
			"DataStore_Mails_Options"
		},
		characterTables = {
			["DataStore_Mails_Characters"] = {
				GetMailboxLastVisit = _GetMailboxLastVisit,
				GetMailItemCount = _GetMailItemCount,
				GetNumMails = _GetNumMails,
				GetMailInfo = _GetMailInfo,
				IterateMails = _IterateMails,
				GetMailSender = _GetMailSender,
				GetMailExpiry = _GetMailExpiry,
				GetMailSubject = _GetMailSubject,
				GetNumExpiredMails = _GetNumExpiredMails,
				GetNumReturnsOnExpiry = _GetNumReturnsOnExpiry,
				GetClosestReturnsOnExpiry = _GetClosestReturnsOnExpiry,
				GetNumDeletionOnExpiry = _GetNumDeletionOnExpiry,
				GetClosestDeletionOnExpiry = _GetClosestDeletionOnExpiry,
				SaveMailToCache = _SaveMailToCache,
				SaveMailAttachmentToCache = _SaveMailAttachmentToCache,
				ClearMailboxEntries = _ClearMailboxEntries,
			},
		},
	})

	thisCharacter = DataStore:GetCharacterDB("DataStore_Mails_Characters", true)
	thisCharacter.Mails = thisCharacter.Mails or {}
	thisCharacter.MailCache = thisCharacter.MailCache or {}
	
	allCharacters = DataStore_Mails_Characters

	DataStore:RegisterMethod(addon, "IsMailBoxOpen", _IsMailBoxOpen)
	
	DataStore:SetGuildCommCallbacks(commPrefix, commCallbacks)
	DataStore:OnGuildComm(commPrefix, DataStore:GetGuildCommHandler())
end)

AddonFactory:OnPlayerLogin(function()
	options = DataStore:SetDefaults("DataStore_Mails_Options", {
		ScanMailBody = true,			-- by default, scan the body of a mail (this action marks it as read)
		CheckMailExpiry = true,		-- check mail expiry or not
		MailWarningThreshold = 5,
		CheckMailExpiryAllAccounts = true,
		CheckMailExpiryAllRealms = true,
		ReportExpiredMailsToChat = true,
	})	

	addon:ListenTo("MAIL_SHOW", OnMailShow)
	addon:ListenTo("PLAYER_INTERACTION_MANAGER_FRAME_SHOW", OnManagerFrameShow)
	addon:ListenTo("BAG_UPDATE", OnBagUpdate)
	
	if not isRetail then
		addon:SetupOptions()
	end
	
	if options.CheckMailExpiry then
		C_Timer.After(5, CheckExpiries)	-- check mail expiries 5 seconds later, to decrease the load at startup
	end
end)


-- *** Hooks ***

local Orig_SendMail = SendMail

local function SendOwnMail(characterKey, subject, body)
	local id = DataStore:GetCharacterID(characterKey)
	local character = DataStore_Mails_Characters[id]
	
	SaveAttachments(character, nil, UnitName("player"), MAIL_EXPIRY)
	
	-- .. then save the mail itself + gold if any
	local moneySent = GetSendMailMoney()
	if (moneySent > 0) or (strlen(body) > 0) then
		TableInsert(character.Mails, {
			money = moneySent,
			icon = (moneySent > 0) and ICON_COIN or ICON_NOTE,
			text = body,
			subject = subject,
			sender = UnitName("player"),
			lastCheck = time(),
			daysLeft = MAIL_EXPIRY,
		} )
	end
	
	-- if the alt has never checked his mail before, this value won't be correct, so set it to make sure expiry returns proper results.
	if not character.lastUpdate then
		character.lastUpdate = time()
	end
	
	TableSort(character.Mails, function(a, b)		-- show mails with the lowest expiry first
		return a.daysLeft < b.daysLeft
	end)
end

hooksecurefunc("SendMail", function(recipient, subject, body, ...)
	body = body or ""			-- body could be nil when SendMail is used in a macro
	
	-- this function takes care of saving mails sent to alts directly into their mailbox, so that client addons don't have to take care about it
	local isRecipientAnAlt

	local recipientName, recipientRealm = strsplit("-", recipient)
	
	recipientRealm = recipientRealm or DataStore.ThisRealm
	-- for the current realm, recipientRealm could be
	-- 	- empty (recipient = "Thaoky")
	--		- packed named (recipient = "Thaoky-MarécagedeZangar" => realm should be "Marécage de Zangar"
	
	-- recipientRealm is nil = current realm
	-- recipientRealm is not nil = any realm (current or other)
	
	-- do we have an alt on the target realm ?

	for realm in pairs(DataStore:GetRealms()) do
		-- "Marécage de Zangar" becomes "MarécagedeZangar"
		
		if strlower(gsub(realm, " ", "")) == strlower(gsub(recipientRealm, " ", "")) then		-- right realm found ? proceed
			for characterName, characterKey in pairs(DataStore:GetCharacters(realm)) do
				if strlower(characterName) == strlower(recipientName) then		-- right alt ? proceed
					SendOwnMail(characterKey, subject, body)
					isRecipientAnAlt = true
					break
				end
			end
		end
	end
	
	if not isRecipientAnAlt then	-- if recipient is not an alt, maybe it's a guildmate
		SendGuildMail(recipientName, subject, body)
	end
end)

local function ReturnOwnMail(characterKey, index, mailSubject, mailMoney, stationaryIcon, numAttachments)
	local id = DataStore:GetCharacterID(characterKey)
	local character = DataStore_Mails_Characters[id]

	if numAttachments then	-- treat attachments as separate entries
		SaveAttachments(character, index, UnitName("player"), MAIL_EXPIRY, true)
	end

	local inboxText = GetInboxText(index)		-- this marks the mail as read, no problem here since the mail is returned anyway
	
	if (mailMoney > 0) or inboxText then			-- if there's money or text .. save the entry
		
		TableInsert(character.Mails, {
			icon = (mailMoney > 0) and ICON_COIN or stationaryIcon,
			money = mailMoney,
			text = inboxText,
			subject = mailSubject,
			sender = UnitName("player"),
			lastCheck = time(),
			daysLeft = MAIL_EXPIRY,
			returned = true,				-- this is the mail we're returning, so true
		} )
	end
end

hooksecurefunc("ReturnInboxItem", function(index, ...)
	local _, stationaryIcon, mailSender, mailSubject, mailMoney, _, _, numAttachments = GetInboxHeaderInfo(index)
	local isRecipientAnAlt

	local recipientName, recipientRealm = strsplit("-", mailSender)

	recipientRealm = recipientRealm or DataStore.ThisRealm
	
	-- do we have an alt on the target realm ?
	for realm in pairs(DataStore:GetRealms()) do
		
		-- "Marécage de Zangar" becomes "MarécagedeZangar"
		if strlower(gsub(realm, " ", "")) == strlower(gsub(recipientRealm, " ", "")) then		-- right realm found ? proceed
			for characterName, characterKey in pairs(DataStore:GetCharacters(realm)) do
				if strlower(characterName) == strlower(recipientName) then		-- right alt ? proceed
					ReturnOwnMail(characterKey, index, mailSubject, mailMoney, stationaryIcon, numAttachments)
					isRecipientAnAlt = true
					break
				end
			end
		end
	end
		
	if not isRecipientAnAlt then	-- if recipient is not an alt, maybe it's a guildmate
		SendGuildMail(recipientName, mailSubject, GetInboxText(index), index)
	end
end)
