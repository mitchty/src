#include <stdio.h>
#include <stdlib.h>
#include <glib.h>

void print_iterator(gpointer item, gpointer prefix);
void print_iterator(gpointer item, gpointer prefix) {
  printf("%s %s\n", prefix, item);
}

void print_iterator_short(gpointer item);
void print_iterator_short(gpointer item) { printf("%s\n", item); }

int main(void) {
  GSList *list = g_slist_append(NULL, g_strdup("first"));
  list = g_slist_append(list, g_strdup("second"));
  list = g_slist_append(list, g_strdup("third"));
  printf("Iterating with a function:\n");
  g_slist_foreach(list, print_iterator, "prepended: ");
  printf("Iterating with a short function\n");
  g_slist_foreach(list, (GFunc)print_iterator_short, NULL);
  printf("Freeing each item.\n");
  g_slist_foreach(list, (GFunc)g_free, NULL);
  g_slist_free(list);
}
