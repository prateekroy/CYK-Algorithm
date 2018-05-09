#include "cyk.h"
#include <map>
#include <set>
// #include <cilk/cilk.h>
using namespace std;

typedef std::vector<string> SymbolsSet;
typedef std::map<string, RuleVector> RulesMap;
typedef std::map<string, int> SymbolIndices;
typedef std::map<string, RuleVector> LexiconsMap;

RulesMap rulesMap;
LexiconsMap lexiconsMap;
SymbolsSet symbols;
SymbolIndices symIndices;


void unaryRelax (int *** scores, int begin, int end, RuleVector& rules, SymbolsSet& symbols, backpointer**** bp){
	cout<<endl<<endl<<endl<<"In Unary Relax"<<endl;
	int prob=0;
	RuleVector rulesList;
	std::vector<string>::iterator itr;
	
	//for all symbols
	for (itr = symbols.begin(); itr != symbols.end(); ++itr){
		rulesList = rulesMap[*itr];
		//for all rules of that symbol
		for(int k=0;k<rulesList.size();k++){
			//get only unary rules
			if(rulesList[k]->is_first_order()){

				//The rule is of the form A-> B. get the score of A>B and that symbol B is present at score [begin][end]
				prob = rulesList[k]->score + scores[begin][end][symIndices[rulesList[k]->right1]];

				// if the above score is greater than the score of B, then add A to the location [begin][end]
		     	if(prob > scores[begin][end][symIndices[rulesList[k]->left]]){
		     		scores[begin][end][symIndices[rulesList[k]->left]] = prob;
		     		// cout << rulesList[k]->left << " ----> "<<rulesList[k]->right1 << endl;
		     		bp[begin][end][symIndices[rulesList[k]->left]]->setBP(rulesList[k]->right1,"",0);
		     	}
         	}
		}
	}
}


void binaryRelax(int *** scores, int nWords, int length, RuleVector& rules, SymbolsSet& symbols, backpointer**** bp){
	cout<<endl<<endl<<endl<<"In Binary Relax"<<endl;
	int end=0;
	int max = -1;
	RuleVector rulesList;
	int lscore=0, rscore =0,score=0;
	std::vector<string> :: iterator itr;
	string right1="", right2="";
	int bpSplit=-1;

	for(int start =0; start <=nWords-length; start++){
		
		end = start + length;
		
		//for all symbols
		for (itr = symbols.begin(); itr != symbols.end(); ++itr){
			max = 0;
			rulesList = rulesMap[*itr];
			for(int j=0;j<rulesList.size();j++){

				//TODO check if for unary rules, the right child is in right1
				if(rulesList[j]->is_second_order()){
					for (int split =start+1;split<=end-1;split++){
						lscore = scores[start][split][symIndices[rulesList[j]->right1]];
						rscore = scores[split][end][symIndices[rulesList[j]->right2]];
						score = rulesList[j]->score + lscore + rscore;

						if(score > max){
							max = score;
							bpSplit = split;
							right1 = rulesList[j]->right1;
							right2 = rulesList[j]->right2;
							// cout<<rulesList[j]->left<<" ------> "<<rulesList[j]->right1<<" "<<rulesList[j]->right2;
						}
					}
				}
			}
			scores[start][end][symIndices[*itr]]=max;
			bp[start][end][symIndices[*itr]]->setBP(right1,right2,bpSplit);

			// cout << right1 << " " << right2 << endl;
			
		}

		unaryRelax(scores, start, end, rules,symbols, bp);
	}
}

struct IntRule{
	int leftsymIndex;
	int right1symIndex;
	int right2symIndex;
	int score;
};


