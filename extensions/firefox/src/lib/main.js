var tabs = require("sdk/tabs");
var url = require("sdk/url");
var simple = require("sdk/simple-storage");
var tabs = require("sdk/tabs");
var myself = require("sdk/self");
var widget = require("sdk/widget");

var tick = function(amount) {
  now = new Date();

  // If it isn't 4AM yet, consider it part of the same day
  if (now.getHours() < 4) {
    now.setDate(now.getDate()-1);
  }

  // Normalize
  now.setHours(0);
  now.setMinutes(0);
  now.setSeconds(0, 0);

  var key = now.toISOString();

  console.log(key);

  var value = simple.storage[key] || 0;
  simple.storage[key] = value + amount;
  return simple.storage[key];
}

var sites = {
  'www.reddit.com': 2,
  'ssl.reddit.com': 2,
  'www.buzfeed.com': 5,
  'www.upworthy.com': 5,
  'imgur.com': 2,
  'i.imgur.com': 2,
  'youtube.com': 1,
  'facebook.com': 2,
  'new.ycombinator.com': 0.5,
}


var count = function(locat) {
  // Pick value here;
  var u = url.URL(locat);
  return tick(sites[u.hostname] || 0);
}

var bar = widget.Widget({
  id: "timesuck-link",
  label: "Timesuck report",
  width: 100,
  contentURL: myself.data.url("widget.html"),
  contentScriptWhen: "ready",
  contentScriptFile: myself.data.url('widget.js'),
  onAttach: function() {
    bar.postMessage(tick(0));
  }
});

// add a listener to the 'activate' event
tabs.on('load', function(tab) {
  bar.postMessage(count(tab.url));
});
