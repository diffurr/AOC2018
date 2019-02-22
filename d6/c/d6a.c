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
						array = realloc((int*) array - 2, sizeof(int) * 2 + _capacity(array) * sizeof(*array));\
						array = (int*)array + 2;

#define init_array(array, cap)	array = malloc(sizeof(int) * 2 + sizeof(*array) * ((cap <= 0) ? 1 : cap));\
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

typedef struct Input {
	Point *points;
	int xmax, ymax, xdim, ydim;
} Input;

Input *read_input(FILE *fp)
{
	char buffer[BUFSIZ];
	Point *points = NULL;
    init_array(points, 10);
	Point p;
	int xmax = 0;
	int ymax = 0;

	while (fgets(buffer, BUFSIZ, fp)) {
		sscanf_s(buffer, "%i, %i", &p.x, &p.y);
		if (p.x > xmax) xmax = p.x;
		if (p.y > ymax) ymax = p.y;
		push(points, p);
	}

    Input *input = (Input*) malloc(sizeof(Input));
    input->points = points;
    input->xmax = xmax;
    input->ymax = ymax;
    input->xdim = xmax + 1;
    input->ydim = ymax + 1;
    return input;
}

int manhattan(const Point p1, const Point p2)
{
	return abs(p1.x - p2.x) + abs(p1.y - p2.y);
}

int infinit(int x, int y, int xmax, int ymax)
{
	return (x == 0 || y == 0 || x == xmax || y == ymax);
}

int greater(void* context, const void* elem1, const void* elem2)
{
	return ~(*(int*)elem1 - *(int*)elem2);
}

int get_answer(const Input* input)
{
    Point *points = input->points;
    Point p2;
    int plen = size(points);
    int *ids = calloc(plen, sizeof(int));
    int ydim = input->ydim;
    int xdim = input->xdim;
    int xmax = input->xmax;
    int ymax = input->ymax;
    int answer = 0;

	for (int y = 0; y < ydim; y++) {
		for (int x = 0; x < xdim; x++) {
			int minid = 0;
			int mindist = INT_MAX;
            int same = 0;
			p2.x = x;
			p2.y = y;
			for (int p = 0; p < plen; p++) {
				int dist = manhattan(points[p], p2);
				if (dist < mindist) { mindist = dist, minid = p, same = 0; }
				else if (dist == mindist) { same = 1; };
            }
            if (infinit(x, y, xmax, ymax)) {
               ids[minid] = -1;
            }
            else if (!same && ids[minid] != -1 && !infinit(x, y, xmax, ymax)) {
               ids[minid]++; 
            }
        }
    }

    qsort_s(ids, plen, sizeof(int), greater, NULL);
    answer = ids[0];
    free(ids);
    return answer;
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

	Input *input = read_input(fp);
	START_PERF(start);
	//get_distances(&grid, points);
	//answer = largest_area(&grid, size(points));
    answer = get_answer(input);
	END_PERF(start, timing);

	printf("answer: %d\n", answer);
	DISPLAY_PERF(timing, freq, MS_UNIT_PERF);
	return 0;
}
#pragma warning(pop)
