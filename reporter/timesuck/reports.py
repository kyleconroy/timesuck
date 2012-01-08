import argparse
import timesuck
from collections import namedtuple
from datetime import date, datetime, timedelta, time


class Report(object):
 
    def __init__(self, ranges, db, type=None, minlength=None):
        """db is sqlite3 db connection"""
        self.db = db
        self.type = type
        self.ranges = ranges
        self.minlength = minlength

    def results(self, start, end):
        query = ('SELECT type, name, start as "[timestamp]",'
                 'end as "[timestamp]", duration FROM logs')

        result = {
            "website": {},
            "application": {},
            "system": {},
            }

        if self.type:
            self.db.execute(query + (' WHERE type=? AND start >= ? AND '
                                     'end <= ? ORDER BY start'),
                            (self.type, start, end))
        else:
            self.db.execute(query + ' WHERE start >= ? AND end <= ? ORDER BY start',
                            (start, end))

        for ltype, name, start, end, length in self.db:
            container = result[ltype]
            container[name] = container.get(name, 0) + length

        for (ltype, kinds) in result.iteritems(): 
            result[ltype] = sorted(kinds.items(), key=lambda x: x[1], reverse=True)

        return result

    def entries(self):
        return [(start, end, self.results(start, end)) for start, end in self.ranges]

    def show(self):
        for (start_date, end_date, results) in self.entries():
            print
            print "Logs on {} - {}".format(start_date, end_date)
            print "=" * 50
            print
            for (ltype, kinds) in results.iteritems():

                if self.type and self.type != ltype:
                    continue

                if not kinds:
                    continue

                print ltype.title()
                print "=" * 50 

                for (name, duration) in kinds:
                    if "Shockwave Flash" in name:
                        continue

                    if duration < self.minlength * 60:
                        continue

                    print "{:30} {}".format(name, timedelta(seconds=duration))

                print


class ColumnReport(Report):

    def show(self):
        entries = self.entries()
        rows = {
            "application": {},
            "website": {},
            "system": {}, 
        }

        for (start_date, end_date, results) in entries:
            for (ltype, kinds) in results.iteritems():
                if self.type and self.type != ltype:
                    continue
                for (name, duration) in kinds:
                    if "Shockwave Flash" in name:
                        continue
                    if name not in rows[ltype]:
                        rows[ltype][name] = {}

                    if duration < self.minlength * 60:
                        continue

                    rows[ltype][name][start_date] = timedelta(seconds=duration)

        for (ltype, names) in rows.iteritems():
            if self.type and self.type != ltype:
                continue

            names = sorted(names.keys())

            print ''.join([n.ljust(30) for n in ["Date"] + names])

            for (start_date, end_date, _) in entries:
                results = []

                for name in names:
                    results.append(rows[ltype][name].get(start_date, timedelta(seconds=0)))

                row = [str(start_date)] + [str(x) for x in results]
                print ''.join([n.ljust(30) for n in row]) 


