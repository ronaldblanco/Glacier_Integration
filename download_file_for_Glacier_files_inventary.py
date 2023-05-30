import subprocess
import argparse
import sqlite3
from datetime import date
import json
import boto3 #python3
import time
import sys
import os

description='Script to get Glacier inventory file need parameter. --saveto /home/admin/'
# Define the command-line arguments
parser = argparse.ArgumentParser(description=description)
#parser.add_argument('database', help='the name of the SQLite database file')
parser.add_argument('--saveto', '-s', help='Save file to. Example: /home/admin/')
#parser.add_argument('--description', '-d', help='Description of the file to download to Glacier')
#parser.add_argument('--tier', '-t', help='Tier type for the download job, options are Expedited or Standard')
args = parser.parse_args()

if len(sys.argv) == 0:
    # Script was called with parameters
    #print("Script called with parameters")
    # Do something with the parameters
    #print(f"Parameters: {sys.argv[1:]}")
#else:
    # Script was called without parameters
    print("Script called without parameters "+description)

vaultName='Production'
accountId='9'

# Create a Glacier client
glacier = boto3.client('glacier')
# Initiate a Job
response = glacier.initiate_job(
    vaultName=vaultName,
    accountId=accountId,
    jobParameters={"Type":"inventory-retrieval"}

)

#response = {"jobId":"C9dduTJAvRgigWmG7mbqQ2Sf9o2VY_rXIgUUJBhd4449BZOLj7dTrYUTdbBjWGLsf5LYeZZQIq68_mwsJAglideD5BSw"}
#response = {"jobId":"rE3dYClRVF1eBWeDfTTLefiyiePXIqBVYLtlsntDHQF6Hd1ElZnpTkyop2HYWrc9ATqy2eN_AUbfsD1T61Dv-P-POx3_"}

# Check job
responseCheck = glacier.describe_job(
    vaultName=vaultName,
    accountId=accountId,
    jobId=response['jobId']
)

while responseCheck["StatusCode"] == "InProgress":
    print(responseCheck["StatusCode"] + " for Job: "+response['jobId']+" waiting to try again.")
    # Sleep for 1 minute
    time.sleep(60)
    # ReCheck job
    responseCheck = glacier.describe_job(
    	vaultName=vaultName,
    	accountId=accountId,
    	jobId=response['jobId']
    )

print(responseCheck["StatusCode"] + " for Job: "+response['jobId']+" ready to retreive.")
# Run the script 'other_script.py' with the arguments and capture its output
#output = subprocess.check_output(["python3", "download_file_job_get_result.py --job "+response['jobId']+" --saveto "+args.saveto])
output = subprocess.check_output(["python3", "download_file_job_get_result.py","--job",response['jobId'],"--saveto",args.saveto])

# set the current working directory
#os.chdir('/path/to/your/files')
newName='retrieved_archive_inventory.txt'
# rename the file
os.rename(args.saveto+'retrieved_archive.tar.gz', args.saveto+newName)

# Print the output of the script
print(output.decode('utf-8')+"Finaly file was renamed to "+newName)
#print("JobId: "+response['jobId']+" ")

# Open file and read JSON data
with open(args.saveto+newName, 'r') as file:
    data = json.load(file)

# Connect to the database
conn = sqlite3.connect("glacierdb_file_inventory.sqlite")
c = conn.cursor()
# Connect to the database
c.execute("DELETE FROM glacier_file_inventory;")
# Commit the changes and close the connection
conn.commit()

for element in data['ArchiveList']:
    #print(element)
    # Connect to the database
    c.execute("INSERT INTO glacier_file_inventory (ArchiveId, ArchiveDescription, CreationDate, Size, SHA256TreeHash) VALUES (?, ?, ?, ?, ?)",
          (element["ArchiveId"], element["ArchiveDescription"], element["CreationDate"], element["Size"], element["SHA256TreeHash"]))
    # Commit the changes and close the connection
    conn.commit()

# Close the database connection
conn.close()