__global__
static void MyFunc2D(IntRule* drules, int r, int* dscores, int A, int B, int C, int start, int end, int* sh_max) {
  int i = blockIdx.x*blockDim.x + threadIdx.x;
  	
  //Debug Code
  if (i == 0)
  {
	// for (int i = 0; i < r; ++i)
	// {
	// 	printf("%d -> %d %d\n", drules[i].leftsymIndex, drules[i].right1symIndex, drules[i].right2symIndex);
	// }
	// for (int u = 0; u < A; ++u)
	// {
	// 	for (int v = 0; v < B; ++v)
	// 	{
	// 	  for (int w = 0; w < C; ++w)
	// 	  {
	// 	    printf("%d ", dscores[u + B * (v + C * w)]);
	// 	  }
	// 	  printf("\n");
	// 	}
	// 	printf("\n");
	// }

  }



  if (i < r)
  {
  		  // printf("Index %d ", i);
		{
			int l_sym = drules[i].right1symIndex;
			int r_sym = drules[i].right2symIndex;
			int symbol = drules[i].leftsymIndex;

			int local_max = 0;
			// int bpSplit=-1;
			// string right1 = "";
			// string right2 = "";

			for (int split =start+1;split<=end-1;split++){
				int lscore = 0;
				int rscore = 0;

				// start + B * (split + C * l_sym)
				// https://stackoverflow.com/questions/7367770/how-to-flatten-or-index-3d-array-in-1d-array
				// (z * xMax * yMax) + (y * xMax) + x;
				int one = (l_sym*A*B) + (split*A) + start;	
				lscore = dscores[one];
	
				int two = (r_sym*A*B) + (end*A) + split;
				rscore = dscores[two];

				int score = drules[i].score + lscore + rscore;

				if(score > local_max){
					local_max = score;
					printf("symbol : %d local_max : %d l_score : %d r_score : %d score : %d\n", symbol, local_max, lscore, rscore, score);

					//needed for backpointer
					// bpSplit = split;
					// right1 = l_sym;
					// right2 = r_sym;

				}
			}	

			//atomic max // for now use lock

			atomicMax(&sh_max[symbol], local_max);
			// bp[start][end][symIndices[symbol]]->setBP(right1,right2,bpSplit);
		}		
  }
}



IntRule* ConvertRule(RuleVector& rules)
{
	IntRule* ruleArr = new IntRule[rules.size()];
	for (int i = 0; i < rules.size(); ++i)
	{
		ruleArr[i].leftsymIndex = symIndices[rules[i]->left];
		ruleArr[i].right1symIndex = symIndices[rules[i]->right1];
		ruleArr[i].right2symIndex = symIndices[rules[i]->right2];
		ruleArr[i].score = rules[i]->score;
	}

	return ruleArr;
}

int to1D( int x, int y, int z , int xMax, int yMax, int zMax) {
    return (z * xMax * yMax) + (y * xMax) + x;
}

int* ConvertScore(int*** score, int A, int B, int C)
{
  int* hscore;// = new int[A*B*C*10];
  cudaMallocHost((void**)&hscore, A*B*C*sizeof(int));


  for (int i = 0; i < A; ++i)
  {
    for (int j = 0; j < B; ++j)
    {
      for (int k = 0; k < C; ++k)
      {
        // hscore[i + B * (j + C * k)] = score[i][j][k];
      	hscore[to1D(i, j, k, A, B, C)] = score[i][j][k];
      }
    }
  }


  return hscore;
}

int* ConvertToCudaDevice(int* a, int n){
  int* d;
  cudaMalloc((void**)&d, n*sizeof(int));
  cudaMemcpy(d, a, n*sizeof(int), cudaMemcpyHostToDevice);

  return d;
}

IntRule* ConvertRuleTOCudaDevice(IntRule* rules, int N){

  IntRule* drules;
  cudaMalloc((void**)&drules, N*sizeof(IntRule));
  cudaMemcpy(drules, rules, N*sizeof(IntRule), cudaMemcpyHostToDevice);	

  return drules;
}

