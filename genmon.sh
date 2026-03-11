#!/usr/bin/env bash

# 1. Prevent multiple instances if a previous request is still hanging
if pidof -x $(basename "$0") -o %PPID >/dev/null; then exit 0; fi

# 2. Randomize: average 20s (range 15-25s)
# Спит от 0 до 10 секунд (рандомно)
sleep $(( RANDOM % 11 ))

# 3. Main Logic
TIMEOUT=5

get_country() {
    local url="$1"
    local name="$2"
    response=$(curl -s --connect-timeout $TIMEOUT --max-time $TIMEOUT -w "\n%{http_code}" "$url")
    http_code=$(echo "$response" | tail -1)
    response=$(echo "$response" | sed '$d')
    if [ "$http_code" -ge 400 ]; then
        echo "[$name] HTTP $http_code" >&2
        return 1
    fi
    if [ -z "$response" ]; then
        echo "[$name] empty response" >&2
        return 1
    fi
    country_code=$(echo "$response" | grep -oE '"countryCode":"[^"]*|"country": "[^"]*' | cut -d'"' -f4 | tail -1)
    if [ -z "$country_code" ]; then
        echo "[$name] no country in response" >&2
        return 1
    fi
    echo "[$name] OK: $country_code" >&2
    echo "$country_code"
    return 0
}

country=$(get_country "https://ipinfo.io" "ipinfo.io") || \
    country=$(get_country "http://ip-api.com/json/?fields=countryCode" "ip-api.com")

if [ -n "$country" ]; then
    [[ "$country" == "RU" ]] && color="#FF0000" || color="#00FF00"
    echo "<txt><span weight='bold' fgcolor='$color'>$country</span></txt>"
else
    echo "<txt><span weight='bold' fgcolor='#FF0000'>Err</span></txt>"
fi

echo "<tool>Last check: $(date +%H:%M:%S)</tool>"

