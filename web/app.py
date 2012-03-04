from flask import Flask, render_template, jsonify
import os
import sqlite3

TIMESUCK_DB = "~/Library/Application Support/timesuck/database.db"


app = Flask(__name__)

@app.route("/")
def index():
    return render_template("graph.html")

if __name__ == "__main__":
    app.run(debug=True)
