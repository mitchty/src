#include <stdio.h>
#include <glib.h>

int main(void) {
  GSList *list = NULL;
  printf("The list is now %d items long.\n", g_slist_length(list));
  list = g_slist_append(list, "ein");
  list = g_slist_append(list, "deux");
  printf("The list is now %d items long.\n", g_slist_length(list));
  g_slist_free(list);
}
