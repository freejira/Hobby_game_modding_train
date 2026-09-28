# RimWorld

## 도구
- 텍스트 에디터 (XML), C# 모드면 .NET Framework 4.7.2 + [Harmony](https://github.com/pardeike/HarmonyRimWorld)
- 로컬 모드 경로: `...\steamapps\common\RimWorld\Mods\`
  - 이 레포의 모드 폴더를 여기에 심볼릭 링크로 연결하면 편하다:
    `mklink /D "...\RimWorld\Mods\MyCoolMod" "<repo>\games\rimworld\mods\MyCoolMod"`

## 모드 폴더 규격 (`mods/<Name>/`)
```
About/About.xml                   # 필수: packageId, 지원 버전
Defs/                             # 새 Def
Patches/                          # 기존 Def XPath 패치
Textures/
Languages/Korean (한국어)/Keyed/  # 자기 모드의 한국어 텍스트
Assemblies/                       # 빌드된 dll (커밋 안 함)
Source/                           # C# 소스
```

## 번역 모드 규격 (`translations/<Name>Korean/`)
```
About/About.xml                            # loadAfter 에 원본 packageId
Languages/Korean (한국어)/Keyed/           # UI 문자열
Languages/Korean (한국어)/DefInjected/     # Def 텍스트 (label, description 등)
Languages/Korean (한국어)/Strings/         # 이름 목록 등
source/                                    # 원본 영어 텍스트 (비교용, 게임은 무시함)
```
- 원본 모드에 `Languages/English` 가 없으면 DefInjected 는 원본 `Defs/` 를 보고 직접 작성해야 한다. 게임 내 개발자 모드의 **"Save translation report"** / RimTrans 같은 도구로 키 목록을 뽑을 수 있다.

## 모드 목록

### mods
| 이름 | packageId | 설명 | 상태 |
|---|---|---|---|

### translations
| 이름 | 원본 모드 (워크샵 ID) | 기준 버전 | 상태 |
|---|---|---|---|
