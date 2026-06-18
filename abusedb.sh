#!/usr/bin/env bash
set -euo pipefail

PLIK=/tmp/abuseidb.txt
MT_PLIK=/tmp/abuseidb.rsc
MT_SSH_ID=/path/to/ssh/id_rsa

rm -rf $PLIK
rm -rf $MT_PLIK

curl -G https://api.abuseipdb.com/api/v2/blacklist -d confidenceMinimum=90 -H "Key:$YOUR_API_KEY" -H "Accept: text/plain" -o $PLIK

echo "/ip firewall address-list" >> $MT_PLIK
echo "/ip firewall address-list remove [/ip firewall address-list find list=abuseidb]" >> $MT_PLIK

while IFS= read -r ip
do
  ip="${ip%%#*}"
  ip="${ip#"${ip%%[![:space:]]*}"}"
  ip="${ip%"${ip##*[![:space:]]}"}"

  [[ -z $ip ]] && continue
echo "add list=abuseidb address=$ip timeout=2d" >> $MT_PLIK
done < "$PLIK"

scp -i $MT_SSH_ID -P $MT_PORT $MT_PLIK $MT_LOGIN@$MT_HOST:/abuseidb.rsc
ssh -i $MT_SSH_ID -o StrictHostKeyChecking=no -p $MT_PORT -l $MT_LOGIN $MT_HOST /import abuseidb.rsc
