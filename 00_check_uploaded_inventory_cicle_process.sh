#!/bin/bash

# get today's date
todayBase=$(date +"%Y-%m-%d")
rightMonth=$(date -d "$todayBase - 6 months" +"%Y-%b-%d")
#TODAY=$(date +"%Y-%b-%d")
TODAY=$rightMonth
days="31"
day="01"
month="$2"
year="$1"

#echo $TODAY

typeset -A months
months=( ['Jan']='01' ['Feb']='02' ['Mar']='03' ['Apr']='04' ['May']='05' ['Jun']='06' ['Jul']='07' ['Aug']='08' ['Sep']='09' ['Oct']='10' ['Nov']='11' ['Dec']='12' )

# check if argument is provided
if [ $# -eq 0 ]; then
  #echo "Error: please provide an arguments, example 2021 Jan."
  #exit 1
  # extract year and month
  YEAR=$(echo $TODAY | cut -d'-' -f1)
  MONTH=$(echo $TODAY | cut -d'-' -f2)
  #DAY=$(echo $nextDate | cut -d'-' -f3)
  month="$MONTH"
  year="$YEAR"
fi

echo "Operation starting from $year-$month-01 for the month."
existOnDB=$(sqlite3 glacierdb_data.sqlite "select substr(description, -18, 11) from glacier_data where description like '%$year-$month-%' group by substr(description, -18, 11) order by id DESC limit 100;")
existOnDBStr=$(echo $existOnDB)
existOnDB=$existOnDBStr

#Check if date exist in Glacier
if echo "$existOnDB" | grep -q "$year-$month-01"; then
  echo "Date '$year-$month-01' found in Glacier, nothing to do!"
else
  echo "Date '$year-$month-01' not found in Glacier; we will run 1_compress_files.sh $year $month 01!"
  # first execution
  #./1_compress_files.sh $year $month $day
fi

# perform operation based on argument
count=2
if [ -z "$MONTH" ]; then
  MONTH="$month"
fi
if [ -z "$YEAR" ]; then
  YEAR="$year"
fi
DAY="$day"

#echo "$YEAR-${months[$MONTH]}-$DAY"
while [ $count -le $days ]
do
  #echo "Count is $count"

  # calculate next day
  #getValidDate=$(date -d "$year-$month-$day" +"%Y-%m-%d")
  #echo $getValidDate
  nextDate=$(date -d "$YEAR-${months[$MONTH]}-$DAY + 1 day" +"%Y-%b-%d")
  echo "The next day to run will be $nextDate"

  # extract year and month
  YEAR=$(echo $nextDate | cut -d'-' -f1)
  MONTH=$(echo $nextDate | cut -d'-' -f2)
  DAY=$(echo $nextDate | cut -d'-' -f3)
 
  #Check if date exist in Glacier
  if [ "$MONTH" = "$month" ] && echo "$existOnDB" | grep -q "$nextDate"; then
    echo "Date '$nextDate' found in Glacier, nothing to do!"
  elif [ "$MONTH" = "$month" ] && ! echo "$existOnDB" | grep -q "$nextDate"; then
    echo "Date '$nextDate' not found in Glacier; we will run 1_compress_files.sh $YEAR $MONTH $DAY!"
    #./1_compress_files.sh $YEAR $MONTH $DAY
  else
    echo "Date '$nextDate' it is out of the month scope, nothing to do!"
  fi
	
  count=$((count+1))
done

echo "Operations done, all necesary days missing on Glacier were uploaded!"
