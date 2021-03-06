#include "boundedbuffer.h"
#include "types.h"
#include "user.h"


struct BB* 
BB_create(int max_capacity){
  //initialize
  struct BB* buf = malloc(sizeof(struct BB));
  memset(buf,0,sizeof(struct BB));
 
  buf->buffer_size = max_capacity;
  buf->mutex = binary_semaphore_create(1);  
  buf->empty = semaphore_create(max_capacity);
  buf->full = semaphore_create(0);
  buf->pointer_to_elements = malloc(sizeof(void*)*max_capacity);
  memset(buf->pointer_to_elements,0,sizeof(void*)*max_capacity);
  buf->count = 0;
  //check the semaphorses
  if(buf->mutex == -1 || buf->empty == 0 || buf->full == 0){
   printf(1,"we had a problam getting semaphores at BB create mutex %d empty %d full %d\n",buf->mutex,buf->empty,buf->full);
   BB_free(buf);
   
   buf =0;  
  }
  return buf;
}

void BB_put(struct BB* bb, void* element)
{ 
  semaphore_down(bb->empty);
  binary_semaphore_down(bb->mutex);
   //insert item
  bb->pointer_to_elements[bb->count] = element;
  bb->count++;
  binary_semaphore_up(bb->mutex);
  semaphore_up(bb->full);
}

void* BB_pop(struct BB* bb)
{
  
  void* element_to_pop;
  semaphore_down(bb->full);
  binary_semaphore_down(bb->mutex);
  element_to_pop = bb->pointer_to_elements[0];
  
  if(!element_to_pop){
  printf(1,"we have uninitialize element\n");
  }
  
  // shift left all elements at the array
  int i;
  for(i = 0; i < bb->count ; i++){
    if(i != (bb->count -1)){
      bb->pointer_to_elements[i] = bb->pointer_to_elements[i+1];
    }else{
      bb->pointer_to_elements[i] = 0;
     }
     
  }
  
  
  bb->count--;
  
  binary_semaphore_up(bb->mutex);
  semaphore_up(bb->empty);
  
  return element_to_pop;
}

void BB_free(struct BB* bb){
  semaphore_free(bb->empty);
  semaphore_free(bb->full);
  free(bb->pointer_to_elements);
  free(bb);
}
