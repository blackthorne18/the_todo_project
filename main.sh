#! /bin/bash

path="/Users/prajwalbharadwaj/Desktop/shellproject/"

function getbranch(){
    wo=$1
    bls=[]
    bln=0
    fname1=$path"branches.txt"
    fname2=$path"list1.txt"
    
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
    fname1=$path"branches.txt"
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
        fname1=$path"branches.txt"
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
        touch $path"$2.txt"
        echo "New branch created: $2"
    elif [ "$key" = "1" ]
    then
        fname1=$path"branches.txt"
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
        rm $path"$2.txt"
        echo "Branch removed: $2"
    fi
}

function listfile(){
    fname2=$1
    farr=()
    farn=0
    IFS='/' read -ra ADDR <<< "$fname"
    IFS='.' read -ra ADDR2 <<< "${ADDR[$((${#ADDR[@]}-1))]}"
    thisbranch="${ADDR2[0]}"
    echo "Notes in $thisbranch"
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
        echo "[$thisbranch notes empty]"
    fi
    
}

function inabranch(){
    arr=()
    arn=0
    fname=$1
    
    argnam=$2
    argpar=$3
    #echo $fname and $argnam and $argpar
    IFS='/' read -ra ADDR <<< "$fname"
    IFS='.' read -ra ADDR2 <<< "${ADDR[$((${#ADDR[@]}-1))]}"
    thisbranch="${ADDR2[0]}"
    
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
            echo "[$thisbranch notes modified: addition]"
            echo "$argpar" >> $fname
        elif [ "$argnam" = "del" ]
        then
            if [ "$argpar" = "" ]
            then
                echo "Nothing to delete"
            elif [ "$argpar" = "all" ]    
            then
                echo "[$thisbranch notes modified: erased]"
                > $fname
            else
                re='^[0-9]+$'
                if ! [[ $argpar =~ $re ]]
                then
                   echo "error: Not a number" >&2; exit 1
                else
                    > $fname
                    keys=0
                    for t in ${!arr[@]}; do
                        if [ "$t" -eq "$argpar" ]
                        then
                            keys=1
                        fi
                        if [ "$t" -ne "$argpar" ]
                        then
                            echo ${arr[$t]} >> $fname
                        fi
                    done
                    if [ "$keys" -eq "1" ]
                    then
                        echo "[$thisbranch notes modified: deletion]"
                    else
                        echo "Nothing deleted"
                    fi
                fi
            fi
        fi
    fi
    listfile $fname
}

function ready_timer(){
    echo -e "Enter your timer message: \c"
    read
    message=$REPLY
    echo "Format for entering time: 10m30s"
    echo -e "Enter your timer time limit: \c"
    read
    tmlm=$REPLY
    IFS='m' read -ra minu <<< "$tmlm"
    IFS='s' read -ra secu <<< "${minu[1]}"
    minu=${minu[0]}
    #echo $minu and $secu
    tim=$(($minu * 60 + $secu))
    x=0
    while [ "$x" -le "$tim" ]
    do
        temp=$(($tim - $x))
        clear
        echo "-------------------------------------------------"
        echo "Timer Ongoing"
        echo ""
        echo $message
        
        echo ""
        echo "You have $(($temp/60))m$(($temp%60))s time left to finish your task"
        echo ""
        echo "-------------------------------------------------"
        sleep 1
        x=$(($x + 1))
    done
    printf \\a
    printf \\a
    printf \\a
    printf \\a
    printf \\a
}

function main_argcheck(){
    branches=$(getbranch 1)
    IFS=' ' read -ra branchlist <<< "$branches"
    
    if [ "$1" = "ls" ]
    then
        echo $branches
    elif [ "$1" = "timer" ]
    then
        ready_timer
    elif [ "$1" = "help" ]
    then
        cat ./README
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
        inabranch $path"$curr.txt" "$1" "$2"
    fi
}

main_argcheck "$1" "$2" "$3"