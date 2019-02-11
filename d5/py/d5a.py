from time import perf_counter_ns
import profile

def readPolymer(fileName):
    file = open(fileName)
    input = file.read()
    polymer = [ord(x) for x in input]
    return polymer

def reaction(polymer):
    polyB = polymer
    polyA = []
    #temp = []

    reactions = 1
    while reactions > 0:
        # temp = polyA
        # polyA = polyB
        # polyB = temp
        # polyB.clear()
        polyA = polyB
        polyB = []
        reactions = 0

        i = 0
        sz = len(polyA)
        while i < sz - 1:
            if _react(polyA[i], polyA[i + 1]):
                i += 2
                reactions += 1
            else:
                polyB.append(polyA[i])
                i += 1
        if i == sz - 1:
            polyB.append(polyA[i])
                
    return len(polyA)

def _react(a, b):
    return a - b == 32 or a - b == -32

def main():
    answer = 0

    timing = perf_counter_ns()
    polymer = readPolymer("input.txt")
    answer = reaction(polymer)
    timing = perf_counter_ns() - timing

    print("Answer:  " + str(answer))
    print("time:  " + str(timing // 1000000) + " ms")
    return

if __name__ == "__main__": main()