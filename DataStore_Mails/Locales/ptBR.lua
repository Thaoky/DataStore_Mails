local addonName = ...
local L = DataStore:SetLocale(addonName, "ptBR")
if not L then return end

L["EXPIRY_CHECK_LABEL"] = "Aviso de Expiração de Correio"
L["SCAN_MAIL_BODY_LABEL"] = "Procurar no corpo do correio (marca-o como lido)"

