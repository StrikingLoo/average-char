#include <stdio.h>
#include <stdlib.h>
#include <time.h>

extern double average_byte(char* s);
extern void replace_byte(char* s, char have, char want);
void replace_byte_c(char* s, char have, char want){
    int i = 0;
    while(s[i]!=0){
        if(s[i]==have){
	    s[i]=want;
	}
	i++;
    }
}
void show_stream(char* s, int length){
    for(int i = 0; i < length; i++){
        printf("%d ",s[i]);
    }
    printf("\n");
} 
int main(){
    int SIZE = 1600000000;
    printf("Starting program...\n");
    char* s = malloc(SIZE);

    for(int i = 0; i < SIZE-1; i++){
        s[i] = (i%3)+1;	
    }
    s[SIZE-1] = 0;
    printf("Initialized array\n");

    //show_stream(s, SIZE);
    float startTime = (float)clock()/CLOCKS_PER_SEC;
    replace_byte(s, 1, 18);
    float endTime = (float)clock()/CLOCKS_PER_SEC;
    float time_asm = endTime - startTime;
    //show_stream(s,SIZE);
    printf("Finished ASM.\n");
    startTime = (float)clock()/CLOCKS_PER_SEC;
    replace_byte_c(s, 1, 18);
    endTime = (float)clock()/CLOCKS_PER_SEC;
    printf("Finished C.\n");
    float time_c = endTime - startTime;

   // show_stream(s,SIZE);
    printf("%.3f vs %.3f", time_asm, time_c);
    printf("\n");
    return 0;
}
