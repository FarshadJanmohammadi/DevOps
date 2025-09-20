#!/bin/bash

# =========================
# Server Info Auto-Doc Script (Confluence Style)
# =========================

OUTPUT_FILE="server_documentation.txt"

# -------------------------
# Gather System Information
# -------------------------
HOSTNAME=$(hostname)
OS_INFO=$(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"')
ARCH=$(uname -m)
CPU_INFO=$(lscpu | grep "Model name:" | sed 's/Model name:\s*//')
CPU_CORES=$(lscpu | grep "^CPU(s):" | awk '{print $2}')
RAM_TOTAL=$(free -h | awk '/Mem:/ {print $2}')
RAM_AVAILABLE=$(free -h | awk '/Mem:/ {print $7}')
SWAP_SIZE=$(free -h | awk '/Swap:/ {print $2}')

# Disk summary (total only)
DISK_TOTAL=$(df -h --total | grep "total" | awk '{print $2}')
LVM_NAME=$(sudo lvs --noheadings -o vg_name 2>/dev/null | head -n1)
LVM_TOTAL=$(sudo lvs --noheadings -o vg_size 2>/dev/null | head -n1)

# Network info
PRIVATE_IP=$(hostname -I | awk '{print $1}')
SSH_PORT=$(ss -tulpn | grep sshd | awk '{split($5,a,":"); print a[length(a)]}' | head -n1)

# -------------------------
# Generate Confluence-Style Doc
# -------------------------
cat <<EOF > $OUTPUT_FILE
h1. Server Overview
* *Hostname:* $HOSTNAME
* *Purpose / Role:* (fill in)
* *OS & Version:* $OS_INFO
* *Architecture:* $ARCH

h2. Hardware Specs
* *CPU:* $CPU_INFO ($CPU_CORES cores)
* *RAM:* $RAM_TOTAL ($RAM_AVAILABLE available)
* *Swap:* $SWAP_SIZE
* *Disks:* Total: $DISK_TOTAL
_All disks are part of LVM $LVM_NAME with ~$LVM_TOTAL total logical volume_

* *Location / Environment:* (fill in)
* *Owner / Responsible Team:* (fill in)

----

h1. Network & Access

h2. IP Addresses
* *Private:* $PRIVATE_IP
* *Public:* (fill in)

h2. SSH
* *SSH Port:* $SSH_PORT
* *Key or user accounts:*
** User: (fill in)
** Other authorized users: (fill in)
*Keys stored in* /home/<user>/.ssh/authorized_keys

h2. Firewall / Security Groups
* *Inbound rules:* (fill in)
* *Outbound rules:* (fill in)

----

h1. Services & Applications

|| Service Name || Version || Deployment Method || Configuration Files || Dependencies || Log Locations || Monitoring / Alerts ||
| Telegram Alert | (fill accordingly) | Docker | /app/config/ | Python3 | /app/logs/ | Custom scripts |
| (add more services) | | | | | | |

h2. Ports in Use

|| Service || Port || Protocol || Internal/External || Notes ||
| Telegram Alert | 5000 | TCP | External | API endpoint for alert sending |
| (add more ports) | | | | |

----

h1. Deployment Procedure
# Clone repository or pull Docker image.
# Update environment variables in \`.env\`.
# Run \`docker compose up -d\`.
# Check logs and health endpoints.

----

h1. Backup & Recovery
* *Backup schedule and location:* (fill in)
* *Disaster recovery steps:* (fill in)

----

h1. Maintenance & Troubleshooting
* *Common issues and fixes:* (fill in)
* *Logs location and how to tail logs:* /var/log
* *Contact person / escalation path:* (fill in)

----

h1. Change History
|| Date || Change Description || Author ||
| $(date +"%Y-%m-%d") | Initial documentation | (fill in) |

EOF

echo "Server documentation generated in $OUTPUT_FILE"

