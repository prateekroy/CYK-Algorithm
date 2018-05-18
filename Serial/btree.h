#include <string>

class BTreeNode {

public:

        std::string name;
        BTreeNode * left, * right;

        BTreeNode(std::string _name, BTreeNode *_left, BTreeNode *_right);
        BTreeNode(std::string _name, BTreeNode *_left);
        BTreeNode(std::string _name);

        std::string string_repr();

        bool has_single_child(){
                return left != NULL && right == NULL;
        }

        bool is_leaf(){
                return left == NULL && right == NULL;
        }
};
