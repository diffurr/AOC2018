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

class GuardMinutFreq {
  constructor(id, freq, minut) {
    this.id = id;
    this.freq = freq;
    this.minut = minut;
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

function makeBitMask(begin, end) {
  var len = end - begin;
  if (len === 0) return 1 << begin;
  if (len === 31) return -1;
  var mask = (1 << (len + 1)) - 1;
  return mask << begin;
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


function countMinutes(currentValue) {
  var id = currentValue[0];
  var sleepMasks = currentValue[1].sleepMasks;
  var minutesFreq = [];
  var maxFreq = 0;
  var maxIndex = -1;
  for (let i = 0; i < 64; i++) minutesFreq.push(0);

  for (let sleepMask in sleepMasks) {
    for (let i = 0; i < 32; i++) {
      if (((1 << i) & sleepMasks[sleepMask].lower) != 0) minutesFreq[i]++;
      if (minutesFreq[i] > maxFreq) {
        maxFreq = minutesFreq[i];
        maxIndex = i;
      }
      if (((1 << i) & sleepMasks[sleepMask].higher) != 0) minutesFreq[i + 32]++;
      if (minutesFreq[i + 32] > maxFreq) {
        maxFreq = minutesFreq[i + 32];
        maxIndex = i + 32;
      }
    }
  }
  
  return new GuardMinutFreq(id, maxFreq, maxIndex);
}

function printRecords(records) {
  for (let i in records) {
    document.writeln("<p>" + records[i].date.getMinutes() + "____" + records[i].state + "<\p>");
  }
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
 
      console.time("performance");
      lines = data.split("\n");
      lines.pop();
      for (let i in lines) {
        records.push(parse(lines[i]));
      }
      records.sort((a, b) => a.date.getTime() - b.date.getTime());
      //printRecords(records);
      checkin(records, guards);

      var guardsCounted = [...guards].map(countMinutes);
      guardsCounted.sort((a, b) => ~(a.freq - b.freq));
      answer = guardsCounted[0].id * guardsCounted[0].minut;
      console.timeEnd("performance");

      document.getElementById("answer").innerText = answer;
    })
}

window.onload = main;
