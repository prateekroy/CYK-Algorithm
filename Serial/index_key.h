#include <string>
#include <unordered_map>

#ifndef TYPES
#define TYPES

#include "types.h"

#endif


struct IndexedRulesKey{
        std::string left, right;
        bool operator==(const IndexedRulesKey &other) const {
                return left == other.left && right == other.right;
        }

        std::string str(){
                return "\"" + left + "\", "+ "\"" + right + "\", ";
        }
};

namespace std {
        template <>
                struct hash<IndexedRulesKey>
        {
                std::size_t operator()(const IndexedRulesKey& k) const
                {
                        using std::size_t;
                        using std::hash;
                        using std::string;

                        // Compute individual hash values for first,
                        // second and third and combine them using XOR
                        // and bit shifting:

                        return ((hash<string>()(k.left)
                                         ^ (hash<string>()(k.right) << 1)) >> 1);
                }
        };
}

typedef std::unordered_map<IndexedRulesKey, StringVector> IndexedRules;
