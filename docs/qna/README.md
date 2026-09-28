# QnA 큐

클라우드 Claude(레포만 볼 수 있음) ↔ 로컬 Claude(PC 게임 폴더·워크샵 접근 가능)가 주고받는 큐.
**브랜치: `local_data`** (모든 모드 세션 공용)

## 상태 = 폴더
```
pending/    새 질문. 로컬이 처리할 것
answered/   답변 완료. 클라우드가 읽을 것
done/       클라우드가 반영 완료. 보관
```

## 항목 = 폴더 하나
`<게임>-<모드>-<3자리 번호>/` (예: `wh3-employment_manager-001/`)
- `question.md`: 질문 (클라우드가 작성)
- `answer.md`: 답변 (로컬이 작성)
- 그 외: 첨부 (로그, TSV, lua 등)

## 흐름
1. **클라우드**: `pending/<id>/question.md` 작성 → push
2. **로컬**: 처리 → `answer.md`·첨부 추가 → 폴더를 `answered/` 로 이동 → push
   → **PR "QnA 알림" 에 코멘트** `answered: <id>` (이게 클라우드를 깨운다)
3. **클라우드**: 읽고 반영 → 폴더를 `done/` 으로 이동 → push

추가 질문이 생기면 새 번호로 만든다 (기존 항목 재사용 안 함).

## 도구
```bash
tools/qna.sh list                       # 상태별 목록
tools/qna.sh new wh3 employment_manager # 다음 번호로 pending 에 생성
tools/qna.sh answer <id>                # pending → answered
tools/qna.sh done <id>                  # answered → done
```
