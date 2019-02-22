import re
import sys
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

def getAnswer(input):
    onborder = input.onborder
    points = input.points
    ids = [0 for x in range(len(points))]
    p = Point(0, 0)

    for y in range(input.ydim):
        for x in range(input.xdim):
            p.x = x
            p.y = y
            same = False
            mindist = sys.maxsize
            minid = 0
            for id in range(len(points)):
                dist = manhattan(points[id], p)
                if dist < mindist:
                    mindist = dist
                    minid = id
                    same = False
                elif dist == mindist:
                    same = True
            if onborder(p):
                ids[minid] = -1
            elif (not onborder(p)) and ids[minid] != -1 and (not same):
                ids[minid] += 1

    ids.sort(reverse = True)
    return ids[0]

def main():
    answer = 0
    input = readInput("input.txt")
    timing = perf_counter_ns()
    answer = getAnswer(input)
    timing = perf_counter_ns() - timing
    print("Answer: {}".format(answer))
    print("timing: {} ms".format(timing // 1000000))

if __name__ == "__main__": main()