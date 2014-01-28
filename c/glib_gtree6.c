#include <stdio.h>
#include <stdlib.h>
#include <glib.h>

gboolean iterate_fn(GNode *n, gpointer data);
gboolean iterate_fn(GNode *n, gpointer data) {
  printf("%s ", n->data);
  return FALSE;
}

int main(void) {
  GNode *root = g_node_new("Atlanta");
  g_node_append(root, g_node_new("Detroit"));
  GNode *portland = g_node_prepend(root, g_node_new("Portland"));
  puts(" cities to start");
  g_node_traverse(root, G_PRE_ORDER, G_TRAVERSE_ALL, -1, iterate_fn, NULL);
  puts("\n inserting Boston before Portland");
  g_node_insert_data_before(root, portland, "Boston");
  g_node_traverse(root, G_PRE_ORDER, G_TRAVERSE_ALL, -1, iterate_fn, NULL);
  puts("\n reversing child nodes");
  g_node_reverse_children(root);
  g_node_traverse(root, G_PRE_ORDER, G_TRAVERSE_ALL, -1, iterate_fn, NULL);
  printf(" root node is %s\n"
         " portland node index is %d\n",
         g_node_get_root(portland)->data, g_node_child_index(root, "Portland"));
  g_node_destroy(root);
  g_node_destroy(portland);
}