void threadBasedRuleBR(int *** scores, int nWords, int length, RuleVector& rules, SymbolsSet& symbols, backpointer**** bp, int A, int B, int C){

	cout << "Baby i am here " <<  A << " " << B << " " << C << " " << symbols.size() << " " << nWords << endl; 

	IntRule* hrules = ConvertRule(rules);
	IntRule* drules = ConvertRuleTOCudaDevice(hrules, rules.size());


	for(int start =0; start <=nWords-length; start++){
		// for (int i = 0; i < A; ++i)
		// {
		// 	for (int j = 0; j < B; ++j)
		// 	{
		// 		for (int k = 0; k < C; ++k)
		// 		{
		// 			cout << scores[i][j][k] << " ";
		// 		}
		// 	}
		// }

		// cout << endl;
		// cout << "\n******************************************\n";


		int* arr = ConvertScore(scores, A, B, C);
		int* dscores = ConvertToCudaDevice(arr, A*B*C);
		// int* dscores;
		// cudaMalloc((void**)&dscores, A*B*C*sizeof(int));
		// cudaMemset(dscores, 0, A*B*C*sizeof(int));
		// cudaMemcpy(dscores, arr, A*B*C*sizeof(int), cudaMemcpyHostToDevice);

		
		int end = start + length;
		int* shared_max = new int[symbols.size()];
		for (int i = 0; i < symbols.size(); ++i)
		{
			shared_max[i] = 0;
		}

		int* sh_max = ConvertToCudaDevice(shared_max, symbols.size());

		// int** testy = alloc2d();
	  	MyFunc2D<<<1, rules.size()*2>>>(drules, rules.size(), dscores, A, B, C, start, end, sh_max);


	  	cudaMemcpy(shared_max, sh_max, symbols.size()*sizeof(int), cudaMemcpyDeviceToHost);

	  	for (int i = 0; i < symbols.size(); ++i)
	  	{
	  		cout << shared_max[i] << " ";
	  	}
	  	cout << "\n@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n";

		//make this parallel for
		for (std::vector<string>::iterator itr = symbols.begin(); itr != symbols.end(); ++itr){
			scores[start][end][symIndices[*itr]] = max(scores[start][end][symIndices[*itr]], shared_max[symIndices[*itr]]);	
		}



		unaryRelax(scores, start, end, rules,symbols, bp);
	}	
}


#include <mutex>
std::mutex guard;
void threadBasedRuleBRcpu(int *** scores, int nWords, int length, RuleVector& rules, SymbolsSet& symbols, backpointer**** bp){




	for(int start =0; start <=nWords-length; start++){
		
		int end = start + length;
		int* shared_max = new int[symbols.size()];
		for (int i = 0; i < symbols.size(); ++i)
		{
			shared_max[i] = 0;
		}

		for (int i = 0; i < rules.size(); ++i)
		{
			string l_sym = rules[i]->right1;
			string r_sym = rules[i]->right2;
			string symbol = rules[i]->left;

			int local_max = 0;
			int bpSplit=-1;
			string right1 = "";
			string right2 = "";

			for (int split =start+1;split<=end-1;split++){
				int lscore = scores[start][split][symIndices[l_sym]];
				int rscore = scores[split][end][symIndices[r_sym]];
				int score = rules[i]->score + lscore + rscore;

				if(score > local_max){
					local_max = score;

					printf("symbol : %d local_max : %d l_score : %d r_score : %d score : %d\n", symIndices[symbol], local_max, lscore, rscore, score);
					//needed for backpointer
					bpSplit = split;
					right1 = l_sym;
					right2 = r_sym;

				}
			}	

			//atomic max // for now use lock
			guard.lock();
			shared_max[symIndices[symbol]] = max(shared_max[symIndices[symbol]], local_max);
			bp[start][end][symIndices[symbol]]->setBP(right1,right2,bpSplit);
			guard.unlock();								
		}

	  	for (int i = 0; i < symbols.size(); ++i)
	  	{
	  		cout << shared_max[i] << " ";
	  	}
	  	cout << "\n@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n";


		//make this parallel for
		for (std::vector<string>::iterator itr = symbols.begin(); itr != symbols.end(); ++itr){
			scores[start][end][symIndices[*itr]] = max(scores[start][end][symIndices[*itr]], shared_max[symIndices[*itr]]);			
		}

			// scores[start][end][symIndices[*itr]]=local_max;
			// // cout << right1 << " " << right2 << endl;
			// bp[start][end][symIndices[*itr]]->setBP(right1,right2,bpSplit);

		unaryRelax(scores, start, end, rules,symbols, bp);
	}	
}




