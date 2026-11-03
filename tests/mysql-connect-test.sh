#!/bin/bash
set -eu

script="$(cd "$(dirname "$0")/.." && pwd)/mysql-connect.sh"
result_file="$(mktemp)"
trap 'rm -f "$result_file"' EXIT
export result_file

mysql() {
  printf '%s\n' "$@" "$MYSQL_PWD" > "$result_file"
}

sleep() {
  exit 0
}

export -f mysql sleep

output="$(printf 'db.example.com\nalice\np@ss word\n' | \
  DB_HOST=old-host DB_USER=old-user DB_PORT=3307 DB_NAME=app bash "$script")"
expected="$(printf '%s\n' -h db.example.com -P 3307 -u alice app \
  --connect-timeout=2 -e 'SELECT 1' 'p@ss word')"
[[ "$(cat "$result_file")" == "$expected" ]]
[[ "$output" == *"Connect Success("* ]]
[[ "$output" != *"p@ss word"* ]]

for input in '' $'\n' $'host\n' $'host\n\n' $'host\nuser\n'; do
  if printf '%s' "$input" | bash "$script" > /dev/null 2>&1; then
    echo "入力不足なのに成功しました" >&2
    exit 1
  fi
done

echo "mysql-connect tests passed"
