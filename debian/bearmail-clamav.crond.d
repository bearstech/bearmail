#
# Regular cron jobs for the bearmail-clamav package
#
0 4 * * *  root  find /var/spool/clamsmtp -type f -name 'virus.*' -and -mtime +30 -exec rm {} \;