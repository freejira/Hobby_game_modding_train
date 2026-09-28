# wh3-employment_manager-003: DB 테이블 포함 pack 빌드 + 빌드 스크립트

빌드할 코드 브랜치: `dev-employment_manager` (커밋 `b5d3072` 이후)

## 배경
Employment Manager에 고용풀 갱신 주기를 3~5턴으로 줄이는 DB 테이블을 추가했다.
레포에는 TSV로만 있다: `games/wh3/mods/employment_manager/pack/db/campaign_variables_tables/!employment_manager.tsv`
002 답변에서 `campaign_variables_tables` 바이너리를 Python으로 정확히 읽었으니, 반대로 쓰는 것도 가능할 것 같다.

## 부탁
1. 레포에 **pack 빌드 스크립트**를 추가해 줘: `tools/build_pack.py`
   - 입력: 모드의 `pack/` 폴더 (예: `games/wh3/mods/employment_manager/pack`)
   - `.tsv` 는 헤더 둘째 줄 `#<table>;<version>;<path>` 를 보고 DB 바이너리로 변환 (지금은 `campaign_variables_tables` v0 = StringU8 + F32 만 되면 충분. 모르는 테이블이면 에러)
   - 나머지 파일(lua 등)은 그대로
   - 출력: PFH5, 타입 Mod, 비압축 `.pack` (예: `build/employment_manager.pack`, `build/` 는 커밋 안 함)
   - 검증: 만든 pack을 002 때 쓴 파서로 다시 읽어서 원본과 같은지 확인
   - 이 스크립트는 `dev-employment_manager` 가 아니라 **`dev` 기반 새 브랜치 `dev-tools`** 에 올려줘 (모든 모드 공용 도구)
2. 그 스크립트로 `employment_manager.pack` 빌드해서 `data/` 에 넣기 (001 테스트에도 이 pack 사용)
3. 가능하면 More Characters 모드와 같이 켰을 때 어느 값이 적용되는지 (후보 교체 턴 수 관찰로 충분, 나중에 해도 됨)

## 답변에 적어줄 것
- [ ] 빌드 스크립트 브랜치/커밋
- [ ] 빌드된 pack의 파일 트리 + DB 테이블 재파싱 결과
- [ ] 바닐라 테이블 헤더(GUID 마커 등)와 다른 점이 있으면 기록
- [ ] (선택) 3번 관찰 결과

## 답변 끝나면
`answer.md` 작성 → `tools/qna.sh answer wh3-employment_manager-003` → `local_data` 에 push → PR "QnA 알림" 에 코멘트 `answered: wh3-employment_manager-003`
