; ModuleID = 'Viper'
source_filename = "Viper"

%list = type { i8**, i32, i32, i8* }
%dict = type { %list, i8*, i8* }

@fmt = private unnamed_addr constant [4 x i8] c"%c\0A\00"
@fmt.1 = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@fmt.2 = private unnamed_addr constant [4 x i8] c"%s\0A\00"
@fmt.3 = private unnamed_addr constant [4 x i8] c"%g\0A\00"
@0 = private unnamed_addr constant [4 x i8] c"int\00"
@1 = private unnamed_addr constant [4 x i8] c"int\00"
@fmt.4 = private unnamed_addr constant [4 x i8] c"%c\0A\00"
@fmt.5 = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@fmt.6 = private unnamed_addr constant [4 x i8] c"%s\0A\00"
@fmt.7 = private unnamed_addr constant [4 x i8] c"%g\0A\00"

declare i32 @printf(i8*, ...)

declare double @pow2(double)

declare %list* @create_list(i8*)

declare i8 @access_char(%list*, i32)

declare i32 @access_int(%list*, i32)

declare void @append_char(%list*, i8)

declare void @append_int(%list*, i32)

declare i32 @contains_char(%list*, i8)

declare i32 @contains_int(%list*, i32)

declare i32 @listlen(%list*)

declare %dict* @create_dict(i8*, i8*)

declare void @add_keyval(%dict*, i8*, i8*)

declare i8* @access_char_key(%dict*, i8)

declare i8* @int_alloc_zone(i32)

declare i8* @char_alloc_zone(i8)

define i32 @main() {
entry:
  %target = alloca i32
  store i32 4, i32* %target
  %present = alloca %list*
  %create_list = call %list* @create_list(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @0, i32 0, i32 0))
  call void @append_int(%list* %create_list, i32 1)
  call void @append_int(%list* %create_list, i32 2)
  call void @append_int(%list* %create_list, i32 3)
  call void @append_int(%list* %create_list, i32 4)
  call void @append_int(%list* %create_list, i32 5)
  store %list* %create_list, %list** %present
  %absent = alloca %list*
  %create_list1 = call %list* @create_list(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @1, i32 0, i32 0))
  call void @append_int(%list* %create_list1, i32 1)
  call void @append_int(%list* %create_list1, i32 2)
  call void @append_int(%list* %create_list1, i32 3)
  call void @append_int(%list* %create_list1, i32 5)
  store %list* %create_list1, %list** %absent
  %present2 = load %list*, %list** %present
  %binary_search_result = call i32 @binary_search(%list* %present2, i32 4)
  %printf = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @fmt.1, i32 0, i32 0), i32 %binary_search_result)
  %absent3 = load %list*, %list** %absent
  %binary_search_result4 = call i32 @binary_search(%list* %absent3, i32 4)
  %printf5 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @fmt.1, i32 0, i32 0), i32 %binary_search_result4)
  ret i32 0
}

define i32 @binary_search(%list* %arr, i32 %x) {
entry:
  %arr1 = alloca %list*
  store %list* %arr, %list** %arr1
  %x2 = alloca i32
  store i32 %x, i32* %x2
  %low = alloca i32
  store i32 0, i32* %low
  %high = alloca i32
  %arr3 = load %list*, %list** %arr1
  %len = call i32 @listlen(%list* %arr3)
  store i32 %len, i32* %high
  %mid = alloca i32
  store i32 0, i32* %mid
  br label %while

while:                                            ; preds = %merge11, %entry
  %low25 = load i32, i32* %low
  %high26 = load i32, i32* %high
  %tmp27 = icmp sle i32 %low25, %high26
  br i1 %tmp27, label %while_body, label %merge

merge:                                            ; preds = %while
  ret i32 -1

while_body:                                       ; preds = %while
  %high4 = load i32, i32* %high
  %low5 = load i32, i32* %low
  %tmp = add i32 %high4, %low5
  %tmp6 = sdiv i32 %tmp, 2
  store i32 %tmp6, i32* %mid
  %mid7 = load i32, i32* %mid
  %arr8 = load %list*, %list** %arr1
  %access = call i32 @access_int(%list* %arr8, i32 %mid7)
  %x9 = load i32, i32* %x2
  %tmp10 = icmp slt i32 %access, %x9
  br i1 %tmp10, label %then, label %else

merge11:                                          ; preds = %merge19, %then
  br label %while

then:                                             ; preds = %while_body
  %mid12 = load i32, i32* %mid
  %tmp13 = add i32 %mid12, 1
  store i32 %tmp13, i32* %low
  br label %merge11

else:                                             ; preds = %while_body
  %mid14 = load i32, i32* %mid
  %arr15 = load %list*, %list** %arr1
  %access16 = call i32 @access_int(%list* %arr15, i32 %mid14)
  %x17 = load i32, i32* %x2
  %tmp18 = icmp sgt i32 %access16, %x17
  br i1 %tmp18, label %then20, label %else23

merge19:                                          ; preds = %then20
  br label %merge11

then20:                                           ; preds = %else
  %mid21 = load i32, i32* %mid
  %tmp22 = sub i32 %mid21, 1
  store i32 %tmp22, i32* %high
  br label %merge19

else23:                                           ; preds = %else
  %mid24 = load i32, i32* %mid
  ret i32 %mid24
}
