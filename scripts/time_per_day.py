import timesuck
from datetime import timedelta

log_entries = timesuck.load_logs()

days = dict()

# Figure out which days are supported
for entry in [le for le in log_entries if le.type == "system"]:
    for day, length in timesuck.split_daterange(entry.start, entry.stop):
        if day not in days:
            days[day] = timedelta()
        days[day] += length



# Figure out which days are supported
apps = {}
for entry in [le for le in log_entries if le.type == "application"]:
    for day, length in timesuck.split_daterange(entry.start, entry.stop):
        if entry.name not in apps:
            apps[entry.name] = timedelta()
        apps[entry.name] += length

print "System Use"
for day, length in sorted(days.iteritems()):
    print "{}\t{}".format(day, length)

for application, length in sorted(apps.iteritems()):
    print "{}\t{}".format(application, length)
