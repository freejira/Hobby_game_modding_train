-- __NAME__ campaign script
-- script/campaign/mod/ 아래 스크립트는 캠페인 로드 시 자동 실행된다.

cm:add_first_tick_callback(function()
    out("[__NAME__] loaded")
end)
