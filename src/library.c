#include <stdio.h>
#include <math.h>

float pow2(float base){
    return pow(base, 2);
}

int imax(int first, int second){
    return (int) fmax(first, second);
}

char cmax(char first, char second){
    return (char) fmax(first, second);
}

int imin(int first, int second){
    return (int) fmin(first, second);
}

char cmin(char first, char second){
    return (char) fmin(first, second);
}

float ptrunc(float input, int decs){
    return floor(pow(10, decs) * input) / pow(10, decs);
}

int main(void){
    printf("sqrt(100) = %f\n", sqrt(100));
    printf("sqrt(100.7) = %f\n", sqrt(100.7));
    printf("pow(100, 3) = %f\n", pow(100, 3));
    printf("pow(1.7, 12) = %f\n", pow(1.7, 12));
    printf("pow2(3) = %f\n", pow2(3));
    printf("floor(2.4) = %f\n", floor(2.4));
    printf("ceil(2.4) = %f\n", ceil(2.4));
    printf("round(2.4) = %f\n", round(2.4));
    printf("round(2.4) = %f\n", round(2.6));
    printf("imax(2, 7) = %d\n", imax(2, 7));
    printf("fmax(2.6, 3.5) = %f\n", fmax(2.6, 3.5));
    printf("cmax('k', 'm') = %c\n", cmax('k', 'm'));
    printf("trunc(5.121212) = %f\n", trunc(5.121212));
    printf("ptrunc(5.121212, 3) = %f\n", ptrunc(5.121212, 3));
}