#define VC_EXTRALEAN
#define WIN32_LEAN_AND_MEAN
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <Windows.h>

#define MS_UNIT_PERF 1000		//scale to milliseconds
#define US_UNIT_PERF 1000000	//scale to microseconds
#define GET_FREQ_PERF(freq) QueryPerformanceFrequency(&freq)
#define START_PERF(begin) QueryPerformanceCounter(&begin)
#define END_PERF(begin, end) QueryPerformanceCounter(&end);\
							 end.QuadPart -= begin.QuadPart
#define DISPLAY_PERF(time, freq, scale)		time.QuadPart *= scale;\
											time.QuadPart /= freq.QuadPart;\
											printf(#time " :%lld\n", time.QuadPart)

#pragma warning(push)
#pragma warning(disable : 4133)

#define _size(array)		((int*) array - 2)[0]
#define _capacity(array)	((int*) array - 2)[1]

#define _grow(array)	_capacity(array) = _capacity(array) * 2;\
						array = realloc((int*) array - 2, sizeof(int) * 2 + _capacity(array) * sizeof(array[0]));\
						array = (int*)array + 2;

#define init_array(array, cap)	array = malloc(sizeof(int) * 2 + sizeof(array[0]) * ((cap <= 0) ? 1 : cap));\
								array = (int*)array + 2;\
								_size(array) = 0;\
								_capacity(array) = (cap <= 0) ? 1 : cap

#define push(array, item)	if(_capacity(array) == _size(array)) { _grow(array) }\
								array[_size(array)++] = item

#define size(array)		_size(array)
#define delete(array)	free((int*) array - 2)

typedef struct Point {
	int x, y;
} Point ;

typedef struct Grid {
	int *locs;
	int xmax, ymax, xdim, ydim;
} Grid;

void read_input(FILE *fp, Grid *grid, Point **_points)
{
	char buffer[BUFSIZ];
	Point *points = *_points;
	Point p;
	int xmax = 0;
	int ymax = 0;

	while (fgets(buffer, BUFSIZ, fp)) {
		sscanf_s(buffer, "%i, %i", &p.x, &p.y);
		if (p.x > xmax) xmax = p.x;
		if (p.y > ymax) ymax = p.y;
		push(points, p);
	}

	*_points = points;
	grid->xmax = xmax;
	grid->ymax = ymax;
	grid->xdim = xmax + 1;
	grid->ydim = ymax + 1;
	grid->locs = malloc(sizeof(int) * (grid->xdim * grid->ydim));
}

int manhattan(const Point p1, const Point p2)
{
	return abs(p1.x - p2.x) + abs(p1.y - p2.y);
}

int dist_below(const Grid *grid, const Point *points, const int maxdist)
{
	int nbelow = 0;
	int xdim = grid->xdim;
	int ydim = grid->ydim;
	int distsum;
	int p;
	Point p2;

	for (int y = 0; y < ydim; y++) {
		for (int x = 0; x < xdim; x++) {
			distsum = 0;
			p = 0;
			p2.x = x;
			p2.y = y;
			while (distsum < maxdist && p < size(points)) {
					distsum += manhattan(points[p++], p2);
			}
			if (distsum < maxdist) nbelow++;
		}
	}
	return nbelow;
}

int main(void)
{
	LARGE_INTEGER freq, start, timing;
	GET_FREQ_PERF(freq);
	FILE *fp = NULL;
	errno_t err = fopen_s(&fp, "input.txt", "rt");
	if (err) {
		perror("Can't open file");
		exit(EXIT_FAILURE);
	}
;
	int answer = 0;
	Grid grid;
	Point *points = NULL;
	init_array(points, 10);

	read_input(fp, &grid, &points);
	START_PERF(start);
	answer = dist_below(&grid, points, 10000);
	END_PERF(start, timing);

	printf("answer: %d\n", answer);
	DISPLAY_PERF(timing, freq, MS_UNIT_PERF);
	return 0;
}
#pragma warning(pop)