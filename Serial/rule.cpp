#include "rule.h"

Rule::Rule(std::string _l, std::string _r1, std::string _r2, int _score):
        left(_l), right1(_r1), right2(_r2), score(_score){};

Rule::Rule(std::string _l, std::string _r1, int _score):
        left(_l), right1(_r1), right2(""), score(_score){};
