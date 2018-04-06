all: btree types.h rule table cyk main
	g++-4.7 -std=c++11 *.o -o main

main: main.cpp
	g++-4.7 -c -std=c++11 main.cpp

cyk: cyk.cpp
	g++-4.7 -c -std=c++11 cyk.cpp

btree: btree.cpp
	g++-4.7 -c -std=c++11 btree.cpp

rule: rule.cpp
	g++-4.7 -c -std=c++11 rule.cpp

table: table.cpp
	g++-4.7 -c -std=c++11 table.cpp

clean:
	rm *.o
	rm main