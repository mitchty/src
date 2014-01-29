#include <stdio.h>
#include <stdlib.h>
#include <glib.h>

int main(void) {
  GTree *t = g_tree_new((GCompareFunc)g_ascii_strcasecmp);
  g_tree_insert(t, "c", "Chicago");
  g_tree_insert(t, "b", "Boston");
  g_tree_insert(t, "d", "Detroit");
  printf("key 'b' => '%s'\n"
         "%s\n",
         g_tree_lookup(t, "b"),
         g_tree_lookup(t, "a") ? "key 'a' found" : "key 'a' not found");
  gpointer *key = NULL;
  gpointer *value = NULL;
  g_tree_lookup_extended(t, "c", (gpointer *)&key, (gpointer *)&value);
  printf("key '%s' => '%s'\n", (char *)key, (char *)value);
  gboolean found =
      g_tree_lookup_extended(t, "a", (gpointer *)&key, (gpointer *)&value);
  printf("%s\n", found ? "key 'a' found" : "key 'a' not found");
}
