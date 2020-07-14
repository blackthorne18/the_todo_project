#! /bin/bash

function getbranch(){
    wo=$1
    bls=[]
    bln=0
    fname1="branches.txt"
    fname2="list1.txt"
    
    while read -r line
    do
        IFS=' ' read -ra count <<< "$line"
        bls[bln]="$line"
        bln+=1
        if [ "${count[1]}" = "1" ]
        then
            if [ "$wo" = "0" ]
            then
                echo ${count[0]}
            fi
        fi
    done < $fname1
    
    if [ "$wo" = "1" ]
    then
        echo ${bls[@]}
    fi
}

function switchbranch(){
    whichto=$1
    fname1="branches.txt"
    while read -r line
    do
        IFS=' ' read -ra count <<< "$line"
        bls[bln]="${count[0]}"
        bln+=1
    done < $fname1
    > $fname1
    
    for t in ${!bls[@]}; do
        if [ "${bls[$t]}" = "$whichto" ]
        then
            echo "${bls[$t]} 1" >> $fname1
        else
            echo "${bls[$t]} 0" >> $fname1
        fi
    done
    
    echo "Switched to branch $whichto"
}

function editbranches(){
    key=$1
    name=$2
    if [ "$key" = "0" ]
    then
        fname1="branches.txt"
        while read -r line
        do
            bls[bln]="${line}"
            bln+=1
        done < $fname1
        > $fname1
        bls[bln]="$name 0"
        for t in ${!bls[@]}; do
            echo ${bls[$t]} >> $fname1
        done
        touch "$2.txt"
        echo "New branch created: $2"
    elif [ "$key" = "1" ]
    then
        fname1="branches.txt"
        while read -r line
        do
            bls[bln]="${line}"
            bln+=1
        done < $fname1
        > $fname1
        
        for t in ${!bls[@]}; do
            IFS=' ' read -ra count <<< "${bls[$t]}"
            if [ "${count[0]}" = "$name" ]
            then
                continue
            elif [ "${count[0]}" = "master" ]
            then
                echo "${count[0]} 1" >> $fname1
            else    
                echo ${bls[$t]} >> $fname1
            fi
        done
        rm "$2.txt"
        echo "Branch removed: $2"
    fi
}

function listfile(){
    fname2=$1
    farr=()
    farn=0
    while read -r line
    do
        farr[farn]="$line"
        farn+=1
    done < $fname2
    
    for t in ${!farr[@]}; do
        echo $t ${farr[$t]}
    done
    
    if [ "${#farr[@]}" -eq "0" ]
    then
        echo "[$fname2 notes empty]"
    fi
    
}

function inabranch(){
    arr=()
    arn=0
    fname=$1
    
    argnam=$2
    argpar=$3
    #echo $fname and $argnam and $argpar
    IFS='.' read -ra ADDR <<< "$fname"
    thisbranch="${ADDR[0]}"
    echo "Notes in $thisbranch"
    key=0
    if [ $argnam ]
    then
        key=1
    fi
    
    while read -r line
    do
        arr[arn]="$line"
        arn+=1
    done < $fname
    
    if [ "$key" -eq "1" ]
    then
        if [ "$argnam" = "add" ]
        then
            echo "[$fname notes modified: addition]"
            echo "$argpar" >> $fname
        elif [ "$argnam" = "del" ]
        then
            if [ "$argpar" = "all" ]
            then
                echo "[$fname notes modified: erased]"
                > $fname
            else
                echo "[$fname notes modified: deletion]"
                > $fname
                for t in ${!arr[@]}; do
                    if [ "$t" -ne "$argpar" ]
                    then
                        echo ${arr[$t]} >> $fname
                    fi
                done
                #echo ${arr[@]}
            fi
        fi
    fi
    listfile $fname
}

branches=$(getbranch 1)
IFS=' ' read -ra branchlist <<< "$branches"

if [ "$1" = "ls" ]
then
    echo $branches
elif [ "$1" = "help" ]
then
    echo "Manual:
alias todo=path+\"/main.sh\"
> todo new <branch-name>
creates new branch
> todo rm <branch-name>
deletes an existing branch
> todo ls
lists all branches (1 repesents active branch)
> todo
lists notes in active branch
> todo add \"notes\"
adds notes to current branch
> todo del <num>
deletes notes in current branch at <num>"
elif [ "$1" = "cd" ]
then
    if [ "$2" = "$(getbranch 0)" ]
    then
        echo "You are already in $2"
        echo $(getbranch 1)
    else
        key=0
        for t in ${!branchlist[@]}; do
            if [ "${branchlist[$t]}" = "$2" ]
            then
                key=1
            fi
        done
        if [ "$key" = "1" ]
        then
            switchbranch $2
            echo $(getbranch 1)
        else
            echo "Branch doesnt exist. Existing branches are:"
            echo $(getbranch 1)
        fi
    fi
elif [ "$1" = "new" ]
then
    key=0
    for t in ${!branchlist[@]}; do
        if [ "${branchlist[$t]}" = "$2" ]
        then
            key=1
        fi
    done
    if [ "$key" = "1" ]
    then
        echo "Branch $2 already exists"
        echo $(getbranch 1)
    else
        editbranches 0 $2
    fi
elif [ "$1" = "rm" ]
then
    key=0
    for t in ${!branchlist[@]}; do
        if [ "${branchlist[$t]}" = "$2" ]
        then
            key=1
        fi
    done
    if [ "$key" = "1" ]
    then
        if [ "$2" = "master" ]
        then
            echo "Cannot remove master branch"
            echo $(getbranch 1)
        else
            editbranches 1 $2
        fi
    else
        echo "Branch $2 doesnt exists"
        echo $(getbranch 1)
    fi
elif [ "$1" = "" ] || [ "$1" = "add" ] || [ "$1" = "del" ]
then
    curr=$(getbranch 0)
    inabranch "$curr.txt" "$1" "$2"
fi