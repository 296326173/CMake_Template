#include <iostream>
#include <project/tmp.hpp>
#include <project/Core/core.hpp>
using namespace std;


int main()
{
    cout << "hello world!!!" << '\n';
    cout << tmp::add(1, 3);
    cout << "hello world!!!" << '\n';
    core co(3);
    co.add(3);
    cout << co.getData() << endl;
    return 0;
}