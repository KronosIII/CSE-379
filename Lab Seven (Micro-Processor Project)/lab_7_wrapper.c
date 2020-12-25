extern int lab7(void);
extern int lab_7_libary(void);
#include<time.h>
#include<math.h>
int randomnum(){ //returns either of the 4 numbers in array
    int Direction[4] = {1,-1,33,-33};
                    //right,left,down,up or
                    //k, j, m, i
    srand ( time(NULL) );
    int randomIndex = rand() % 4;
    int randomValue = Direction[randomIndex];
    return randomValue;
}
int randomnum_left_or_right(){ //returns either of the 4 numbers in array
    int Direction[2] = {1,-1};
                    //right,left
                    //k, j
    srand ( time(NULL) );
    int randomIndex = rand() % 2;
    int randomValue = Direction[randomIndex];
    return randomValue;
}

int points_add_from_ghosts(int num,int score){
    return pow(2,num)*100+score;//calculates the score when a ghost has been eaten
}
int in_respawn(int offset){
    int offset_bool= offset<=8 && offset>=0;
    return offset_bool; //returns a boolean which tells if the ghost can leave the respawn
}

int check_wall(int charrr){
    return charrr==45||charrr==124||charrr==43||charrr==91||charrr==93;
                //2D,7C,2B,5B,5D
}
int main(void){
    lab7();
}
