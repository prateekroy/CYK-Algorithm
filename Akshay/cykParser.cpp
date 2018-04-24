#include "cyk.h"
#include <map>
using namespace std;

typedef std::set<string> SymbolsSet;
typedef std::map<string, RuleVector> RulesMap;
RulesMap rulesMap;
SymbolsSet symbols;


void binaryRelax(int *** scores, int nWords, int Length, RuleVector& rules){

	int end=0;
	int max = -1;
	RuleVector rulesList;
	int lscore=0, rscore =0,score=0;

	for(int start =0; start <=nWords-length; start++){
		
		end = start + length;
		for(int i=0; i<symbols.size(); i++){
			max = -1;
			rulesList = rulesMap[symbols[i]];
			for(int i=0;i<rulesList.size();i++){

				for (int split =start+1;split<=end-1;split++){
					lscore = scores[start][split][rulesList[i].right1];
					rscore = scores[split][end][rulesList[i].right2];
					score = rule_score + lscore + rscore;

					if(score < max){
						max = score;
					}
				}

			}
			scores[start][end][symbol]=max;
		}

	}

}


void unaryRelax (int *** scores, int begin, int end, RuleVector& rules, SymbolsSet& symbols, string lastSymbol){
	int prob;
	for(int j=0;j<symbols.size();j++){
		rulesList = rulesMap[symbols];
		for(int k=0;k<rulesList.size();k++){
			//get only unary rules

			prob = rulesList[k]->score * score[begin][end][rulesList[k]->right1];
         	if(prob > score[begin][end][rulesList[k]->left]){
         		score[begin][end][rulesList[k]->left] = prob;
         	}
            	 
         /*
			if(rulesList[k]->right1 == words[i]){
				//TODO we need to give number to each symbol
				scores[i][i][symbols[j]] = rulesList[k]->score; 
			}*/
		}
	}
}

void lexiconScores(int*** scores, const StringVector & words, RuleVector & rules, RuleVector & lexicons, SymbolsSet& symbols){
	RuleVector rulesList;
	for(int i=0;i<words.size();i++){
		for(int j=0;j<symbols.size();j++){
			rulesList = rulesMap[symbols[j]];
			for(int k=0;k<rulesList.size();k++){
				if(rulesList[k]->right1 == words[i]){
					//TODO we need to give number to each symbol
					scores[i][i][symbols[j]] = rulesList[k]->score; 
				}
			}
			unaryRelax(scores, i, i, rules,symbols,symbols[j]);	
		}
		
	}
}

void cykParser(const StringVector & words, RuleVector & rules, RuleVector & lexicons, SymbolsSet& symbols){
	//size should be words.length, words.length, total non-terminals 
	int scores [][][] = new int[words.size()][words.size()][symbols.size()];
	int nWords = words.size();
		
	lexiconScores(scores,words,nWords,lexicons,symbols);

	for(int length =2; length<=nWords; length++){
		binaryRelax(scores,nWords,length,rules);

		//TODO implement below fn call
		//unaryRelax(scores,nWords,length,rules);
	}
	//tree = backtrackBestParseTree(scores);
	//return tree;
}

void fillMap(RulesMap& map, RuleVector& rules){
	string key;
	for(auto i = 0; i < rules.size(); ++i){
                key = rules[i]->left;
                if(map.find(key)  == map.end()){ // key not exist
                        map[key] = RuleVector {};
                }
                map[key].push_back(rules[i]);
        }
}	

void fillSet(SymbolsSet& sym, RuleVector& rules){
	string key;
	for(auto i = 0; i < rules.size(); ++i){
            key = rules[i]->left;
            if(sym.find(key)  == sym.end()){ // key not exist
                    sym.insert(key);
            }
    }
}	

void initializeRulesMap(RulesMap & map, RuleVector & rules, RuleVector & lexicons){
	
	fillMap(map,rules);
	fillMap(map,lexicons);	
}

void initializeSymbols(SymbolsSet& sym,RuleVector & rules, RuleVector & lexicons){
	fillSet(sym,rules);
	fillSet(sym,lexicons)
}

void cykParserUtil(const StringVector & words, RuleVector & rules, RuleVector & lexicons){
	
	//Write initialization code
	initializeRulesMap(&rulesMap, rules, lexicons);
	initializeSymbols(&symbols,rules,lexicons);
	cykParser(words,rules,lexicons,symbols);

}
