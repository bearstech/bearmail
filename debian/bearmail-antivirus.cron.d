# Regular cron jobs for the bearmail-antivirus package
#
0 4 * * *  root  find /var/spool/clamsmtp-bearmail -type f -name 'virus.*' -and -mtime +30 -exec rm {} \;
