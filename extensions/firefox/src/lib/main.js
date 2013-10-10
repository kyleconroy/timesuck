var windows = require("sdk/windows").browserWindows;
var tabs = require("sdk/tabs");
var simple = require("sdk/simple-storage");
var timers = require("sdk/timers");
var myself = require("sdk/self");
var tabs = require("sdk/tabs");
var widget = require("sdk/widget");

// Hooray race conditions
var hasFocus = true;

var incr = function(key) {
  var value = simple.storage[key] || 0;
  simple.storage[key] = value + 1;
}

var track = function() {
  if (!hasFocus || windows.activeWindow === null) {
    return;
  }

  var tab = windows.activeWindow.tabs.activeTab;

  if (tab === null) {
    return;
  }

  now = new Date();

  var year = "default:" + now.getUTCFullYear();
  var month = year + ":" + now.getUTCMonth();
  var day = month + ":" + now.getUTCDate();
  var hour = day + ":" + now.getUTCHours();

  incr(month);
  incr(day);
  incr(hour);
}

// add a listener to the 'activate' event
windows.on('activate', function(window) {
  hasFocus = true;
});

windows.on('open', function(window) {
  hasFocus = true;
});
  
// add a listener to the 'deactivate' event
windows.on('deactivate', function(window) {
  hasFocus = false;
});

timers.setInterval(track, 1001);

/*
*/

widget.Widget({
  id: "timesuck-link",
  label: "Timesuck report",
  contentURL: myself.data.url("icon.png"),
  onClick: function() {
    tabs.open({
      url: myself.data.url("index.html"),
      onReady: function(tab) {
        var worker = tab.attach({
          contentScriptFile: [myself.data.url("js/jquery-2.0.3.min.js"),
                              myself.data.url("js/jquery.flot.min.js"),
                              myself.data.url("js/timesuck.js")]
        });

        worker.port.on("getbucket", function getBucket(payload) {
          worker.port.emit("gotbucket", {
            y: simple.storage[payload.key] || 0,
            x: payload.x
          });
        });
      }
    });
  }
});
