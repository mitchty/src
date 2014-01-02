#include <stdio.h>
#include <stdlib.h>
#include <glib.h>

int main(void) {
  GList *list = g_list_append(NULL, "Austin ");
  list = g_list_append(list, "Bowie ");
  list = g_list_append(list, "Charleston ");
  printf("List contents:\n");
  g_list_foreach(list, (GFunc)printf, NULL);
  GList *last = g_list_last(list);
  printf("\nFirst item is %s\n"
         "next to last (using g_list_previous) is %s\n"
         "next to last (using g_list_nth_prev) is %s\n",
         g_list_first(last)->data, g_list_previous(last)->data,
         g_list_nth_prev(last, 1)->data);
  g_list_free(list);
}
