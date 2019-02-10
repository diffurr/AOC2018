#include "pch.h"

#ifdef _MSC_VER
#pragma warning(push)
#pragma warning(disable : 4133)
#endif
#ifdef __GNUC__
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wincompatible-pointer-types"
#endif

#define INDEX(arr, type) ((type *)(arr->data))
#define START_PERF(begin) QueryPerformanceCounter(&begin)
#define END_PERF(begin, end, freq) QueryPerformanceCounter(&end);\
										end -= begin;\
										end *= 1000000;\
										end /= freq

typedef struct Record {
	int id;
	int minutes;
	time_t elapsed;
} Record;

typedef struct Array {
	size_t size;
	size_t capacity;
	size_t elem_len;
	unsigned char *data;
} Array;

typedef struct Map {
	size_t capacity;
	int *keys;
	void **values;
} Map;

Map* map_init(const size_t capacity)
{
	Map* new_map = (Map*) malloc(sizeof(Map));
	new_map->keys = (int*) malloc(sizeof(int) * capacity);
	for (int i = 0; i < capacity; i++)
		new_map->keys[i] = -1;
	new_map->values = malloc(sizeof(void**) * capacity);
	new_map->capacity = capacity;
	return new_map;
}

void map_insert(Map * const map, const int key, void * const value)
{
	assert(map != NULL && value != NULL);
	int hash = key % map->capacity;

	while (map->keys[hash] != key && map->keys[hash] >= 0) {
		hash = (hash + 1) % map->capacity;
	}
	map->keys[hash] = key;
	map->values[hash] = value;
}

void* map_get(Map * const map, const int key)
{
	assert(map != NULL);
	int hash = key % map->capacity;

	while (map->keys[hash] != key) {
		if (map->keys[hash] == -1) return NULL;
		hash = (hash + 1) % map->capacity;
	}
	return map->values[hash];
}

void array_grow(Array *a)
{
	assert(a != NULL);
	size_t new_capacity = a->capacity == 0 ? 1 : a->capacity * 2;
	a->data = realloc(a->data, new_capacity * a->elem_len);
	a->capacity = new_capacity;
}

void array_push(Array *a, const void* elem)
{
	assert(a != NULL && elem != NULL);
	if (a->size == a->capacity)
		array_grow(a);
	memcpy(a->data + a->size * a->elem_len, elem, a->elem_len);
	a->size++;
}

void* array_at(const Array* a, const size_t index)
{
	assert(index < a->size);
	assert(a != NULL);
	return a->data + index * a->elem_len;
}
size_t array_size(const Array* a)
{
	assert(a != NULL);
	return a->size;
}

Array* array_init(const size_t capacity, const size_t elem_len)
{
	Array* new_array = (Array*)malloc(sizeof(Array));
	new_array->capacity = capacity;
	new_array->size = 0;
	new_array->elem_len = elem_len;
	new_array->data = (unsigned char*)malloc(capacity * elem_len);
	return new_array;
}

void array_free(Array *a)
{
	assert(a != NULL);
	free(a->data);
	free(a);
}

time_t epoch(const struct tm *date)
{
	static const int days_in_mon[] = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };
	static const long long int sec_in_year = 31557600ll; 
	static const int sec_in_day = 86400;
	static const int sec_in_hour = 3600;
	time_t total;

	total = date->tm_year * sec_in_year;
	for (int mon = 0; mon < date->tm_mon; mon++)
		total += days_in_mon[mon] * sec_in_day;
	total += date->tm_mday * sec_in_day;
	total += date->tm_hour * sec_in_hour;
	total += date->tm_min * 60;
	total += date->tm_sec;
	return total;
}

void parse_input(FILE *input, Array *records)
{
	Record record;
	struct tm date;
	char buffer[BUFSIZ];
	int id;

	date.tm_sec = 0;
	while (fgets(buffer, BUFSIZ, input) && !feof(input)) {
		id = -1;
		sscanf_s(buffer, "%*[[]%d%*[-]%d%*[-]%d %d%*[:]%d%*[]] %*5s %*[#]%d", 
			&date.tm_year,
			&date.tm_mon,
			&date.tm_mday,
			&date.tm_hour,
			&date.tm_min,
			&id);
		date.tm_year = date.tm_year - 1500;
		date.tm_mon--;

		record.minutes = date.tm_min;
		record.id = id;
		record.elapsed = epoch(&date);
		array_push(records, &record);
	}
}

