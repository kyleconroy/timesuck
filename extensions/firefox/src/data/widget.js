self.on("message", function(message) {
  var meter = document.getElementById("bar");

  if (message >= 100) {
    document.getElementById("meter").style.background = "#6b0101";
    meter.style.background = "red";
    meter.style.width = Math.min(message - 100, 100) + "%";
  } else {
    meter.style.width = message + "%";
  }

  console.log(message);
});

