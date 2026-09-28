# Hobby Game Modding

개인용 게임 모드 모음. 게임별로 **직접 만든 모드(mods)** 와 **번역 모드(translations)** 를 분리해서 관리한다.

## 구조

```
games/
  wh3/                      # Total War: WARHAMMER III
    mods/<ModName>/         # 직접 만든 모드 (RPFM으로 풀어둔 .pack 내용)
    translations/<Target>/  # 다른 모드의 한글화 모드
  rimworld/                 # RimWorld
    mods/<ModName>/         # 직접 만든 모드 (XML / C#)
    translations/<Target>/  # 다른 모드의 한글화 모드
tools/                      # 공용 스크립트 (새 모드 생성 등)
docs/                       # 규칙, 메모
```

- 각 카테고리의 `_template/` 을 복사해서 새 모드를 시작한다.
- 게임별 모드 목록은 `games/<game>/README.md` 표에 추가한다.

## 새 모드 만들기

```bash
tools/new-mod.sh wh3 mods my_cool_mod
tools/new-mod.sh wh3 translations some_mod_ko
tools/new-mod.sh rimworld mods MyCoolMod
tools/new-mod.sh rimworld translations SomeModKorean
```

## 규칙

[docs/conventions.md](docs/conventions.md) 참고.
