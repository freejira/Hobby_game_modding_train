-- employment_manager 고용풀 테스트 (조사용, 배포 전 이 파일은 빼거나 ENABLED = false)
--
-- 알아내려는 것: 고용창(풀)에 있는 후보를 스크립트로 찾아서 지울 수 있는가?
--
-- 1. 풀에 새 후보가 들어올 때(NewCharacterEnteredRecruitmentPool) 후보 정보를 기록한다.
-- 2. 화면 오른쪽 아래 [풀 테스트] 버튼을 누르면:
--    a. 기록된 후보 + faction:character_list() 의 군대 없는 군주를 전부 로그에 적는다.
--    b. 기록된 후보 중 가장 최근 1명을 삭제 시도한다 (불멸 해제 + kill_character).
--    c. 0.5초 뒤 그 후보가 아직 남아 있는지 로그에 적는다.
-- 3. 결과는 게임 폴더의 employment_manager_pool_test.txt 에 쌓인다.
--
-- 테스트 순서: 캠페인 로드 → 턴 넘기기 (풀에 새 후보가 들어오게) → 고용창 열어서 후보 이름 확인
--             → [풀 테스트] 클릭 → 고용창 다시 열어서 그 후보가 사라졌는지 확인 → 로그 파일 전달

local ENABLED = true
local MOD = "employment_manager_pool_test"
local BUTTON_ID = MOD .. "_button"
local EVENT_KEY = MOD .. "|run"
local LOG_FILE = MOD .. ".txt"

if not ENABLED then
    return
end

-- 풀에 들어온 후보의 family member cqi (들어온 순서대로). 세이브에는 저장 안 됨.
local tracked = {}

local function log(msg)
    out("[" .. MOD .. "] " .. tostring(msg))
    local file = io.open(LOG_FILE, "a")
    if file then
        file:write(tostring(msg) .. "\n")
        file:close()
    end
end

local function safe(fn, default)
    local ok, result = pcall(fn)
    if ok then
        return result
    end
    return default or ("ERR " .. tostring(result))
end

local function describe_character(c)
    if not c or c:is_null_interface() then
        return "character=NULL"
    end
    return string.format(
        "char_cqi=%s type=%s subtype=%s name=%s %s rank=%s force=%s region=%s garrison=%s at_sea=%s wounded=%s pos=(%s,%s) leader=%s unique=%s immortal=%s",
        safe(function() return c:command_queue_index() end),
        safe(function() return c:character_type_key() end),
        safe(function() return c:character_subtype_key() end),
        safe(function() return c:get_forename() end),
        safe(function() return c:get_surname() end),
        safe(function() return c:rank() end),
        safe(function() return tostring(c:has_military_force()) end),
        safe(function() return tostring(c:has_region()) end),
        safe(function() return tostring(c:has_garrison_residence()) end),
        safe(function() return tostring(c:is_at_sea()) end),
        safe(function() return tostring(c:is_wounded()) end),
        safe(function() return c:logical_position_x() end),
        safe(function() return c:logical_position_y() end),
        safe(function() return tostring(c:is_faction_leader()) end),
        safe(function() return tostring(c:character_details():is_unique()) end),
        safe(function() return tostring(c:character_details():is_immortal()) end))
end

local function describe_fm(fm_cqi)
    local fm = cm:get_family_member_by_cqi(fm_cqi)
    if not fm or fm:is_null_interface() then
        return "fm=" .. fm_cqi .. " family_member=NOT FOUND"
    end
    return "fm=" .. fm_cqi .. " " .. describe_character(fm:character())
end

local function local_faction()
    return cm:get_faction(cm:get_local_faction_name(true))
end

---------------------------------------------------------------------------
-- 테스트 본체
---------------------------------------------------------------------------

