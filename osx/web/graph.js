$.getJSON("http://localhost:9045/graph", function(d) {
  $.plot($("#chart"), [d.data], {
    xaxis: { 
      mode: "time",
    },
    grid: {
      borderWidth: 0,
      hoverable: true,
    },
    lines: { show: true, fill: true },
    points: { show: true}
  });
});



