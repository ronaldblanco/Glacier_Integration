import subprocess
import argparse
import sqlite3
from datetime import date
import json
import boto3 #python3

# Define the command-line arguments
parser = argparse.ArgumentParser(description='Script to upload file to Glacier')
#parser.add_argument('database', help='the name of the SQLite database file')
parser.add_argument('--file', '-f', help='File to download to Glacier')
parser.add_argument('--description', '-d', help='Description of the file to download to Glacier')
parser.add_argument('--tier', '-t', help='Tier type for the download job, options are Expedited or Standard')
args = parser.parse_args()

# Connect to the database
conn = sqlite3.connect("glacierdb_data.sqlite")
c = conn.cursor()
# Insert a new row of data
c.execute("SELECT * FROM glacier_data where file='"+args.file+"' or  file like '%"+args.file+"%' or description = '"+args.description+"' limit 1;")
# Fetch all the rows from the result set
rows = c.fetchall()

fileToDownload=[]
# Process the rows
for row in rows:
    #print(row)
    fileToDownload=row

# Close the database connection
c.close()
conn.close()

#print(fileToDownload[2])

# Create a Glacier client
glacier = boto3.client('glacier')
# Initiate a Job
response = glacier.initiate_job(
    vaultName='Production',
    accountId='9',
    jobParameters={"Type": "archive-retrieval","ArchiveId": fileToDownload[2],"Description": "My job to download "+fileToDownload[1],"Tier": args.tier}
)

today = date.today()
# Open a file in append mode
with open("glacier_download_log.log", "a") as f:
    # Write some text to the end of the file
    f.write(today.strftime("%Y-%m-%d")+' Process Completed for '+args.file +' -> '+args.description+' download job from Glacier jobId: '+response["jobId"]+".\n")
#print(today.strftime("%Y-%m-%d")+' Process Completed for '+args.file +' -> '+args.description+' download job to Glacier jobId: '+response["jobId"]+'!')
print(response["jobId"])
