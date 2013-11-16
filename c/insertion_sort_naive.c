#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "sort_common.h"

void insertion_sort_naive(int array[], int size)
{
    int i;

    for ( i = 1; i < size; i++ ) {
        int j, save = array[i];
        for ( j = i; j >= 1 && array[j-1] > save; j-- ) {
            array[j] = array[j - 1];
        }
        array[j] = save;
    }
}

int main(int argv, char ** argc)
{
    uint64_t index;

    for (index = 0; index < COUNT; index++) {
        insertion_sort_naive(SORT_ARRAY, sizeof(*SORT_ARRAY));
    }

    exit(0);
}
