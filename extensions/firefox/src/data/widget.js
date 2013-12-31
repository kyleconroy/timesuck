self.on("message", function(message) {
  var meter = document.getElementById("bar");

  if (message >= 100) {
    document.getElementById("meter").className = "over";
    meter.style.width = Math.min(message - 100, 100) + "%";
  } else {
    document.getElementById("meter").className = "under";
    meter.style.width = message + "%";
  }

  console.log(message);
});

