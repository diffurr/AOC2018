#include <algorithm>
#include <vector>
#include <string>
#include <fstream>
#include <chrono>
#include <iostream>
#include <numeric>

class Polymer
{
	std::vector<char> polymer;

	bool isReaction(const char a, const char b)
	{
		return (a - b) == 32 || (a - b) == -32;
	}

public:
	Polymer(const std::string &str) :
		polymer(str.begin(), str.end()) {}

	void react();
	void filter(const char elem);
	size_t length() { return polymer.size(); }
	friend std::ostream& operator<< (std::ostream& os, const Polymer &p) {
		std::string str(p.polymer.begin(), p.polymer.end());
		return os << str;
	}
};

void Polymer::filter(const char elem)
{
	std::vector<char> newpoly;
	std::remove_copy_if(polymer.begin(), polymer.end(), std::back_inserter(newpoly),
		[elem](const char ch) { return (elem - ch) == 0 || (elem - ch) == 32 || (elem - ch) == -32; });
	newpoly.swap(polymer);
}

void Polymer::react()
{
	size_t reactions = 1;
	std::vector<char> newpoly;
	newpoly.reserve(polymer.size());

	while (reactions) {
		reactions = 0;
		auto it = polymer.begin();
		for (; it < polymer.end() - 1; it++) {
			if (isReaction(*it, *(it + 1))) {
				++reactions;
				++it;
			}
			else {
				newpoly.push_back(*it);
			}
		}
		if (it == polymer.end() - 1) newpoly.push_back(*it);

		newpoly.swap(polymer);
		newpoly.clear();
	}
}

int main(void)
{
	std::fstream fs;
	std::string input;

	auto start = std::chrono::high_resolution_clock::now();
	fs.open("input.txt", std::fstream::in);
	if (fs.fail()) {
		std::cout << "Can't open file.\n";
		return 1;
	}
	fs >> input;

	std::vector<size_t> lengths;
	std::vector<Polymer> polymers;
	std::vector<char> elements('Z' - 'A' + 1);
	std::iota(elements.begin(), elements.end(), 'A');

	for (auto it = elements.begin(); it != elements.end(); it++) {
		polymers.push_back(Polymer(input));
        polymers.back().filter(*it);
        polymers.back().react();
		lengths.push_back(polymers.back().length());
	}
	auto minit = std::min_element(lengths.begin(), lengths.end());
	auto end = std::chrono::high_resolution_clock::now() - start;

	std::cout << "Answer:  " << *minit << "\n";
	std::cout << "time:  " << std::chrono::duration_cast<std::chrono::milliseconds>(end).count() << " ms\n";

	return 0;
}
