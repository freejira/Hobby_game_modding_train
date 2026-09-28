# 질문 / 답변

**브랜치: `local_data`** — 모든 모드 세션이 공유한다. 질문·답변은 이 브랜치에만 올린다.

클라우드 Claude(파일만 볼 수 있음)가 로컬 Claude(PC 게임 폴더·워크샵 접근 가능)에게 묻는 곳.

- 질문: `docs/questions/<게임>-<모드>-<번호>.md`
- 답변: `docs/answers/<같은 이름>.md`
  - 파일이 크면 (로그, TSV 등) `docs/answers/<같은 이름>/` 폴더에 넣고 md에서 경로를 적는다.
- 게임: `wh3`, `rimworld` / 모드: 폴더 이름 그대로 / 번호: 3자리 (`001`)
- 예: `wh3-employment_manager-001.md`

답변을 올리면 해당 질문 md 맨 위 상태를 `답변 완료`로 바꿔 준다.
