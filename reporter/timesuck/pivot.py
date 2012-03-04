import argparse
import os
import sqlite3
import calendar
from datetime import datetime, timedelta, time, date

parser = argparse.ArgumentParser(description="Timesuck migration tool")
parser.add_argument("olddb", type=str, help="Path to old timesuck database")
parser.add_argument("newdb", type=str, help="Path to current new database")
args = parser.parse_args()

connection = sqlite3.connect(os.path.expanduser(args.olddb))
cursor = connection.cursor()

current_db = sqlite3.connect(os.path.expanduser(args.newdb))
current_cursor = current_db.cursor()

for entry in cursor.execute("SELECT * FROM logs"):
    kind, name, start, end, duration = entry
    start = datetime.strptime(start, "%Y-%m-%d %H:%M:%S")
    end = datetime.strptime(end, "%Y-%m-%d %H:%M:%S")
    start_ts = calendar.timegm(start.utctimetuple())
    end_ts = calendar.timegm(end.utctimetuple())
    current_cursor.execute("INSERT INTO logs VALUES (?,?,?,?,?)",
                          (kind, name, start_ts, end_ts, duration))

current_db.commit()

cursor.close()
current_cursor.close()

