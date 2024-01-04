#!/usr/bin/env bash

check_internet() {
    if ping -q -c 1 -W 1 google.com >/dev/null; then
        return 0  # Success (connected)
    else
        return 1  # Failure (disconnected)
    fi
}

if check_internet; then
	# Fetch the country information using ipinfo.io
	response=$(curl -s -w "%{http_code}" https://ipinfo.io)
	status_code=${response: -3}
	country=$(echo "$response" | grep -o '"country": "[^"]*' | cut -d'"' -f4)

	if [ "$status_code" != "200" ]; then
		echo "<txt><span weight=\"bold\" fgcolor=\"#FF0000\">not avail.</span></txt>"
	else
		# Set the color based on the country
		if [ "$country" = "RU" ]; then
			color="#FF0000"  # Red for Russia
		else
			color="#00FF00"  # Green for other countries
		fi

		# Display the country name in the specified color and bold style
		echo "<txt><span weight=\"bold\" fgcolor=\"$color\">$country</span></txt>"
	fi

	# Provide an empty tooltip (you can customize this with more information if needed)
	echo "<tool></tool>"
else
    # Disconnected
    echo "<txt>No connection</txt>"
    echo "<tool></tool>"
fi
