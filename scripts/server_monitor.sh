
#!/bin/bash

# ==========================================
# SERVER MONITORING SCRIPT
# Project: Linux Monitoring
# Environment: macOS
# ==========================================

# Get project directory dynamically
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

LOG_DIR="$PROJECT_DIR/logs"
LOG_FILE="$LOG_DIR/server_monitor.log"

mkdir -p "$LOG_DIR"

# Save terminal output to log file as well

echo ""
echo "====================================="
echo "       SERVER MONITORING REPORT"
echo "====================================="

echo "Hostname: $(hostname)"
echo "Date: $(date)"
echo ""

# CPU UTILIZATION
CPU_USAGE=$(top -l 2 -n 0 | awk '
/CPU usage/ {
    user_usage = ""
    sys_usage = ""

    for (i = 1; i <= NF; i++) {
        if ($i == "user,") user_usage = $(i-1)
        if ($i == "sys,") sys_usage = $(i-1)
    }

    gsub("%", "", user_usage)
    gsub("%", "", sys_usage)

    if (user_usage != "" && sys_usage != "") {
        cpu = user_usage + sys_usage
    }
}
END {
    if (cpu == "")
        print "N/A"
    else
        printf "%.1f", cpu
}')

echo "CPU Usage: ${CPU_USAGE}%"


# MEMORY UTILIZATION
FREE_MEMORY=$(memory_pressure -Q | awk -F': ' '
/System-wide memory free percentage/ {
    gsub("%", "", $2)
    print $2
}')

if [[ -n "$FREE_MEMORY" ]]; then
    MEMORY_USAGE=$(awk -v free="$FREE_MEMORY" \
        'BEGIN {printf "%.1f", 100-free}')
    echo "Memory Usage: ${MEMORY_USAGE}%"
else
    MEMORY_USAGE="N/A"
    echo "Memory Usage: Unavailable"
fi

# DISK UTILIZATION
DISK_USAGE=$(df -h / | awk 'NR==2 {gsub("%","",$5); print $5}')

echo "Disk Usage: ${DISK_USAGE}%"

echo ""
echo "--------------- ALERTS ----------------"

# RESOURCE THRESHOLD CHECK
check_threshold() {
    NAME=$1
    VALUE=$2

    if [[ "$VALUE" == "N/A" || -z "$VALUE" ]]; then
        echo "INFO: $NAME measurement unavailable"
    elif awk -v usage="$VALUE" \
        'BEGIN {exit !(usage > 80)}'; then
        echo "WARNING: $NAME usage is above 80%!"
    else
        echo "OK: $NAME usage is normal."
    fi
}

check_threshold "CPU" "$CPU_USAGE"
check_threshold "Memory" "$MEMORY_USAGE"
check_threshold "Disk" "$DISK_USAGE"

echo "====================================="
echo "       MONITORING COMPLETED"
echo "====================================="
