"use strict";

function getData(data) {
  var re = /\d+/g;
  var xmax = 0;
  var ymax = 0;
  var points = [];
  var lines = data.split('\n');
  for (let n in lines) {
    let numbers = lines[n].match(re);
    let x = parseInt(numbers[0]);
    let y = parseInt(numbers[1]);
    if (x > xmax) xmax = x;
    if (y > ymax) ymax = y;
    points.push({x: x, y: y});
  } 
  return {points: points, xmax: xmax, ymax: ymax, xdim: xmax + 1, ydim: ymax + 1};
}

function manhattan(p1, p2) {
  return Math.abs(p1.x - p2.x) + Math.abs(p1.y - p2.y);
}

function getAnswer(input, maxdist) {
    var points = input.points;
    var regions = 0;
    for (let y = 0; y < input.ydim; y++) {
        for (let x = 0; x < input.xdim; x++) {
            let sum = 0;
            for (let p in points) {
                sum += manhattan({x: x, y: y}, points[p]);
                if (sum >= maxdist) break;
            }
            if (sum < maxdist) regions++;
        }
    }
    return regions;
}

function main() {
  fetch("input.txt")
    .then(function (response) {
      return response.text();
    })
    .then(function (data) {
      var answer = 0;
      var input = getData(data);
      console.time("timing");
      answer = getAnswer(input, 10000);
      console.timeEnd("timing");
      document.getElementById("answer").innerText = answer;
    })
}

window.onload = main;