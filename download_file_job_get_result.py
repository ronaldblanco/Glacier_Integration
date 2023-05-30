import subprocess
import argparse
import sqlite3
from datetime import date
import json
import boto3 #python3
import os

# Define the command-line arguments
parser = argparse.ArgumentParser(description='Get the file once a job it is completed')
#parser.add_argument('database', help='the name of the SQLite database file')
parser.add_argument('--job', '-j', help='Glacier job id')
parser.add_argument('--saveto', '-s', help='Location to save the file')
#parser.add_argument('--description', '-d', help='Description of the file to download to Glacier')
#parser.add_argument('--tier', '-t', help='Tier type for the download job, options are Expedited or Standard')
args = parser.parse_args()

# Create a Glacier client
glacier = boto3.client('glacier')
# Initiate a Job
response = glacier.get_job_output(
    vaultName='Production',
    accountId='9',
    jobId=args.job
   # arg.saveto
)

# The response contains the job output in bytes
job_output = response['body'].read()

# FinalFile
file_path = args.saveto+response["archiveDescription"]
# Check if the file exists before deleting it
if os.path.exists(file_path):
    os.remove(file_path)
    #print(f'The existing file {file_path} has been deleted before\n')
#else:
    #print(f'The file {file_path} does not exist')

# Write the job output to a file
with open(file_path, 'wb') as f:
    f.write(job_output)

print('JobId ' + args.job + ' have status code: '+str(response["status"])+' when saving file to '+args.saveto+response["archiveDescription"]+'!\n')
