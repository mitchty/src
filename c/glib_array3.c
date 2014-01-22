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
  printf("Array is empty\n");
  int x[2] = { 4, 5 };
  g_array_append_vals(a, &x, 2);
  print_array(a);
  printf("Prepending values\n");
  int y[2] = { 2, 3 };
  g_array_prepend_vals(a, &y, 2);
  print_array(a);
  printf("Some more prepending\n");
  int z = 1;
  g_array_prepend_val(a, z);
  print_array(a);
  g_array_free(a, FALSE);
}
