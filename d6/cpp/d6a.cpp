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
	std::vector<int> ids;
	int xmax, ymax, xdim, ydim;

	bool infinit(int x, int y)
	{
		return (x == 0 || y == 0 || x == xmax || y == ymax);
	}

public:
	Input(std::fstream &fs);
	int getLargestArea();
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

	ids = std::vector<int>(points.size(), 0);
	Input::xmax = xmax;
	Input::ymax = ymax;
	xdim = xmax + 1;
	ydim = ymax + 1;
}

int Input::getLargestArea()
{
	Point p2(0, 0);
	int dist = 0;
	int mindist = 0;
	int minid = 0;
	bool samedist = false;

	for (int y = 0; y < ydim; y++) {
		for (int x = 0; x < xdim; x++) {
			p2 = Point(x, y);
			mindist = INT_MAX;
			samedist = false;
			for (int id = 0; id < points.size(); id++) {
				dist = manhattan(points[id], p2);
				if (dist < mindist) {
					mindist = dist;
					minid = id;
					samedist = false;
				}
				else if (dist == mindist) 
					samedist = true;
			}

			if (!samedist && ids[minid] != -1 && !infinit(x, y))
				ids[minid]++;
			else if (infinit(x, y)) 
				ids[minid] = -1;
		}
	}
	std::sort(ids.begin(), ids.end());
	return ids.back();
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
	answer = input.getLargestArea();
	auto timing = high_resolution_clock::now() - start;

	std::cout << "asnwer :" << answer << std::endl;
	std::cout << "timing :" << duration_cast<milliseconds>(timing).count() << " ms\n";
	return 0;
}