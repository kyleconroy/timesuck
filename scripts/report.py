import argparse
import timesuck
from datetime import date, datetime, timedelta, time

parser = argparse.ArgumentParser(description="Daily Timesuck report")
parser.add_argument("date", type=str, 
                    help=("Can be either 'today' or a date in the format "
                          "YYYY-MM-DD or YYYY-MM"))
args = parser.parse_args()


class Report(object):
 
    date_format = "%B %d, %Y"

    def scope(self):
        def day(dt):
            if not isinstance(dt, datetime): 
                dt = datetime.combine(dt, time()) 
            return dt.date()
        return day


class MonthlyReport(Report):

    date_format = "%B %Y"

    def scope(self):
        def month(dt):
            if not isinstance(dt, datetime):
                dt = datetime.combine(dt, time()) 
            return dt.date().month
        return month


class DailyReport(Report):
    pass

logs = timesuck.load_logs()

if args.date == "today":
    args.date = date.today().strftime("%Y-%m-%d")

try:
    args.date = datetime.strptime(args.date, "%Y-%m-%d").date()
    report = DailyReport()
except:
    args.date = datetime.strptime(args.date, "%Y-%m").date()
    report = MonthlyReport()

print
print "Computer usage for {}".format(args.date.strftime(report.date_format))
print "--------------------------------------"

scope = report.scope()

# Figure out which days are supported
def day_total(given, scope):
    total = timedelta()

    for entry in [le for le in logs if le.type == "system"]:
        if scope(given) in [scope(dt) for dt in [entry.start, entry.stop]]:
            for day, length in timesuck.split_daterange(entry.start, entry.stop):
                if scope(day) == scope(given):
                    total += length

    return total

print "Total:\t{}".format(day_total(args.date, scope))

# Ugly
if isinstance(report, MonthlyReport):
    print
    print "Day Breakdown"
    print "-------------"
    start = args.date
    oscope = DailyReport().scope()
    while start.month == args.date.month:
        total = day_total(start, oscope)
        if total:
            print "{1}\t{0}".format(total, start.strftime("%a %m-%d"))
        start += timedelta(days=1)

# Figure out which days are supported
apps = {}
for entry in [le for le in logs if le.type == "application"]:
    if scope(args.date) in [scope(dt) for dt in [entry.start, entry.stop]]:
        for day, length in timesuck.split_daterange(entry.start, entry.stop):
            if entry.name not in apps:
                apps[entry.name] = timedelta()
            if scope(day) == scope(args.date):
                apps[entry.name] += length

if len(apps):
    print 
    print "Application Breakdown"
    print "---------------------"
    minimum = timedelta(minutes=1)
    for application in sorted(apps, key=apps.get, reverse=True):
        length = apps[application] 
        if length > minimum:
            print "{}\t{}".format(length, application)

print



