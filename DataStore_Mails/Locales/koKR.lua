local addonName = ...
local L = DataStore:SetLocale(addonName, "koKR")
if not L then return end

-- Translated using ChatGPT, please advise if you notice a mistake.
L["EXPIRED_EMAILS_WARNING"] = "%s (%s) 님의 이메일이 만료되었습니다 (또는 만료 예정)."
L["EXPIRY_ALL_ACCOUNTS_DISABLED"] = "현재 계정만 고려됩니다. 가져온 계정은 무시됩니다."
L["EXPIRY_ALL_ACCOUNTS_ENABLED"] = "이메일 삭제 시간 확인은 알려진 모든 계정을 확인합니다."
L["EXPIRY_ALL_ACCOUNTS_LABEL"] = "알려진 모든 계정의 이메일 삭제 시간 확인"
L["EXPIRY_ALL_ACCOUNTS_TITLE"] = "모든 계정 검사"
L["EXPIRY_ALL_REALMS_DISABLED"] = "현재 서버만 고려됩니다. 다른 서버는 무시됩니다."
L["EXPIRY_ALL_REALMS_ENABLED"] = "이메일 삭제 시간 확인은 알려진 모든 서버를 확인합니다."
L["EXPIRY_ALL_REALMS_LABEL"] = "알려진 모든 서버의 이메일 삭제 시간 확인"
L["EXPIRY_ALL_REALMS_TITLE"] = "모든 진영 검사"
L["EXPIRY_CHECK_DISABLED"] = "이메일 삭제 시간 확인이 수행되지 않습니다."
L["EXPIRY_CHECK_ENABLED"] = "로그인 5초 후에 이메일 삭제 시간이 확인됩니다. DataStore를 사용하는 애드온은 삭제 예정인 이메일이 발견되면 알림을 받게 됩니다."
L["EXPIRY_CHECK_LABEL"] = "우편 만료 경고"
L["EXPIRY_CHECK_TITLE"] = "우편 만료 검사"
L["REPORT_EXPIRED_MAILS_DISABLED"] = "채팅에 아무 것도 표시되지 않습니다."
L["REPORT_EXPIRED_MAILS_ENABLED"] = "이메일 만료 확인 중에 만료된 이메일이 있는 캐릭터 목록이 채팅에 표시됩니다."
L["REPORT_EXPIRED_MAILS_LABEL"] = "이메일 만료 경고 (채팅 창)"
L["REPORT_EXPIRED_MAILS_TITLE"] = "이메일 만료 경고 (채팅 창)"
L["SCAN_MAIL_BODY_DISABLED"] = "읽은 이메일만 스캔됩니다. 이메일은 여전히 읽지 않은 상태로 유지됩니다."
L["SCAN_MAIL_BODY_ENABLED"] = "우편함을 여는 경우 이메일이 완전히 스캔됩니다. 모든 이메일이 읽은 상태로 표시됩니다."
L["SCAN_MAIL_BODY_LABEL"] = "우편 내용을 검사 (읽은 것으로 표시)"
L["SCAN_MAIL_BODY_TITLE"] = "우편 내용 검사"
L["Warn when mail expires in less days than this value"] = "우편이 이 날짜 안에 만료되면 경고"
