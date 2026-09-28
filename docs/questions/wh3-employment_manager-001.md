# wh3-employment_manager-001: 고용풀 테스트 빌드 실행

상태: 답변 대기
브랜치: `dev-employment_manager`

## 배경
고용창(군주 고용풀)에서 바로 해고하는 기능을 만들 수 있는지 확인하려고 한다.
스크립트 문서에 풀 후보를 지우는 함수가 없어서, 게임에서 직접 확인해야 한다.

## 부탁
1. `dev-employment_manager` 브랜치의 `games/wh3/mods/employment_manager/pack/` 내용을 그대로 RPFM으로 `.pack` 빌드
   - 파일 3개: `script/campaign/mod/employment_manager.lua`, `script/campaign/mod/employment_manager_pool_test.lua` (나머지는 빈 폴더)
   - pack 타입 Mod, 이름 `employment_manager.pack` → `data/` 에 넣고 런처에서 활성화
2. 아무 세력 캠페인 로드 (새 게임이든 세이브든)
3. **턴을 한 번 넘기기** (풀에 새 후보가 들어와야 추적됨)
4. 군주 고용창 열기 → 후보 이름 적어두기
5. 화면 오른쪽 아래 빈 네모 버튼 **[풀 테스트]** 클릭
6. 고용창 다시 열기 → 삭제 시도된 후보가 사라졌는지 확인
7. 게임 설치 폴더(`...\Total War WARHAMMER III\`)에 생긴 파일 2개를 답변 폴더에 복사
   - `employment_manager_pool_test.txt`
   - `employment_manager_ui_dump.txt`

## 답변에 적어줄 것
- [ ] 5번 버튼이 보였나? (안 보였으면 3~6번 대신 스크립트 로그/에러 상황)
- [ ] 6번: 후보가 사라졌나? (사라짐 / 그대로 / 다른 변화)
- [ ] 로그 파일 2개 → `docs/answers/wh3-employment_manager-001/`
- [ ] 게임 튕김, 스크립트 에러 팝업 있었으면 내용
- [ ] (가능하면) 해고/고용창으로 보내기 버튼도 눌러보고 결과
