#ifndef TYPES
#define TYPES

#include "types.h"

#endif

#include <iostream>
#include <iomanip>

#include <string>
#include <vector>
#include <unordered_map>


/*
  Backpointer entry that can be either:
  - string
  - tuple of ((int, int, string), (int, int, string))
*/
class BPTableEntryItem{
public:
        virtual bool is_single(){};
};

class BPSingleEntry: public BPTableEntryItem{
public:
        BPSingleEntry(std::string _name): name(_name){};
        std::string name;

        bool is_single(){
                return true;
        }
};

class BPTupleEntry: public BPTableEntryItem{
public:
        BPTupleEntry(int _l1, int _l2, std::string _lname, int _r1, int _r2, std::string _rname):
                l1(_l1), l2(_l2), lname(_lname), r1(_r1), r2(_r2), rname(_rname){};

        int l1, l2, r1, r2;
        std::string lname, rname;

        bool is_single(){
                return false;
        }
};

void  print_dp_table(std::vector<std::vector<StringVector>> &table, int N);

typedef std::unordered_map<std::string, std::vector<BPTableEntryItem*>> BPTableEntry;
