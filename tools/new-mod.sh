#!/usr/bin/env bash
# 사용법: tools/new-mod.sh <wh3|rimworld> <mods|translations> <Name>
set -euo pipefail
[ $# -eq 3 ] || { echo "usage: $0 <wh3|rimworld> <mods|translations> <Name>" >&2; exit 1; }
game=$1 kind=$2 name=$3
root=$(cd "$(dirname "$0")/.." && pwd)
src="$root/games/$game/$kind/_template"
dst="$root/games/$game/$kind/$name"
[ -d "$src" ] || { echo "no template: $src" >&2; exit 1; }
[ -e "$dst" ] && { echo "already exists: $dst" >&2; exit 1; }

cp -r "$src" "$dst"
# 파일명/내용의 __NAME__ 치환
find "$dst" -depth -name '*__NAME__*' | while read -r f; do
  mv "$f" "$(dirname "$f")/$(basename "$f" | sed "s/__NAME__/$name/g")"
done
find "$dst" -type f ! -name .gitkeep -exec sed -i "s/__NAME__/$name/g" {} +
echo "created: games/$game/$kind/$name"
echo "-> games/$game/README.md 모드 목록에 추가하는 거 잊지 말기"
