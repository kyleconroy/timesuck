# timesuck-tools

Anaylize your [Timesuck](https://www.github.com/derferman/Timesuck) logs with ease.

## Example: Hours spent on the computer per day

```python
import timesuck
from datetime import timedelta, datetime, time

log_entries = timesuck.load_logs()

days = {}

def time_per_day(start, stop):
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

# Figure out which days are supported
for entry in [le for le in log_entries if le.type == "system"]:
    for day, length in time_per_day(entry.start, entry.stop):
        if day not in days:
            days[day] = timedelta()
        days[day] += length

for day, length in sorted(days.iteritems()):
    print "{}\t{}".format(day, length)
```

```
>>> python usage_per_day.py
2011-08-31	11:42:27
2011-09-01	7:55:56
2011-09-02	9:31:02
2011-09-03	3:20:09
```

## Have a cool script?

Send me a pull request. I'd love to see some more advanced scripts.

