#! /bin/bash

path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/"

if [ -d $path ]
then
    kos=1
else
    echo "Path incorrect"
    exit 1
fi

rare_heading=$(tput setaf 202);
only_message_output=$(tput setaf 33);
passive_output=$(tput setaf 248);
text_heading=$(tput setaf 29);
dashes=$(tput setaf 15);
error_message=$(tput setaf 52);

function checker(){
    arr=(branches.txt master.txt)
    for t in ${!arr[@]}
    do
        if [ -e "$path${arr[$t]}" ]
        then
            continue
        else
            touch $path${arr[$t]}
            
            if [ "${arr[$t]}" = "branches.txt" ]
            then
                echo "master 1" > $path${arr[$t]}
            else
                touch $path"done"${arr[$t]}
            fi
        fi
    done
}

function backup(){
    echo "${rare_heading}Any archives if existing will be overwritten. Proceed? [y/n]${dashes}"
    read
    ans=$REPLY
    if [ "$ans" = "y" ] || [ "$ans" = "Y" ]
    then
        echo "${only_message_output}Making Backup${dashes}"
    else
        echo "${passive_output}Exited${dashes}"
        exit 1
    fi
    
    if [ -d $path"archives" ]
    then
        key=0
    else
        mkdir $path"archives"
    fi
    
    for t in ${!branchlist[@]}
        do
            if [ "${#branchlist[$t]}" -ge "3" ]
            then
                cp $path${branchlist[$t]}.txt $path"archives"
            fi
        done
    
    echo ${only_message_output}Exported to: $path"archives" ${dashes}
}

function getbranch(){
    wo=$1
    bls=[]
    bln=0
    fname1=$path"branches.txt"
    
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
    
    echo "${only_message_output}Switched to branch $whichto${dashes}"
}

function editbranches(){
    key=$1
    name=$2
    if [ "$key" = "0" ]
    then
        if [ "${#name}" -le "2" ]
        then
            echo "${error_message}Branch name should be atleast 3 charachters${dashes}"
            exit 1
        fi
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
        touch $path"done$2.txt"
        echo "${only_message_output}New branch created: $2${dashes}"
    elif [ "$key" = "1" ]
    then
        echo "${rare_heading}Deleting branch $name. Proceed? [y/n]${dashes}"
        read
        ans=$REPLY
        if [ "$ans" = "y" ] || [ "$ans" = "Y" ]
        then
            kas=1
        else
            echo "${passive_output}Exited${dashes}"
            exit 1
        fi
    
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
        rm $path"done$2.txt"
        echo "${only_message_output}Branch removed: $2${dashes}"
    fi
}

function listfile(){
    fname2=$1
    comp=$2
    farr=()
    farn=0
    IFS='/' read -ra ADDR <<< "$fname2"
    IFS='.' read -ra ADDR2 <<< "${ADDR[$((${#ADDR[@]}-1))]}"
    thisbranch="${ADDR2[0]}"
    echo "${dashes}-------------------------------------------------${dashes}"
    echo "${text_heading}Notes in $thisbranch${dashes}"
    echo ""
    while read -r line
    do
        farr[farn]="$line"
        farn=$(($farn + 1))
    done < $fname2
    
    for t in ${!farr[@]}; do
        echo "${only_message_output}$t${dashes} ${dashes}${farr[$t]}${dashes}"
    done
    
    if [ "${#farr[@]}" -eq "0" ]
    then
        echo "[$thisbranch notes empty]"
    fi
    echo ""
    
    if [ "$comp" = "2" ]
    then
        echo ""
        echo "${text_heading}Completed notes in $thisbranch${dashes}"
        arr=()
        arn=0
        while read -r line
        do
            arr[arn]="$line"
            arn=$(($arn + 1))
        done < $path"done"$thisbranch".txt"
        
        for t in ${!arr[@]}; do
            echo "${only_message_output}$t ${dashes}${arr[$t]}${dashes}"
        done
        if [ "${#arr[@]}" -eq "0" ]
        then
            echo "[$thisbranch completed notes empty]"
        fi
        echo ""
    fi
    
    echo "${dashes}-------------------------------------------------${dashes}"
}

