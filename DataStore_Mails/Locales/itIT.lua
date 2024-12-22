local addonName = ...
local L = AddonFactory:SetLocale(addonName, "itIT")
if not L then return end

-- Translated using ChatGPT, please advise if you notice a mistake.
L["EXPIRED_EMAILS_WARNING"] = "%s (%s) ha email scadute (o in procinto di scadere)"
L["EXPIRY_ALL_ACCOUNTS_DISABLED"] = "Solo l'account attuale sarà preso in considerazione; gli account importati verranno ignorati."
L["EXPIRY_ALL_ACCOUNTS_ENABLED"] = "La verifica dei tempi di cancellazione della posta esaminerà tutti gli account conosciuti."
L["EXPIRY_ALL_ACCOUNTS_LABEL"] = "Verifica di tutti i tempi di cancellazione della posta in tutti gli account conosciuti"
L["EXPIRY_ALL_ACCOUNTS_TITLE"] = "Verifica di Tutti gli Account"
L["EXPIRY_ALL_REALMS_DISABLED"] = "Solo il reame attuale sarà preso in considerazione; gli altri reami verranno ignorati."
L["EXPIRY_ALL_REALMS_ENABLED"] = "La verifica dei tempi di cancellazione della posta esaminerà tutti i reami conosciuti."
L["EXPIRY_ALL_REALMS_LABEL"] = "Verifica di tutti i tempi di cancellazione della posta in tutti i reami conosciuti"
L["EXPIRY_ALL_REALMS_TITLE"] = "Verifica di Tutti i Reami"
L["EXPIRY_CHECK_DISABLED"] = "Non verrà effettuata una verifica dei tempi di cancellazione."
L["EXPIRY_CHECK_ENABLED"] = "I tempi di cancellazione della posta verranno controllati 5 secondi dopo l'accesso. I plugin che utilizzano DataStore verranno notificati se viene trovata una mail in procinto di cancellazione."
L["EXPIRY_CHECK_LABEL"] = "Avviso di Cancellazione della Posta"
L["EXPIRY_CHECK_TITLE"] = "Controlla i Tempi di Cancellazione della Posta"
L["REPORT_EXPIRED_MAILS_DISABLED"] = "Niente verrà mostrato nella chat."
L["REPORT_EXPIRED_MAILS_ENABLED"] = "Durante il controllo della scadenza della posta, l'elenco dei personaggi con email scadute verrà mostrato anche nella chat."
L["REPORT_EXPIRED_MAILS_LABEL"] = "Avviso di scadenza della posta (frame della chat)"
L["REPORT_EXPIRED_MAILS_TITLE"] = "Avviso di scadenza della posta (frame della chat)"
L["SCAN_MAIL_BODY_DISABLED"] = "Verranno scansionate solo le email lette. Le email rimarranno non lette."
L["SCAN_MAIL_BODY_ENABLED"] = "Le email verranno completamente scansionate aprendo la casella di posta. Tutte le email verranno contrassegnate come lette."
L["SCAN_MAIL_BODY_LABEL"] = "Scansiona il contenuto delle email (contrassegna come lette)"
L["SCAN_MAIL_BODY_TITLE"] = "Scansione Completa della Posta"
