#! /bin/bash
arr=()
arn=0
fname="list1.txt"

IFS='.' read -ra ADDR <<< "$fname"
branch="${ADDR[0]}"

key=0
if [ $1 ]
then
    key=1
fi

while read -r line
do
    arr[arn]="$line"
    arn+=1
done < $fname

function listfile(){
    farr=()
    farn=0
    while read -r line
    do
        farr[farn]="$line"
        farn+=1
    done < $fname
    
    for t in ${!farr[@]}; do
        echo $t ${farr[$t]}
    done
    
    if [ "${#farr[@]}" -eq "0" ]
    then
        echo "[$fname notes empty]"
    fi
    
}

if [ "$key" -eq "1" ]
then
    if [ "$1" = "add" ]
    then
        echo "[$fname notes modified: addition]"
        echo "$2" >> $fname
    elif [ "$1" = "del" ]
    then
        if [ "$2" = "all" ]
        then
            echo "[$fname notes modified: erased]"
            > $fname
        else
            echo "[$fname notes modified: deletion]"
            > $fname
            for t in ${!arr[@]}; do
                if [ "$t" -ne "$2" ]
                then
                    echo ${arr[$t]} >> $fname
                fi
            done
            #echo ${arr[@]}
        fi
    fi
fi

listfile