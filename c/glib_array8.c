#include <stdio.h>
#include <stdlib.h>
#include <glib.h>

int main(void) {
  GByteArray *a = g_byte_array_new();
  guint8 x = 0xFF;
  g_byte_array_append(a, &x, sizeof(x));
  printf("The first byte value in decimal is %d\n", a->data[0]);
  x = 0x01;
  g_byte_array_prepend(a, &x, sizeof(x));
  printf("After prepending, the first value is %d\n", a->data[0]);
  g_byte_array_remove_index(a, 0);
  printf("After remove_index, the first value is %d\n", a->data[0]);
  g_byte_array_prepend(g_byte_array_append(a, &x, sizeof(x)), &x, sizeof(x));
  printf("After two appends, array length is %d\n", a->len);
  g_byte_array_free(a, TRUE);
}
