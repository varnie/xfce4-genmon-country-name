#!/usr/bin/env bash

if [ $(( RANDOM % 4 )) -eq 0 ]; then
    # Skip execution 25% of the time
    exit 1
fi

# Function to check internet connectivity
check_internet() {
    # Ping Google to check for internet connection
    if ping -q -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; then
        return 0  # Connected
    else
        return 1  # Not connected
    fi
}

# Main execution block
if check_internet; then
    # Fetch country information from ip-api.com using the JSON format
    response=$(curl -s "http://ip-api.com/json/?fields=country,countryCode,status,message")
    # Check if the API returned a successful response
    if echo "$response" | grep -q '"status":"success"'; then
        country_code=$(echo "$response" | grep -o '"countryCode":"[^"]*' | cut -d'"' -f4)
        country_name=$(echo "$response" | grep -o '"country":"[^"]*' | cut -d'"' -f4)

        # Set the color based on the country code
        if [ "$country_code" = "RU" ]; then
            color="#FF0000"  # Red for Russia
        else
            color="#00FF00"  # Green for other countries
        fi

        # Display the country name in the specified color and bold style
        echo "<txt><span weight=\"bold\" fgcolor=\"$color\">$country_code </span></txt>"
    else
        # Handle error message from API
        error_message=$(echo "$response" | grep -o '"message":"[^"]*' | cut -d'"' -f4)
        echo "<txt><span weight=\"bold\" fgcolor=\"#FF0000\">Err: $error_message</span></txt>"
    fi

    # Provide an empty tooltip (you can customize this with more information if needed)
    echo "<tool></tool>"
else
    # Disconnected
    echo "<txt>No cxn</txt>"
    echo "<tool></tool>"
fi
