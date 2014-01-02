#include <stdio.h>
#include <glib.h>

int main(void) {
  GSList *list = NULL;
  list = g_slist_prepend(list, "um");
  list = g_slist_append(list, "deux");
  list = g_slist_append(list, "deux");
  list = g_slist_append(list, "drei");
  list = g_slist_append(list, "drei");
  printf("The list is now %d items long.\n", g_slist_length(list));
  list = g_slist_remove(list, "deux");
  printf("The list is now %d items long.\n", g_slist_length(list));
  list = g_slist_remove_all(list, "drei");
  printf("The list is now %d items long.\n", g_slist_length(list));
  g_slist_free(list);
}
