#include <stdio.h>
#include <stdlib.h>
#include <glib.h>

typedef struct {
  char *name;
  int priority;
} task_s;

task_s *make_task(char *name, int priority);
task_s *make_task(char *name, int priority) {
  task_s *t = g_new(task_s, 1);
  t->name = name;
  t->priority = priority;
  return t;
}
void print_task(gpointer item);
void print_task(gpointer item) { printf("%s   ", ((task_s *)item)->name); }

gint task_sorter(gconstpointer a, gconstpointer b, gpointer data);
gint task_sorter(gconstpointer a, gconstpointer b, gpointer data) {
  return ((task_s *)a)->priority - ((task_s *)b)->priority;
}
int main(void) {
  GQueue *q = g_queue_new();
  g_queue_push_tail(q, make_task("Reboot server", 2));
  g_queue_push_tail(q, make_task("Pull cable", 2));
  g_queue_push_tail(q, make_task("Nethack", 1));
  g_queue_push_tail(q, make_task("New monitor", 3));
  printf("queue: ");
  g_queue_foreach(q, (GFunc)print_task, NULL);
  g_queue_sort(q, (GCompareDataFunc)task_sorter, NULL);
  printf("\nsorted queue: ");
  g_queue_foreach(q, (GFunc)print_task, NULL);
  printf("\n");
  g_queue_free(q);
}
