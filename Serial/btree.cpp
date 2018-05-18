#include "btree.h"

BTreeNode::BTreeNode(std::string _name, BTreeNode *_left, BTreeNode *_right):
        name(_name), left(_left), right(_right){};

BTreeNode::BTreeNode(std::string _name, BTreeNode *_left):
        name(_name), left(_left), right(NULL){};

BTreeNode::BTreeNode(std::string _name):
        name(_name), left(NULL), right(NULL){};

std::string BTreeNode::string_repr(){
        if(is_leaf()){
                return "'" + name + "'";
        }
        else if(has_single_child()){
                return "('" + name + "', '" + left->string_repr() +"'" + ")";
        }
        else{
                std::string left_str = left->string_repr(), right_str = right->string_repr();
                return "('" + name + "', '" + left_str + "', '" + right_str + "')";
        }
};
