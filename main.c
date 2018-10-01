#include <stdio.h>
#include <stdlib.h>

extern double average_byte(char* s); 
int main(){
    printf("Starting program...\n");
    char* s = malloc(32);
    for(int i = 0; i < 31; i++){
        s[i] = (i%3)+1;	
    }
    s[31] = 0;
    double r = average_byte(s);
    printf("%.3f ",r);
    return 0;
}