//Parallel Binary Relax
void blockBasedRuleBR(int *** scores, int nWords, int length, RuleVector& rules, SymbolsSet& symbols, backpointer**** bp){

	for(int start =0; start <=nWords-length; start++){
		
		int end = start + length;
		int* shared_max = new int[symbols.size()];
		for (int i = 0; i < symbols.size(); ++i)
		{
			shared_max[i] = 0;
		}

		for (int i = 0; i < nWords; ++i)
		{
			for (int j = 0; j < nWords; ++j)
			{
				for (int k = 0; k < symbols.size(); ++k)
				{
					cout << scores[i][j][k] << " ";
				}
			}
		}

		cout << endl;
		cout << "\n******************************************\n";
	
		// #pragma cilk grainsize = 1
		//for all symbols
		//make the for parallel
		for (std::vector<string>::iterator itr = symbols.begin(); itr != symbols.end(); ++itr){
			int local_max = 0;
			RuleVector rulesList = rulesMap[*itr];
			string right1="", right2="";
			int bpSplit=-1;

			//For each binary rule in the grammar
			for(int j=0;j<rulesList.size();j++){

				//TODO check if for unary rules, the right child is in right1
				if(rulesList[j]->is_second_order()){
					for (int split =start+1;split<=end-1;split++){
						int lscore = scores[start][split][symIndices[rulesList[j]->right1]];
						int rscore = scores[split][end][symIndices[rulesList[j]->right2]];
						int score = rulesList[j]->score + lscore + rscore;

						if(score > local_max){
							local_max = score;

							//needed for backpointer
							bpSplit = split;
							right1 = rulesList[j]->right1;
							right2 = rulesList[j]->right2;

						}
					}
				}
			}

			//atomic max // for now use lock
			guard.lock();
			shared_max[symIndices[*itr]] = max(shared_max[symIndices[*itr]], local_max);
			bp[start][end][symIndices[*itr]]->setBP(right1,right2,bpSplit);
			guard.unlock();
		}

	  	for (int i = 0; i < symbols.size(); ++i)
	  	{
	  		cout << shared_max[i] << " ";
	  	}
	  	cout << "\n@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n";

		//make this parallel for
		for (std::vector<string>::iterator itr = symbols.begin(); itr != symbols.end(); ++itr){
			scores[start][end][symIndices[*itr]] = max(scores[start][end][symIndices[*itr]], shared_max[symIndices[*itr]]);	
		}




			// scores[start][end][symIndices[*itr]]=local_max;
			// // cout << right1 << " " << right2 << endl;
			// bp[start][end][symIndices[*itr]]->setBP(right1,right2,bpSplit);

		unaryRelax(scores, start, end, rules,symbols, bp);
	}
}




