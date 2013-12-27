#include <stdio.h>
#include <glib.h>
int main(void) {
  GSList *list = NULL;
  list = g_slist_append(list, "ein");
  list = g_slist_append(list, "dois");
  list = g_slist_append(list, "trois");
  printf("The last item is '%s'\n"
         "The item at index 1 is '%s'\n"
         "Item at index 1 the easier way: '%s'\n"
         "The next item after the first item is '%s'\n",
         g_slist_last(list)->data, g_slist_nth(list, 1)->data,
         g_slist_nth_data(list, 1), g_slist_next(list)->data);
  g_slist_free(list);
}
