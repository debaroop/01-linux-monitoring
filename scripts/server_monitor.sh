
#!/bin/bash

# =====================================
# SERVER MONITORING SCRIPT
# Project: Linux Monitoring
# =====================================

echo "====================================="
echo "       SERVER MONITORING REPORT"
echo "====================================="

echo "Hostname: $(hostname)"
echo "Date: $(date)"
echo ""

# CPU Usage (macOS)
CPU_USAGE=$(top -l 2 -n 0 | awk '/CPU usage/ {usage=$3} END {print usage}')

# Memory Usage (macOS)
MEMORY_INFO=$(vm_stat)
echo "Memory Information:"
echo "$MEMORY_INFO" | head -5

# Disk Usage
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}')

echo ""
echo "Disk Usage: $DISK_USAGE"

echo "====================================="
echo "       MONITORING COMPLETED"
echo "====================================="
