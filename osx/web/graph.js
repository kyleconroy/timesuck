$.getJSON("http://localhost:9045/graph", function(d) {

  var graph = new Rickshaw.Graph( {
    element: document.querySelector("#chart"),
    width: 740,
    height: 250,
    series: [ {
      color: 'steelblue',
      name: "Total Hours",
      data: d.data
    } ]
  } );

  var axes = new Rickshaw.Graph.Axis.Time( { graph: graph } );

  var hoverDetail = new Rickshaw.Graph.HoverDetail( {
    graph: graph
  });

  var y_axis = new Rickshaw.Graph.Axis.Y( {
          graph: graph,
          orientation: 'left',
          tickFormat: Rickshaw.Fixtures.Number.formatKMBT,
          element: document.getElementById('y_axis'),
  } );

  graph.render();

});
