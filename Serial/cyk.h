#ifndef RULE
#define RULE

#include "rule.h"

#endif




#ifndef BTREE
#define BTREE

#include "btree.h"
#endif




#ifndef INDEX_KEY
#define INDEX_KEY

#include "index_key.h"
#endif




#ifndef TYPES
#define TYPES

#include "types.h"
#endif




#ifndef TABLE
#define TABLE

#include "table.h"
#endif

#ifndef BP
#define BP

#include "bp.h"

#endif

#include <iostream>
#include <string>
#include <unordered_map>
#include <vector>

std::vector<BTreeNode*> cyk(const StringVector &  words, RuleVector & rules);

void cykParser(const StringVector & words, RuleVector & rules,RuleVector & lexicons);
void cykParserUtil(const StringVector & words, RuleVector & rules,RuleVector & lexicons);