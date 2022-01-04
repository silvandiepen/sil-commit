#!/bin/bash

black=`tput setaf 0`
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
blue=`tput setaf 4`
magenta=`tput setaf 5`
cyan=`tput setaf 6`
white=`tput setaf 7`
reset=`tput sgr0`
bold=`tput bold`
dim=`tput dim`

# printf "\t${bold}${blue}GiG${reset}${bold}Commit${reset}"



function question {
    printf "\n"
    if [[ ! -z "$2" ]]; then
        printf "\t${bold}${1}${reset} ${blue}($2)${reset} \n"
    else 
        printf "\t${bold}${1}${reset} \n"
    fi 
}


#### SELECT

# Renders a text based list of options that can be selected by the
# user using up, down and enter keys and returns the chosen option.
#
#   Arguments   : list of options, maximum of 256
#                 "opt1" "opt2" ...
#   Return value: selected index (0 for opt1, 1 for opt2 ...)
function select_option {

    # little helpers for terminal print control and key input
    ESC=$( printf "\033")
    cursor_blink_on()  { printf "$ESC[?25h"; }
    cursor_blink_off() { printf "$ESC[?25l"; }
    cursor_to()        { printf "$ESC[$1;${2:-1}H"; }
    print_option()     { printf "\t  $1       "; }
    print_selected()   { printf "\t${blue}${bold}✓ ${1}${reset}  "; }
    get_cursor_row()   { IFS=';' read -sdR -p $'\E[6n' ROW COL; echo ${ROW#*[}; }
    key_input()        { read -s -n3 key 2>/dev/null >&2
                         if [[ $key = $ESC[A ]]; then echo up;    fi
                         if [[ $key = $ESC[B ]]; then echo down;  fi
                         if [[ $key = ""     ]]; then echo enter; fi; }

    # initially print empty new lines (scroll down if at bottom of screen)
    for opt; do printf "\n"; done

    # determine current screen position for overwriting the options
    local lastrow=`get_cursor_row`
    local startrow=$(($lastrow - $#))

    # ensure cursor and input echoing back on upon a ctrl+c during read -s
    trap "cursor_blink_on; stty echo; printf '\n'; exit" 2
    cursor_blink_off

    local selected=0
    while true; do
        # print options by overwriting the last lines
        local idx=0
        for opt; do
            cursor_to $(($startrow + $idx))
            if [ $idx -eq $selected ]; then
                print_selected "$opt"
            else
                print_option "$opt"
            fi
            ((idx++))
        done

        # user key control
        case `key_input` in
            enter) break;;
            up)    ((selected--));
                   if [ $selected -lt 0 ]; then selected=$(($# - 1)); fi;;
            down)  ((selected++));
                   if [ $selected -ge $# ]; then selected=0; fi;;
        esac
    done

    # cursor position back to normal
    cursor_to $lastrow
    printf "\n"
    cursor_blink_on

    return $selected
}

# type_options=("feature" "fix" "bugfix" "test")
# select_option "${type_options[@]}"
# TYPE=${type_options[$choice]}
# echo TYPE

function select_opt {
    select_option "$@" 1>&2
    local result=$?
    echo $result
    return $result
}

# case `select_opt "Yes" "No" "Cancel"` in
#     0) echo "selected Yes";;
#     1) echo "selected No";;
#     2) echo "selected Cancel";;
# esac


function get_length {
    COUNTER=0

    for file in $@
    do
        let COUNTER=COUNTER+1 

    done
    echo $COUNTER
}

#### COMMIT SCRIPT


branch=$(git symbolic-ref HEAD | sed -e 's,.*/\(.*\),\1,')
staged=$(git diff --name-only --staged)
stagedstatus=$(git diff --name-status --staged)
stageLength=$(get_length $staged)
stagedArray=()
for file in $stagedstatus
do
    stagedArray+=($file)
done




printf "\n"
printf "\t${bold}${blue}Sil${reset}${bold}Commit${reset}"
printf "\n"
printf "\n\tbranch\t ${bold}$branch${reset}"
printf "\n\tchanges\t ${bold}${stageLength}${reset}"
printf "\n"
printf "\n"
# echo '\033[38;5;1mnormal \033[02;38;5;1mdim \033[01;38;5;1mbold'

if [ -z "$staged" ]; then
    printf "\tThere are no staged files."
    printf "\n"
    printf "\n"
    exit 0
fi

printf "\t${bold}Staged files${reset}"
printf "\n"


x=0
xt=${#stagedArray[@]}
while [ $x -le $xt ]
do    
    if [ "${stagedArray[$x]}" = "M" ]; then
        echo "\t- ${yellow}${stagedArray[$x+1]}${reset}"
    elif [ "${stagedArray[$x]}" = "A" ]; then 
        echo "\t+ ${green}${stagedArray[$x+1]}${reset}"   
    elif [ "${stagedArray[$x]}" = "A" ]; then 
        echo "\t+ ${green}${stagedArray[$x+1]}${reset}"
    fi
    x=$(( $x + 2 ))
done


# temporary exit!
printf "\n"
printf "\n"
printf "\n"
exit 0;


# len=${#stagedstatus[@]}
# for (( i=0; i<$len; i++ )); do 
#     input="${stagedstatus[$i]}"  
#     echo ${input%   *}
# done


# SHOW ADVANCED FIELDS
question "Advanced?" "y/N"
read -p " " ADVANCED_ANSWER
N='n';
ADVANCED=0
IS_ADVANCED=${ADVANCED_ANSWER:-$N}


if [ "$IS_ADVANCED" = 'y' ]; then 
    echo "Yes, its true"
    ADVANCED=1
fi



if [ $ADVANCED = 1 ]; then


    # CURRENT TEAM
    branchArray=(${branch//-/ })
    question 'Team ID' $branchArray
    read -p " " TEAM_ANSWER
    TEAM="${TEAM_ANSWER:-$branchArray}"


    # TICKET NUMBER
    TICKET_NUMBER="${branch//[^0-9]/}"

    question 'Ticket Number' $TICKET_NUMBER
    read -p " " TICKET_ANSWER
    TICKET="${TICKET_ANSWER:-$TICKET_NUMBER}"


    # PACKAGE
    PACKAGE_FOLDER=$(basename $PWD)
    question 'Package name' $PACKAGE_FOLDER
    read -p " " PACKAGE_ANSWER
    PACKAGE="${PACKAGE_ANSWER:-$PACKAGE_FOLDER}"


    # SHOW COMMIT MESSAGE
    question "Closing?" "y/N"
    read -p " " COMMIT_ANSWER
    N='n';
    CLOSES="${COMMIT_ANSWER:-$N}"

fi

# TYPE OF BRANCH
question "Type"
type_options=("build" "chore" "ci" "docs" "feat" "fix" "perf" "refactor" "revert" "style" "test")
# type_options=("feat" "fix" "bugfix" "test")
select_option "${type_options[@]}"
choice=$?
BRANCH_TYPE="${type_options[$choice]}"


# COMMIT MESSAGE
question "Commit Message"
read -p " " MESSAGE_ANSWER
MESSAGE=`echo "$MESSAGE_ANSWER" | awk '{print tolower($0)}'`

COMMIT_MSG1="[$BRANCH_TYPE]: $MESSAGE"
COMMIT_MSG2=""
COMMIT_FULL_MSG="[$BRANCH_TYPE]: $MESSAGE"


if $ADVANCED; then
    COMMIT_MSG1="$BRANCH_TYPE($PACKAGE): $MESSAGE"
    COMMIT_MSG2="Closes #${TEAM}-${TICKET}"

    if ["$CLOSES" = 'n' ] || [ "$CLOSES" = 'N' ]; then 
        COMMIT_FULL_MSG="git commit -m \"${COMMIT_MSG1}\""
    else
        COMMIT_FULL_MSG="git commit -m \"${COMMIT_MSG1}\" -m \"${COMMIT_MSG2}\""
    fi
fi



# SHOW COMMIT MESSAGE
question "Are you sure you want to commit;"
printf "\t${yellow}$COMMIT_FULL_MSG${reset}" 
printf "\t"
read -p "${blue}Y/n${reset}   " COMMIT_ANSWER
Y='y';
DO_COMMIT="${COMMIT_ANSWER:-$Y}"


# echo $DO_COMMIT

if [ "$DO_COMMIT" = 'y' ] || [ "$DO_COMMIT" = 'Y' ]; then
echo 'There you go...'
git commit -m "${COMMIT_MSG1}" -m "${COMMIT_MSG2}"
echo ''
echo ''
else 
    echo "Ok, you don't have to.."
fi