#include "semaphore.h"
#include "types.h"
#include "user.h"


struct semaphore* semaphore_create(int initial_semaphore_value){
  struct semaphore* sem=malloc(sizeof(struct semaphore)); 
  // acquire semaphors
  sem->s1 = binary_semaphore_create(1);
  
  // s2 should be initialized with the min{1,initial_semaphore_value}
  if(initial_semaphore_value >= 1){
    sem->s2 = binary_semaphore_create(1);
  }else{
    sem->s2 = binary_semaphore_create(initial_semaphore_value);
  }
  
  if(sem->s1 == -1 || sem->s2 == -1){
     printf(1,"we had a probalem initialize in semaphore_create\n");
     free(sem);
     return 0;
  }
  //initialize value
  sem->value = initial_semaphore_value;//dynamic
  sem->initial_value = initial_semaphore_value;//static
  
  return sem;
}
void semaphore_down(struct semaphore* sem ){
  binary_semaphore_down(sem->s2);
  binary_semaphore_down(sem->s1);
  sem->value--;	
  if(sem->value > 0){
   binary_semaphore_up(sem->s2);
  }
  binary_semaphore_up(sem->s1); 
}
void semaphore_up(struct semaphore* sem ){
  binary_semaphore_down(sem->s1);
  sem->value++;	
  if(sem->value ==1){
   binary_semaphore_up(sem->s2); 
   }
  binary_semaphore_up(sem->s1);
}

void semaphore_free(struct semaphore* sem){
  free(sem);
}


