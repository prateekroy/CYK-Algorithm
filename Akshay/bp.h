#include <string>
using namespace std;

class backpointer{

public:
	string right1;
	string right2;
	int split;

	backpointer(string _right1, string _right2, int _split){
		right1 = _right1;
		right2 = _right2;
		split = _split;
	}

	void setBP(string _right1, string _right2, int _split){
		right1 = _right1;
		right2 = _right2;
		split = _split;
	}

};