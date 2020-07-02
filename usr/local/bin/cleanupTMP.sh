#!/bin/sh
# Clean file and dirs more than 3 days old in /tmp nightly

/usr/bin/find /tmp -type f -atime +2 -mtime +2  |xargs  /bin/rm -f &&

/usr/bin/find /tmp -type d -mtime +2 -exec /bin/rm -rf '{}' \; &&

/usr/bin/find /tmp -type l -ctime +2 |xargs /bin/rm -f &&

/usr/bin/find -L /tmp -mtime +2 -print -exec rm -f {} \; 

#Clean log files
/bin/rm /tmp/*.log
/bin/rm /tmp/*.out
