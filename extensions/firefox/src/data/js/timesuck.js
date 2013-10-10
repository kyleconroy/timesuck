var buckets = [];

var options = {
    xaxis: {
      show: true,
    }, 
    yaxis: {
      show: true,
      max: 60
    }
};


self.port.on("gotbucket", function(payload) {
  buckets.push([payload.x, payload.y / 60.0]);

  if (buckets.length == 24) {
    $("#graph").plot([{data: buckets, lines: { show: true, steps: true }}], options);
  }

});

var now = new Date();
now.setUTCSeconds(0);
now.setUTCMinutes(0);
now.setUTCMilliseconds(0);

for (var i = 0; i < 24; i++) {
  var year = "default:" + now.getUTCFullYear();
  var month = year + ":" + now.getUTCMonth();
  var day = month + ":" + now.getUTCDate();
  var key = day + ":" + now.getUTCHours();

  self.port.emit("getbucket", {
    x: 23 - i,
    key: key,
  });

  now.setUTCHours(now.getUTCHours() - 1);
}
