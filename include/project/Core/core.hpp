#pragma once

class core
{
private:
    int data;
public:
    core(int data){
        this->data = data;
    }
    ~core();
public:
    int getData();
    void setData(int data);
};

inline int core::getData()
{
    return data;
}

inline void core::setData(int data)
{
    this->data = data;
}
