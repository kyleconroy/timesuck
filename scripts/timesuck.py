import os
from collections import namedtuple
from datetime import datetime, timedelta, time

LogEntry = namedtuple('LogEntry', 'user type name event start stop length')

def split_daterange(start, stop):
    """Given two datetimess, return a list of (date, timedelta) tuples
    """
    startdate = start.date() 
    stopdate = stop.date()
    while startdate <= stopdate:
        tomorrow = datetime.combine(startdate + timedelta(days=1), time()) 
        if stop < tomorrow:
            yield (startdate, (stop - start))
        else:
            yield (startdate, (tomorrow - start))

        startdate += timedelta(days=1)
        start = tomorrow


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
