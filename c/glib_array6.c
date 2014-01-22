#include <stdio.h>
#include <stdlib.h>
#include <glib.h>

void print_array(GArray *a);
void print_array(GArray *a) {
  printf("Array holds: ");

  for (guint i = 0; i < a->len; i++)
    printf("%d ", g_array_index(a, int, i));

  printf("\n");
}

int compare_ints(gpointer a, gpointer b);
int compare_ints(gpointer a, gpointer b) {
  int *x = (int *)a;
  int *y = (int *)b;
  return *x - *y;
}

int main(void) {
  GArray *a = g_array_new(FALSE, FALSE, sizeof(int));
  int x[6] = { 2, 1, 6, 5, 4, 3 };
  g_array_append_vals(a, &x, 6);
  print_array(a);
  g_array_sort(a, (GCompareFunc)compare_ints);
  print_array(a);
  g_array_free(a, FALSE);
}
