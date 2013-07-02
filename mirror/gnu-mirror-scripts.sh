# mirror scripts #
#!/bin/bash
 
# Variables
RSYNC=`which rsync`
RSYNC_HOST="mirrors.ibiblio.org"
RSYNC_DIRECTORY="gnuftp/gnu"
RSYNC_OPTIONS="-avrltpHS --delete-excluded"
 
LOCKFILE="/tmp/gnu_lockfile"
MIRROR_PATH="/mirror/gnu"
 
# Start
host $RSYNC_HOST > /dev/null
hres=$?
if [ $hres -ne 0 ]; then
        echo "gnu mirror - host $RSYNC_HOST resolution failed" >/dev/stderr
        exit 1
fi
 
if [ -e $LOCKFILE ]; then
        echo "gnu mirror - Lockfile $LOCKFILE exists" >/dev/stderr
        exit 1
fi
 
# Lock file
touch $LOCKFILE
 
# Synchronization
$RSYNC $RSYNC_OPTIONS rsync://$RSYNC_HOST/$RSYNC_DIRECTORY/ $MIRROR_PATH
 
# Lock file delete
rm $LOCKFILE
 
# End
