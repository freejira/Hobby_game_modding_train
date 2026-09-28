# 규칙

## 폴더 이름
- WH3: `snake_case` (pack 파일 이름과 동일하게. 예: `my_cool_mod` → `my_cool_mod.pack`)
- RimWorld: `PascalCase` (예: `MyCoolMod`)
- 번역 모드: 원본 모드 이름 + 접미사
  - WH3: `<원본>_ko`
  - RimWorld: `<원본>Korean`

## 모드 README 필수 항목
각 모드 폴더의 `README.md` 에 적는다.
- 한 줄 설명
- 대상 게임 버전
- (번역) 원본 모드 이름 / 스팀 워크샵 ID / 번역 기준 원본 버전
- 의존 모드, 로드 순서
- 변경 이력

## 번역 모드 작업 흐름
1. 원본 모드의 원문 텍스트를 `source/` 에 넣는다 (원본 업데이트 때 diff 비교용).
2. 번역본을 게임 규격 위치에 넣는다 (게임별 README 참고).
3. 원본이 업데이트되면 `source/` 를 갱신하고 `git diff` 로 바뀐 키만 번역한다.

## 커밋
- 접두사로 게임/모드 표시: `wh3/my_cool_mod: 유닛 스탯 조정`, `rimworld/SomeModKorean: 1.2 원문 반영`
- 빌드 결과물(`.pack`, `.dll`)은 커밋하지 않는다.

## 브랜치
- `main`: 기본. `dev` 에서 PR로 합친다.
- `dev`: 개발 통합.
- `local_data`: 클라우드 ↔ 로컬 질문·답변, 로컬에서 뽑은 로그/데이터 공유용. 모든 모드 세션 공용.
- `dev-<모드이름>`: 모드별 작업 브랜치 (`dev` 에서 따서 작업 → `dev` 로 PR).
  (`dev/<이름>` 은 `dev` 브랜치와 이름이 겹쳐서 git에서 만들 수 없음)

## 클라우드 ↔ 로컬 질문
[docs/questions/README.md](questions/README.md) 참고.
