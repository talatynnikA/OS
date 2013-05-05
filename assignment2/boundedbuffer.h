#include "types.h"
#include "mmu.h"
#include "param.h"
#include "proc.h"
#include "user.h"

struct BB {
 int buffer_size;
 int mutex;//protect the CS
 struct semaphore* empty_slots; // empty slots
 struct semaphore* full_slots; // full slots
 void* elements[100];
};


struct BB* BB_create(int max_capacity);
void BB_put(struct BB* bb, void* element);
void* BB_pop(struct BB* bb);