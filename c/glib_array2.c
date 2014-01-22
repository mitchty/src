#include <stdio.h>
#include <stdlib.h>
#include <glib.h>

int main(void) {
  GArray *a = g_array_sized_new(TRUE, TRUE, sizeof(int), 16);
  printf("Array preallocation is hidden so array size == %d\n"
         "Array was init()'d to zeros so third item is = %d\n",
         a->len, g_array_index(a, int, 2));

  g_array_free(a, FALSE);

  a = g_array_new(FALSE, FALSE, sizeof(char));
  g_array_set_size(a, 16);
  g_array_free(a, FALSE);

  a = g_array_new(FALSE, FALSE, sizeof(char));
  char *x = g_strdup("Hello world");

  g_array_append_val(a, x);
  g_array_free(a, TRUE);
}
