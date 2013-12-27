#include <stdio.h>
#include <glib.h>

int main(void) {
  GSList *list = NULL;
  list = g_slist_append(list, "deux");
  list = g_slist_prepend(list, "um");
  printf("The list is now %d items long.\n", g_slist_length(list));
  list = g_slist_remove(list, "um");
  printf("The list is now %d items long.\n", g_slist_length(list));
  g_slist_free(list);
}
