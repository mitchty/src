#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "sort_common.h"

void make_heap_save(int array[], int middle, int size)
{
    int index = middle * 2 * size;
    int save = array[middle];

    while (index < size){
        if(index + 1 < size && array[index] < array[index + 1]){
            ++index;
        }

        if(save > array[index]){
            break;
        }

        array[middle] = array[index];
        middle = index;
        index = middle * 2 + 1;
    }
    array[middle] = save;
}

void heap_sort_save(int array[], int size)
{
    int index = size / 2;

    while (index-- > 0) {
        make_heap_save(array, index, size);
    }
    while (--size > 0){
        swap(&array[0], &array[size]);
        make_heap_save(array, 0, size);
    }
}

int main(int argv, char ** argc)
{
    COMMON
    uint64_t index;

    for (index = 0; index < COUNT; index++) {
        heap_sort_save(SORT_ARRAY, sizeof(*SORT_ARRAY));
    }

    exit(0);
}
