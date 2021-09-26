var CACHED_CIRCUMFERENCE = 188.495559215;

function createProgressBar(title, parent) {
	var barContainer = document.createElement("object");
	barContainer.setAttribute("type", "image/svg+xml");
	barContainer.setAttribute("data", "circularprogress.svg");

	barContainer.bars = {};

	barContainer.addElement = function(id, colour) {
		var bar = document.createElementNS("http://www.w3.org/2000/svg", "circle");
		bar.setAttribute("class", "bar");
		bar.setAttribute("r", "30");
		bar.setAttribute("cx", "50");
		bar.setAttribute("cy", "50");
		bar.setAttribute("fill", "transparent");
		bar.setAttribute("transform", "rotate(-90, 50, 50)");
		bar.setAttribute("stroke-linecap", "round");

		bar.setAttribute("stroke-dasharray", CACHED_CIRCUMFERENCE.toString());
		bar.setAttribute("stroke-dashoffset", "0");
		bar.style.stroke = "rgb(" + colour[0].toString() + "," + colour[1].toString() + "," + colour[2].toString() + ");";

		console.log(this.contentDocument);
		this.contentDocument.getElementsByTagName("svg")[0].appendChild(bar);
		this.bars[id] = bar;
	};

	barContainer.setProgress = function(id, percentage) {
		this.bars[id].setAttribute(
			"stroke-dashoffset",
			(CACHED_CIRCUMFERENCE - percentage * CACHED_CIRCUMFERENCE).toString()
		);
	}

	parent.appendChild(barContainer);
	return barContainer;
}
