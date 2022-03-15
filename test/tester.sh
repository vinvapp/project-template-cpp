#!/bin/bash

#********************************************************************************
#                        Testing Scipt for the Project
#********************************************************************************
#Author: Vincent von Appen

#Program Name (Unit under Test)
progname=./bin/graderx
#Test Directory and it's subdirectories
testDir="test"
inpDir="input"
expDir="expOut"
outDir="actOut"
flagDir="Flag"

diffFlags="-u "
preFix="--ignore-matching-lines="
#dateRegex='^([0-9]+[-]){2}[0-9]+[[:space:]](([0-9])+):(([0-9])+):([0-9])+[\s]$'
dateRegex='^([0-9]+[-]){2}[0-9]+'

#Array for the most second lowest Dir. structure excluding the flag_agrg tests
dataDir=( CtrlErr CtrlWarn DataErr DataWarn Valid )
#dataDir=( "CtrlErr" "CtrlWarn" "DataErr" "DataWarn" "Valid" )
basicDir="basic"
bonusDir="bonus"

#$cpulimit and $outlimit are valid positive integers
cpulimit=3 #seconds of CPU time
outlimit=100000

#check Snytax, create
log=./$testDir/logfile
touch ${log}

#Lookup the syntax for this: (create if non existance?)
echo "Testing script for the project" > ${log}
echo "Author: Vincent von Appen" >> ${log}
echo "Test run on:" >> ${log}
date >> ${log}
echo "(Logfile '${log}' created in the ${testDir} Directory)"
# then process cmd line args to get user's chosen values


#progname is an executable file (-x, -f)
if ! [[ -f ${progname} && -x ${progname} ]] ; then
    # no executable program
    echo "Program: '${progname}' is not executable. Process terminated" >> ${log}
    exit 0
fi

#Array for checking the existance of every Directory
checkDirs=(${inpDir} ${expDir})
subdataDir=(${basicDir} ${bonusDir})

#files=( ./${inpDir}/*/*/* )
#for var in "${files[@]}"; do
    #echo $var
#done

