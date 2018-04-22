#include "cyk.h"
#include "cykParser.h"
#include <iostream>

int main(){
        RuleVector rules  {new Rule("S", "NP", "VP", 1), // **QUESTION**: how to make it on the stack?
                        new Rule("S", "X1", "VP", 1),
                        new Rule("X1", "AUX", "NP", 1),
                        new Rule("S", "book", 1),
                        new Rule("S", "include", 1),
                        new Rule("S", "prefer", 1),
                        new Rule("S", "VERB", "NP", 1),
                        new Rule("S", "X2", "PP", 1),
                        new Rule("S", "VERB", "PP", 1),
                        new Rule("S", "VP", "PP", 1),
                        new Rule("NP", "I", 1),
                        new Rule("NP", "she", 1),
                        new Rule("NP", "me", 1),
                        new Rule("NP", "TWA", 1),
                        new Rule("NP", "Houston", 1),
                        new Rule("NP", "DET", "NOMINAL", 1),
                        new Rule("NOMINAL", "book", 1),
                        new Rule("NOMINAL", "flight", 1),
                        new Rule("NOMINAL", "meal", 1),
                        new Rule("NOMINAL", "money", 1),
                        new Rule("NOMINAL", "NOMINAL", "NOUN", 1),
                        new Rule("NOMINAL", "NOMINAL", "PP", 1),
                        //lexicons
                        new Rule("VP", "book", 1),
                        new Rule("VP", "include", 1),
                        new Rule("VP", "prefer", 1),
                        new Rule("VP", "VERB", "NP", 1),
                        new Rule("VP", "X2", "PP", 1),
                        new Rule("X2", "VERB", "NP", 1),
                        new Rule("VP", "VERB", "PP", 1),
                        new Rule("VP", "VP", "PP", 1),
                        new Rule("PP", "PREPOSITION", "NP", 1),
                        new Rule("DET", "that" , 1),
                        new Rule("DET", "this", 1),
                        new Rule("DET", "a", 1),
                        new Rule("DET", "the", 1),
                        new Rule("NOUN", "book", 1),
                        new Rule("NOUN", "flight", 1),
                        new Rule("NOUN", "meal", 1),
                        new Rule("NOUN", "money", 1),
                        new Rule("VERB", "book", 1),
                        new Rule("VERB", "include", 1),
                        new Rule("VERB", "prefer", 1),
                        new Rule("PRONOUN", "I", 1),
                        new Rule("PRONOUN", "she", 1),
                        new Rule("PRONOUN", "me", 1),
                        new Rule("PROPER-NOUN", "TWA", 1),
                        new Rule("PROPER-NOUN", "Houston", 1),
                        new Rule("AUX", "does", 1),
                        new Rule("PREPOSITION", "from", 1),
                        new Rule("PREPOSITION", "to", 1),
                        new Rule("PREPOSITION", "on", 1),
                        new Rule("PREPOSITION", "near", 1),
                        new Rule("PREPOSITION", "through", 1),
                        new Rule("S", "Book", 1)};

        StringVector sents {"does", "the", "flight", "include", "a", "meal"};

        //std::vector<BTreeNode*> parses = cyk(sents, rules);
        cykParser(sents,rules);

        for(auto tree : parses){
                std::cout << tree->string_repr() << std::endl;
        }

        //remember to destroy the rules
        return 0;
}