$.getJSON("http://localhost:9045/graph", function(d) {
  $.plot($("#chart"), [d.data], {
    xaxis: { 
      tickMapper: function (val, i, length) {
        if (i == 0 || i == length - 1) {
          val.label = "";
          return val;
        }
        return val;
      },
      mode: "time",
      tickLength: 0,
      color: "#a6a6a6",
    },
    yaxis: {
      tickMapper: function (val, i, length) {
        if (i % 2 == 0 || i == length - 1) {
          val.label = "";
          return val;
        }
        return val;
      },
      color: "#a6a6a6",
    },
    grid: {
      borderWidth: 0,
      hoverable: true,
    },
    lines: { show: true, fill: true },
    points: { show: true}
  });
});



