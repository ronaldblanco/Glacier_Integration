#!/bin/bash

#echo $1
# get today's date
#TODAY=$(date +"%Y-%m-%d")
#TODAY="$1"
#echo $TODAY
command1="1_compress_files.sh"
command2="2_upload_to_glacier_compressed_files.sh"
command3="3_delete_compress_files.sh"

declare -A months
months=( ['Jan']='01' ['Feb']='02' ['Mar']='03' ['Apr']='04' ['May']='05' ['Jun']='06' ['Jul']='07' ['Aug']='08' ['Sep']='09' ['Oct']='10' ['Nov']='11' ['Dec']='12' )

# calculate date 7 months ago
#MONTHS_AGO=$(date -d "$TODAY -7 months" +"%Y-%b-%d")
LAST_DATE_DB=$(sqlite3 glacierdb_data.sqlite "SELECT substr(description, -18, 11) as lastdate FROM glacier_data GROUP BY substr(description, -18, 11) ORDER BY id DESC LIMIT 1;")
LAST_DATE_DB_FIX=$(echo "$LAST_DATE_DB" | sed 's/Jan/01/g')
LAST_DATE_DB_FIX=$(echo "$LAST_DATE_DB_FIX" | sed 's/Feb/02/g')
LAST_DATE_DB_FIX=$(echo "$LAST_DATE_DB_FIX" | sed 's/Mar/03/g')
LAST_DATE_DB_FIX=$(echo "$LAST_DATE_DB_FIX" | sed 's/Apr/04/g')
LAST_DATE_DB_FIX=$(echo "$LAST_DATE_DB_FIX" | sed 's/May/05/g')
LAST_DATE_DB_FIX=$(echo "$LAST_DATE_DB_FIX" | sed 's/Jun/06/g')
LAST_DATE_DB_FIX=$(echo "$LAST_DATE_DB_FIX" | sed 's/Jul/07/g')
LAST_DATE_DB_FIX=$(echo "$LAST_DATE_DB_FIX" | sed 's/Aug/08/g')
LAST_DATE_DB_FIX=$(echo "$LAST_DATE_DB_FIX" | sed 's/Sep/09/g')
LAST_DATE_DB_FIX=$(echo "$LAST_DATE_DB_FIX" | sed 's/Oct/10/g')
LAST_DATE_DB_FIX=$(echo "$LAST_DATE_DB_FIX" | sed 's/Nov/11/g')
LAST_DATE_DB_FIX=$(echo "$LAST_DATE_DB_FIX" | sed 's/Dec/12/g')
NEXT_DATE_TO_PROCCESS=$(date -d "$LAST_DATE_DB_FIX + 1 day" +"%Y-%b-%d")
#echo $NEXT_DATE_TO_PROCCESS
#echo $MONTHS_AGO

# extract year and month
YEAR=$(echo $NEXT_DATE_TO_PROCCESS | cut -d'-' -f1)
MONTH=$(echo $NEXT_DATE_TO_PROCCESS | cut -d'-' -f2)
DAY=$(echo $NEXT_DATE_TO_PROCCESS | cut -d'-' -f3)

# check if argument is provided
if [ $# -eq 0 ]; then
  echo "Error: please provide an argument, 1 to compress, 2 to upload and 3 to delete compress file."
  exit 1
fi

# check if argument is between 1 and 3
if ! [ $1 -ge 1 -a $1 -le 3 ]; then
  echo "Error: argument must be between 1 and 3."
  exit 1
fi

# perform operation based on argument
case $1 in
  1)
    echo "Performing sh $command1 $YEAR $MONTH $DAY"
    #sh $command1 $YEAR $MONTH
    # add code for operation 1
    ;;
  2)
    echo "Performing sh $command2 $YEAR $MONTH $DAY"
    #sh $command2 $YEAR $MONTH
    # add code for operation 2
    ;;
  3)
    echo "Performing sh $command3 $YEAR $MONTH $DAY"
    #sh $command3 $YEAR $MONTH
    # add code for operation 3
    ;;
esac

echo "Operation $1 was finished for year $YEAR, month $MONTH, day $DAY."

