-- lord_hero_manager
-- 맵에서 선택한 자기 세력 군주/영웅에 버튼 두 개를 붙인다.
--   [영구 삭제]       군주·영웅. 불멸을 끄고 죽여서 고용창으로 돌아오지 않게 한다 (레벨 무관).
--   [고용창으로 보내기] 영웅 전용. 불멸로 만든 뒤 죽여서 부상 상태로 만들고, 즉시 회복시켜 고용창으로 돌린다.
--                     (군주는 바닐라 해산으로 이미 고용창에 돌아간다)
-- 두 버튼 모두 3초 안에 두 번 클릭해야 실행된다.
--
-- 고용창(풀)을 직접 건드리는 API가 없으므로 풀에 있는 군주는 고용해서 맵에 꺼낸 뒤 삭제한다.
-- 디버그: DUMP_UI = true 로 두면 패널이 열릴 때마다 UI 트리를 lord_hero_manager_ui_dump.txt 에 기록한다.

local MOD = "lord_hero_manager"
local EVENT_PREFIX = "lord_hero_manager|"
local CONFIRM_SECONDS = 3
local DUMP_UI = false

local selected_cqi = nil
local armed = { id = nil, at = nil }

local function log(msg)
    out("[" .. MOD .. "] " .. tostring(msg))
end

local function is_general(character)
    return character:character_type("general")
end

local function is_hero(character)
    return not is_general(character) and not character:character_type("colonel")
end

local function is_local_character(character)
    return character and not character:is_null_interface()
        and character:faction():name() == cm:get_local_faction_name(true)
        and (is_general(character) or is_hero(character))
end

---------------------------------------------------------------------------
-- 동작
---------------------------------------------------------------------------

-- 각 동작: check(character) -> 불가 이유 또는 nil, run(character)
local ACTIONS = {}

ACTIONS.remove = {
    button_id = MOD .. "_remove",
    title = "영구 삭제",
    help = "고용창으로 돌아오지 않고 완전히 사라집니다. 되돌릴 수 없습니다.",
    applies = function(character) return true end,
    check = function(character)
        if character:is_faction_leader() then
            return "세력 지도자는 삭제할 수 없습니다."
        end
        if is_general(character) and character:has_military_force()
            and character:military_force():unit_list():num_items() > 1 then
            return "군대에 유닛이 남아 있습니다. 유닛을 먼저 해산하거나 다른 군대로 옮기세요."
        end
        return nil
    end,
    run = function(character)
        -- 불멸을 끄지 않으면 죽여도 고용창으로 돌아온다
        cm:suppress_immortality(character:family_member():command_queue_index(), true)
        -- 영웅은 destroy_force = false (소속 군대를 건드리지 않도록)
        cm:kill_character(cm:char_lookup_str(character), is_general(character))
    end,
}

ACTIONS.recall = {
    button_id = MOD .. "_recall",
    title = "고용창으로 보내기",
    help = "영웅을 맵에서 빼서 고용창으로 돌려보냅니다. 레벨·스킬은 유지됩니다.",
    applies = is_hero,
    check = function(character)
        if character:is_faction_leader() then
            return "세력 지도자는 보낼 수 없습니다."
        end
        return nil
    end,
    run = function(character)
        local fm_cqi = character:family_member():command_queue_index()
        local lookup = cm:char_lookup_str(character)
        cm:suppress_immortality(fm_cqi, false)
        cm:set_character_immortality(lookup, true)
        cm:kill_character(lookup, false)
        -- 불멸 캐릭터는 죽으면 새 cqi로 재생성되므로 family member 로 다시 찾는다
        cm:callback(function()
            local fm = cm:get_family_member_by_cqi(fm_cqi)
            if not fm or fm:is_null_interface() then
                log("recall: family member " .. fm_cqi .. " not found")
                return
            end
            local c = fm:character()
            if c and not c:is_null_interface() then
                cm:stop_character_convalescing(c:command_queue_index())
            end
        end, 0.2)
    end,
}

local ACTION_ORDER = { "recall", "remove" }

local function reject_reason(action, character)
    if not is_local_character(character) then
        return "자기 세력 군주/영웅만 가능합니다."
    end
    if not action.applies(character) then
        return "이 캐릭터에는 사용할 수 없습니다."
    end
    return action.check(character)
end

