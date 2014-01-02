#include <stdio.h>
#include <stdlib.h>
#include <glib.h>

gint my_finder(gconstpointer item);
gint my_finder(gconstpointer item) {
  return g_ascii_strcasecmp(item, "second");
}

int main(void) {
  GSList *list = g_slist_append(NULL, "first");
  list = g_slist_append(list, "second");
  list = g_slist_append(list, "third");
  GSList *item = g_slist_append(NULL, "second");
  printf("Second item is %s\n", item->data);
  item = g_slist_find_custom(list, NULL, (GCompareFunc)my_finder);
  printf("Second item is %s\n", item->data);
  item = g_slist_find(list, "delta");
  printf("delta is not in the list so there, we have %s\n",
         item ? item->data : "(null)");
  g_slist_free(list);
}