//void update(const Array *records, Map *time_tables)
//{}

int comp_records(const void *a, const void *b)
{
	//if (((Record*)a)->elapsed > ((Record*)b)->elapsed) return 1;
	//if (((Record*)a)->elapsed < ((Record*)b)->elapsed) return -1;
	//return 0;
	return (int) ( ((Record*)a)->elapsed - ((Record*)b)->elapsed );
}

void sort_records(Array *records)
{
	qsort(records->data, records->size, records->elem_len, comp_records);
}

void update_ttable(unsigned short *ttable, int begin, int end)
{
	for (int i = begin; i < end; i++) {
		ttable[i]++;
	}
}

void update(const Array * const records, Map * const time_tables)
{
	int begin = -1;
	int end = -1;
	int id = -1;
	unsigned short *ttable;

	for (size_t i = 0; i < records->size; i++) {
		if ((INDEX(records, Record)[i].id) > 0) {
			id = INDEX(records, Record)[i].id;
			continue;
		}
		if (begin < 0) {
			begin = INDEX(records, Record)[i].minutes;
		}
		else {
			end = INDEX(records, Record)[i].minutes;
			ttable = map_get(time_tables, id);
			if (ttable != NULL) {
				update_ttable(ttable, begin, end);
			}
			else {
				ttable = calloc(60, sizeof(unsigned short));
				update_ttable(ttable, begin, end);
				map_insert(time_tables, id, ttable);
				ttable = NULL;
			}
			begin = end = -1;
		}
	}
}

int get_answer(const Map * const time_tables)
{
	const Map * const map = time_tables;
	int max_min = -1;
	int max_freq = -1;
	int max_id = -1;

	for (int i = 0; i < map->capacity; i++) {
		if (map->keys[i] >= 0) {
			for (int j = 0; j < 60; j++) {
				if (((unsigned short*)(map->values)[i])[j] > max_freq) {
					max_freq = ((unsigned short*)(map->values)[i])[j];
					max_min = j;
					max_id = map->keys[i];
				}
			}
		}
	}
	return max_id * max_min;
}

void print_tables(const Map * const time_tables)
{
	const Map * const map = time_tables;
	for (int i = 0; i < map->capacity; i++) {
		if (map->keys[i] >= 0) {
			printf("%d | ", map->keys[i]);
			for (int j = 0; j < 60; j++) {
				printf("%d, ", ((unsigned short*)(map->values)[i])[j]);
			}
			printf("\n");

		}
	}
}

int main(void)
{
	unsigned long long q_freq, q_begin, q_parse, q_sort, q_update, q_answer;
	QueryPerformanceFrequency(&q_freq);

	Array *records = array_init(0, sizeof(Record));
	Map *time_tables = map_init(101);
	int answer = 0;

	START_PERF(q_begin);
	parse_input(stdin, records);
	END_PERF(q_begin, q_parse, q_freq);

	START_PERF(q_begin);
	sort_records(records);
	END_PERF(q_begin, q_sort, q_freq);

	START_PERF(q_begin);
	update(records, time_tables);
	END_PERF(q_begin, q_update, q_freq);

	START_PERF(q_begin);
	answer = get_answer(time_tables);
	END_PERF(q_begin, q_answer, q_freq);

	//for (int i = 0; i < records->size; i++) {
	//	printf("%d|%d|%d\n", INDEX(records, Record)[i].elapsed,
	//		INDEX(records, Record)[i].minutes,
	//		INDEX(records, Record)[i].id);
	//}

	printf("Answer = %d\n", answer);
	printf("parsing  = %lld us\n", q_parse);
	printf("sorting	 = %lld us\n", q_sort);
	printf("updating = %lld us\n", q_update);
	printf("answer   = %lld us\n", q_answer);

	return 0;
}

#ifdef _MSC_VER
#pragma warning(pop)
#endif
#ifdef __GNUC__
#pragma GCC diagnostic pop
#endif
