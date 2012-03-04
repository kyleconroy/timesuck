from flask import Flask, render_template, jsonify
import os
import sqlite3

TIMESUCK_DB = "~/Library/Application Support/timesuck/database.db"


app = Flask(__name__)

@app.route("/graph")
def graph():
    connection = sqlite3.connect(os.path.expanduser(TIMESUCK_DB))
    cursor = connection.cursor()
    query =  ("SELECT strftime('%s', date(start, 'unixepoch', 'localtime')), "
              " sum(duration) "
              "FROM logs WHERE start > strftime('%s', '2012-02-01') "
              "AND type != 'system' AND name != 'Google Chrome' "
              "GROUP BY date(start, 'unixepoch', 'localtime')")
    
    data = [{"x": float(x), "y": y / 3600} for (x,y) in cursor.execute(query)]
    
    return jsonify(data=data, name="Total Hours")

@app.route("/")
def index():
    return render_template("graph.html")

if __name__ == "__main__":
    app.run(debug=True)
