#!/usr/bin/env bash
# QnA 큐 관리. docs/qna/README.md 참고.
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
q="$root/docs/qna"

usage() { echo "usage: $0 list | new <game> <mod> | answer <id> | done <id>" >&2; exit 1; }

find_item() {
  local id=$1 st
  for st in pending answered done; do
    [ -d "$q/$st/$id" ] && { echo "$st"; return; }
  done
  echo "not found: $id" >&2; exit 1
}

move() {
  local id=$1 from=$2 to=$3 cur
  cur=$(find_item "$id")
  [ "$cur" = "$from" ] || { echo "$id is in $cur/, expected $from/" >&2; exit 1; }
  git -C "$root" mv "$q/$from/$id" "$q/$to/$id"
  echo "$id: $from -> $to"
}

case "${1:-}" in
  list)
    for st in pending answered done; do
      echo "[$st]"
      find "$q/$st" -mindepth 1 -maxdepth 1 -type d -printf '  %f\n' | sort
    done ;;
  new)
    [ $# -eq 3 ] || usage
    prefix="$2-$3"
    last=$(find "$q" -mindepth 2 -maxdepth 2 -type d -name "$prefix-*" -printf '%f\n' \
           | sed "s/^$prefix-//" | sort -n | tail -1)
    id=$(printf '%s-%03d' "$prefix" $((10#${last:-0} + 1)))
    mkdir -p "$q/pending/$id"
    printf '# %s: \n\n## 배경\n\n## 부탁\n\n## 답변에 적어줄 것\n- [ ] \n' "$id" > "$q/pending/$id/question.md"
    echo "created: docs/qna/pending/$id/question.md" ;;
  answer)
    [ $# -eq 2 ] || usage
    [ -f "$q/pending/$2/answer.md" ] || { echo "write docs/qna/pending/$2/answer.md first" >&2; exit 1; }
    move "$2" pending answered ;;
  done)
    [ $# -eq 2 ] || usage
    move "$2" answered done ;;
  *) usage ;;
esac
