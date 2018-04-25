#include "cyk.h"
#include <map>
#include <set>
using namespace std;

typedef std::set<string> SymbolsSet;
typedef std::map<string, RuleVector> RulesMap;
typedef std::map<string, int> SymbolIndices;

RulesMap rulesMap;
SymbolsSet symbols;
SymbolIndices symIndices;


void unaryRelax (int *** scores, int begin, int end, RuleVector& rules, SymbolsSet& symbols){
	int prob;
	RuleVector rulesList;
	set <string, int > :: iterator itr;
	
	//for all symbols
	for (itr = symbols.begin(); itr != symbols.end(); ++itr){
		rulesList = rulesMap[*itr];
		//for all rules of that symbol
		for(int k=0;k<rulesList.size();k++){
			//get only unary rules
			if(rulesList[k]->is_first_order()){

				//The rule is of the form A-> B. get the score of A>B and that symbol B is present at score [begin][end]
				prob = rulesList[k]->score * scores[begin][end][symIndices[rulesList[k]->right1]];

				// if the above score is greater than the score of B, then add A to the location [begin][end]
		     	if(prob > scores[begin][end][symIndices[rulesList[k]->left]]){
		     		scores[begin][end][symIndices[rulesList[k]->left]] = prob;
		     	}
         	}
		}
	}
}


void binaryRelax(int *** scores, int nWords, int length, RuleVector& rules, SymbolsSet& symbols){

	int end=0;
	int max = -1;
	RuleVector rulesList;
	int lscore=0, rscore =0,score=0;
	set <string, int > :: iterator itr;

	for(int start =0; start <=nWords-length; start++){
		
		end = start + length;
		
		//for all symbols
		for (itr = symbols.begin(); itr != symbols.end(); ++itr){
			max = -1;
			rulesList = rulesMap[*itr];
			for(int j=0;j<rulesList.size();j++){

				//TODO check if for unary rules, the right child is in right1
				if(rulesList[j]->is_second_order()){
					for (int split =start+1;split<=end-1;split++){
						lscore = scores[start][split][symIndices[rulesList[j]->right1]];
						rscore = scores[split][end][symIndices[rulesList[j]->right2]];
						score = rulesList[j]->score * lscore * rscore;

						if(score > max){
							max = score;
						}
					}
				}
			}
			scores[start][end][symIndices[*itr]]=max;
		}

		unaryRelax(scores, start, end, rules,symbols);
	}
}


void lexiconScores(int*** scores, const StringVector & words, RuleVector & rules, RuleVector & lexicons, SymbolsSet& symbols){
	RuleVector rulesList;
	set <string, int > :: iterator itr;

	//
	for(int i=0;i<words.size();i++){
		//for all symbols
		for (itr = symbols.begin(); itr != symbols.end(); ++itr){
			rulesList = rulesMap[*itr];
			//for all rules of that symbol
			for(int k=0;k<rulesList.size();k++){
				//if the rule produces that symbol on the RHS
				if(rulesList[k]->right1 == words[i]){
					//TODO we need to give number to each symbol
					//add score of that rule in the location
					scores[i][i+1][symIndices[*itr]] = rulesList[k]->score; 
				}
			}
				
		}

		unaryRelax(scores, i, i+1, rules,symbols);
		
	}
}

void printMatrix(int *** scores, int x, int y, int z){
	for (int i = 0; i < x; ++i)
	{
		for (int j = 0; j < y; ++j)
		{
			for (int k = 0; k < z; ++k)
			{
				cout<<" "<< scores[i][j][k]<<" ";
			}
			cout<<endl;
		}
	}
}


void cykParser(const StringVector & words, RuleVector & rules, RuleVector & lexicons, SymbolsSet& symbols){
	//size should be words.length, words.length, total non-terminals 
	int *** scores  = new int**[words.size()+1];
	for (int i = 0; i < words.size()+1; ++i)
	{
		scores[i] = new int*[words.size()+1];
		for (int j = 0; j < words.size()+1; ++j)
		{
			scores[i][j] = new int[symbols.size()];
		}
	}

	//[words.size()+1][symbols.size()];
	int nWords = words.size();
		
	lexiconScores(scores,words,rules,lexicons,symbols);

	for(int length =2; length<=nWords; length++){
		binaryRelax(scores,nWords,length,rules, symbols);
		
	}

	printMatrix(scores, words.size()+1,words.size()+1,symbols.size());
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
	fillSet(sym,lexicons);
}

void initializeSymbolIndices(SymbolsSet& symbols, SymbolIndices& symIndices){

	int count =0;
	set <string, int > :: iterator itr;
	for (itr = symbols.begin(); itr != symbols.end(); ++itr)
    {
    	symIndices[*itr] = count;
    	count++;
    }

}

void cykParserUtil(const StringVector & words, RuleVector & rules, RuleVector & lexicons){
	
	//Write initialization code
	initializeRulesMap(rulesMap, rules, lexicons);
	initializeSymbols(symbols,rules,lexicons);
	initializeSymbolIndices(symbols, symIndices);
	cykParser(words,rules,lexicons,symbols);

}
