import argparse
import os
import sqlite3
from datetime import datetime, timedelta, time, date

parser = argparse.ArgumentParser(description="Timesuck migration tool")
parser.add_argument("--database", type=str, help="Path to timesuck database",
                    default="~/Library/Application Support/timesuck/database.db")
parser.add_argument("--logs", type=str, help="Path to timesuck Logs directory", 
                    default="~/Library/Application Support/timesuck/Logs")
args = parser.parse_args()

connection = sqlite3.connect(os.path.expanduser(args.database),
            detect_types=sqlite3.PARSE_DECLTYPES|sqlite3.PARSE_COLNAMES)
cursor = connection.cursor()

for log in os.listdir(os.path.expanduser(args.logs)):
    log_file = os.path.expanduser(os.path.join(args.logs, log))
    for line in open(log_file):
        line = [l.strip() for l in line.split("\t")]
        _, type, name, _, start, end, duration = line
        if name == "osx":
            name = "OS X"
        cursor.execute("INSERT INTO logs VALUES (?,?,?,?,?)",
                       (type, name, start, end, int(duration)))
connection.commit()

cursor.close()

