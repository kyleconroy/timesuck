var currentUrl = null;
var startTime = null

function startHandler(event){
  startTime = new Date();
  tab = event.target.activeTab || event.target;
  currentUrl = tab.url;
}

function stopHandler(event){
  endTime = new Date();
  tab = event.target.activeTab || event.target;
  if (tab.url && tab.url == currentUrl) {
    console.log("I visited " + currentUrl + " for " + (endTime - startTime) + " milliseconds");
  }
}
 
safari.application.addEventListener("activate", startHandler, true);
safari.application.addEventListener("deactivate", stopHandler, true);
