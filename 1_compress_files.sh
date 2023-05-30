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

echo "Starting Compression $year-$month-$day!"
# use the find command to get all subfolders of the folder
#subfolders=$(find "$folder" -type d)
subfolders=$(ls -dR $folder/*)

# loop through the subfolders and perform an operation on each
for subfolder in $subfolders; do

 	domain=$(echo $subfolder | cut -c 51-90)
	domainReady=$(echo $domain | tr . _)
	#echo $domainReady

	# check if the folder exists
 	if [ -d "$subfolder/archive/$year/$month/$day" ]; then
   		echo "Executing -> tar -czvf $destinationFolder/$domainReady-$year-$month-$day.tar.gz $subfolder/archive/$year/$month/$day"
   		tar -czvf "$destinationFolder/$domainReady-$year-$month-$day.tar.gz" "$subfolder/archive/$year/$month/$day"
 	fi
 done

# Run next script with the same argument
./2_upload_to_glacier_compressed_files.sh $year $month $day
