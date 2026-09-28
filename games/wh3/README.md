# Total War: WARHAMMER III

## 도구
- [RPFM](https://github.com/Frodo45127/rpfm) — `.pack` 열기/편집, DB·loc 테이블 TSV 내보내기/가져오기
- 게임 경로: `...\steamapps\common\Total War WARHAMMER III\data\`

## 모드 폴더 규격 (`mods/<name>/`)
`pack/` 아래는 `.pack` 내부 경로 그대로 둔다. RPFM에서 TSV로 내보낸 파일을 커밋하고, 빌드할 때 RPFM으로 다시 `.pack` 으로 묶는다.

```
pack/
  db/<table>_tables/<name>.tsv      # DB 테이블 (유닛, 건물 등)
  script/campaign/mod/<name>.lua    # 캠페인 스크립트
  text/db/<name>.loc.tsv            # 텍스트 (loc)
```

## 번역 모드 규격 (`translations/<name>_ko/`)
```
source/                   # 원본 모드에서 뽑은 loc TSV (원문, 비교용)
pack/text/db/*.loc.tsv    # 번역된 loc TSV
```
- WH3는 한국어를 공식 지원하지 않으므로 보통 **영어 loc 키를 한국어 텍스트로 덮어쓰는** 방식이다. 한글 폰트 모드가 필요할 수 있다.
- 원본 모드보다 우선 적용되도록 loc 파일명/로드 순서를 조정한다 (파일명 앞에 `!!` 를 붙이는 관례가 흔함). 모드 README에 로드 순서를 적어둘 것.

## 모드 목록

### mods
| 이름 | 설명 | 상태 |
|---|---|---|
| [employment_manager](mods/employment_manager) | Employment Manager: 군주·영웅 영구 삭제, 영웅 고용창 복귀, 고용풀 리셋 | 인게임 테스트 전 |

### translations
| 이름 | 원본 모드 (워크샵 ID) | 기준 버전 | 상태 |
|---|---|---|---|
