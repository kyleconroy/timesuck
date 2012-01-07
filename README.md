# Timesuck 

Are you spending too much time on the computer? Find out with Timesuck. 

Timesuck logs your
- computer usage
- application usage
- website usage (via browser extensions)

## Aren't there better solutions available?

Almost all existing solutions send data back to an external website (I'm looking at you RescueTime). 

Timesuck stores all data locally in a SQLite3 database. No data is every sent to 3rd party servers.

## How do I see my usage?

Install the included python command line tool

    cd reporter
    python setup.py install

Now with the tool installed

    timesuck

which will show you your usage report for the day, which will look something like this

    Logs from 2012-01-07 00:00:00 to 2012-01-08 00:00:00
    ==================================================

    Website
    ==================================================
    docs.python.org                0:05:43.204000
    nytimes.com                    0:03:19.091000
    sqlite.org                     0:03:12.852000
    google.com                     0:02:33.635000
    stackoverflow.com              0:02:30.842999

    Application
    ==================================================
    MacVim                         1:04:24.656839
    Google Chrome                  0:36:30.671043
    Terminal                       0:22:45.532895

    System
    ==================================================
    OS X                           1:53:07.929059

## Installation

[Download Timesuck.app here](http://dl.dropbox.com/u/40773/Timesuck.zip)

## Supported Platforms

Timesuck is currently only for OS X.