void lexiconScores(int*** scores, const StringVector & words, RuleVector & rules, RuleVector & lexicons, SymbolsSet& symbols, backpointer**** bp){
	cout<<endl<<endl<<endl<<"In Lexicon Scores"<<endl;
	RuleVector rulesList;
	std::vector<string> :: iterator itr;

	//for all words
	for(int i=0;i<words.size();i++){
		//for all symbols
		for (itr = symbols.begin(); itr != symbols.end(); ++itr){
			rulesList = lexiconsMap[*itr];
			//for all rules of that symbol
			for(int k=0;k<rulesList.size();k++){
				//if the unary rule produces that symbol on the RHS
				if(rulesList[k]->is_first_order()){
					if(rulesList[k]->right1 == words[i]){
						
						//add score of that rule in the location
						scores[i][i+1][symIndices[*itr]] = rulesList[k]->score;
						cout<<rulesList[k]->left<<" ------> "<<rulesList[k]->right1;
					}
				}
			}
				
		}
		cout<<endl;
		unaryRelax(scores, i, i+1, rules,symbols, bp);
		
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

void printBPTree(backpointer**** bp, int start, int end, string symbol, const StringVector & words){

	if (symIndices.find(symbol) == symIndices.end())
	{
		cout << symbol << "not found\n";
		return;
	}

	int symIndex = symIndices[symbol];
	backpointer* curr = bp[start][end][symIndex];

	cout << "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n";

	cout << symbol << " -> " << curr->right1 <<" "<< curr->right2 << endl;
	if(curr->right1 =="" && curr->right2 ==""){
		cout<<words[start]<<endl;
	}

	cout << "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n";

	int split = (curr->split != 0) ? curr->split : 0;

	if(curr->right1 != ""){
		printBPTree(bp, start, split, curr->right1,words);
	}

	if (curr->right2 != "")
	{
		printBPTree(bp, split, end, curr->right2,words);
	}

}
#include <unistd.h>
void cykParser(const StringVector & words, RuleVector & rules, RuleVector & lexicons, SymbolsSet& symbols){
	//size should be words.length, words.length, total non-terminals 

	cout<<" Size of words "<<words.size()+1<<endl;
	cout<<" Size of symbols "<<symbols.size()+1<<endl;

	int *** scores  = new int**[words.size()+1];
	backpointer**** bp = new backpointer***[words.size()+1];

	for (int i = 0; i < words.size()+1; ++i)
	{
		scores[i] = new int*[words.size()+1];
		bp[i] = new backpointer**[words.size()+1];

		for (int j = 0; j < words.size()+1; ++j)
		{
			scores[i][j] = new int[symbols.size()];
			bp[i][j] = new backpointer*[symbols.size()];


			for (int k = 0; k < symbols.size(); ++k)
			{
				scores[i][j][k]=0;
				bp[i][j][k]= new backpointer("","",-1);
			}
		}
	}

	//[words.size()+1][symbols.size()];
	int nWords = words.size();
		
	lexiconScores(scores,words,rules,lexicons,symbols,bp);

	for(int length =2; length<=nWords; length++){
		// binaryRelax(scores,nWords,length,rules, symbols, bp);
		// blockBasedRuleBR(scores,nWords,length,rules, symbols, bp);
		// threadBasedRuleBRcpu(scores,nWords,length,rules, symbols, bp);

		threadBasedRuleBR(scores,nWords,length,rules, symbols, bp, words.size()+1, words.size()+1, symbols.size());
	}

	printMatrix(scores, words.size()+1,words.size()+1,symbols.size());
	// printBPTree(bp, 0, words.size(), "S",words);
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

#include <algorithm>
void fillSet(SymbolsSet& sym, RuleVector& rules){
	string key;
	for(auto i = 0; i < rules.size(); ++i){
            key = rules[i]->left;
            if (std::find(sym.begin(), sym.end(), key) == sym.end() )
            {
            	sym.push_back(key);
            }
    }
}	

void initializeRulesMap(RulesMap & map, RuleVector & rules, RuleVector & lexicons){
	
	fillMap(map,rules);
	//fillMap(map,lexicons);	
}

void initializeLexiconsMap(RulesMap & map, RuleVector & lexicons){
	fillMap(map,lexicons);	
}

void initializeSymbols(SymbolsSet& sym,RuleVector & rules, RuleVector & lexicons){
	fillSet(sym,rules);
	fillSet(sym,lexicons);
}

void initializeSymbolIndices(SymbolsSet& symbols, SymbolIndices& symIndices){

	int count =0;
	vector<string> :: iterator itr;
	for (itr = symbols.begin(); itr != symbols.end(); ++itr)
    {
    	symIndices[*itr] = count;
    	count++;
    }

}

void cykParserUtil(const StringVector & words, RuleVector & rules, RuleVector & lexicons){
	
	//Write initialization code
	initializeRulesMap(rulesMap, rules, lexicons);
	initializeLexiconsMap(lexiconsMap,lexicons);
	initializeSymbols(symbols,rules,lexicons);
	initializeSymbolIndices(symbols, symIndices);
	cykParser(words,rules,lexicons,symbols);

}