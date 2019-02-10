"use strict"

window.onload = function() {
    for (let i = 0; i < 10; i++) {
        d4b();
    }

}
class Record {
    constructor(id, min, elapsed) {
        this.id = id;
        this.min = min;
        this.elapsed = elapsed;
    }
}

function d4b() {
    fetch("input.txt")
        .then(function (response) {
            return response.text();
        })
        .then(function (input) {
            console.time("parse");
            var records = parse(input);
            console.timeEnd("parse");

            console.time("sort");
            records.sort(function (a, b) {
                return a.elapsed - b.elapsed;
            });
            console.timeEnd("sort");

            console.time("update");
            var timeTables = update(records);
            console.timeEnd("update");

            console.time("answer");
            var answer = getAnswer(timeTables);
            console.timeEnd("answer");

            document.getElementById("answer").innerText = answer;
        })
}

function getAnswer(timeTables) {
    var bestfreq = -1;
    var bestid = -1;
    var bestmin = -1;
    var ttable;

    for (let id in timeTables) {
        ttable = timeTables[id];
        ttable.forEach(function (freq, min) {
            if (freq > bestfreq) {
                bestfreq = freq;
                bestmin = min;
                bestid = id;
            }
        });
    }

    return bestid * bestmin;
}

function updateTable(ttable, begin, end) {
    for (let i = begin; i < end; i++) {
        ttable[i]++;
    }
    return ttable;
}

function update(records) {
    var timeTables = {};
    var id = -1;
    var begin = -1;
    var record;

    for (let i in records) {
        record = records[i];
        if (record.id >= 0) id = record.id;
        else if (begin < 0) begin = record.min;
        else {
            if (timeTables[id] == null) {
                timeTables[id] = new Array(60).fill(0);
                updateTable(timeTables[id], begin, record.min);
            }
            else {
                updateTable(timeTables[id], begin, record.min);
            }
            begin = -1;
        } 
    }

    return timeTables;
}

function parse(input) {
    var lines;
    var records = [];
    var numbers;

    lines = input.split("\n");
    records = lines.map(function(line) {
        numbers = scanner(line);
        return new Record(numbers.id, numbers.min, epoch(numbers));
    });
    return records;
}

function epoch(numbers) {
    return new Date(numbers.year,
        numbers.month,
        numbers.day,
        numbers.hour,
        numbers.min,
        0, 0)
        .valueOf();
}

function scanner(line) {
    var numbers = {year: -1, month:-1, day:-1, hour:-1, min:-1, id:-1};
    numbers.year = parseFloat(line.substr(1,4));
    numbers.month = parseFloat(line.substr(7,2));
    numbers.day = parseFloat(line.substr(9,2));
    numbers.hour = parseFloat(line.substr(12,2));
    numbers.min = parseFloat(line.substr(15,2));
    numbers.id = parseFloat(line.substr(26,4));
    return numbers;
}
