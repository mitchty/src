#include <stdio.h>
#include <stdlib.h>
#include <glib.h>

int main(void) {
  GPtrArray *a = g_ptr_array_new();
  g_ptr_array_add(a, g_strdup("hello "));
  g_ptr_array_add(a, g_strdup("again "));
  g_ptr_array_add(a, g_strdup("there "));
  g_ptr_array_add(a, g_strdup("world "));
  g_ptr_array_add(a, g_strdup("\n"));
  printf("GPtrArray contents\n");
  g_ptr_array_foreach(a, (GFunc)printf, NULL);
  printf("Removing third item\n");
  g_ptr_array_remove_index(a, 2);
  g_ptr_array_foreach(a, (GFunc)printf, NULL);
  printf("Removing second and third item\n");
  g_ptr_array_remove_range(a, 1, 2);
  g_ptr_array_foreach(a, (GFunc)printf, NULL);
  printf("First item is '%s'\n", g_ptr_array_index(a, 0));
  g_ptr_array_free(a, TRUE);
}
