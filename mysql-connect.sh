#!/bin/bash
#
# Aurora(MySQL互換)への接続チェックを1秒ごとに実行するスクリプト
# データベースアップグレード時のダウンタイム計測用
#
# 使い方:
#   DB_HOST=xxx.rds.amazonaws.com DB_USER=admin DB_NAME=mydb ./check_aurora_connection.sh
#   → 実行時にパスワードの入力を求められます(画面には表示されません)
#
# 停止: Ctrl+C

DB_HOST="${DB_HOST:?DB_HOST を環境変数で指定してください}"
DB_PORT="${DB_PORT:-3306}"
DB_USER="${DB_USER:?DB_USER を環境変数で指定してください}"
DB_NAME="${DB_NAME:-mysql}"
INTERVAL="${INTERVAL:-1}"

export TZ="Asia/Tokyo"

# パスワードをインタラクティブに入力(画面非表示・履歴にも残らない)
read -r -s -p "DB Password: " DB_PASS
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
