#include <stdio.h>
#include <stdlib.h>
#include <glib.h>

typedef struct {
  char *name;
  int shoe_size;
} person_s;

int main(void) {
  GSList *list = NULL;
  person_s *tom = (person_s *)malloc(sizeof(person_s));
  tom->name = "Tom";
  tom->shoe_size = 12;
  list = g_slist_append(list, tom);
  person_s *fred = g_new(person_s, 1);
  fred->name = "Fred";
  fred->shoe_size = 11;
  list = g_slist_append(list, fred);
  printf("Tom's shoe size is '%d'\n"
         "The last person_s's name is '%s'\n",
         ((person_s *)list->data)->shoe_size,
         ((person_s *)g_slist_last(list)->data)->name);
  g_slist_free(list);
  free(tom);
  g_free(fred);
}
