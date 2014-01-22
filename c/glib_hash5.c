#include <stdio.h>
#include <stdlib.h>
#include <glib.h>

gboolean wide_open(gpointer key, gpointer value, gpointer user_data);
gboolean wide_open(gpointer key, gpointer value, gpointer user_data) {
  return TRUE;
}

void key_destroyed(gpointer data);
void key_destroyed(gpointer data) { printf("Got a GDestroyNotify callback\n"); }

int main(void) {
  GHashTable *hash = g_hash_table_new_full(g_str_hash, g_str_equal,
                                           (GDestroyNotify)key_destroyed,
                                           (GDestroyNotify)key_destroyed);
  g_hash_table_insert(hash, "Texas", "Austin");
  g_hash_table_insert(hash, "Virginia", "Richmond");
  g_hash_table_insert(hash, "Ohio", "Columbus");
  g_hash_table_insert(hash, "Oregon", "Salem");
  g_hash_table_insert(hash, "New York", "Albany");
  printf("Removing New York, should be two callbacks displayed\n");
  g_hash_table_remove(hash, "New York");
  if (g_hash_table_steal(hash, "Texas"))
    printf("Texas has been stolen, nothings been lost though, %d items "
           "remaining\n",
           g_hash_table_size(hash));
  printf("Stealing remaining items\n");
  g_hash_table_foreach_steal(hash, (GHRFunc)wide_open, NULL);
  printf("Destroying the GHashTable, but it is now empty, no callbacks\n");
  g_hash_table_destroy(hash);
}
