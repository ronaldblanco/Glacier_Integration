import subprocess
import argparse
import sqlite3
from datetime import date
import json

# Define the command-line arguments
parser = argparse.ArgumentParser(description='Script to upload file to Glacier')
#parser.add_argument('database', help='the name of the SQLite database file')
parser.add_argument('--file', '-f', help='File to upload to Glacier')
parser.add_argument('--description', '-d', help='Description of the file to upload to Glacier')
args = parser.parse_args()

# the command to execute
#command = "ls -l"+" "+args.file
command = "aws glacier upload-archive --account-id=96 --vault-name=Production --body="+args.file+" --archive-description="+args.description
#command = "hostname"

# execute the command and capture the output
# output = subprocess.check_output(command, shell=True)

# print the output
try:
    output = subprocess.check_output(command, shell=True)
    #print(output.decode())
    resultData = json.loads(output.decode())
    #resultData = json.loads('{"location": "/969165847182/vaults/Production_PBX_Share_glacier/archives/voUWPugEgTQrhIG1aVOE5UoFZnT746Lt2wyqQK4nQ41PqKFvm6UKn9T40ICP-3pk0IWvXrNjtNnmYd0inVncr4ruix1Qa2raIj50rn6gxhSTduMWaVUoDxYf1rbr1led2M-i6nWqhg","checksum": "c5c9241274bee45e7e60d8b247a15bd5f69bf821b813215194156fd60fc4afc9","archiveId": "voUWPugEgTQrhIG1aVOE5UoFZnT746Lt2wyqQK4nQ41PqKFvm6UKn9T40ICP-3pk0IWvXrNjtNnmYd0inVncr4ruix1Qa2raIj50rn6gxhSTduMWaVUoDxYf1rbr1led2M-i6nWqhg"}')
    today = date.today()
except subprocess.CalledProcessError as e:
    print("Command failed with exit code", e.returncode)

# Connect to the database
conn = sqlite3.connect("glacierdb_data.sqlite")
c = conn.cursor()

# Check if the table exists
#c.execute("SELECT file FROM glacier_data limit 1;")
#table_exists = c.fetchone() is not None

# Print the result
#if table_exists:
#    print('The table exists!')
#else:
#    print('The table does not exist.')
    # Create a new table
#    c.execute('''CREATE TABLE glacier_data
#             (id INTEGER PRIMARY KEY,
#              file VARCHAR(300),
#              archiveId VARCHAR(300),
#	       location VARCHAR(300),
#	       checksum VARCHAR(300),
#              date DATE,
#              description TEXT);''')

# Execute a query if provided
if resultData:
    #print(resultData["archiveId"])
    # Insert a new row of data
    c.execute("INSERT INTO glacier_data (file, archiveId, location, checksum, description, date) VALUES (?, ?, ?, ?, ?, ?)",
          (args.file, resultData["archiveId"], resultData["location"], resultData["checksum"], args.description, today))
    # Commit the changes and close the connection
    conn.commit()
    #result = c.fetchall()
    #print(result)

# Close the database connection
conn.close()

# Open a file in append mode
with open("glacier_upload_log.log", "a") as f:
    # Write some text to the end of the file
    f.write(today.strftime("%Y-%m-%d")+' Process Completed for '+args.file +' -> '+args.description+' upload to Glacier archiveId: '+resultData["archiveId"]+".\n")
print(today.strftime("%Y-%m-%d")+' Process Completed for '+args.file +' -> '+args.description+' upload to Glacier archiveId: '+resultData["archiveId"]+'!')
