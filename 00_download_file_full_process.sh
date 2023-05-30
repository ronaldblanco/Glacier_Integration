#!/bin/bash

# check if argument is provided
if [ $# -eq 0 ]; then
  echo "Error: please provide an argument for file, saveto location and retreival type, example: test/archive/2021-Jan-04 /home/admin/ Standard"
  exit 1
fi

tier="$3"
saveTo="$2"
file="$1"

resultJobId=$(python3 download_file_job.py --file $file --description $file --tier $tier)
#resultJobId="rE3dYClRVF1eBWeDfTTLefiyiePXIqBVYLtlsntDHQF6Hd1ElZnpTkyop2HYWrc9ATqy2eN_AUbfsD1T61Dv-P-POx3_"

# Wait for a variable to be set
while [ -z "$VAR" ]
do
    resultJobIdStatus=$(python3 download_file_job_check.py --job $resultJobId)
    # Use an if statement to compare the values of the variables
    if [ $resultJobIdStatus = "Succeeded" ]; then
    	#echo "The fruits are the same."
	VAR=1
	echo $resultJobIdStatus" for jobId: "$resultJobId" file ready to be retreived!"
    else
    	#echo "The fruits are different."
	echo $resultJobIdStatus" for jobId: "$resultJobId" waiting 1 minute!"
    fi
    #echo "Waiting for VAR to be set..."
    #echo $resultJobIdStatus " for jobId: "$resultJobId" waiting 1 minute!"
    sleep 60
done

resultJobIdStatus=$(python3 download_file_job_get_result.py --job $resultJobId --saveto $saveTo)
echo $resultJobIdStatus
