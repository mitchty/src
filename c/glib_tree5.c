#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <glib.h>

gint finder(gpointer key, gpointer user_data);
gint finder(gpointer key, gpointer user_data) {
  int len = strlen((char *)key);

  if (len == 3)
    return 0;

  return (len < 3) ? 1 : -1;
}

int main(void) {
  GTree *t = g_tree_new((GCompareFunc)g_ascii_strcasecmp);
  g_tree_insert(t, "dddd", "Detroit");
  g_tree_insert(t, "a", "Annandale");
  g_tree_insert(t, "ccc", "Cleveland");
  g_tree_insert(t, "bb", "Boston");
  gpointer value = g_tree_search(t, (GCompareFunc)finder, NULL);
  printf("found value %s from a key with 3 ascii characters\n", value);
  g_tree_destroy(t);
}
