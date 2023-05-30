import subprocess
import argparse
import sqlite3
from datetime import date
import json
import boto3 #python3

# Define the command-line arguments
parser = argparse.ArgumentParser(description='Script to check the all job status')
#parser.add_argument('database', help='the name of the SQLite database file')
parser.add_argument('--completed', '-c', help='Completed state of the job, true or false')
#parser.add_argument('--description', '-d', help='Description of the file to download to Glacier')
#parser.add_argument('--tier', '-t', help='Tier type for the download job, options are Expedited or Standard')
args = parser.parse_args()

# Create a Glacier client
glacier = boto3.client('glacier')
# Initiate a Job
response = glacier.list_jobs(
    vaultName='Production',
    accountId='9',
    completed=args.completed
    
)

#print('JobId '+args.job +' have status code: '+response["StatusCode"]+'!')
print(response['JobList'])
