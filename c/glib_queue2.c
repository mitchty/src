#include <stdio.h>
#include <stdlib.h>
#include <glib.h>

int main(void) {
  GQueue *q = g_queue_new();
  g_queue_push_tail(q, "Jebediah");
  g_queue_push_tail(q, "Bob");
  g_queue_push_tail(q, "Bill");
  puts("Queue is Jebediah, Bob, Bill. Bill is pushing Jebediah to the end of "
       "line");
  int bill_pos = g_queue_index(q, "Bill");
  g_queue_remove(q, "Bob");
  printf("Bill moved from position %d to %d\n", bill_pos,
         g_queue_index(q, "Bill"));
  puts("Bill is trying to eva Jebediah");
  GList *bill_pointer = g_queue_peek_tail_link(q);
  g_queue_insert_before(q, bill_pointer, "Bill");
  printf("middle kerbal is now %s\n", g_queue_peek_nth(q, 1));
  printf("%s is still the final Kerbal in line despite his best efforts\n",
         g_queue_peek_tail(q));
  g_queue_free(q);
  g_list_free(bill_pointer);
}
