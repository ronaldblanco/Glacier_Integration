#!/bin/bash

# set the folder you want to search for subfolders
folder="/mnt/efs-production/var-lib-freeswitch-recordings"
destinationFolder="/mnt/storage"
#folder="/home/admin/glacier_deep_archive_backup-main"

# check if argument is provided
if [ $# -eq 0 ]; then
  echo "Error: please provide an argument for year month and day, example: 2022 Jan 04."
  exit 1
fi

day="$3"
month="$2"
year="$1"

echo "Starting Cleanning $year-$month-$day!"

# use the find command to get all subfolders of the folder
#subfolders=$(find "$folder" -type d)
subfolders=$(ls -dR $folder/*)

# loop through the subfolders and perform an operation on each
for subfolder in $subfolders; do

        domain=$(echo $subfolder | cut -c 51-90)
        domainReady=$(echo $domain | tr . _)
        #echo $domainReady

	#echo "Entering $subfolder"
        # check if the folder exists
        if [ -d "$subfolder/archive/$year/$month/$day" ]; then
                echo "Executing -> rm $destinationFolder/$domainReady-$year-$month-$day.tar.gz"
                rm "$destinationFolder/$domainReady-$year-$month-$day.tar.gz"
        #else
                #echo "The folder $folder does not exist."
        fi

        #tar -czvf "$month.tar.gz" "$subfolder/$month"

        # perform your operation on $subfolder here

done

echo "All process ended for $year-$month-$day"