local function perform(action_key, cqi)
    local action = ACTIONS[action_key]
    local character = cm:get_character_by_cqi(cqi)
    if not action or not character then
        return
    end
    local reason = reject_reason(action, character)
    if reason then
        log(action_key .. " rejected (" .. tostring(cqi) .. "): " .. reason)
        return
    end
    log(action_key .. " " .. tostring(cqi) .. " " .. character:get_forename() .. " " .. character:get_surname())
    action.run(character)
end

---------------------------------------------------------------------------
-- 버튼 UI
---------------------------------------------------------------------------

local function get_button(action, index)
    local root = core:get_ui_root()
    local button = find_child_uicomponent(root, action.button_id)
    if button then
        return button
    end
    button = UIComponent(root:CreateComponent(action.button_id, "ui/templates/square_medium_button"))
    local sw, sh = core:get_screen_resolution()
    local bw, bh = button:Dimensions()
    button:MoveTo(math.floor(sw / 2 - bw / 2 + (index - 1.5) * (bw + 8)), sh - bh - 180)
    return button
end

local function hide_buttons()
    for _, key in ipairs(ACTION_ORDER) do
        local button = find_child_uicomponent(core:get_ui_root(), ACTIONS[key].button_id)
        if button then
            button:SetVisible(false)
        end
    end
end

local function refresh_buttons()
    armed.id, armed.at = nil, nil
    local character = selected_cqi and cm:get_character_by_cqi(selected_cqi)
    if not is_local_character(character) then
        hide_buttons()
        return
    end
    for i, key in ipairs(ACTION_ORDER) do
        local action = ACTIONS[key]
        local button = get_button(action, i)
        if not action.applies(character) then
            button:SetVisible(false)
        else
            button:SetVisible(true)
            local reason = action.check(character)
            if reason then
                button:SetState("inactive")
                button:SetTooltipText(action.title .. "||" .. reason, true)
            else
                button:SetState("active")
                button:SetTooltipText(action.title .. "||" .. action.help
                    .. "\n" .. CONFIRM_SECONDS .. "초 안에 두 번 클릭하세요.", true)
            end
        end
    end
end

local function on_click(action_key)
    if not selected_cqi then
        return
    end
    local action = ACTIONS[action_key]
    local now = os.clock()
    if armed.id == action_key and now - armed.at <= CONFIRM_SECONDS then
        -- 모델 변경은 UITriggerScriptEvent 를 거쳐야 멀티플레이에서도 동기화된다
        local faction = cm:get_faction(cm:get_local_faction_name(true))
        CampaignUI.TriggerCampaignScriptEvent(faction:command_queue_index(),
            EVENT_PREFIX .. action_key .. "|" .. selected_cqi)
        selected_cqi = nil
        armed.id, armed.at = nil, nil
        hide_buttons()
    else
        armed.id, armed.at = action_key, now
        find_child_uicomponent(core:get_ui_root(), action.button_id)
            :SetTooltipText(action.title .. "||한 번 더 클릭하면 실행됩니다.", true)
    end
end

---------------------------------------------------------------------------
-- UI 덤프 (고용창 조사용)
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
    local file = io.open(MOD .. "_ui_dump.txt", "a")
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
            refresh_buttons()
        end, true)

    core:add_listener(MOD .. "_click", "ComponentLClickUp", true,
        function(context)
            for _, key in ipairs(ACTION_ORDER) do
                if context.string == ACTIONS[key].button_id then
                    on_click(key)
                    return
                end
            end
        end, true)

    core:add_listener(MOD .. "_perform", "UITriggerScriptEvent",
        function(context) return context:trigger():sub(1, #EVENT_PREFIX) == EVENT_PREFIX end,
        function(context)
            local key, cqi = context:trigger():sub(#EVENT_PREFIX + 1):match("^(%w+)|(%d+)$")
            if key then
                perform(key, tonumber(cqi))
            end
        end, true)

    core:add_listener(MOD .. "_panel_dump", "PanelOpenedCampaign",
        function() return DUMP_UI end,
        function(context) dump_panel(context.string) end, true)

    core:add_listener(MOD .. "_turn_end", "FactionTurnEnd", true,
        function() selected_cqi = nil; hide_buttons() end, true)
    core:add_listener(MOD .. "_char_moved", "CharacterFinishedMovingEvent", true,
        function() if selected_cqi then refresh_buttons() end end, true)
end)
