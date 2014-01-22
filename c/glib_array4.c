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
  int x[2] = { 1, 5 };
  g_array_append_vals(a, &x, 2);
  print_array(a);
  printf("Insert '2'\n");
  int b = 2;
  g_array_insert_val(a, 1, b);
  print_array(a);
  printf("Inserting multiple values\n");
  int y[2] = { 3, 4 };
  g_array_insert_vals(a, 2, y, 2);
  print_array(a);
  g_array_free(a, FALSE);
}
