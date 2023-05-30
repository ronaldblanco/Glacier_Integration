#!/bin/bash

# get today's date

days="$4"
day="$3"
month="$2"
year="$1"

typeset -A months
months=( ['Jan']='01' ['Feb']='02' ['Mar']='03' ['Apr']='04' ['May']='05' ['Jun']='06' ['Jul']='07' ['Aug']='08' ['Sep']='09' ['Oct']='10' ['Nov']='11' ['Dec']='12' )

# check if argument is provided
if [ $# -eq 0 ]; then
  echo "Error: please provide an arguments, example 2021 01 01 30."
  exit 1
fi

echo "Operation starting from $year-$month-$day to $days days."
# first execution
./1_compress_files.sh $year $month $day

# perform operation based on argument
count=2
MONTH="$month"
DAY="$day"
YEAR="$year"
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
  ./1_compress_files.sh $YEAR $MONTH $DAY

  count=$((count+1))
done

echo "Operation ended from $year-$month-$day to $YEAR-$MONTH-$DAY."
