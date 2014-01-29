#include <stdio.h>
#include <stdlib.h>
#include <glib.h>

gboolean iterate_all(gpointer key, gpointer value, gpointer data);
gboolean iterate_all(gpointer key, gpointer value, gpointer data) {
  printf("%s, %s\n", key, value);
  return FALSE;
}

gboolean iterate_some(gpointer key, gpointer value, gpointer data);
gboolean iterate_some(gpointer key, gpointer value, gpointer data) {
  printf("%s, %s\n", key, value);
  return g_ascii_strcasecmp(key, "b") == 0;
}

int main(void) {
  GTree *t = g_tree_new((GCompareFunc)g_ascii_strcasecmp);
  g_tree_insert(t, "d", "Detroit");
  g_tree_insert(t, "a", "Atlanta");
  g_tree_insert(t, "c", "Chicago");
  g_tree_insert(t, "b", "Boston");
  puts("Iterating over all nodes");
  g_tree_foreach(t, (GTraverseFunc)iterate_all, NULL);
  puts("Iterating over some specific nodes");
  g_tree_foreach(t, (GTraverseFunc)iterate_some, NULL);
  g_tree_destroy(t);
}
