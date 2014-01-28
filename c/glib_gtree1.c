#include <stdio.h>
#include <stdlib.h>
#include <glib.h>

int main(void) {
  GTree *t = g_tree_new((GCompareFunc)g_ascii_strcasecmp);
  g_tree_insert(t, "c", "Chicago");
  printf("The tree height is %d\n", g_tree_height(t));
  g_tree_insert(t, "b", "Boston");
  g_tree_insert(t, "d", "Detroit");
  printf("Height is now %d for %d nodes in the tree\n", g_tree_height(t),
         g_tree_nnodes(t));
  g_tree_remove(t, "d");
  printf("Height is now %d for %d nodes in the tree\n", g_tree_height(t),
         g_tree_nnodes(t));
  g_tree_destroy(t);
}
