#include "table.h"

void  print_dp_table(std::vector<std::vector<StringVector>> &table, int N){
        int width = 20;
        std::cout << "\t";
        for(int j = 0; j < N; ++j){
                std::cout << std::setw(width) << j; //the jth column
        }

        //-- line separation
        std::cout << std::endl;
        for(int i=0; i < (1+N)*width; ++i){
                std::cout << "-";
        }
        std::cout << std::endl;


        for(int i = 0; i < N; ++i){
                std::cout << i << "\t"; //the ith row
                for(int j = 0; j < N; ++j){
                        std::string cell_content = "";
                        for(auto &stuff : table.at(i).at(j)){
                                cell_content += (stuff + " ");
                        }
                        std::cout  << std::setw(width) << cell_content;
                }
                //-- line separation
                std::cout << std::endl;
                for(int i=0; i < (1+N)*width; ++i){
                        std::cout << "-";
                }
                std::cout << std::endl;
        }
}
