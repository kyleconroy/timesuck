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
      tickLength: 0,
      mode: "time",
      color: "#a6a6a6",
    },
    yaxis: {
      tickMapper: function (val, i, length) {
        if (i == 0 || i == length - 1) {
          val.label = "";
          return val;
        }
        return val;
      },
      labelWidth: 40,
      min: 0.01,
      color: "#a6a6a6",
    },
    grid: {
      borderWidth: 1,
      borderColor: "#a6a6a6",
      hoverable: true,
    },
    lines: { show: true, fill: true },
    points: { show: true}
  });
});



