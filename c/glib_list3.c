#include <stdio.h>
#include <stdlib.h>
#include <glib.h>

int main(void) {
  GList *list = g_list_append(NULL, "Austin ");
  list = g_list_append(list, "Bowie ");
  list = g_list_append(list, "Chicago ");
  printf("The list\n");
  g_list_foreach(list, (GFunc)printf, NULL);
  GList *bowie = g_list_nth(list, 1);
  list = g_list_remove_link(list, bowie);
  printf("\nlist after the remove_link call: \n");
  g_list_foreach(list, (GFunc)printf, NULL);
  list = g_list_delete_link(list, g_list_nth(list, 1));
  printf("list after delete_link call: \n");
  list = g_list_remove_link(list, g_list_nth(list, 1));
  printf("list after remove_link call: \n");
  g_list_foreach(list, (GFunc)printf, NULL);
  g_list_free_1(bowie);
  g_list_free(list);
}
