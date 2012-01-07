import argparse
import os
import sqlite3
from collections import namedtuple
from datetime import datetime, timedelta, time, date
from timesuck.reports import Report

LogEntry = namedtuple('LogEntry', 'user type name event start stop length')

def split_daterange(start, stop):
    """Given two datetimess, return a list of (date, timedelta) tuples
    """
    try:
        stopdate = stop.date()
    except AttributeError:
        stopdate = stop

    try:
        startdate = start.date()
    except AttributeError:
        startdate = start

    while startdate <= stopdate:
        tomorrow = datetime.combine(startdate + timedelta(days=1), time()) 
        if stop < tomorrow:
            yield (startdate, (stop - start))
        else:
            yield (startdate, (tomorrow - start))

        startdate += timedelta(days=1)
        start = tomorrow

def simpledate(value):
    return datetime.strptime(value, u"%Y-%m-%d")

def load_logs(log_dir="~/Library/Application Support/timesuck/Logs"):
    """Return a list of LogEntry objects
    """
    # Create SQLite tables
    log_dir = os.path.expanduser(log_dir)
    entries = []

    for path in os.listdir(log_dir):
        log_file = os.path.join(log_dir, path)

        for entry_line in open(log_file):
            # Break up the log entry into columns
            cols = entry_line.strip().split("\t")

            cols[4] = datetime.strptime(cols[4], "%Y-%m-%d %H:%M:%S")
            cols[5] = datetime.strptime(cols[5], "%Y-%m-%d %H:%M:%S")

            # Turn length into an int
            cols[6] = timedelta(seconds=int(cols[6]))

            entry = LogEntry(*cols)
            entries.append(entry)

    # Save all the entries
    return entries

def today():
    return str(date.today())

def tomorrow():
    return str(date.today() + timedelta(days=1))

def main():
    parser = argparse.ArgumentParser(description="Timesuck command line tool")
    parser.add_argument("-t", "--type", type=str, help="Type of log to see",
                        choices=["application", "website", "system"], default=None)
    parser.add_argument("-db", "--database", type=str, help="Path to timesuck database",
                        default="~/Library/Application Support/timesuck/database.db")
    parser.add_argument("-ml", "--minlength", type=int, default=2, 
                        help="Only show durations longer than N minutes")
    parser.add_argument("start", type=simpledate, default=today(), 
                        help="Generate a report for this day", nargs="?")
    parser.add_argument("end", type=simpledate, default=tomorrow(),
                        help="all the way to this day", nargs="?")
    args = parser.parse_args()


    connection = sqlite3.connect(os.path.expanduser(args.database),
                detect_types=sqlite3.PARSE_DECLTYPES|sqlite3.PARSE_COLNAMES)
    cursor = connection.cursor()

    report = Report(cursor, type=args.type, start=args.start, end=args.end,
                    minlength=args.minlength) 
    report.show()
    cursor.close()

