#!/bin/sh

MAIL_TO=mailto@email.com
MAIL_TO_FAILURE=failure@email.com
SUBJECT="[TIMELAPSE]"
SNAPSHOT_PATH=/path/to/Timelapse
MESSAGE_BODY="This is the last snapshot from Timelapse. You can download the timelapse video anytime in the next 14 days (but link expires after first download!)  from the link below:"
#username and password when direct link is provided for BASIC AUTH
HTTP_USERNAME=username
HTTP_PASSWORD=password
#Message to provide when video upload failed and direct link from server is provided
MESSAGE_BODY_NO_VIDEO_UPLOAD="This is the last snapshot from Timelapse.  You can download the timelapse video from the link below: https://$HTTP_USERNAME:$HTTP_PASSWORD@www.barney.ro/Hdd/500gb/Movies/Timelapse/"
MESSAGE_BODY_VIDEO_FOLDER_LINK="Timelapse videos can be downloaded from here: https://$HTTP_USERNAME:$HTTP_PASSWORD@www.barney.ro/Hdd/500gb/Movies/Timelapse "
#url of the file upload service
URL="https://file.io"
#how long shall the link be available
DEFAULT_EXPIRE="14d" 
#do not modify below!!!!!

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
VIDEO_FILE_PATH=$(find $SNAPSHOT_PATH -name "*avi" -type f -exec stat -c '%Y %n' {} \; | sort -nr | awk 'NR==1,NR==1 {print $2}')
if [ ! -f "$VIDEO_FILE_PATH" ]; then

    exit
fi
VIDEO_FILE_NAME=$(basename -- "$VIDEO_FILE_PATH")
EXPIRE=${2:-$DEFAULT_EXPIRE}
#VIDEO_FILE_PATH=/mnt/500gb/Movies/Timelapse/test.txt
RESPONSE=$(curl -# -F "file=@${VIDEO_FILE_PATH}" "${URL}/?expires=${EXPIRE}")
# Response looks like this: {"success":true,"key":"EhzvHTCg","link":"https://file.io/EhzvHTCg","expiry":"14 days"}
PATTERN="success"
if [ -z "${RESPONSE##*$PATTERN*}" ] ;then  #upload was successful
    #trim heading
    RESPONSE=${RESPONSE#*\"link\":}
    #trim tail
    RESPONSE=${RESPONSE%%,\"expiry\"*}
    echo $MESSAGE_BODY $RESPONSE $MESSAGE_BODY_VIDEO_FOLDER_LINK | mail -s $SUBJECT  $MAIL_TO $MAIL_TO_FAILURE -A "$SNAPSHOT_PATH/lastsnap.jpg"
else
    echo "Timelapse error. Video file could not be uploaded. Website returned" $RESPONSE  | mail -s $SUBJECT  $MAIL_TO_FAILURE
    echo $MESSAGE_BODY_NO_VIDEO_UPLOAD$VIDEO_FILE_NAME $MESSAGE_BODY_VIDEO_FOLDER_LINK | mail -s $SUBJECT  $MAIL_TO $MAIL_TO_FAILURE -A "$SNAPSHOT_PATH/lastsnap.jpg"
fi


