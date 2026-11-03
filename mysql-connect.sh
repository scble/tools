#!/bin/bash
#
# Aurora(MySQL互換)への接続チェックを1秒ごとに実行するスクリプト
# データベースアップグレード時のダウンタイム計測用
#
# 使い方:
#   DB_NAME=mydb ./mysql-connect.sh
#   → 実行時にホスト、ユーザー名、パスワードの入力を求められます
#   → パスワードは画面に表示されません
#
# 停止: Ctrl+C

DB_PORT="${DB_PORT:-3306}"
DB_NAME="${DB_NAME:-mysql}"
INTERVAL="${INTERVAL:-1}"

export TZ="Asia/Tokyo"

if ! read -r -p "DB Host: " DB_HOST || [[ -z "$DB_HOST" ]]; then
  echo "DB Host を入力してください" >&2
  exit 1
fi

if ! read -r -p "DB User: " DB_USER || [[ -z "$DB_USER" ]]; then
  echo "DB User を入力してください" >&2
  exit 1
fi

# パスワードをインタラクティブに入力(画面非表示・履歴にも残らない)
if ! read -r -s -p "DB Password: " DB_PASS; then
  echo >&2
  echo "DB Password の入力に失敗しました" >&2
  exit 1
fi
echo
export MYSQL_PWD="$DB_PASS"
unset DB_PASS

while true; do
  now=$(date '+%H:%M:%S')
  if mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" "$DB_NAME" \
       --connect-timeout=2 -e "SELECT 1" >/dev/null 2>&1; then
    echo "Connect Success(${now})"
  else
    echo "Connect Fail (${now})"
  fi
  sleep "$INTERVAL"
done
