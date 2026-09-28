# wh3-employment_manager-002 답변

대상: `...\steamapps\workshop\content\1142710\3285143427\more_characters_recruit_pools_fast_refresh.pack` (668 bytes, PFH5, 타입 Mod, 비압축)

RPFM이 PC에 없어서 Python으로 pack을 직접 파싱했다. DB 테이블 바이너리는 스키마 없이 읽었는데,
같은 방식으로 바닐라 `db.pack` 의 `campaign_variables_tables/data__` 1068행을 끝 바이트까지 오차 없이 읽었으므로
컬럼 구조(`variable_key` StringU8, `value` F32)는 확실하다. 컬럼 이름은 RPFM 스키마 이름을 추정해서 붙였다.

## 파일 트리
```
db/campaign_variables_tables/!character_recruit_pool_larger_faster_refresh   (258 B)
notes.rpfm_reserved                                                            (42 B, 빈 메모)
settings.rpfm_reserved                                                         (207 B, RPFM 기본 설정)
```
- `script/` 없음 → lua 파일 없음
- DB 테이블은 1개뿐이고 테이블 버전 마커 없음(version 0)

## `campaign_variables_tables` 내용 (바닐라와 비교)

| variable_key | 모드 | 바닐라 (현재 설치본 db.pack) |
|---|---|---|
| `character_recruitment_max_rounds_in_pool` | **3.0** | 15.0 |
| `character_recruitment_min_rounds_in_pool` | **2.0** | 10.0 |
| `min_total_recruitment_pool_entries` | 3.0 | 3.0 (같음) |
| `recruitment_pool_entries_per_category` | **3.0** | 2.0 |

해석 (이름 기준 추정):
- 후보가 풀에 머무는 기간을 바닐라 10~15턴에서 2~3턴으로 줄인다 → 갱신이 빨라진다 ("fast refresh")
- 카테고리당 후보 수를 2에서 3으로 늘린다 → 후보가 많아진다 ("more characters")
- 스크립트 없이 DB 값 4개만 덮어쓰는 모드다. 테이블 파일 이름 앞에 `!` 를 붙여 바닐라 `data__` 보다 먼저 로드되게 했다.

## 참고: 바닐라 `campaign_variables_tables` 의 관련 키
풀 크기, 갱신과 관련 있어 보이는 나머지 키:
- `province_governor_pool_size` = 4.0
- `persistent_character_recruitment_cost_multiplier` = 0.2

## 첨부
- `campaign_variables_tables__character_recruit_pool_larger_faster_refresh.tsv`: 모드 테이블 TSV (RPFM 형식 헤더)
