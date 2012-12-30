
/* DB */
var db = null;

var onerror = function(e) {
  console.log(e.value);
}

var init = function() {
  var request = indexedDB.open("timesuck", 2);

  request.onsuccess = function(e) {
    console.log('Opened Database');
    db = request.result;
  }

  request.onupgradeneeded = function (e) {
    e.currentTarget.result.createObjectStore("visit", {keyPath: "id", autoIncrement: true});
  };

  request.onerror = onerror;
}()

times = [];

var flush = function() {
  for(var i = times.length - 1; i >= 0; i--) {
    var entry = times.shift();

    var parser = document.createElement('a');
    parser.href = entry.url

    if (parser.protocol.search('chrome') >= 0) {
      continue;
    }

    if (db == null) {
      continue;
    }

    var trans = db.transaction(["visit"], "readwrite");
    var store = trans.objectStore("visit");
  
    var now = new Date();

    var request = store.add({
      "url": entry.url,
      "duration": now - entry.date,
      "timestamp" : now.getTime()
    });

    request.onerror = onerror;
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
