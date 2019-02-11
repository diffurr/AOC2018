#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <windows.h>

#define GET_FREQ(freq) QueryPerformanceFrequency(&freq)
#define START_PERF(begin) QueryPerformanceCounter(&begin)
#define END_PERF(begin, end, freq) QueryPerformanceCounter(&end);\
										end.QuadPart -= begin.QuadPart;\
										end.QuadPart *= 1000;\
										end.QuadPart /= freq.QuadPart

size_t fsize(FILE* fp)
{
    size_t size = 0;
    fseek(fp, 0, SEEK_END);
    size = ftell(fp);
    rewind(fp);
    return size;
}

int react(char a, char b)
{
    return (abs(a - b) == 32);
}

size_t scan(char* poly, size_t sz)
{
    size_t reactions = 1;
    size_t newsize = 0;
    size_t size = sz;
    char* polymer = poly;
    char* saveptr = (char*) malloc(size);
    char* newpolymer = saveptr;
    char* tempptr = NULL;

    while (reactions) {
        newsize = 0;
        reactions = 0;
        size_t i;
        for (i = 0; i < size - 1; i++) {
            if (react(polymer[i], polymer[i + 1])) {
                ++i;
                ++reactions;
            }
            else {
                newpolymer[newsize++] = polymer[i];
            }
        }
        if (i == size - 1)
            newpolymer[newsize++] = polymer[i];
        //swap pointers and sizes
        size = newsize;
        tempptr = polymer;
        polymer = newpolymer;
        newpolymer = tempptr;
    }

    free(saveptr);    
    return size;
}

int main(void)
{
    LARGE_INTEGER freq, begin, end;
    GET_FREQ(freq);
    size_t size = 0;
    size_t length = 0;
    FILE* fp = NULL;
    char* polymer = NULL;

    START_PERF(begin);
    fp = fopen("input.txt", "rt");
    size = fsize(fp);
    polymer = (char*) malloc(size);
    fread(polymer, 1, size, fp);

    length = scan(polymer, size);
    END_PERF(begin, end, freq);

    printf("Answer:  %lld\n", length);
    printf("time:   %lld ms\n", end.QuadPart);

    return 0;
}
