#include <stdio.h>
#include <stdlib.h>
#include <glib.h>

int main(void) {
  GQueue *q = g_queue_new();
  g_queue_push_tail(q, "Alice ");
  g_queue_push_tail(q, "Bob ");
  g_queue_push_tail(q, "Fred ");
  printf("queue is: ");
  g_queue_foreach(q, (GFunc)printf, NULL);
  g_queue_reverse(q);
  printf("\nafter reversal queue is: ");
  g_queue_foreach(q, (GFunc)printf, NULL);
  GQueue *new_q = g_queue_copy(q);
  g_queue_reverse(new_q);
  printf("\nreversed copy of original queue is now: ");
  g_queue_foreach(new_q, (GFunc)printf, NULL);
  printf("\n");
  g_queue_free(q);
  g_queue_free(new_q);
}
