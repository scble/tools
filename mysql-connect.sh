#!/bin/bash
while true; do
  mysql -h DB_HOST \
        -u DB_USER -p'xxxx' \
        -e "select now();" || echo "DISCONNECTED"
  sleep 1
done
