#include "semaphore.h"
#include "boundedbuffer.h"
struct cup {
  int i;
};
struct action {
  int i;
};

int main(int argc, char** argv) {
  //variables
  int A=0;
  int B=0;
  int C=0;
  int S=0;
  int M=0;
  printf(1,"A: %d B: %d C: %d  S: %d M: %d\n",A,B,C,S,M);
  
  //reading configuration
  //#####
  
  
  
  //#####
  
  //Databases
   struct semaphore* bouncer = semaphore_create(M);//this is the bounder to the Beinstein
   struct BB* ABB =BB_create(A); //this is a BB for student actions: drink, ans for a dring
   struct BB* DrinkBB=BB_create(A);//this is a BB holding the drinks that are ready to be drinking
   struct BB* CBB=BB_create(C);//this is a BB hold clean cups
   struct BB* DBB=BB_create(C);//this is a BB hold dirty cups
   printf(1,"ABB: %d DrinkBB: %d CBB: %d  DBB: %d bounder: %d\n",&ABB,&DrinkBB,&CBB,&DBB,&bounder);
  return 0;
}