function del_done(){
    arr=()
    arn=0
    fname=$1
    argpar=$2
    while read -r line
    do
        arr[arn]="$line"
        arn=$(($arn + 1))
    done < $fname
    
    if [ "$argpar" = "" ]
    then
        echo "Nothing to delete"
    elif [ "$argpar" = "all" ]    
    then
        echo "${only_message_output}[$thisbranch notes modified: erased]${dashes}"
        > $fname
    else
        re='^[0-9]+$'
        if ! [[ $argpar =~ $re ]]
        then
           echo "${error_message}error: Not a number${dashes}" >&2; exit 1
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
                echo "${only_message_output}[$thisbranch notes modified: deletion]${dashes}"
            else
                echo "${only_message_output}Nothing deleted${dashes}"
            fi
        fi
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
        arn=$(($arn + 1))
    done < $fname
    
    if [ "$key" -eq "1" ]
    then
        if [ "$argnam" = "add" ]
        then
            echo "${only_message_output}[$thisbranch notes modified: addition]${dashes}"
            echo "$argpar" >> $fname
        elif [ "$argnam" = "del" ]
        then
            if [ "$argpar" = "" ]
            then
                echo "Nothing to delete"
            elif [ "$argpar" = "all" ]    
            then
                echo "${only_message_output}[$thisbranch notes modified: erased]${dashes}"
                > $fname
            else
                re='^[0-9]+$'
                if ! [[ $argpar =~ $re ]]
                then
                   echo "${error_message}error: Not a number${dashes}" >&2; exit 1
                else
                    echo -e "${error_message}Delete item or save to completed? [d/c] \c${dashes}"
                    read
                    ans=$REPLY
                    save=0
                    if [ "$ans" = "c" ] || [ "$ans" = "C" ]
                    then
                        save=1
                    fi
                    > $fname
                    keys=0
                    for t in ${!arr[@]}; do
                        if [ "$t" -eq "$argpar" ]
                        then
                            keys=1
                            if [ "$save" = "1" ]
                            then
                                echo ${arr[$t]} >> $path"done"$thisbranch".txt"
                            fi
                        fi
                        if [ "$t" -ne "$argpar" ]
                        then
                            echo ${arr[$t]} >> $fname
                        fi
                    done
                    if [ "$keys" -eq "1" ]
                    then
                        echo "${only_message_output}[$thisbranch notes modified: deletion]${dashes}"
                    else
                        echo "${only_message_output}Nothing deleted${dashes}"
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
        echo "${dashes}-------------------------------------------------${dashes}"
        echo "Timer Ongoing"
        echo ""
        echo "${rare_heading}$message${dashes}"
        
        echo ""
        echo "${dashes}You have ${text_heading}$(($temp/60))m$(($temp%60))s${dashes} time left to finish your task"
        echo ""
        echo "${dashes}-------------------------------------------------${dashes}"
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
        echo "${text_heading}$(getbranch 1)${dashes}"
    elif [ "$1" = "all" ]
    then
        for t in ${!branchlist[@]}
        do
            if [ "${#branchlist[$t]}" -ge "3" ]
            then
                if [ "$2" = "wc" ]
                then
                    listfile $path${branchlist[$t]}.txt "2"
                else
                    listfile $path${branchlist[$t]}.txt
                fi
            fi
        done
    elif [ "$1" = "backup" ]
    then
        backup
    elif [ "$1" = "wc" ]
    then
        curr=$(getbranch 0)
        if [ "$2" = "del" ]
        then
            del_done "$path"done"$curr.txt" "$3"
        fi
        
        listfile $path"$curr.txt" "2"
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
            echo "${only_message_output}You are already in $2${dashes}"
            echo "${text_heading}$(getbranch 1)${dashes}"
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
                echo "${error_message}Branch doesnt exist. ${dashes}Existing branches are:"
                echo "${text_heading}$(getbranch 1)${dashes}"
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
            echo "${error_message}Branch $2 already exists${dashes}"
            echo "${text_heading}$(getbranch 1)${dashes}"
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
                echo "${error_message}Cannot remove master branch${dashes}"
                echo "${text_heading}$(getbranch 1)${dashes}"
            else
                editbranches 1 $2
            fi
        else
            echo "${error_message}Branch $2 doesnt exists${dashes}"
            echo "${text_heading}$(getbranch 1)${dashes}"
        fi
    elif [ "$1" = "" ] || [ "$1" = "add" ] || [ "$1" = "del" ]
    then
        curr=$(getbranch 0)
        inabranch $path"$curr.txt" "$1" "$2"
    fi
}

checker
main_argcheck "$1" "$2" "$3"