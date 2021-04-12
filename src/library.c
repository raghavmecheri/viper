#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

struct list{
    void** data;
    int size;
    int mem;
    char* type;
};

struct list* create_list(char* type){
    struct list* inlist = malloc(sizeof(struct list));
    char* toadd = malloc(strlen(type));
    strcpy(toadd, type);
    inlist->type = toadd;
    inlist->size = 0;
    inlist->mem = 64;
    inlist->data = malloc(64);
    return inlist;
}

void realloc_check(struct list* inlist){
    if(inlist->mem <= (inlist->size * 8)){
        void** newdata = realloc(inlist->data, inlist->mem + 64);
        if (newdata == NULL){
            printf("Failure to reallocate data");
            return;
        }
        inlist->data = newdata;
    }
}

void append_str(struct list* inlist, char* str){
    if(strcmp(inlist->type, "string")){
        printf("Can only append %s, not string\n", inlist->type);
        return;
    }

    realloc_check(inlist);
    char* toadd = malloc(strlen(str));
    strcpy(toadd, str);
    inlist->data[(inlist->size)] = toadd;
    inlist->size = inlist->size + 1;
}

void append_char(struct list* inlist, char chr){
    if(strcmp(inlist->type, "char")){
        printf("Can only append %s, not char\n", inlist->type);
        return;
    }

    realloc_check(inlist);
    char* toadd = malloc(1);
    *toadd = chr;
    inlist->data[(inlist->size)] = toadd;
    inlist->size = inlist->size + 1;
}

void append_int(struct list* inlist, int num){
    if(strcmp(inlist->type, "int")){
        printf("Can only append %s, not int\n", inlist->type);
        return;
    }

    realloc_check(inlist);
    int* toadd = malloc(4);
    *toadd = num;
    inlist->data[(inlist->size)] = toadd;
    inlist->size = inlist->size + 1;
}

void append_float(struct list* inlist, float flt){
    if(strcmp(inlist->type, "float")){
        printf("Can only append %s, not float\n", inlist->type);
        return;
    }

    realloc_check(inlist);
    float* toadd = malloc(4);
    *toadd = flt;
    inlist->data[(inlist->size)] = toadd;
    inlist->size = inlist->size + 1;
}

void append_list(struct list* inlist, struct list* outlist){
    if(strcmp(inlist->type, "list")){
        printf("Can only append %s, not list\n", inlist->type);
        return;
    }

    realloc_check(inlist);
    inlist->data[(inlist->size)] = outlist;
    inlist->size = inlist->size + 1;
}

void* access(struct list* inlist, int index){
    return inlist->data[index];
}

int access_int(struct list* inlist, int index){
    if(strcmp(inlist->type, "int")){
        printf("Can only access %s, not int\n", inlist->type);
        return 0;
    }

    int* num = (int*) access(inlist, index);
    if(num == NULL){
        printf("Illegal index accessed\n");
        return 0;
    }
    return *num;
}

char access_char(struct list* inlist, int index){
    if(strcmp(inlist->type, "char")){
        printf("Can only access %s, not char\n", inlist->type);
        return 0;
    }

    char* chr = (char*) access(inlist, index);
    if(chr == NULL){
        printf("Illegal index accessed\n");
        return 0;
    }
    return *chr;
}

float access_float(struct list* inlist, int index){
    if(strcmp(inlist->type, "float")){
        printf("Can only access %s, not float\n", inlist->type);
        return 0;
    }

    float* flt = (float*) access(inlist, index);
    if(flt == NULL){
        printf("Illegal index accessed\n");
        return 0;
    }
    return *flt;
}

char* access_str(struct list* inlist, int index){
    if(strcmp(inlist->type, "string")){
        printf("Can only access %s, not string\n", inlist->type);
        return 0;
    }

    char* str = (char*) access(inlist, index);
    if(str == NULL){
        printf("Illegal index accessed\n");
        return NULL;
    }
    return str;
}

int contains_int(struct list* inlist, int tocheck){
    if(strcmp(inlist->type, "int")){
        printf("Can only check membership for %s, not int\n", inlist->type);
        return 0;
    }

    int i;
    for(i = 0; i < inlist->size; i++){
        int* num = (int*) access(inlist, i);
        if(*num == tocheck){
            return 1;
        }   
    }
    return 0;
}

int contains_char(struct list* inlist, char tocheck){
    if(strcmp(inlist->type, "char")){
        printf("Can only check membership for %s, not char\n", inlist->type);
        return 0;
    }

    int i;
    for(i = 0; i < inlist->size; i++){
        char* chr = (char*) access(inlist, i);
        if(*chr == tocheck){
            return 1;
        }   
    }
    return 0;
}

int contains_float(struct list* inlist, float tocheck){
    if(strcmp(inlist->type, "float")){
        printf("Can only check membership for %s, not float\n", inlist->type);
        return 0;
    }

    int i;
    for(i = 0; i < inlist->size; i++){
        float* flt = (float*) access(inlist, i);
        if(*flt == tocheck){
            return 1;
        }   
    }
    return 0;
}

int contains_str(struct list* inlist, char* tocheck){
    if(strcmp(inlist->type, "string")){
        printf("Can only check membership for %s, not string\n", inlist->type);
        return 0;
    }

    int i;
    for(i = 0; i < inlist->size; i++){
        char* str = (char*) access(inlist, i);
        if(!strcmp(str, tocheck)){
            return 1;
        }   
    }
    return 0;
}

struct list* access_list(struct list* inlist, int index){
    if(strcmp(inlist->type, "list")){
        printf("Can only access %s, not list\n", inlist->type);
        return 0;
    }

    struct list* lst = (struct list*) access(inlist, index);
    if(lst == NULL){
        printf("Illegal index accessed\n");
        return NULL;
    }
    return lst;
}

char* get_type(struct list* inlist){
    return inlist->type;
}

int listlen(struct list* inlist){
    return inlist->size;
}

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

    struct list* mylist = create_list("int");
    append_int(mylist, 0);
    append_str(mylist, "yooo");
    append_int(mylist, 1);
    append_int(mylist, 2);
    append_int(mylist, 3);
    append_int(mylist, 4);
    append_int(mylist, 5);
    append_int(mylist, 6);
    append_int(mylist, 7);
    append_int(mylist, 8);
    //append_float(mylist, 4.5);
    //append_char(mylist, 'c');
    struct list* otherlist = create_list("list");
    //append_int(otherlist, 1);
    append_list(otherlist, mylist);

    printf("Type: %s\n", get_type(mylist));
    printf("Type: %s\n", get_type(otherlist));
    printf("Length: %d\n", listlen(mylist));
    printf("Length: %d\n", listlen(otherlist));

    printf("@ index 0: %d\n", access_int(mylist, 0));
    printf("@ index 5: %d\n", access_int(mylist, 5));
    printf("@ Illegal Index: %d\n", access_int(mylist, 1000));

    struct list* accessed = access_list(otherlist, 0);
    printf("@ index 5: %d\n", access_int(accessed, 5));

    printf("contains_int(mylist, 5): %d\n", contains_int(mylist, 5));
    printf("contains_int(mylist, 10): %d\n", contains_int(mylist, 10));
}
