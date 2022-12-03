#include <stdlib.h>
#include <stdio.h>

void parse_input_to_buffer(const char* filename, int* output_buffer) {
  FILE* fp = fopen(filename, "r");
  char line[256];
  int output_ix = 0;
  while (fgets(line, 256, fp)) {
    if (line[0] == '\n') {
      output_buffer[output_ix++] = -1;
    } else {
      int result = atoi(line);
      output_buffer[output_ix++] = result;
    }
  }
  output_buffer[output_ix++] = -2;

  fclose(fp);
}

int* do_input(const char* filename) {
  // This program runs and exits; I don't do any explicit memory cleanup or bounds checking.
  int* output_buffer = calloc(8192, sizeof(int));
  parse_input_to_buffer(filename, output_buffer);

  return output_buffer;
}

void print_input(int* items) {
  int ix = 0;
  while (1) {
    printf("%d\n", items[ix]);
    if (items[ix] == -2) break;
    ix += 1;
  }
}

int q1() {
  int* items = do_input("data/d1");
  //print_input(items);
  int ix = 0;
  int current = 0;
  int max = 0;
  while (1) {
    if (items[ix] == -1 || items[ix] == -2) {
      if (current > max) {
        max = current;
      }
      current = 0;
    } else {
      current += items[ix];
    }
    if (items[ix] == -2) break;
    ix += 1;
  }
  return max;
}

void insertion_sort_desc(int* items, int num) {
  for (int i = 0; i < num; ++i) {
    for (int j = i + 1; j < num; ++j) {
      if (items[i] < items[j]) {
        int temp =  items[i];
        items[i] = items[j];
        items[j] = temp;
      }
    }
  }  
}

int q2() {
  int* items = do_input("data/d1");
  //print_input(items);
  int* outs = calloc(8192, sizeof(int));
  int ix = 0;
  int ox = 0;
  int current = 0;
  while (1) {
    if (items[ix] == -1 || items[ix] == -2) {
      outs[ox++] = current;
      current = 0;
    } else {
      current += items[ix];
    }
    if (items[ix] == -2) break;
    ix += 1;
  }
  insertion_sort_desc(outs, 8192);
  return outs[0]+outs[1]+outs[2];
}

void test() {
  int* items = do_input("data/d1_test");
  print_input(items);
}

int main() {
  printf("Q1: %d\n", q1());
  printf("Q2: %d\n", q2());
  return 0;
}
