#!/bin/bash
# Nagios Check - 2025 MIJN.HOST API CHECK EXPIRY DOMAIN(S)
# 20250115 v2.0 - Step (debian 12.x tested)

#
# API key is required, ask support@mijn.host for an API key.
#

# Main Vars
crit=30
warn=60

apikey=$1

# Check for curl & dateutils & apikey
if ! [ -x "$(command -v curl)" ]; then
  echo 'Error: curl is not installed.' >&2
  exit $ERROR
fi

if ! [ -x "$(command -v dateutils.ddiff)" ]; then
  echo 'Error: dateutils is not installed.' >&2
  exit $ERROR
fi

if [ -z "$apikey" ]
then
        echo Usage: "$0 <apikey> (requires dateutils and curl)"
        exit $ERROR
fi

# Run complete check for all domain(s) expiry
json_response=$(curl -s --location --request POST 'https://mijn.host/api/v1/domain/domains/' --header 'API-Key: '$apikey'' --header 'Content-Type: application/x-www-form-urlencoded' --header 'Accept: application/json');

today=$(date +%Y-%m-%d)

output=""
all_domains=""
exit_code=0  # Default exit code for "DOMAINS OK"

# Process JSON and store results in variables
while read -r domain expiredate; do
  remainingdays=$(( ($(date --date="$expiredate UTC" +%s) - $(date --date="$today UTC" +%s)) / (60*60*24) ))
  all_domains+="$domain ($remainingdays days) "
  if [ "$remainingdays" -lt $crit ]; then
    output+="CRITICAL: renewal for $domain ($remainingdays days) "
    exit_code=2
  elif [ "$remainingdays" -lt $warn ] && [ "$exit_code" -ne 2 ]; then
    output+="WARNING: renewal for $domain ($remainingdays days) "
    exit_code=1
  fi
done < <(echo "$json_response" | jq -r '.data.domains[] | "\(.domain) \(.renewal_date)"')

# Display results
if [ -n "$output" ]; then
  echo "$output"
else
  echo "DOMAIN(S) OK: $all_domains"
fi

# Exit with the appropriate code
exit $exit_code
