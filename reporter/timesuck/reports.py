import argparse
import timesuck
from collections import namedtuple
from datetime import date, datetime, timedelta, time


class Report(object):
 
    def __init__(self, db, type=None, minlength=None, start=None, end=None):
        """db is sqlite3 db connection"""
        self.db = db
        self.type = type
        self.start = start
        self.end = end
        self.minlength = minlength

    def results(self):
        query = ('SELECT type, name, start as "[timestamp]",'
                 'end as "[timestamp]", duration FROM logs')

        result = {
            "website": {},
            "application": {},
            "system": {},
            }

        if self.type:
            self.db.execute(query + (' WHERE type=? OR start >= ? AND '
                                     'end <= ? ORDER BY start'),
                            (self.type, self.start, self.end))
        else:
            self.db.execute(query + ' WHERE start >= ? OR end <= ? ORDER BY start',
                            (self.start, self.end))

        for ltype, name, start, end, length in self.db:
            container = result[ltype]
            container[name] = container.get(name, 0) + length

        return result


    def show(self):
        print
        print "Logs from {} to {}".format(self.start, self.end)
        print "=" * 50
        print
        for (ltype, kinds) in self.results().iteritems():
            print ltype.title()
            print "=" * 50
            for (name, duration) in sorted(kinds.items(), key=lambda x: x[1], 
                                           reverse=True):
                if "Shockwave Flash" in name:
                    continue

                if duration < self.minlength * 60:
                    continue

                print "{:30} {}".format(name, timedelta(seconds=duration))

            print

