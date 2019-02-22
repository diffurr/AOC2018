import re
from time import perf_counter_ns

class Point:
    def __init__(self, x, y):
        self.x = x
        self.y = y

class Info:
    def __init__(self, points, xmax, ymax):
        self.points = points
        self.xmax = xmax
        self.ymax = ymax
        self.xdim = xmax + 1
        self.ydim = ymax + 1

    def onborder(self, p):
        return p.x == 0 or p.y == 0 or p.x == self.xmax or p.y == self.ymax

def readInput(fileName):
    points = []
    xmax = ymax = 0
    p = re.compile(r'(\d+),\s(\d+)')

    try:
        info = open(fileName)
        for line in info:
            m = p.match(line)
            if m == None:
                raise Exception(fileName + " is wrong input file")
            x = int(m.group(1))
            y = int(m.group(2))
            if x < 0 or y < 0:
                raise Exception(fileName + " is wrong input file")
            if x > xmax:
                xmax = x
            if y > ymax:
                ymax = y
            points.append(Point(x, y))

    except IOError as ioerror:
        print("{} {}".format(ioerror.filename, ioerror.strerror))
        exit()
    except Exception as error:
        print(error.args)
        exit()

    return Info(points, xmax, ymax)

def manhattan(p1, p2):
    return abs(p1.x - p2.x) + abs(p1.y - p2.y)

def getAnswer(input, maxdist):
    points = input.points
    p2 = Point(0, 0)
    regions = 0

    for y in range(input.ydim):
        for x in range(input.xdim):
            p2.x = x
            p2.y = y
            regions += 1
            sumdist = 0
            for p in points:
                sumdist += manhattan(p, p2)
                if sumdist >= maxdist:
                    regions -= 1
                    break
    return regions

def main():
    answer = 0
    input = readInput("input.txt")
    timing = perf_counter_ns()
    answer = getAnswer(input, 10000)
    timing = perf_counter_ns() - timing
    print("Answer: {}".format(answer))
    print("timing: {} ms".format(timing // 1000000))

if __name__ == "__main__": main()