#include <stdio.h>
#include <stdlib.h>
#include <glib.h>

int main(void) {
  GQueue *q = g_queue_new();

  printf("empty queue? %s\n", g_queue_is_empty(q) ? "ja" : "nein");

  g_queue_push_tail(q, "Alice");
  g_queue_push_tail(q, "Bob");
  g_queue_push_tail(q, "Fred");

  printf("first in queue is %s\n"
         "last in queue is %s\n"
         "queue is %d long\n"
         "%s was just popped off\n"
         "%s is first in queue\n",
         g_queue_peek_head(q), g_queue_peek_tail(q), g_queue_get_length(q),
         g_queue_pop_head(q), g_queue_peek_head(q));

  g_queue_push_head(q, "Mitch");

  printf("%s is first in queue\n", g_queue_peek_head(q));
  g_queue_free(q);
}
