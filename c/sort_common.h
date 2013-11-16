#include <stdint.h>
#include <stdlib.h>

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

#define VECSIZE(array) (int)(sizeof(array)/sizeof((array)[0]))

int SORT_ARRAY[] = {5, 100, 20, 50, 6, 0, 250, 400, 1000};
const uint64_t COUNT = 500000001;
int **_work_set;


void _reset_work_set() {
    int _array_size = VECSIZE(SORT_ARRAY);
    *_work_set = malloc(_array_size * sizeof(int));
    memcpy(*_work_set, SORT_ARRAY, sizeof(SORT_ARRAY));
};

void _free_work_set() {
    free(_work_set);
}
