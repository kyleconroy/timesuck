// The current active URL
times = [];

var flush = function() {
  for(var i = times.length - 1; i >= 0; i--) {
    var entry = times.shift();

    var parser = document.createElement('a');
    parser.href = entry.url

    if (parser.protocol.search('chrome') >= 0) {
      continue;
    }

    var interval = new Date() - entry.date;
    console.log(interval + " " + entry.url);
  }
}

var track = function(tab) {
  flush();

  times.push({
    url: tab.url,
    date: new Date()
  });
};

chrome.tabs.onSelectionChanged.addListener(function(tabId, selectInfo) {
  chrome.tabs.get(tabId, function(tab) {
    track(tab);
  });
});

chrome.windows.onFocusChanged.addListener(function(windowId) {
  if (windowId == chrome.windows.WINDOW_ID_NONE || windowId < 0) {
    flush();
    return;
  }

  chrome.tabs.getSelected(windowId, function(tab) {
    track(tab);
  });
});

chrome.tabs.onUpdated.addListener(function(tabId, changeInfo, tab) {
  chrome.tabs.getSelected(tab.windowId, function(currentTab) {
    if (currentTab.id == tabId && currentTab.status == "complete") {
      track(tab);
    }
  });
});
