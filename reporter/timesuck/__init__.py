import argparse
import os
import sqlite3
from collections import namedtuple
from datetime import datetime, timedelta, time, date
from timesuck.reports import Report, ColumnReport

LogEntry = namedtuple('LogEntry', 'user type name event start stop length')

def split_daterange(start, stop, days=1):
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

    while startdate < stopdate:
        tomorrow = datetime.combine(startdate + timedelta(days=days), time()) 
        if stop < tomorrow:
            yield (startdate, stop)
        else:
            yield (startdate, tomorrow)

        startdate += timedelta(days=days)
        start = tomorrow

def simpledate(value):
    return datetime.strptime(value, u"%Y-%m-%d")

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
    parser.add_argument("--columns", action="store_true", default=False, 
                        help="Display the report in columns") 
    parser.add_argument("-d", "--delta", type=int, default=1, help="Delta size")
    parser.add_argument("--total", action="store_true", default=False, 
                        help="Show an aggregate for the given range")
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

    if args.total:
        ranges = [(args.start, args.end)]
    else:
        ranges = split_daterange(args.start, args.end, days=args.delta)

    report_class = Report

    if args.columns:
        report_class = ColumnReport

    report = report_class(ranges, cursor, type=args.type, minlength=args.minlength) 
    report.show()

    cursor.close()

