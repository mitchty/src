#include <stdint.h>

void swap(int *lhs, int *rhs)
{
    int tmp = *lhs;
    *lhs = *rhs;
    *rhs = tmp;
}

int sorted(int array[], int len)
{
    int i;

    for (i = 0; i < (len-1); i++){
        if(array[i] > array[i+1]){
            return 0;
        }
    }
    return 1;
}

struct node {
    int data;
    struct node *next;
};

struct list {
    int size;
    struct node *head;
};

#define COMMON \
int SORT_ARRAY[] = {5, 100, 20, 50, 6, 0, 250, 400}; \
uint64_t COUNT = 500000001;
