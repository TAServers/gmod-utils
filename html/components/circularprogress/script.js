var CACHED_CIRCUMFERENCE = 188.495559215;

function setLabelPos(label, percentage, radius) {
	var pi2pct = Math.PI * 2 * percentage - Math.PI / 2;

	var x = Math.cos(pi2pct) * radius + 50;
	var y = Math.sin(pi2pct) * radius + 50;

	label.setAttribute("x", x.toString());
	label.setAttribute("y", y.toString());
}

function createProgressBar(title, parent) {
	var barContainer = document.createElement("object");
	barContainer.setAttribute("type", "image/svg+xml");
	barContainer.setAttribute("data", "circularprogress.svg");

	barContainer.bars = {};

	barContainer.addElement = function(id, colour) {
		// Container
		var container = document.createElementNS("http://www.w3.org/2000/svg", "g");

		// Progress bar
		var bar = document.createElementNS("http://www.w3.org/2000/svg", "circle");
		bar.setAttribute("class", "bar");

		bar.setAttribute("r", "30");
		bar.setAttribute("cx", "50");
		bar.setAttribute("cy", "50");
		bar.setAttribute("transform", "rotate(-90, 50, 50)");

		bar.setAttribute("fill", "transparent");
		bar.setAttribute("stroke-linecap", "round");

		bar.setAttribute("stroke-dasharray", CACHED_CIRCUMFERENCE.toString());
		bar.setAttribute("stroke-dashoffset", "0");
		bar.setAttribute("stroke", "rgb(" + colour[0].toString() + "," + colour[1].toString() + "," + colour[2].toString() + ")");
		container.appendChild(bar);

		// Label
		var label = document.createElementNS("http://www.w3.org/2000/svg", "text");
		label.setAttribute("class", "label");
		label.setAttribute("text-anchor", "middle");
		label.setAttribute("dominant-baseline", "middle");
		setLabelPos(label, 1, 30);

		label.innerHTML = title;
		container.appendChild(label);

		this.contentDocument.getElementsByTagName("svg")[0].appendChild(container);
		this.bars[id] = container;
	};

	barContainer.setProgress = function(id, percentage) {
		this.bars[id].setAttribute(
			"stroke-dashoffset",
			(CACHED_CIRCUMFERENCE - percentage * CACHED_CIRCUMFERENCE).toString()
		);
	}

	barContainer.addEventListener("load", function() {
		barContainer.contentDocument.getElementsByClassName("title")[0].innerText = title;
	});

	parent.appendChild(barContainer);
	return barContainer;
}
