#include <stdio.h>
#include <stdlib.h>
#include <glib.h>

void key_destroyed(gpointer data);
void key_destroyed(gpointer data) { printf("key %s destroyed\n", data); }
void value_destroyed(gpointer data);
void value_destroyed(gpointer data) { printf("value %s destroyed\n", data); }

int main(void) {
  GTree *t = g_tree_new_full((GCompareDataFunc)g_ascii_strcasecmp, NULL,
                             (GDestroyNotify)key_destroyed,
                             (GDestroyNotify)value_destroyed);
  g_tree_insert(t, "c", "Chicago");
  g_tree_insert(t, "b", "Boston");
  g_tree_insert(t, "d", "Detroit");
  printf(" replacing key 'b', destroy callbacks should kick in\n");
  g_tree_replace(t, "b", "Billings");
  printf(" stealing key 'b', no destroy callbacks should kick in\n");
  g_tree_steal(t, "b");
  printf(" nuking the tree\n");
  g_tree_destroy(t);
}
