#!/usr/bin/env bash
set -euo pipefail

MT_HOST=your_hostname_here
MT_PORT=22
MT_LOGIN=username_here
# https://github.com/borestad/blocklist-abuseipdb
# ~100% confidence single-IP list of reported offenders
#[1d,3d,7d,14d,30d,60d,90d,120d,180d,365d,all]
SOURCE_URL="https://raw.githubusercontent.com/borestad/blocklist-abuseipdb/refs/heads/main/abuseipdb-s100-14d.ipv4"
# ~99% condfidence subnet list of reported offenders; /24 subnets where 75% of traffic or more is bad
#SOURCE_URL="https://raw.githubusercontent.com/borestad/blocklist-abuseipdb/refs/heads/main/stats/hallofshame/subnets/abuseipdb-s99-hallofshame-14d-75percent.ipv4"
#[1d,3d,7d,14d,30d,60d,90d,120d,180d,365d,all]
#[1,5,10,15,20,25,50,75]percent

UNPROCESSED_LIST=/tmp/abuseipdb.txt
OUTPUT_LIST=/tmp/abuseipdb.rsc
ROUTEROS_SSH_KEYFILE=/path/to/ssh/id_rsa

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
ssh -i $ROUTEROS_SSH_KEYFILE -o StrictHostKeyChecking=no -p $MT_PORT -l $MT_LOGIN $MT_HOST /import verbose=true abuseipdb.rsc
