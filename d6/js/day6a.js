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

function initArray(length, item){
  var array = [];
  for (let i = 0; i < length; i++) {
    array[i] = item;
  }
  return array;
}

function manhattan(p1, p2) {
  return Math.abs(p1.x - p2.x) + Math.abs(p1.y - p2.y);
}

function makeInfinit(input) {
  return function(x, y) {
    return x === 0 || y === 0 || x === input.xmax || y === input.ymax;
  }
}
  
function getLargestArea(input) {
  var points = input.points;
  var infinit = makeInfinit(input);
  var ids = initArray(points.length, 0);
  for (let y = 0; y < input.ydim; y++) {
    for (let x = 0; x < input.xdim; x++) {
      let mindist = Number.MAX_SAFE_INTEGER;
      let minid;
      let same = false;
      for (let p in points) {
        let dist = manhattan({x: x, y: y}, points[p]);
        if (dist < mindist) {
          mindist = dist;
          minid = p;
          same = false;
        }
        else if (dist === mindist) same = true;
      }
      if (!same && ids[minid] != -1 && !infinit(x, y))
        ids[minid]++;
      else if (infinit(x, y)) 
        ids[minid] = -1;
    }
  }
  ids.sort(function (a, b) { return ~(a - b);});
  return ids[0]; 
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
      answer = getLargestArea(input);
      console.timeEnd("timing");
      document.getElementById("answer").innerText = answer;
    })
}

window.onload = main;