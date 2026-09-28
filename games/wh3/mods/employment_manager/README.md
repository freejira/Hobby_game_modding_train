# Employment Manager (`employment_manager`)

맵에서 선택한 자기 세력 군주/영웅에게 버튼을 추가한다. 연방 후 쓸모없는 군주·영웅 정리용.

| 버튼 | 표시 대상 | 동작 |
|---|---|---|
| 고용창으로 보내기 | 영웅 | 맵에서 빼서 고용창으로 복귀 (군주 해산과 같은 효과, 레벨·스킬 유지) |
| 해고 (퇴직금 1000 골드) | 군주·영웅 | 퇴직금을 내고 영구 삭제. 레벨/불멸 무관, 고용창으로 안 돌아옴 |

모든 버튼은 **3초 안에 두 번 클릭**해야 실행된다. 퇴직금은 lua의 `SEVERANCE_PAY` 로 바꿀 수 있다.

- 게임 버전: WH3 (인게임 미검증)
- 의존 모드: 없음
- 비슷한/관련 모드 (워크샵 ID, 내용은 검색 결과 요약이라 직접 확인 전):
  - Execute (useless) Lords & Heroes (2958113532): 군주·영웅 처형 버튼
  - More Characters in Recruit Pools & Fast Refresh (3285143427): 풀 크기 증가, 갱신 주기 10~15턴 → 2~3턴
  - Character Recruitment Pool Refresh (2545767395), Faster Character Refresh (2820394157): 갱신 주기 단축 (WH3 호환 여부 불확실)
  - 돈 내고 즉시 리셋하는 모드는 못 찾음

## 사용법
- **고용풀 정리**: 필요 없는 후보를 고용 → 맵에서 선택 → 해고.
  고용하면 풀에서 빠지고 다음 턴에 새 후보가 보충된다 (고용풀을 직접 건드리는 스크립트 API는 없음).
  비용 = 고용비 + 퇴직금 1000.
- 세력 지도자는 대상 제외
- 군대에 유닛이 남은 군주는 삭제 불가 (실수 방지)

## 원리
- 해고: `cm:treasury_mod(faction, -1000)` → `cm:suppress_immortality(fm_cqi, true)` → `cm:kill_character(lookup, 군주면 true)`
  - 골드 차감은 문서상 "양수여야 함"이라 음수 동작 확인 필요
- 고용창으로 보내기: `cm:set_character_immortality(lookup, true)` → `cm:kill_character` 로 부상 상태 →
  family member 로 재생성된 캐릭터를 찾아 `cm:stop_character_convalescing(cqi)` 로 즉시 복귀
  - 부작용: 한 번 보낸 영웅은 **불멸**이 된다 (이후 전투에서 죽어도 부상 후 복귀). 필요하면 해고로 정리.
- 클릭은 `UITriggerScriptEvent` 를 거쳐 처리 (멀티플레이 동기화)

## 테스트 중: 고용창에서 바로 해고
`NewCharacterEnteredRecruitmentPool` 이벤트로 풀 후보를 알아낼 수 있다. 남은 확인은 두 가지:
1. 풀 후보를 스크립트로 지울 수 있는가 → `employment_manager_pool_test.lua`
2. 고용창에서 선택된 후보를 알아낼 수 있는가 → UI 덤프 (`DUMP_UI = true`)

### 테스트 방법
1. `pack/` 전체로 빌드 (테스트 파일, `DUMP_UI = true` 상태 그대로)
2. 캠페인 로드 → **턴 넘기기** (풀에 새 후보가 들어와야 추적됨. 로드 전부터 있던 후보는 추적 안 됨)
3. 군주 고용창 열기 → 후보 이름 기억 (UI 덤프도 이때 기록됨)
4. 화면 오른쪽 아래 **[풀 테스트]** 버튼 클릭 → 가장 최근 들어온 후보 1명 삭제 시도
5. 고용창 다시 열어서 그 후보가 사라졌는지 확인
6. 게임 폴더(`Total War WARHAMMER III/`)의 두 파일을 `local_data` QnA 큐로 전달 (`wh3-employment_manager-001`)
   - `employment_manager_pool_test.txt`
   - `employment_manager_ui_dump.txt`
   - + 5번 결과 (사라졌는지) 한 줄

배포 전: 테스트 파일 삭제, `DUMP_UI = false`

## 인게임 확인할 것
- [ ] 버튼 표시/위치 (`ui/templates/square_medium_button`, 아이콘 없음)
- [ ] 해고: 고레벨 군주, 불멸 전설 군주가 풀로 안 돌아오는지
- [ ] 해고: 군대에 붙은 영웅 삭제 시 군대가 멀쩡한지
- [ ] 고용창으로 보내기: 영웅 고용 목록에 나타나는지, 레벨/스킬/장비 유지되는지
- [ ] 해고: 1000 골드가 빠지는지, 골드 부족하면 버튼이 비활성인지
- [ ] 고용 → 해고 후 다음 턴에 고용풀이 보충되는지

## 변경 이력
- 0.5 (테스트): 고용풀 후보 추적·삭제 테스트, UI 덤프 기본 켜짐
- 0.4: 영구 삭제 → 해고 (퇴직금 1000 골드). 추정 방식이던 고용풀 리셋 제거
- 0.3: Employment Manager 로 이름 변경. 고용풀 리셋 (1000 골드) 추가
- 0.2: 영웅 지원, 영웅 고용창 복귀 버튼 추가
- 0.1: 군주 영구 삭제
