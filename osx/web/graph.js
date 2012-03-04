Rickshaw.namespace('Rickshaw.Graph.SaneHoverDetail');

Rickshaw.Graph.SaneHoverDetail = function(args) {

	var graph = this.graph = args.graph;
	
	var element = this.element = document.createElement('div');
	element.className = 'detail';
	
	this.visible = true;

	graph.element.appendChild(element);

	var self = this;

	this.lastEvent = null;

	this.update = function(e) {

		e = e || this.lastEvent;
		if (!e) return;
		this.lastEvent = e;

		if (e.target.nodeName != 'path' && e.target.nodeName != 'svg') return;

		var eventX = e.offsetX || e.layerX;
		var eventY = e.offsetY || e.layerY;

		var domainX = graph.x.invert(eventX);
		var stackedData = graph.stackedData;

		var topSeriesData = stackedData.slice(-1).shift();

		var domainIndexScale = d3.scale.linear()
			.domain([topSeriesData[0].x, topSeriesData.slice(-1).shift().x])
			.range([0, topSeriesData.length]);

		var approximateIndex = Math.floor(domainIndexScale(domainX));
		var dataIndex = approximateIndex || 0;

		for (var i = approximateIndex; i < stackedData[0].length - 1;) {

			if (stackedData[0][i].x <= domainX && stackedData[0][i + 1].x > domainX) {
				dataIndex = i;
				break;
			}
			if (stackedData[0][i + 1] < domainX) { i++ } else { i-- }
		}

		domainX = stackedData[0][dataIndex].x;

		var detail = graph.series.active()
			.map( function(s) { return { name: s.name, value: s.stack[dataIndex] } } );

		if (this.visible) {
			self.render.call( self, domainX, detail, eventX, eventY);
		}
	}

	this.xFormatter = function(x) {
		return new Date( x * 1000 ).toUTCString();
	}

	this.graph.element.addEventListener( 
		'mousemove', 
		function(e) { 
			self.visible = true; 
			self.update(e) 
		}, 
		false 
	);

	this.graph.onUpdate( function() { self.update() } );

	this.graph.element.addEventListener( 
		'mouseout', 
		function(e) { 
			if (e.relatedTarget && !(e.relatedTarget.compareDocumentPosition(self.graph.element) & Node.DOCUMENT_POSITION_CONTAINS)) {
				self.hide();
			}
		 }, 
		false 
	);

	this.hide = function() {
		this.visible = false;
		this.element.classList.add('inactive');
	}

	this.show = function() {
		this.visible = true;
		this.element.classList.remove('inactive');
	}

	this.render = function(domainX, detail, mouseX, mouseY) {

		this.element.innerHTML = '';
		this.element.style.left = graph.x(domainX) + 'px';

		var xLabel = document.createElement('div');
		xLabel.className = 'x_label';

    if (graph.x(domainX) > (graph.width / 2)) {
      xLabel.style.right = 0;
    } else {
      xLabel.style.left = 0;
    }

		xLabel.innerHTML = this.xFormatter(domainX);
		this.element.appendChild(xLabel);

		var activeItem = null;

		var sortFn = function(a, b) {
			return (a.value.y0 + a.value.y) - (b.value.y0 + b.value.y);
		}

		detail.sort(sortFn).forEach( function(d) {

			var item = document.createElement('div');
			item.innerHTML = d.name + ':&nbsp;' + d.value.y.toFixed(2);
			item.style.top = graph.y(d.value.y0 + d.value.y) + 'px';

      if (graph.x(domainX) > (graph.width / 2)) {
        item.style.right = 0;
        item.className = "item pleft";
      } else {
        item.className = "item pright";
        item.style.left = 0;
      }
    
      var domainMouseY = graph.y.magnitude.invert(graph.element.offsetHeight - mouseY);
			
			this.element.appendChild(item);

			var dot = document.createElement('div');
			dot.className = 'dot';
			dot.style.top = item.style.top;

			this.element.appendChild(dot);

			if (domainMouseY > d.value.y0 && domainMouseY < d.value.y0 + d.value.y && !activeItem) {

				activeItem = item;
				item.className = item.className + ' active';	
				dot.className = 'dot active';
			}

		}, this );

		this.show();
	}
}

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

  var hoverDetail = new Rickshaw.Graph.SaneHoverDetail( {
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
