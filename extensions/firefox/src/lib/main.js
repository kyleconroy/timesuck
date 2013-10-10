var pb = require("private-browsing");
var tabs = require("tabs");
var windows = require("windows");

var window = require("window-utils").activeWindow;

var times = {};

function track(tab) {
  if (times[tab] === undefined) {
    return;
  }

  var tracked = times[tab];
  delete times[tab];

  var interval = new Date() - tracked.date;
  console.log(interval + ' ' + tracked.url);
}

// Listen for tab content loads.
tabs.on('ready', function(tab) {
  if (pb.isActive) {
    return;
  }

  if (tabs.activeTab == tab) {
    track(tab);

    times[tab] = {
      url: tab.url,
      date: new Date()
    }
  }
});

tabs.on('activate', function(tab) {
  if (pb.isActive) {
    return;
  }

  times[tab] = {
    url: tab.url,
    date: new Date()
  }
});

tabs.on('deactivate', function(tab) {
  if (pb.isActive) {
    return;
  }

  track(tab);
});

windows.on('deactivate', function(window) {
  if (pb.isActive) {
    return;
  }

  track(tabs.activeTab);
});

windows.on('close', function(window) {
  if (pb.isActive) {
    return;
  }

  track(tabs.activeTab);
});

tabs.on('close', function(tab) {
  if (pb.isActive) {
    return;
  }

  track(tab);
});
