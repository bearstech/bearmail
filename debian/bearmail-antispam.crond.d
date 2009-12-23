#
# Regular cron jobs for the bearmail-antispam package
#
35  1   1 * *  root  /usr/sbin/bearmail-dspam_cleaner -c
55  */3 * * *  root  /usr/sbin/bearmail-dspam_cleaner -dck
15  4   1 * *  root  find /var/spool/dspam/data -type f -name '*.sig' -and -mtime +30 -exec rm {} \;
