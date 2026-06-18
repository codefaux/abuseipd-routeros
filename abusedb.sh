#!/usr/bin/env bash
set -euo pipefail

MT_HOST=your_hostname_here
MT_PORT=22
MT_LOGIN=username_here
SOURCE_URL="https://raw.githubusercontent.com/borestad/blocklist-abuseipdb/refs/heads/main/abuseipdb-s100-14d.ipv4"
UNPROCESSED_LIST=/tmp/abuseipdb.txt
OUTPUT_LIST=/tmp/abuseipdb.rsc
ROUTEROS_SSH_KEYFILE=/path/to/ssh/id_rsa
# https://github.com/borestad/blocklist-abuseipdb - [1d,3d,7d,14d,30d,60d,90d,120d,180d,365d,all]

rm -rf $UNPROCESSED_LIST
rm -rf $OUTPUT_LIST

curl -fJLs $SOURCE_URL -o $UNPROCESSED_LIST

echo "/ip firewall address-list" > $OUTPUT_LIST
echo "/ip firewall address-list remove [/ip firewall address-list find list=abuseipdb]" >> $OUTPUT_LIST

while IFS= read -r ip
do
  ip="${ip%%#*}"
  ip="${ip#"${ip%%[![:space:]]*}"}"
  ip="${ip%"${ip##*[![:space:]]}"}"

  [[ -z $ip ]] && continue
echo "add list=abuseipdb address=$ip timeout=2d" >> $OUTPUT_LIST
done < "$UNPROCESSED_LIST"

scp -i $ROUTEROS_SSH_KEYFILE -P $MT_PORT $OUTPUT_LIST $MT_LOGIN@$MT_HOST:/abuseipdb.rsc
ssh -i $ROUTEROS_SSH_KEYFILE -o StrictHostKeyChecking=no -p $MT_PORT -l $MT_LOGIN $MT_HOST /import abuseidb.rsc
