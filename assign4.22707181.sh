 # Alice Karatchentzeff de Vienne
 # Student Number: 22707181
 # alice.karatchentzeff@ucdconnect.ie

 # This program generates a computer science transcript from a set of core/elective modules and the argument specifying whether there is an internship in stage 3
 # To use: enter "./assign4.22707181.sh [OPTIONS]"
 # OPTIONS could be: I, NI, --help
 # running the program might require "chmod u+x assign4.22707181.sh"

 # A temporary file is used to store the transcript as it is generated, and output it in columns at the end
 # Stages are printed sequentially
 # Within stages:
 #      - core modules are printed sequentially
 #      - elective modules are chosen randomly (unless Internship)
 #      - elective modules are printed sequentially
 # GP are picked randomly
 # total GP is global and updated every time a module is added to the temporary file


source ./stage1.sh.inc # stage 1 module codes, names, credits
source ./stage2.sh.inc # stage 2 module codes, names, credits
source ./stage3.sh.inc # stage 3 module codes, names, credits
source ./stage4.sh.inc # stage 4 module codes, names, credits
source ./grades.sh.inc # module grades & GP
source ./mincredits.sh.inc # stage minimum credits

# ========================================================================
# FUNCTIONS
# ========================================================================

print_modules () {
    declare -n modules=$1
    for (( i=0; i< ${#modules[@]}; i+=3 )); do
        let "grade=${RANDOM} % 5"
        echo -e "${modules[$i]}\t${modules[${i}+1]}\t${modules[${i}+2]}\t${grades[${grade}*2]}\t${grades[${grade}*2+1]}" >> temp.txt
        let "totalGP+=${grades[${grade}*2+1]}"
    done
}

total_credits () {
    declare -n modules=$1
    credits=0
    for (( i=0; i< ${#modules[@]}; i+=3 )); do
        let "credits+=${modules[${i}+2]}"
    done
    echo $credits
}

print_stage () { 
    declare -n stage_core=stage$1core
    declare -n stage_elective=stage$1elective
    echo -e "Stage $1" >> temp.txt
    echo -e "------\t-----\t----\t-----\t---" >> temp.txt
    print_modules stage_core

    declare -a electives
    if [ $1 -eq 3 -a $2 == "I" ]; then
        electives+=("${stage_elective[0]}")
        electives+=("${stage_elective[1]}")
        electives+=("${stage_elective[2]}")
    else
        declare -i "credits=${minc[$1 - 1]} - $(total_credits stage_core)"
        declare -i index
        declare -i cred
        while [ $credits -gt 0 ]; do
            let "index=$RANDOM % ( ${#stage_elective[@]} / 3 ) * 3"
            let "cred=${stage_elective[${index} + 2]}"
            if [ ${stage_elective[${index}]} != "COMP30790" -a $credits -ge $cred -a $(echo ${electives[@]} | grep "${stage_elective[${index}]}" | wc -w) -eq 0 ]; then
                electives+=("${stage_elective[${index}]}")
                electives+=("${stage_elective[${index}+1]}")
                electives+=("${stage_elective[${index}+2]}")
                let "credits=$credits - $cred"
            fi
        done
    fi
    print_modules electives
    echo -e "------\t-----\t----\t-----\t---" >> temp.txt
}

print_correct_usage () {
    echo "Correct usage: $0 <I|NI>"
    echo "I for intership in stage 3"
    echo "NI for no internship in stage 3"
    exit 0
}

# ========================================================================
# INPUT-VALIDATION
# ========================================================================

if [  $# -ne 1  -o  "$1" = "--help" ]; then #quotes for $1 in case it is empty
    print_correct_usage
fi

if [ "$1" != "I" -a "$1" != "NI" ]; then 
    print_correct_usage
fi

# ========================================================================
# BODY
# ========================================================================

totalGP=0
touch temp.txt
echo -e "======\t=====\t====\t=====\t===" >> temp.txt
print_stage 1
print_stage 2
print_stage 3 $1
print_stage 4
column -t -s $'\t' -N "Module,Title,Cred,Grade,G.P" temp.txt
rm temp.txt
echo "Total Grade Point Score: $totalGP"