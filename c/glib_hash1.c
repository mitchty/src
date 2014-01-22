#include <stdio.h>
#include <stdlib.h>
#include <glib.h>

int main(void) {
  GHashTable *hash = g_hash_table_new(g_str_hash, g_str_equal);
  g_hash_table_insert(hash, "Virginia", "Richmond");
  g_hash_table_insert(hash, "Texas", "Austin");
  g_hash_table_insert(hash, "Ohio", "Columbus");
  printf("There are %d keys in the hash\n"
         "The Capital of Texas is %s\n",
         g_hash_table_size(hash), g_hash_table_lookup(hash, "Texas"));
  gboolean found = g_hash_table_remove(hash, "Virginia");
  printf("The value Virginia was %sfound and removed\n", found ? "" : "not ");
  g_hash_table_destroy(hash);
}
