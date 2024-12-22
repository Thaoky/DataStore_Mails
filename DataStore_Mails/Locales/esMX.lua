local addonName = ...
local L = AddonFactory:SetLocale(addonName, "esMX")
if not L then return end

-- Translated using ChatGPT, please advise if you notice a mistake.
L["EXPIRED_EMAILS_WARNING"] = "%s (%s) tiene correos electrónicos caducados (o a punto de caducar)"
L["EXPIRY_ALL_ACCOUNTS_DISABLED"] = "Solo la cuenta actual será considerada; las cuentas importadas serán ignoradas."
L["EXPIRY_ALL_ACCOUNTS_ENABLED"] = "La revisión de los tiempos de borrado de correo examinará todas las cuentas conocidas."
L["EXPIRY_ALL_ACCOUNTS_LABEL"] = "Revisar todos los tiempos de borrado de correo en todas las cuentas conocidas"
L["EXPIRY_ALL_ACCOUNTS_TITLE"] = "Revisión de Todas las Cuentas"
L["EXPIRY_ALL_REALMS_DISABLED"] = "Solo el reino actual será considerado; otros reinos serán ignorados."
L["EXPIRY_ALL_REALMS_ENABLED"] = "La revisión de los tiempos de borrado de correo examinará todos los reinos conocidos."
L["EXPIRY_ALL_REALMS_LABEL"] = "Revisar todos los tiempos de borrado de correo en todos los reinos conocidos"
L["EXPIRY_ALL_REALMS_TITLE"] = "Revisión de Todos los Reinos"
L["EXPIRY_CHECK_DISABLED"] = "No se realizará una revisión de los tiempos de borrado."
L["EXPIRY_CHECK_ENABLED"] = "Los tiempos de borrado de correo serán revisados 5 segundos después de iniciar sesión. Los complementos que utilicen DataStore serán notificados si se encuentra un correo a punto de borrarse."
L["EXPIRY_CHECK_LABEL"] = "Advertencia de expiración del correo"
L["EXPIRY_CHECK_TITLE"] = "Revisar Tiempos de Borrado de Correo"
L["REPORT_EXPIRED_MAILS_DISABLED"] = "No se mostrará nada en el chat."
L["REPORT_EXPIRED_MAILS_ENABLED"] = "Durante la verificación de la caducidad del correo, la lista de personajes con correos electrónicos caducados también se mostrará en el chat."
L["REPORT_EXPIRED_MAILS_LABEL"] = "Aviso de caducidad del correo (cuadro de chat)"
L["REPORT_EXPIRED_MAILS_TITLE"] = "Aviso de caducidad del correo (cuadro de chat)"
L["SCAN_MAIL_BODY_DISABLED"] = "Solo se escanearán los correos leídos. Los correos seguirán teniendo el estado de no leídos."
L["SCAN_MAIL_BODY_ENABLED"] = "Los correos serán completamente escaneados al abrir el buzón. Todos los correos serán marcados como leídos."
L["SCAN_MAIL_BODY_LABEL"] = "Analizar el contenido de los correos (marcarlos como leídos)"
L["SCAN_MAIL_BODY_TITLE"] = "Escaneo Completo del Correo"
L["Warn when mail expires in less days than this value"] = "Advertir cuando el correo expira en menos días que los indicados"
