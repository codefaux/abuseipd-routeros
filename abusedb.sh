#!/bin/bash

PLIK=/tmp/abuseidb.txt
MT_PLIK=/tmp/abuseidb.rsc
SOURCE_URL="https://raw.githubusercontent.com/borestad/blocklist-abuseipdb/refs/heads/main/abuseipdb-s100-14d.ipv4"
# https://github.com/borestad/blocklist-abuseipdb - [1d,3d,7d,14d,30d,60d,90d,120d,180d,365d,all]

rm -rf $PLIK
rm -rf $MT_PLIK

curl -fJLs $SOURCE_URL -o $PLIK

echo "/ip firewall address-list" >> $MT_PLIK
echo "/ip firewall address-list remove [/ip firewall address-list find list=abuseidb]" >> $MT_PLIK

while IFS= read -r ip
do
echo "add list=abuseidb address=$ip timeout=2d" >> $MT_PLIK
done < "$PLIK"

sshpass -p "$MT_PASSWORD" scp -P $MT_PORT -r $MT_PLIK $MT_LOGIN@$MT_HOST:/abuseidb.rsc
sshpass -p "$MT_PASSWORD" ssh -o StrictHostKeyChecking=no -oHostKeyAlgorithms=+ssh-dss -p $MT_PORT -l $MT_LOGIN $MT_HOST /import abuseidb.rsc
