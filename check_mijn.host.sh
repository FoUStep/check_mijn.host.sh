#!/bin/bash
# Nagios Check - 2023 MIJN.HOST API CHECK EXPIRY DOMAIN
# 20230614 v1.0 - Step (debian 11.x tested)

#
# API key is required, ask support@mijn.host for an API key.
# WARNING: SCRIPT NEEDS TO BE TESTED IF MULTIPLE DOMAINS!
#

# Main Vars
OK=0
WARNING=1
CRITICAL=2
ERROR=4

crit=30
warn=60

domain=$1
apikey=$2

# Check for curl & dateutils
if ! [ -x "$(command -v curl)" ]; then
  echo 'Error: curl is not installed.' >&2
  exit $ERROR
fi

if ! [ -x "$(command -v dateutils.ddiff)" ]; then
  echo 'Error: dateutils is not installed.' >&2
  exit $ERROR
fi

if [ -z "$domain" ] || [ -z "$apikey" ]
# $domain is required but is not used except for display in output.
then
        echo Usage: "$0 <domain> <apikey> (requires dateutils and curl)"
        exit $ERROR
fi

# Check date today
today=$(date "+%Y-%m-%d")

# Run complete check for domain expiry
expiredate=$(curl -s --location --request POST 'https://mijn.host/api/v1/domain/domains/' --header 'API-Key: '$apikey'' --header 'Content-Type: application/x-www-form-urlencoded' --header 'Accept: application/json' | jq -r '.data."domains" | .[] | .renewal_date')
remainingdays=$(( ($(date --date="$expiredate UTC" +%s) - $(date --date="$today UTC" +%s) )/(60*60*24) ))
output=$(dateutils.ddiff -f '%Y years, %m months, %d days' today "$(dateutils.dadd now $remainingdays)")

if [ "$remainingdays" -lt "$crit" ]; 
	then
		echo "CRITICAL - Renew domain $1. It expires in: $output | Remaining(Days)=$remainingdays"
		exit $CRITICAL
	else 
		if [ "$remainingdays" -lt "$warn" ];
			then 
				echo "WARNING - Renew domain $1. It expires in: $output | Remaining(Days)=$remainingdays"
				exit $WARNING
			else
				echo "DOMAIN OK - Domain $1 expires in: $output | Remaining(Days)=$remainingdays"
				exit $OK
		fi
fi
