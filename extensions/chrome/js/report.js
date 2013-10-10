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
    visits();
  }

  request.onerror = onerror;
}()


var visits = function() {
  if (db == null) {
    return;
  }

  var trans = db.transaction(["visit"], "readwrite");
  var store = trans.objectStore("visit");

  // Get everything in the store;
  var keyRange = IDBKeyRange.lowerBound(0);
  var request = store.openCursor(keyRange);

  var results = [];
  var startDate = new Date().getTime();

  request.onsuccess = function(e) {
    var result = e.target.result;

    if (!!result == false) {
      render(massage(results, startDate));
      return;
    }

    startDate = Math.min(startDate, result.value.timestamp);
    results.push(result.value);

    result.continue();
  };

  request.onerror = onerror;
}

function hours(timestamp) {
  return timestamp / 1000 / 60 / 60;
}

function massage(results, startDate) {
  var start = midnight(startDate);

  var evil = {};
  var ok = {};

  for (var i = 0; i < results.length; i++) {
    var result = results[i];
    var index = x(result, start);

    if (evil[index] === undefined) {
      evil[index] = 0;
    }
    
    if (ok[index] === undefined) {
      ok[index] = 0;
    }

    if (isEvil(result)) {
      evil[index] += result.duration;
    } else {
      ok[index] += result.duration;
    }
  }

  results = [[], []];

  for (var key in evil) {
    if (evil.hasOwnProperty(key)) {
      results[0].push({'x': parseInt(key), 'y': hours(evil[key])});
    }
  }

  for (var key in ok) {
    if (ok.hasOwnProperty(key)) {
      results[1].push({'x': parseInt(key), 'y': hours(ok[key])});
    }
  }

  return results;
}

function render(layers) {
  var stack = d3.layout.stack(),
      layers = stack(layers),
      yGroupMax = d3.max(layers, function(layer) { return d3.max(layer, function(d) { return d.y; }); }),
      yStackMax = d3.max(layers, function(layer) { return d3.max(layer, function(d) { return d.y0 + d.y; }); });
  
  var margin = {top: 40, right: 10, bottom: 20, left: 50},
      width = 960 - margin.left - margin.right,
      height = 500 - margin.top - margin.bottom;
  
  var x = d3.scale.ordinal()
      .domain(d3.range(layers[0].length))
      .rangeRoundBands([0, width], .08);
  
  var y = d3.scale.linear()
      .domain([0, yStackMax])
      .range([height, 0]);
  
  var color = d3.scale.linear()
      .domain([0, layers.length - 1])
      .range(["#556", "#aad"]);
  
  var yAxis = d3.svg.axis()
      .scale(y)
      .tickSize(0)
      .tickPadding(6)
      .orient("left");
  
  var svg = d3.select("#chart").append("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
    .append("g")
      .attr("transform", "translate(" + margin.left + "," + margin.top + ")");
  
  var layer = svg.selectAll(".layer")
      .data(layers)
    .enter().append("g")
      .attr("class", "layer")
      .style("fill", function(d, i) { return color(i); });
  
  var rect = layer.selectAll("rect")
      .data(function(d) { return d; })
    .enter().append("rect")
      .attr("x", function(d) { return x(d.x); })
      .attr("y", height)
      .attr("width", x.rangeBand())
      .attr("height", 0);
  
  rect.transition()
      .delay(function(d, i) { return i * 10; })
      .attr("y", function(d) { return y(d.y0 + d.y); })
      .attr("height", function(d) { return y(d.y0) - y(d.y0 + d.y); });
  
  svg.append("g")
      .attr("class", "y axis")
      .call(yAxis);
}

function isEvil(result) {
  var a = document.createElement('a');
  a.href = result.url;
  return (a.hostname == 'reddit.com'
    || a.hostname == 'www.reddit.com'
    || a.hostname == 'i.imgur.com'
    || a.hostname == 'imgur.com'
    || a.hostname == 'www.facebook.com'
    || a.hostname == 'facebook.com'
    || a.hostname == 'www.youtube.com'
    || a.hostname == 'news.ycombinator.com'
    || a.hostname == 'youtube.com');

}

function x(result, start) {
  var difference = midnight(result.timestamp) - start;
  if (difference > 0) {
    difference = difference / 86400000;
  }
  return Math.floor(difference);
}

function midnight(timestamp) {
  var start = new Date(timestamp);
  start.setHours(0);
  start.setMinutes(0);
  start.setSeconds(0);
  start.setMilliseconds(0);
  return start.getTime();
}
