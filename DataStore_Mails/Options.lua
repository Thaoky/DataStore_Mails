if not DataStore then return end

local addonName, addon = ...

function addon:SetupOptions()
	-- can't improve the slider right now, the use of parentKey in XML make it hard to address _Low & _High..
	local f = DataStoreMailOptions

	DataStore:AddOptionCategory(f, addonName, "DataStore")

	-- localize options
	local L = DataStore:GetLocale(addonName)
	
	DataStoreMailOptions_SliderMailExpiry.tooltipText = L["Warn when mail expires in less days than this value"]
	DataStoreMailOptions_SliderMailExpiryLow:SetText("1")
	DataStoreMailOptions_SliderMailExpiryHigh:SetText("15")
	
	-- restore saved options to gui
	local options = DataStore_Mails_Options
	
	DataStoreMailOptions_SliderMailExpiry:SetValue(options.MailWarningThreshold)
	DataStoreMailOptions_SliderMailExpiryText:SetText(format("%s (%s)", L["EXPIRY_CHECK_LABEL"], DataStoreMailOptions_SliderMailExpiry:GetValue()))
	
	f.CheckMailExpiry:SetChecked(options.CheckMailExpiry)
	f.ScanMailBody:SetChecked(options.ScanMailBody)
	f.CheckMailExpiryAllAccounts:SetChecked(options.CheckMailExpiryAllAccounts)
	f.CheckMailExpiryAllRealms:SetChecked(options.CheckMailExpiryAllRealms)
	f.ReportExpiredMailsToChat:SetChecked(options.ReportExpiredMailsToChat)
end
