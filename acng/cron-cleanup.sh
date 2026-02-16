#!/bin/bash
# Automated Apt-Cacher NG Expiration
# Logs results to /var/log/apt-cacher-ng/cleanup.log
# sudo crontab -e
# 0 2 * * 0 /usr/local/bin/cron-cleanup.sh

echo "Starting cleanup: $(date)" >> /var/log/apt-cacher-ng/cleanup.log

# This command tells acngtool to run the expiration task
# 'maint' is the command, and we provide the admin credentials if set
/usr/lib/apt-cacher-ng/acngtool maint -n > /dev/null

echo "Cleanup finished: $(date)" >> /var/log/apt-cacher-ng/cleanup.log
echo "--------------------------" >> /var/log/apt-cacher-ng/cleanup.log