local function run_test()
    local faction = local_faction()
    log("")
    log("===== pool test (turn " .. cm:model():turn_number() .. ", faction " .. faction:name() .. ") =====")

    log("-- tracked pool candidates (NewCharacterEnteredRecruitmentPool): " .. #tracked)
    for i, fm_cqi in ipairs(tracked) do
        log(string.format("  [%d] %s", i, describe_fm(fm_cqi)))
    end

    log("-- character_list generals without military force")
    local list = faction:character_list()
    local count = 0
    for i = 0, list:num_items() - 1 do
        local c = list:item_at(i)
        if c:character_type("general") and not c:has_military_force() then
            count = count + 1
            log("  fm=" .. safe(function() return c:family_member():command_queue_index() end)
                .. " " .. describe_character(c))
        end
    end
    log("  total " .. count .. " (character_list size " .. list:num_items() .. ")")

    -- 가장 최근 후보 1명 삭제 시도
    local target = nil
    for i = #tracked, 1, -1 do
        local fm = cm:get_family_member_by_cqi(tracked[i])
        if fm and not fm:is_null_interface() and not fm:character():is_null_interface() then
            target = tracked[i]
            break
        end
    end
    if not target then
        log("-- delete test: no tracked candidate with a character interface (턴을 넘겨 풀에 새 후보가 들어온 뒤 다시 시도)")
        return
    end

    local c = cm:get_family_member_by_cqi(target):character()
    log("-- delete test target: " .. describe_fm(target))
    local ok, err = pcall(function()
        cm:suppress_immortality(target, true)
        cm:kill_character(cm:char_lookup_str(c), false)
    end)
    log("   kill call: " .. (ok and "ok" or ("ERROR " .. tostring(err))))

    cm:callback(function()
        log("-- after 0.5s: " .. describe_fm(target))
        log("   -> 이제 고용창을 열어서 이 후보가 사라졌는지 확인하세요")
    end, 0.5)
end

---------------------------------------------------------------------------
-- 버튼
---------------------------------------------------------------------------

local function ensure_button()
    local root = core:get_ui_root()
    local button = find_child_uicomponent(root, BUTTON_ID)
    if not button then
        button = UIComponent(root:CreateComponent(BUTTON_ID, "ui/templates/square_medium_button"))
        local sw, sh = core:get_screen_resolution()
        local bw, bh = button:Dimensions()
        button:MoveTo(sw - bw - 40, sh - bh - 260)
    end
    button:SetVisible(true)
    button:SetState("active")
    button:SetTooltipText("풀 테스트||고용풀 후보를 로그에 적고, 가장 최근 후보 1명을 삭제 시도합니다.\n결과: " .. LOG_FILE, true)
end

---------------------------------------------------------------------------
-- 리스너
---------------------------------------------------------------------------

cm:add_first_tick_callback(function()
    log("")
    log("===== loaded (turn " .. cm:model():turn_number() .. ") =====")

    if cm:get_local_faction_name(true) then
        ensure_button()
    end

    core:add_listener(MOD .. "_pool_entered", "NewCharacterEnteredRecruitmentPool", true,
        function(context)
            local details = context:character_details()
            if details:faction():name() ~= cm:get_local_faction_name(true) then
                return
            end
            local fm_cqi = safe(function() return details:family_member():command_queue_index() end, nil)
            log(string.format("pool entered: fm=%s name=%s %s subtype=%s | %s",
                tostring(fm_cqi),
                safe(function() return details:get_forename() end),
                safe(function() return details:get_surname() end),
                safe(function() return details:character_subtype_key() end),
                safe(function() return describe_character(details:character()) end)))
            if type(fm_cqi) == "number" then
                table.insert(tracked, fm_cqi)
            end
        end, true)

    core:add_listener(MOD .. "_click", "ComponentLClickUp",
        function(context) return context.string == BUTTON_ID end,
        function()
            CampaignUI.TriggerCampaignScriptEvent(local_faction():command_queue_index(), EVENT_KEY)
        end, true)

    core:add_listener(MOD .. "_run", "UITriggerScriptEvent",
        function(context) return context:trigger() == EVENT_KEY end,
        function()
            local ok, err = pcall(run_test)
            if not ok then
                log("!! run_test error: " .. tostring(err))
            end
        end, true)

    core:add_listener(MOD .. "_turn_start", "FactionTurnStart",
        function(context) return context:faction():name() == cm:get_local_faction_name(true) end,
        function() ensure_button() end, true)
end)
