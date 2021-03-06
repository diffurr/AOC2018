import time

class Record:
    def __init__(self, line):
        year = int(line[1:5])
        month = int(line[6:8])
        day = int(line[9:11])
        hour = int(line[12:14])
        self.minute = int(line[15:17])
        if line[25] == '#':
            self.id = int(line[26:30])
        else:
            self.id = -1
        self.elapsed = self.epoch(year, month, day, hour, self.minute)
    
    def __lt__(self, other):
        return self.elapsed < other.elapsed

    def epoch(self, year, month, day, hour, minute):
        DAYS_IN_MON = [ 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 ]
        SEC_IN_YEAR = 31557600
        SEC_IN_DAY = 86400
        SEC_IN_HOUR = 3600

        total = (year - 1900) * SEC_IN_YEAR
        for i in range(month - 1):
            total += DAYS_IN_MON[i] * SEC_IN_DAY
        total += day * SEC_IN_DAY
        total += hour * SEC_IN_HOUR
        total += minute * 60
        return total

def parse(input):
    records = []
    for line in input:
        records.append(Record(line)) 
    return records 

def update(records):
    timeTables = {}
    id = -1
    begin = -1
    ttable = None

    for record in records:
        if record.id >= 0:
            id = record.id
        elif begin < 0:
            begin = record.minute
        else:
            ttable = timeTables.get(id)
            if ttable == None:
                ttable = [0] * 60
                markMinute(ttable, begin, record.minute)
                timeTables[id] = ttable
            else:
                markMinute(ttable, begin, record.minute)
            begin = -1

    return timeTables

def markMinute(ttable, begin, end):
    for i in range(begin, end):
        ttable[i] += 1

def getAnswer(timeTables):
    bestid = -1
    bestminute = -1
    bestfreq = -1
    ttable = []

    for id in timeTables.keys():
        ttable = timeTables[id]
        for minute in range(len(ttable)):
            if ttable[minute] > bestfreq:
                bestfreq = ttable[minute]
                bestminute = minute
                bestid = id

    return bestid * bestminute

def main():
    input = open("input.txt")

    start = time.perf_counter_ns()
    records = parse(input)
    parseTime = time.perf_counter_ns() - start

    start = time.perf_counter_ns()
    records.sort()
    sortTime = time.perf_counter_ns() - start

    start = time.perf_counter_ns()
    timeTables = update(records)
    updateTime = time.perf_counter_ns() - start

    start = time.perf_counter_ns()
    answer = getAnswer(timeTables)
    asnwerTime = time.perf_counter_ns() - start

    print("Answer: " + str(answer))
    print("parse:  " + str(parseTime // 1000) + " us")
    print("sort:  " + str(sortTime // 1000) + " us")
    print("update:  " + str(updateTime // 1000) + " us")
    print("answer:  " + str(asnwerTime // 1000) + " us")

if __name__ == "__main__": main()