#Check of every of the required directories if it is a Dir and readable
for xDir in "${checkDirs[@]}"; do
    files=( ./$testDir/${xDir}/*/* )
    for var in "${files[@]}"; do
      if ! [[ -d $var && -r $var ]]; then
        echo "Directory '$var' is not a readable directory. Process terminated." >> ${log}
        exit 0
      fi
  done
done

echo "" >> ${log}

#check if every file in the inDir has a corresponding file in expDir
  #add/append the data to variables and print them at the end of the scirpt
    #count of files
    #title that is missing
  #maybe not necessary: check in the for loops?


#Counter for log summary
#Add distingtion for every dir and the error?
testnum=0
errnum=0

echo "" >> ${log}

#Checking all valid data inputs

for yDir in "${dataDir[@]}"; do
  for zDir in ${subdataDir[@]}; do
    for dfile in ./$testDir/${inpDir}/${yDir}/${zDir}/*; do
      
      
      # find matching file in each
      fname=$(basename $dfile)   # get just the filename by itself (basename cmd)
      dname=$(dirname $dfile)
    
      # expected output
      efile=./${testDir}/${expDir}/${yDir}/${zDir}/$fname
      
      # Actual output
      actout=./$testDir/${outDir}/${yDir}/${zDir}/$fname

      #echo "F: $fname D: $dfile"

      if [ -z "$(ls -A ${dname})" ] ; then
          echo "${dfile} is a empty directory">> ${log}
          
      elif ! [[ -f $dfile && -r $dfile ]] ; then
          #don't terminate the process but add it to variables and print them at the end

          # no readable dfile
          echo "Testfile ${dfile} is not readable. Process terminated" >> ${log}
          #exit 0
          # test for each
      else
          #number of testcases
          (( testnum++ ))

          # remember to put this inside brackets to run in separate shell, otherwise when you run the script
          # this limit will stick around after it's done
          (ulimit -t $cputime;  ${progname} ${dfile} 2>&1 | head -c ${outlimit} > ${actout}) > /dev/null

          diffOut=$(mktemp)
          diffAct=$(mktemp)
          diffExp=$(mktemp)

          (tail --lines=+2 ${actout}) > ${diffAct}
          (tail --lines=+2 ${efile}) > ${diffExp}

          #Find the differences, excluding the Date line  (does not work like this!           
          #diff ${diffFlags} ${preFix}${dateRegex} ${preFix}${dateRegex} ${actout} ${efile} > $diffOut
          diff ${diffFlags} ${diffAct} ${diffExp} > $diffOut
          diffs=$?

          #echo "Variable Diffs:"
          #echo "$diffs"
          
                  
          
          if [ ${diffs} -eq 0 ] ; then
              #passed
              echo "Testfile ${dfile}: passed" >> ${log}
          else
            #failed
            echo "" >> ${log}
            echo "Testfile ${dfile}: failed" >> ${log}
            (( errnum++ ))
            
            echo "" >> ${log}
            echo "----   BEGIN  REPORT    ----" >> ${log}
            echo "---- Test File Name: ${fname} ----" >> ${log}              
                      
            echo "---- Test File Contents ----" >> ${log}
            echo "" >> ${log}
            cat  ${dfile}  >> ${log}
            echo "" >> ${log}
          
            echo "---- Expected Contents ----" >> ${log}
            echo "" >> ${log}
            cat  ${efile}  >> ${log}
            echo "" >> ${log}

            echo "---- Actual Output ----" >> ${log}
            echo "" >> ${log}
            cat  ${actout}  >> ${log}
            echo "" >> ${log}
            
            echo "---- Diffrences ----" >> ${log}
            echo "" >> ${log}
            cat  ${diffOut}  >> ${log}
            echo "" >> ${log}
          fi
      fi
    done
  done
done


#Checking the Flags
dfile=""
fname=""

flag=( ./$testDir/${inpDir}/${flagDir}/Flags_Args/* )
for dfile in "${flag[@]}"; do

    fname=$(basename $dfile)

    # expected output
    efile=./${testDir}/${expDir}/${flagDir}/Flags_Args/$fname

    # Actual output
    actout=./$testDir/${outDir}/${flagDir}/Flags_Args/$fname

    
    #echo "F: $fname D: $dfile"
    
    if ! [[ -f $dfile && -r $dfile ]] ; then
        # no readable dfile
        echo "Testfile ${dfile} is not readable. Process terminated" >> ${log}
        exit 0
    else
        #number of testcases
        (( testnum++ ))
       
       inparg=`cat $dfile`
       
       
       
       # remember to put this inside brackets to run in separate shell, otherwise when you run the script
       # this limit will stick around after it's done
       (ulimit -t $cputime;   ${inparg} 2>&1 | head -c ${outlimit} > ${actout}) > /dev/null
#${progname}
       #echo "Actual Output:"
       #cat ${actout}
       
       diffOut=$(mktemp)
       diffAct=$(mktemp)
       diffExp=$(mktemp)
       
       (tail --lines=+2 ${actout}) > ${diffAct}
       (tail --lines=+2 ${efile}) > ${diffExp}
       
       
       #Find the differences, excluding the Date line            
       #diff ${diffFlags} ${preFix}${dateRegex} ${preFix}${dateRegex} ${actout} ${efile} > $diffOut
       diff ${diffFlags} ${diffAct} ${diffExp} > $diffOut
       diffs=$?
       
       #diffs=1

       
       
       if [ ${diffs} -eq 0 ] ; then
           #passed
           echo "Testfile ${dfile}: passed" >> ${log}
       else
          #failed
          echo "" >> ${log}
          echo "Testfile ${dfile}: failed" >> ${log}
          (( errnum++ ))
          
          echo "" >> ${log}
          echo "----   BEGIN  REPORT    ----" >> ${log}
          #echo $PWD >> ${log}
          #echo "${progname} ${inparg}" >> ${log}
          echo "---- Test File Name: ${fname} ----" >> ${log}          
                  
          echo "---- Test File Contents ----" >> ${log}
          echo "" >> ${log}
          cat  ${dfile}  >> ${log}
          echo "" >> ${log}
        
          echo "---- Expected Contents ----" >> ${log}
          echo "" >> ${log}
          cat  ${efile}  >> ${log}
          echo "" >> ${log}

          echo "---- Actual Output ----" >> ${log}
          echo "" >> ${log}
          cat  ${actout}  >> ${log}
          echo "" >> ${log}
          
          echo "---- Diffrences ----" >> ${log}
          echo "" >> ${log}
          cat  ${diffOut}  >> ${log}
          echo "" >> ${log}
       fi
    fi
done


#Output seperated between different test scenarios
echo "" >> ${log}
echo "**** LOG SUMMARY ****" >> ${log}
echo "Number of Test Cases: $testnum" >> ${log}
echo "Number of Test Failures: $errnum" >> ${log}
echo "" >> ${log}

echo ""
echo "**** LOG SUMMARY ****"
echo "Number of Test Cases: $testnum"
echo "Number of Test Failures: $errnum"
echo ""
echo "All done!"
#cat "${log}"
