#include <stdio.h>
#include <stdlib.h>
#include <glib.h>

int main(void) {
  GQueue *q = g_queue_new();
  g_queue_push_tail(q, "Alice ");
  g_queue_push_tail(q, "Bob ");
  g_queue_push_tail(q, "Fred ");
  g_queue_push_tail(q, "Jim ");
  printf("queue is: ");
  g_queue_foreach(q, (GFunc)printf, NULL);
  GList *fred_link = g_queue_peek_nth_link(q, 2);
  printf("\nlink at index 2 is %s\n", fred_link->data);
  g_queue_unlink(q, fred_link);
  g_list_free(fred_link);
  GList *jim_link = g_queue_peek_nth_link(q, 2);
  printf("index 2 is now %s\n", jim_link->data);
  g_queue_delete_link(q, jim_link);
  printf("queue now: ");
  g_queue_foreach(q, (GFunc)printf, NULL);
  printf("\n");
  g_queue_free(q);
  g_list_free(jim_link);
}
