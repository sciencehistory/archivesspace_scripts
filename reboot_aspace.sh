/opt/archivesspace/archivesspace.sh restart
find /tmp -maxdepth 1  -type d -mtime +20 | grep jetty.*war | awk '{print "rm -rf "$1 }'| bash

