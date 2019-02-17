#include <algorithm>
#include <iostream>
#include <fstream>
#include <vector>
#include <chrono>
using namespace std::chrono;

struct Point {
	int x, y;
	Point(int _x, int _y) : x(_x), y(_y) {};
};

class Input {
	std::vector<Point> points;
	int xmax, ymax, xdim, ydim;

public:
	Input(std::fstream &fs);
	int getRegionSize(int maxdist);
};

int manhattan(const Point &p1, const Point &p2)
{
	return abs(p1.x - p2.x) + abs(p1.y - p2.y);
}

Input::Input(std::fstream& fs)
{
	int x, y;
	char colon;
	int xmax = 0;
	int ymax = 0;

	while (!fs.eof()) {
		fs >> x >> colon >> y;
		points.emplace_back(Point(x, y));
		if (x > xmax) xmax = x;
		if (y > ymax) ymax = y;
	}

	Input::xmax = xmax;
	Input::ymax = ymax;
	xdim = xmax + 1;
	ydim = ymax + 1;
}

int Input::getRegionSize(int maxdist)
{
	Point p2(0, 0);
	int sumdist = 0;
	int regsize = 0;

	for (int y = 0; y < ydim; y++) {
		for (int x = 0; x < xdim; x++) {
			sumdist = 0;
			p2 = Point(x, y);
			for (Point p : points) {
				if (sumdist < maxdist)
					sumdist += manhattan(p, p2);
				else break;
			}
			if (sumdist < maxdist) regsize++;
		}
	}
	return regsize;
}

int main()
{
	std::fstream fs("input.txt", std::fstream::in);
	if (fs.fail()) {
		std::cout << "Can't open file.\n";
		exit(EXIT_FAILURE);
	}

	int answer = 0;
	Input input = fs;
	auto start = high_resolution_clock::now();
	answer = input.getRegionSize(10000);
	auto timing = high_resolution_clock::now() - start;

	std::cout << "asnwer :" << answer << std::endl;
	std::cout << "timing :" << duration_cast<milliseconds>(timing).count() << " ms\n";
	return 0;
}