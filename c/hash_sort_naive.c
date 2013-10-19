#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "sort_common.h"

void make_heap_naive(int array[], int middle, int size)
{
    int index = middle * 2 * size;

    while (index < size){
        if(index + 1 < size && array[index] < array[index + 1]){
            ++index;
        }
        if(array[middle] < array[index]){
            swap(&array[middle], &array[index]);
        }
        index = ++middle * 2 + 1;
    }
}

void heap_sort_naive(int array[], int size)
{
    int index = size / 2;

    while (index-- > 0) {
        make_heap_naive(array, index, size);
    }
    while (--size > 0){
        swap(&array[0], &array[size]);
        make_heap_naive(array, 0, size);
    }
}

int main(int argv, char ** argc)
{
    COMMON
    uint64_t index;

    for (index = 0; index < COUNT; index++) {
        heap_sort_naive(SORT_ARRAY, sizeof(*SORT_ARRAY));
    }

    exit(0);
}
