var RADIUS = 37.5;
var CIRCUMFERENCE = 2 * Math.PI * RADIUS;
var MIN_PROGRESS = 0.0000001;

function setLabelPos(label, percentage) {
	var pi2pct = Math.PI * 2 * percentage - Math.PI / 2;

	var x = Math.cos(pi2pct) * RADIUS + 50;
	var y = Math.sin(pi2pct) * RADIUS + 50;

	label.setAttribute("x", x.toString());
	label.setAttribute("y", y.toString());
}

function createProgressBar(title, parent) {
	var barContainer = document.createElement("object");
	barContainer.setAttribute("type", "image/svg+xml");
	barContainer.setAttribute("data", "https://www.taservers.com/gmod/utils/components/circularprogress/circularprogress.svg");

	barContainer.bars = {};

	barContainer.sortElements = function() {
		var elements = {};
		var keys = [];

		for (var id in this.bars) {
			elements[this.bars[id].percentage] = this.bars[id];
			keys.push(this.bars[id].percentage);
		}

		keys.sort(function(a, b) {
			return b - a;
		});

		for (var i = 0; i < keys.length; i++) {
			elements[keys[i]].parentNode.appendChild(elements[keys[i]]);
		}
	};

	barContainer.addElement = function(id, colour) {
		// Container
		var container = document.createElementNS("http://www.w3.org/2000/svg", "g");
		container.percentage = 0;

		// Progress bar
		var bar = document.createElementNS("http://www.w3.org/2000/svg", "circle");
		bar.setAttribute("class", "bar");

		bar.setAttribute("r", RADIUS.toString());
		bar.setAttribute("cx", "50");
		bar.setAttribute("cy", "50");
		bar.setAttribute("transform", "rotate(-90, 50, 50)");

		bar.setAttribute("fill", "transparent");
		bar.setAttribute("stroke-linecap", "round");
		bar.setAttribute("filter", "url(#drop-shadow)")

		bar.setAttribute("stroke-dasharray", CIRCUMFERENCE.toString());
		bar.setAttribute("stroke-dashoffset", (CIRCUMFERENCE - MIN_PROGRESS * CIRCUMFERENCE).toString());
		bar.setAttribute("stroke", colour);
		container.appendChild(bar);
		container.bar = bar;

		// Label
		var label = document.createElementNS("http://www.w3.org/2000/svg", "text");
		label.setAttribute("class", "label");
		label.setAttribute("text-anchor", "middle");
		label.setAttribute("dominant-baseline", "middle");

		label.appendChild(document.createTextNode(id))
		container.appendChild(label);
		container.label = label;

		this.contentDocument.getElementsByTagName("svg")[0].appendChild(container);
		this.bars[id] = container;

		setLabelPos(label, MIN_PROGRESS);
		this.sortElements();
	};

	barContainer.setProgress = function(id, percentage) {
		percentage = Math.min(1, Math.max(MIN_PROGRESS, percentage));
		this.bars[id].percentage = percentage;

		this.bars[id].bar.setAttribute(
			"stroke-dashoffset",
			(CIRCUMFERENCE - percentage * CIRCUMFERENCE).toString()
		);

		setLabelPos(this.bars[id].label, percentage);
		this.sortElements();
	};

	barContainer.addEventListener("load", function() {
		barContainer.contentDocument.getElementsByClassName("title")[0].appendChild(
			document.createTextNode(title)
		);
	});

	parent.appendChild(barContainer);
	return barContainer;
}
