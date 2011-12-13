// The current active URL
currentUrl = "";

var changeCurrentUrl = function(tab) {
  if (tab == undefined)
    return;

  console.log(tab.url);
};

chrome.tabs.onSelectionChanged.addListener(function(tabId, selectInfo) {
  chrome.tabs.get(tabId, function(tab) {
    changeCurrentUrl(tab);
  });
});

chrome.windows.onFocusChanged.addListener(function(windowId) {
  if (windowId < 0) {
    console.log("Chrome got hidden");
    return;
  }

  chrome.tabs.getSelected(windowId, function(tab) {
    changeCurrentUrl(tab);
  });
});

chrome.tabs.onUpdated.addListener(function(tabId, changeInfo, tab) {
  chrome.tabs.getSelected(tab.windowId, function(currentTab) {
    if (currentTab.id == tabId && currentTab.status == "complete") {
      changeCurrentUrl(tab);
    }
  });
});
