#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <glib.h>

gint finder(gpointer a, gpointer b);
gint finder(gpointer a, gpointer b) { return strcmp(a, b); }

int main(void) {
  GQueue *q = g_queue_new();
  g_queue_push_tail(q, "Alice");
  g_queue_push_tail(q, "Bob");
  g_queue_push_tail(q, "Fred");
  g_queue_push_tail(q, "Jim");
  GList *fred_link = g_queue_find(q, "Fred");
  printf("fred node contains %s\n", fred_link->data);
  GList *joe_link = g_queue_find(q, "Joe");
  printf("search for 'Joe' yields %s\n", joe_link ? "valid" : "invalid");
  GList *bob = g_queue_find_custom(q, "Bob", (GCompareFunc)finder);
  printf("custom finding function found %s\n", bob->data);
  bob = g_queue_find_custom(q, "Bob", (GCompareFunc)g_ascii_strcasecmp);
  printf("g_ascii_strcasecmp found %s\n", bob->data);
  g_queue_free(q);
  g_list_free(bob);

  if (joe_link)
    g_list_free(joe_link);
  if (fred_link)
    g_list_free(fred_link);
}
