var Observable = require("FuseJS/Observable");


//reel items
var colors = ["#fe40fe", "#eea9b8", "#cd4f39", "#ffa07a", "#cd853f", "#eead0e", "#458b00", "#01fcff", "#00688b", "#7a7a7a"];

var reel1 = Observable(1,2,5,6,9,1,2,7,3,8,5,3,5,8,6,4,0,1,0,1);
var reel2 = Observable(2,3,4,9,5,3,6,8,6,5,3,5,7,8,8,0,5,0,4,0,2,2,3,4,5,7,8,9,7,5,3);
var reel3 = Observable(2,3,4,2,3,1,2,4,5,3,2,2,1,5,7,8,9,7,5,3,1,2,3,4,5,6,7,8,9,0,9,8,7,6,5,4,3);

var reel1View = reel1.map(function(x){ return colors[x]; });
var reel2View = reel2.map(function(x){ return colors[x]; });
var reel3View = reel3.map(function(x){ return colors[x]; });

module.exports = {
	reel1 :reel1View,
	reel2 :reel2View,
	reel3 :reel3View
};
