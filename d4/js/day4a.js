"use strict";
const STATE_WAKEUP = -1;
const STATE_ASLEEP = -2;

class Record {
  constructor(date, state) {
    this.date = date;
    this.state = state;
  }
}

class Guard {
  constructor() {
    this.sleepMasks = [];
    this.sleepMins = 0;
  }
}

class TimeMask {
  constructor(begin, end) {
    this.lower = 0;
    this.higher = 0;
    if (begin < 32 && end < 32) {
      this.lower = makeBitMask(begin, end);
    }
    else if (begin < 32 && end >= 32) {
      this.lower = makeBitMask(begin, 31);
      this.higher = makeBitMask(0, end - 32);
    }
    else {
      this.higher = makeBitMask(begin - 32, end - 32);
    }
  }

  OR(mask) {
    this.lower = this.lower | mask.lower;
    this.higher = this.higher | mask.higher;
  }

  AND(mask) {
    this.lower = this.lower & mask.lower;
    this.higher = this.higher & mask.higher;
  }
}

function getBitPos(mask) {
  let low = -1;
  let high = -1;
  for (let i = 0; i < 32; i++) {
    if ((1 << i) === mask.lower) {
      low = i;
      break;
    }
  }
  for (let i = 0; i < 32; i++) {
    if ((1 << i) === mask.higher) {
      high = i + 32;
      break;
    }
  }
  if (low === high) return -1;
  else return low < high ? high : low;
}

class TimeMaskCopy {
  constructor(mask) {
    this.lower = mask.lower;
    this.higher = mask.higher;
  }

  AND(mask) {
    this.lower = this.lower & mask.lower;
    this.higher = this.higher & mask.higher;
  }
}

function makeBitMask(begin, end) {
  var len = end - begin;
  if (len === 0) return 1 << begin;
  if (len === 31) return -1;
  var mask = (1 << (len + 1)) - 1;
  return mask << begin;
}


/*
function getThatMinut(guard) {
  var mask = new TimeMask(0, 63);
  var lastMask = 0;
  for (let i in guard.sleepMasks) {
    mask.AND(guard.sleepMasks[i]);
    if (mask.higher === 0 && mask.lower === 0) return getBitPos(lastMask);
    lastMask = new TimeMaskCopy(mask);
  }
  return getBitPos(mask);
}
*/

function getThatMinut(guard) {
  var thatMinut = -1;
  var minutes = [];
  for (let i = 0; i < guard.sleepMasks.length - 1; i++) {
    for (let j = 1; j < guard.sleepMasks.length; j++) {
      var mask = new TimeMaskCopy(guard.sleepMasks[i]);
      mask.AND(guard.sleepMasks[j]);
      thatMinut = getBitPos(mask);
      if (thatMinut >= 0) minutes.push(thatMinut);
    }
  }
  return modeMinutes(minutes);
}

function modeMinutes(arr) {
  var freq = [];
  for (let i = 0; i < 60; i++) freq.push(0);
  for (let i = 0; i < arr.length; i++) {
    freq[arr[i]]++;
  }
  var max = 0;
  var maxindex = -1;
  for (let i = 0; i < freq.length; i++) {
    if (freq[i] > max) {
      max = freq[i];
      maxindex = i;
    }
  }

  return maxindex;
}

function getMaxSleepGuardsIds(guards) {
  var guardsIds = [];
  var listGuards = [...guards].sort(compareByMaxSleep);
  let maxSleep = listGuards[0][1].sleepMins;
  guardsIds.push(listGuards[0][0]);
  for (let i = 1; i < listGuards.length; i++) {
    if (listGuards[i][1].sleepMins === maxSleep) guardsIds.push(listGuards[i][0]);
  }

  return guardsIds;
}

function compareByMaxSleep(a, b) {
  return ~(a[1].sleepMins - b[1].sleepMins);
}

function checkin(records, guards) {
  var guard = 0;
  var lastGuardId = 0;
  var lastDay = -1;
  var id = 0;

  for (var i = 0; i < records.length; i++) {
    id = records[i].state;
    if (id < 0) {
      guard = guards.get(lastGuardId);
      if (lastDay != records[i].date.getDay()) {
        lastDay = records[i].date.getDay();
        let begin = records[i].date.getMinutes();
        let end = records[++i].date.getMinutes();
        guard.sleepMins += end - begin;
        let mask = new TimeMask(begin, end - 1);
        guard.sleepMasks.push(mask);
      }
      else {
        let begin = records[i].date.getMinutes();
        let end = records[++i].date.getMinutes();
        guard.sleepMins += end - begin;
        let mask = guard.sleepMasks.pop();
        mask.OR(new TimeMask(begin, end - 1));
        guard.sleepMasks.push(mask);
      }
    }
    else {
      lastGuardId = id;
      lastDay = -1;
      if (!guards.has(id)) {
        guards.set(id, new Guard);
      }
    }
  }
}

function parse(line) {
  var dateNumbers = line.match(/\d+/g);
  var idNumber = 0;
  var state = 0;
  var date = new Date(
    dateNumbers[0],
    dateNumbers[1],
    dateNumbers[2],
    dateNumbers[3],
    dateNumbers[4]);

  if (line.search("Guard") >= 0) {
    state = parseInt(dateNumbers[5]);
  }
  else if (line.search("wakes") >= 0) state = STATE_WAKEUP;
  else state = STATE_ASLEEP;
  return new Record(date, state);
}

function compareByDate(a, b) {
  return (a.date.getTime() - b.date.getTime());
}

function main() {
  fetch("input.txt")
    .then(function (response) {
      return response.text();
    })
    .then(function (data) {
      var answer = 0;
      var lines = [];
      var records = [];
      var guards = new Map;

      lines = data.split("\n");
      for (let i in lines) {
        records.push(parse(lines[i]));
      }
      records.sort(compareByDate);
      checkin(records, guards);

      var thatId = ([...guards].sort(compareByMaxSleep))[0][0];
      var thatMinut = getThatMinut(guards.get(thatId));

      document.getElementById("answer").innerText = thatId * thatMinut;
    })
}

window.onload = function() {
  console.time("test");
  main();
  console.timeEnd("test");
}