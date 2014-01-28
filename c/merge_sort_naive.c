#include <stdio.h>
#include <stdlib.h>
#include "sort_common.h"

void print_list(int *list, int len) {
  int i;

  printf("[");

  for (i = 0; i < len; i++)
    printf("%d ", list[i]);

  printf("]\n");
}

void merge(int *arr, int size1, int size2) {
  int temp[size1 + size2];
  int idx1 = 0;
  int idx2 = 0;

  while (idx1 + idx2 < size1 + size2) {
    if (idx1 < size1 && arr[idx1] <= arr[size1 + idx2] ||
        idx1 < size1 && idx2 >= size2) {
      temp[idx1 + idx2] = arr[idx1];
      idx1++;
    }

    if (idx2 < size2 && arr[size1 + idx2] <= arr[idx1] ||
        idx2 < size2 && idx1 >= size1) {
      temp[idx1 + idx2] = arr[size1 + idx2];
      idx2++;
    }
  }

  for (int i = 0; i < size1 + size2; i++)
    arr[i] = temp[i];
}

void merge_sort_naive(int *arr, int size) {
  if (size == 1)
    return;

  int size1 = size / 2;
  int size2 = size - size1;

  merge_sort_naive(arr, size1);
  merge_sort_naive(arr + size1, size2);
  merge(arr, size1, size2);
}

int main(int argc, char **argv) {
  //  for (uint64_t index = 0; index < COUNT; index++) {
  _reset_work_set();
  print_list(*_work_set, VECSIZE(*_work_set));
  merge_sort_naive(*_work_set, VECSIZE(_work_set));
  print_list(*_work_set, VECSIZE(*_work_set));
  //  }

  _free_work_set();

  return 0;
}
