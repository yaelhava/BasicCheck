#!/bin/bash

cd $1
co=1
mem=1
tr=1

make &> output.txt

comp=$?
run=$2
shift 2
memleaks="FAIL"
threadrace="FAIL"

if [ $comp -eq 0 ]; then
    comp="PASS"
    co=0
    valgrind --leak-check=full --error-exitcode=2 ./$run  "$@" &> output.txt
    memleaks=$?
    valgrind --tool=helgrind --error-exitcode=3 ./$run "$@" &> output.txt
    threadrace=$?
    if [ $memleaks -eq 0 ]; then
        memleaks="PASS"
        mem=0
    else
        memleaks="FAIL"   
        mem=1 
    fi

    if [ $threadrace -eq 0 ]; then
        threadrace="PASS"
        tr=0
    else
        threadrace="FAIL"    
        tr=1
    fi

else
    comp="FAIL" 
    co=1
fi    


echo "  Compliation       Memory leaks        Thread race"
echo "      $comp              $memleaks               $threadrace"
    
    

exit $(($((4*$co)) + $((2*$mem)) + $((1*$tr))))