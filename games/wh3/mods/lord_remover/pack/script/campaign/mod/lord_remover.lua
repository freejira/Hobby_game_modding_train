-- lord_remover
-- 선택한 자기 세력 군주를 영구 삭제한다 (레벨/불멸 무관).
-- 고용창(풀)을 직접 건드리는 API가 없으므로: 풀에서 고용 -> 맵에서 선택 -> 삭제 버튼 두 번 클릭.
--
-- 디버그: DUMP_UI = true 로 두면 패널이 열릴 때마다 UI 트리를 lord_remover_ui_dump.txt 에 기록한다.
--         (고용창에서 직접 삭제하는 기능을 만들기 위한 조사용)

local MOD = "lord_remover"
local BUTTON_ID = "lord_remover_button"
local EVENT_PREFIX = "lord_remover|"
local CONFIRM_SECONDS = 3
local DUMP_UI = false

local selected_cqi = nil
local armed_at = nil

local function log(msg)
    out("[" .. MOD .. "] " .. tostring(msg))
end

---------------------------------------------------------------------------
-- 삭제 가능 여부
---------------------------------------------------------------------------

-- 삭제 가능하면 nil, 아니면 이유 문자열
local function reject_reason(character)
    if not character or character:is_null_interface() then
        return "군주가 선택되지 않았습니다."
    end
    if character:faction():name() ~= cm:get_local_faction_name(true) then
        return "자기 세력 군주만 삭제할 수 있습니다."
    end
    if not character:character_type("general") then
        return "군주만 삭제할 수 있습니다."
    end
    if character:is_faction_leader() then
        return "세력 지도자는 삭제할 수 없습니다."
    end
    if character:has_military_force() and character:military_force():unit_list():num_items() > 1 then
        return "군대에 유닛이 남아 있습니다. 유닛을 먼저 해산하거나 다른 군대로 옮기세요."
    end
    return nil
end

local function remove_lord(cqi)
    local character = cm:get_character_by_cqi(cqi)
    local reason = reject_reason(character)
    if reason then
        log("remove rejected (" .. tostring(cqi) .. "): " .. reason)
        return
    end
    log("removing " .. tostring(cqi) .. " " .. character:get_forename() .. " " .. character:get_surname())
    -- 불멸을 끄지 않으면 죽여도 풀로 돌아온다
    cm:suppress_immortality(character:family_member():command_queue_index(), true)
    cm:kill_character(cm:char_lookup_str(character), true)
end

---------------------------------------------------------------------------
-- 버튼 UI
---------------------------------------------------------------------------

local function get_button()
    local root = core:get_ui_root()
    local button = find_child_uicomponent(root, BUTTON_ID)
    if button then
        return button
    end
    button = UIComponent(root:CreateComponent(BUTTON_ID, "ui/templates/square_medium_button"))
    local sw, sh = core:get_screen_resolution()
    local bw, bh = button:Dimensions()
    button:MoveTo(math.floor(sw / 2 - bw / 2), sh - bh - 180)
    return button
end

local function refresh_button()
    local button = get_button()
    local character = selected_cqi and cm:get_character_by_cqi(selected_cqi)
    local is_general = character and not character:is_null_interface() and character:character_type("general")
        and character:faction():name() == cm:get_local_faction_name(true)

    button:SetVisible(is_general and true or false)
    if not is_general then
        return
    end

    local reason = reject_reason(character)
    if reason then
        button:SetState("inactive")
        button:SetTooltipText("군주 영구 삭제||" .. reason, true)
    else
        button:SetState("active")
        button:SetTooltipText("군주 영구 삭제||" .. CONFIRM_SECONDS .. "초 안에 두 번 클릭하면 삭제됩니다. 되돌릴 수 없습니다.", true)
    end
end

local function hide_button()
    selected_cqi = nil
    armed_at = nil
    local button = find_child_uicomponent(core:get_ui_root(), BUTTON_ID)
    if button then
        button:SetVisible(false)
    end
end

---------------------------------------------------------------------------
-- UI 덤프 (조사용)
---------------------------------------------------------------------------

local CONTEXT_TYPES = { "CcoCampaignCharacter", "CcoCharacterDetails", "CcoFamilyMember" }

local function dump_uic(file, uic, depth)
    local line = string.rep("  ", depth) .. tostring(uic:Id())
    for _, cco in ipairs(CONTEXT_TYPES) do
        local ok, id = pcall(function() return uic:GetContextObjectId(cco) end)
        if ok and id and id ~= "" then
            line = line .. "  [" .. cco .. "=" .. tostring(id) .. "]"
        end
    end
    file:write(line .. "\n")
    for i = 0, uic:ChildCount() - 1 do
        dump_uic(file, UIComponent(uic:Find(i)), depth + 1)
    end
end

local function dump_panel(panel_name)
    local panel = find_uicomponent(core:get_ui_root(), panel_name)
    if not panel then
        return
    end
    local file = io.open("lord_remover_ui_dump.txt", "a")
    if not file then
        return
    end
    file:write("==== " .. panel_name .. " (turn " .. cm:model():turn_number() .. ")\n")
    local ok, err = pcall(dump_uic, file, panel, 0)
    if not ok then
        file:write("!! " .. tostring(err) .. "\n")
    end
    file:close()
end

---------------------------------------------------------------------------
-- 리스너
---------------------------------------------------------------------------

cm:add_first_tick_callback(function()
    log("loaded")

    core:add_listener(MOD .. "_selected", "CharacterSelected", true,
        function(context)
            selected_cqi = context:character():command_queue_index()
            armed_at = nil
            refresh_button()
        end, true)

    core:add_listener(MOD .. "_panel_dump", "PanelOpenedCampaign", true,
        function(context)
            if DUMP_UI then
                dump_panel(context.string)
            end
        end, true)

    core:add_listener(MOD .. "_click", "ComponentLClickUp",
        function(context) return context.string == BUTTON_ID end,
        function()
            if not selected_cqi then
                return
            end
            local now = os.clock()
            if armed_at and now - armed_at <= CONFIRM_SECONDS then
                armed_at = nil
                -- 모델 변경은 UITriggerScriptEvent 를 거쳐야 멀티플레이에서도 동기화된다
                local faction = cm:get_faction(cm:get_local_faction_name(true))
                CampaignUI.TriggerCampaignScriptEvent(faction:command_queue_index(), EVENT_PREFIX .. selected_cqi)
                hide_button()
            else
                armed_at = now
                get_button():SetTooltipText("군주 영구 삭제||한 번 더 클릭하면 삭제됩니다.", true)
            end
        end, true)

    core:add_listener(MOD .. "_do_remove", "UITriggerScriptEvent",
        function(context) return context:trigger():sub(1, #EVENT_PREFIX) == EVENT_PREFIX end,
        function(context)
            remove_lord(tonumber(context:trigger():sub(#EVENT_PREFIX + 1)))
        end, true)

    -- 턴 종료/선택 해제 시 버튼 숨김
    core:add_listener(MOD .. "_turn_end", "FactionTurnEnd", true, hide_button, true)
    core:add_listener(MOD .. "_char_moved", "CharacterFinishedMovingEvent", true,
        function() if selected_cqi then refresh_button() end end, true)
end)
