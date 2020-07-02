#!/bin/sh
MAIL_TO=sample@gmail.com
MAIL_TO_FAILURE=sample_failure@gmail.com
SUBJECT="[TIMELAPSE]"
SNAPSHOT_PATH=/mnt/500gb/Movies/Timelapse
MESSAGE_BODY="This is the last snapshot from Timelapse"

#do not modify below

if grep -qs '/mnt/500gb' /proc/mounts; then
    echo "Drive is mounted."
else
    echo "Drive not mounted. Mounting drive"
    mount /mnt/500gb
    if [ $? -eq 0 ]; then
       echo "Mount success!"
       systemctl restart motion
       sleep 5
    else

       systemctl stop motion
    exit
    fi
fi 

if [ ! -f "$SNAPSHOT_PATH/lastsnap.jpg" ]; then
    echo "Timelapse error. Snapshot files doesn't exist." | mail -s $SUBJECT  $MAIL_TO_FAILURE
    exit
fi

if [ ! -f "$VIDEO_FILE" ]; then
    echo "Timelapse error. Video file  doesn't exist." | mail -s $SUBJECT  $MAIL_TO_FAILURE
    exit
fi

VIDEO_FILE=$(find $SNAPSHOT_PATH -name "*avi" -type f -exec stat -c '%Y %n' {} \; | sort -nr | awk 'NR==1,NR==1 {print $2}')
echo $MESSAGE_BODY | mail -s $SUBJECT  $MAIL_TO $MAIL_TO_FAILURE -A "$SNAPSHOT_PATH/lastsnap.jpg" -A $VIDEO_FILE
