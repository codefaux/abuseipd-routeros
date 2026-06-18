# AbuseIPDB with RouterOS
A minimum-viable script to import an AbuseIPDB mirror list to a RouterOS target, over SSH, using keys.

## Usage

Add script to cron and run periodically. Modify period of database file as needed.

```
SOURCE_URL="https://raw.githubusercontent.com/borestad/blocklist-abuseipdb/refs/heads/main/abuseipdb-s100-14d.ipv4"
# https://github.com/borestad/blocklist-abuseipdb - [1d,3d,7d,14d,30d,60d,90d,120d,180d,365d,all]
```

Optional: Adjust the firewall list entry timeout.

`echo "add list=abuseidb address=$ip timeout=2d" >> $MT_PLIK`


Set up firewall rules as appropriate using this list. Typical uses are 

`/ip/firewall/filter/add action=drop chain=input in-interface=WAN1 src-add-ress-list=abuseipdb`

`/ip/firewall/raw/add action=drop chain=prerouting src-address-list=abuseidb`
`/ip/firewall/raw/add action=drop chain=prerouting dst-address-list=abuseidb`

## Keyfile

We're only going to cover the basics here, assuming the target audience has general topical experience.

- Generate a key using ssh-keygen or use your existing key.
- Give the contents of the .pub file to RouterOS; System, Users, SSH Keys. You can upload and import the file (allowing password-protected keyfile use) or just copy-paste the text of a passwordless file into a New entry.
- Update the script variable to the path of your not-.pub file.
  
