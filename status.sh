#!/bin/sh

# status bar for your PS1 or vim statusline

IFS= read -r status < /sys/class/power_supply/BAT0/status
IFS= read -r capacity < /sys/class/power_supply/BAT0/capacity

# Determine gauge symbol
if [ "$capacity" -ge 90 ]; then
    gauge="𝍤"
    color="\033[0;32m"  # Green
elif [ "$capacity" -ge 70 ]; then
    gauge="𝍣"
    color="\033[0;33m"  # Yellow
elif [ "$capacity" -ge 50 ]; then
    gauge="𝍢"
    color="\033[0;33m"  # Yellow
elif [ "$capacity" -ge 30 ]; then
    gauge="𝍡"
    color="\033[0;33m"  # Yellow
else
    gauge="𝍠"
    color="\033[0;31m"  # Red
fi

# Decide icon
if [ "$status" = "Charging" ]; then
    icon="\033[0;33m🗲\033[0m"
elif [ "$status" = "Full" ]; then
    icon="\033[0;32m✔\033[0m"
else
    icon="\033[0;31m↘\033[0m"
fi

case "$status" in
    Charging) icon="\033[0;33m🗲\033[0m" ;;
    Full)     icon="\033[0;32m✔\033[0m" ;;
    *)        icon="\033[0;31m↘\033[0m" ;;
esac


# Audio volume
volume=$(amixer get Speaker | grep -oP '\d+%' | head -n 1 | tr -d '%')
is_mute=$(amixer get Speaker | grep -oP '\[on\]|\[off\]' | head -n 1)

# Determine volume gauge symbol
if [ "$volume" -ge 85 ]; then
    vol_gauge="🕪"  # High volume
elif [ "$volume" -ge 40 ]; then
    vol_gauge="🕩"  # Medium volume
else
    vol_gauge="🕨" # Low volume
fi
if [ "$is_mute" = "[off]" ]; then
    vol_gauge="🕨\033[0;31m✘\033[0m"  # Muted
fi

# ⌔ ✈︎
# Wi-Fi signal level
wifi_signal=$(iwconfig 2>/dev/null | grep -oP 'Link Quality=\K\d+/\d+' | awk -F'/' '{printf "%.0f", ($1/$2)*100}')

# Determine Wi-Fi gauge symbol
if [ -z "$wifi_signal" ]; then
    wifi_gauge="ᯤ\033[0;31m✘\033[0m"  # No Wi-Fi
elif [ "$wifi_signal" -ge 80 ]; then
    wifi_gauge="ᯤ\033[0;32m✔\033[0m"  # Excellent signal
elif [ "$wifi_signal" -ge 60 ]; then
    wifi_gauge="ᯤ\033[0;33m✔\033[0m"  # Good signal
elif [ "$wifi_signal" -ge 40 ]; then
    wifi_gauge="ᯤ\033[0;33m-\033[0m"  # Fair signal
elif [ "$wifi_signal" -ge 20 ]; then
    wifi_gauge="ᯤ\033[0;31m-\033[0m"  # Weak signal
else
    wifi_gauge="ᯤ\033[0;31m✘\033[0m"  # Very weak or no signal
fi

to_subscript() {
    local number="$1"
    local result=""
    while [ -n "$number" ]; do
        digit="${number%${number#?}}"  # Extract the first character
        number="${number#?}"          # Remove the first character
        case "$digit" in
            0) result="${result}₀" ;;
            1) result="${result}₁" ;;
            2) result="${result}₂" ;;
            3) result="${result}₃" ;;
            4) result="${result}₄" ;;
            5) result="${result}₅" ;;
            6) result="${result}₆" ;;
            7) result="${result}₇" ;;
            8) result="${result}₈" ;;
            9) result="${result}₉" ;;
            P) result="${result}ₚ" ;;
            M) result="${result}ₘ" ;;
        esac
    done
    echo "$result"
}

# Clock with date
month_number=$(date "+%-m")
am_pm=$(date "+%p")
subscript_month=$(to_subscript "$month_number")
subscript_am_pm=$(to_subscript "$am_pm")
current_time=$(date "+%a, %b\033[2m₍$subscript_month₎\033[0m%-d  %I:%M$subscript_am_pm")

echo "${wifi_gauge} ${vol_gauge}  ${color}${gauge}\033[0m$icon  $current_time"