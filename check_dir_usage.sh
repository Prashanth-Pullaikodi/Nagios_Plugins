#!/bin/bash
######
#Purpose:Calculate the user Home directory usage mounted on local Disk.
######
#Prashanth Pullaikodi
DIR="Mentioned the dir name here"
DU=/usr/bin/du
TAIL=/usr/bin/tail
AWK=/bin/awk
ADMIN_EMAIL="your_email_id"

USAGE() {
         echo "Usage $0 -f dir [-s m]"
         echo "eg. $0 -f /home -s m"
        }
#Clear the TMP file

folder1=$2
divisor=1
BC=/usr/bin/bc

#Clear the TMP file
foldername=`echo $folder1 |awk -F "/" '{print $2$3$4}'`

clear_file() {
                rm -rf $DIR/dir_usage_$foldername.txt
             }
clear_file

if [ "$#" == "0" ]; then
        USAGE
        exit 3
fi

#Check folder
FOLDER() {
        if [ -d "$folder1" ];then folder=$folder1 ;else
          echo "ERROR: Folder is invalid"
          exit 1
         fi
}

for i in `ls -lt $folder1 | grep "^d" | tr -s ' ' ' ' | cut -d' ' -f9`
 do
        MU(){
            case "$1" in
                [Mm])
                    divisor=1024
                    return
                    ;;
                [Gg])
                    divisor=1048576
                    return
                    ;;
                   *)
                    echo "Please use:m for Megabytes (MB) data"
                    exit 3
           esac
}


while (( $# )); do
case "$1" in
        --help)
        echo $USAGE
        exit 3
        ;;
        -h)
        echo $USAGE
        exit 3
        ;;
        -f)
         FOLDER "$2"
        ;;
        -s)
        MU $2
        ;;
        *)
        echo "$USAGE"
esac

shift
shift

done

owner=`stat -c "%U"  $folder1/$i`
RESULT_SIZE=`$DU -sk $folder1/$i|$TAIL -1|awk '{print $1}'`
OUT=$( echo "scale=2; $RESULT_SIZE / $divisor " |bc )
RESULT_TMP=`echo $OUT|awk -F. '{print $1}'`
echo "$folder1/$i  $RESULT_TMP $owner" >> $DIR/dir_usage_$foldername.txt

done


if [ -s "dir_usage_$foldername.txt" ] ; then
     echo " Script running fine" > /dev/null
  else
      mutt -s "Linse DiskUage Script not running on `hostname`" $ADMIN_EMAIL << EOF
        Hi

          Issue detected for script $0 on Linsee Host `hostname` .
          Please check.

          Br/Support Team
          EOF

fi
