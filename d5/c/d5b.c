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

size_t filter(const char unit, const char* poly, char* filt, const size_t size)
{
    size_t filt_i = 0;
    for (size_t i = 0; i < size; i++) {
        if (!(poly[i] == unit || poly[i] == unit + 32)) {
            filt[filt_i++] = poly[i];
        }
    }
    return filt_i;
}

int cmp(const void* a, const void* b)
{
    if ( *(size_t*)a <  *(size_t*)b) return -1;
    if ( *(size_t*)a == *(size_t*)b) return 0;
    return 1;
}

int main(void)
{
    LARGE_INTEGER freq, begin, end;
    GET_FREQ(freq);
    size_t size = 0;
    size_t filtered_size = 0;
    size_t length = 0;
    FILE* fp = NULL;
    char* polymer = NULL;
    char* filtered = NULL;
    #define NELEMS 26
    size_t lens[NELEMS];

    START_PERF(begin);
    fp = fopen("input.txt", "rt");
    size = fsize(fp);
    polymer = (char*) malloc(size);
    filtered = (char*) malloc(size);
    fread(polymer, 1, size, fp);

    for (int i = 0; i < NELEMS; i++) {
        filtered_size = filter(i + 65, polymer, filtered, size);
        lens[i] = scan(filtered, filtered_size);
    }

    qsort(&lens, NELEMS, sizeof(size_t), cmp);
    length = lens[0];
    END_PERF(begin, end, freq);

    printf("Answer:  %lld\n", length);
    printf("time:   %lld ms\n", end.QuadPart);

    return 0;
}
