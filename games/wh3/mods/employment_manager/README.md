# Employment Manager (`employment_manager`)

맵에서 선택한 자기 세력 군주/영웅에게 버튼을 추가한다. 연방 후 쓸모없는 군주·영웅 정리용.

| 버튼 | 표시 대상 | 동작 |
|---|---|---|
| 고용창으로 보내기 | 영웅 | 맵에서 빼서 고용창으로 복귀 (군주 해산과 같은 효과, 레벨·스킬 유지) |
| 영구 삭제 | 군주·영웅 | 불멸을 끄고 삭제. 레벨/불멸 무관, 고용창으로 안 돌아옴 |
| 고용풀 리셋 (1000 골드) | 군주 | 군주 고용풀의 일반 군주 후보를 전부 삭제. 빈 자리는 게임이 새로 채움 |

모든 버튼은 **3초 안에 두 번 클릭**해야 실행된다. 리셋 비용은 lua의 `RESET_COST` 로 바꿀 수 있다.

- 게임 버전: WH3 (인게임 미검증)
- 의존 모드: 없음
- 비슷한/관련 모드 (워크샵 ID, 내용은 검색 결과 요약이라 직접 확인 전):
  - Execute (useless) Lords & Heroes (2958113532): 군주·영웅 처형 버튼
  - More Characters in Recruit Pools & Fast Refresh (3285143427): 풀 크기 증가, 갱신 주기 10~15턴 → 2~3턴
  - Character Recruitment Pool Refresh (2545767395), Faster Character Refresh (2820394157): 갱신 주기 단축 (WH3 호환 여부 불확실)
  - 돈 내고 즉시 리셋하는 모드는 못 찾음

## 사용법
- 고용창에 있는 특정 군주를 지우려면: 고용 → 맵에서 선택 → 영구 삭제
  (고용창 풀을 직접 건드리는 스크립트 API가 없음)
- 세력 지도자는 대상 제외
- 군대에 유닛이 남은 군주는 삭제 불가 (실수 방지)

## 원리
- 영구 삭제: `cm:suppress_immortality(fm_cqi, true)` → `cm:kill_character(lookup, 군주면 true)`
- 고용창으로 보내기: `cm:set_character_immortality(lookup, true)` → `cm:kill_character` 로 부상 상태 →
  family member 로 재생성된 캐릭터를 찾아 `cm:stop_character_convalescing(cqi)` 로 즉시 복귀
  - 부작용: 한 번 보낸 영웅은 **불멸**이 된다 (이후 전투에서 죽어도 부상 후 복귀). 필요하면 영구 삭제로 정리.
- 고용풀 리셋: 풀 후보를 읽는 API가 없어서 `faction:character_list()` 중
  군대·주둔지·지역이 없고 바다에도 없는 군주를 풀 후보로 **추정**해서 삭제한다.
  - 제외: 세력 지도자, 부상 중(`is_wounded`), 전설 군주(`character_details():is_unique()`)
  - 골드 차감: `cm:treasury_mod(faction, -1000)` (문서상 "양수여야 함"이라 음수 동작 확인 필요)
- 클릭은 `UITriggerScriptEvent` 를 거쳐 처리 (멀티플레이 동기화)

## TODO: 고용창에서 바로 삭제
1. lua 파일의 `DUMP_UI = true` 로 바꾸고 빌드
2. 게임에서 군주 고용창 열기
3. 게임 폴더의 `employment_manager_ui_dump.txt` 를 레포에 올리기

## 인게임 확인할 것
- [ ] 버튼 표시/위치 (`ui/templates/square_medium_button`, 아이콘 없음)
- [ ] 영구 삭제: 고레벨 군주, 불멸 전설 군주가 풀로 안 돌아오는지
- [ ] 영구 삭제: 군대에 붙은 영웅 삭제 시 군대가 멀쩡한지
- [ ] 고용창으로 보내기: 영웅 고용 목록에 나타나는지, 레벨/스킬/장비 유지되는지
- [ ] 고용풀 리셋: 풀 후보가 실제로 지워지는지 (스크립트 로그에 지운 이름이 찍힘)
- [ ] 고용풀 리셋: 맵에 있는 군주, 전설 군주가 **안** 지워지는지
- [ ] 고용풀 리셋: 1000 골드가 빠지는지
- [ ] 고용풀 리셋: 빈 풀이 언제 채워지는지. 바닐라 갱신 주기가 10~15턴이라 오래 빌 수 있음 → 그러면 Fast Refresh 류 모드와 같이 쓰거나 리셋 후 `spawn_character_to_pool` 로 직접 채우는 기능 추가

## 변경 이력
- 0.3: Employment Manager 로 이름 변경. 고용풀 리셋 (1000 골드) 추가
- 0.2: 영웅 지원, 영웅 고용창 복귀 버튼 추가
- 0.1: 군주 영구 삭제
