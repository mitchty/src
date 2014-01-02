#include <stdio.h>
#include <stdlib.h>
#include <glib.h>

int main(void) {
  GSList *list1 = NULL;
  list1 = g_slist_append(list1, "ein");
  list1 = g_slist_append(list1, "zwei");
  GSList *list2 = NULL;
  list2 = g_slist_append(list2, "drei");
  list2 = g_slist_append(list2, "vier");
  GSList *both = g_slist_concat(list1, list2);
  printf("The third item in the concatenated list is %s\n",
         g_slist_nth_data(both, 2));
  GSList *reversed = g_slist_reverse(both);
  printf("The first item in the reversed list is %s\n", reversed->data);
  g_slist_free(reversed);
}
