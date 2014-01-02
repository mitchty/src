#include <stdio.h>
#include <stdlib.h>
#include <glib.h>

int main(void) {
  GList *list = NULL;
  list = g_list_append(list, "Austin ");
  printf("First item is %s\n", list->data);
  list = g_list_insert(list, "Baltimore ", 1);
  printf("Second item is %s\n", g_list_next(list)->data);
  list = g_list_remove(list, "Baltimore ");
  printf("After removing crappy Baltimore length is %d\n", g_list_length(list));
  GList *other_list = g_list_append(NULL, "Baltimore ");
  list = g_list_concat(list, other_list);
  printf("After concatenation: \n");
  g_list_foreach(list, (GFunc)printf, NULL);
  list = g_list_reverse(list);
  printf("\nAfter reverse: \n");
  g_list_foreach(list, (GFunc)printf, NULL);
  g_list_free(list);
  g_list_free(other_list);
}
