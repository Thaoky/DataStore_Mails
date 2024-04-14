local addonName = ...
local L = DataStore:SetLocale(addonName, "zhCN")
if not L then return end

L["EXPIRY_CHECK_LABEL"] = "邮件过期警告"
L["SCAN_MAIL_BODY_LABEL"] = "扫描邮件内容(标记为已读)"
L["Warn when mail expires in less days than this value"] = "在邮件过期前多少天进行警告"
