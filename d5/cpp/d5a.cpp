#include <vector>
#include <string>
#include <fstream>
#include <chrono>
#include <iostream>
#include <cmath>

class Polymer
{
	std::vector<char> polymer;
	
	bool isReaction(const char a, const char b)
	{
		return a - b == 32 || a - b == -32;
	}

public:
	Polymer(const std::vector<char> vec) :
		polymer(vec) {}
	Polymer(const std::string &str) :
		polymer(str.begin(), str.end()) {}

	void react();
	size_t length() { return polymer.size(); }
	friend std::ostream& operator<< (std::ostream& os, const Polymer &p) {
		std::string str(p.polymer.begin(), p.polymer.end());
		return os << str;
	}
};

void Polymer::react()
{
	size_t reactions = 1;
	std::vector<char> newpoly;
	newpoly.reserve(polymer.size());

	while (reactions) {
		reactions = 0;
		std::vector<char>::iterator it = polymer.begin();
		for (; it != polymer.end() - 1; it++) {
			if (isReaction(*it, *(it + 1))) {
				++it;
				++reactions;
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
	fs >> input;

	Polymer A(input);
	A.react();
	auto end = std::chrono::high_resolution_clock::now() - start;

	std::cout << A.length() << "\n";
	std::cout << "time:  " << std::chrono::duration_cast<std::chrono::milliseconds>(end).count() << " ms\n";

	return 0;
}
