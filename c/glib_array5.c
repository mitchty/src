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

int main(void) {
  GArray *a = g_array_new(FALSE, FALSE, sizeof(int));
  int x[6] = { 1, 2, 3, 4, 5, 6 };
  g_array_append_vals(a, &x, 6);
  print_array(a);
  g_array_remove_index(a, 0);
  print_array(a);
  g_array_remove_range(a, 0, 2);
  print_array(a);
  g_array_remove_index_fast(a, 0);
  print_array(a);
  g_array_free(a, FALSE);
}
