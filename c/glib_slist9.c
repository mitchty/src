#include <glib.h>
#include <stdlib.h>
#include <stdio.h>

gint my_comparator(gconstpointer item1, gconstpointer item2);

gint my_comparator(gconstpointer item1, gconstpointer item2) {
  return g_ascii_strcasecmp(item1, item2);
}

int main(void) {
  GSList *list = g_slist_append(NULL, "Chicago");
  list = g_slist_append(list, "Boston");
  list = g_slist_append(list, "London");
  list = g_slist_sort(list, (GCompareFunc)my_comparator);
  printf("First item is %s\n"
         "Last item is %s\n",
         list->data, g_slist_last(list)->data);
  g_slist_free(list);
}
