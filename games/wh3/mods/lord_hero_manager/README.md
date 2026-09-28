# lord_hero_manager

맵에서 선택한 자기 세력 군주/영웅에게 버튼 두 개를 추가한다. 연방 후 쓸모없는 군주·영웅 정리용.

| 버튼 | 대상 | 동작 |
|---|---|---|
| 영구 삭제 | 군주·영웅 | 불멸을 끄고 삭제. 레벨/불멸 무관, 고용창으로 안 돌아옴 |
| 고용창으로 보내기 | 영웅 | 맵에서 빼서 고용창으로 복귀 (군주 해산과 같은 효과, 레벨·스킬 유지) |

두 버튼 모두 **3초 안에 두 번 클릭**해야 실행된다.

- 게임 버전: WH3 (인게임 미검증)
- 의존 모드: 없음
- 비슷한 모드: Execute (useless) Lords & Heroes (워크샵 2958113532)

## 사용법
- 고용창에 있는 군주를 지우려면: 고용 → 맵에서 선택 → 영구 삭제
  (고용창 풀을 직접 건드리는 스크립트 API가 없음)
- 세력 지도자는 대상 제외
- 군대에 유닛이 남은 군주는 삭제 불가 (실수 방지)

## 원리
- 영구 삭제: `cm:suppress_immortality(fm_cqi, true)` → `cm:kill_character(lookup, 군주면 true)`
- 고용창으로 보내기: `cm:set_character_immortality(lookup, true)` → `cm:kill_character` 로 부상 상태 →
  family member 로 재생성된 캐릭터를 찾아 `cm:stop_character_convalescing(cqi)` 로 즉시 복귀
  - 부작용: 한 번 보낸 영웅은 **불멸**이 된다 (이후 전투에서 죽어도 부상 후 복귀). 필요하면 영구 삭제로 정리.
- 클릭은 `UITriggerScriptEvent` 를 거쳐 처리 (멀티플레이 동기화)

## TODO: 고용창에서 바로 삭제
1. lua 파일의 `DUMP_UI = true` 로 바꾸고 빌드
2. 게임에서 군주 고용창 열기
3. 게임 폴더의 `lord_hero_manager_ui_dump.txt` 를 레포에 올리기

## 인게임 확인할 것
- [ ] 버튼 표시/위치 (`ui/templates/square_medium_button`, 아이콘 없음)
- [ ] 영구 삭제: 고레벨 군주, 불멸 전설 군주가 풀로 안 돌아오는지
- [ ] 영구 삭제: 군대에 붙은 영웅 삭제 시 군대가 멀쩡한지
- [ ] 고용창으로 보내기: 영웅 고용 목록에 나타나는지, 레벨/스킬/장비 유지되는지

## 변경 이력
- 0.2: lord_remover → lord_hero_manager. 영웅 지원, 영웅 고용창 복귀 버튼 추가
- 0.1: 군주 영구 삭제 (인게임 미검증)
