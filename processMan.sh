#!/bin/bash

####################### change to appropriate process #####################
processPath='/home/hadcmono/OkaraAPI'
startProcessCMD="$processPath/run.sh"
runningUser=hadcmono #for root if running under root privilege

black=$(tput setaf 0)
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
magenta=$(tput setaf 5)
cyan=$(tput setaf 6)
white=$(tput setaf 7)
normal=$(tput sgr0)
#printf "%40s\n" "[${blue}This text is blue${normal}]"

###########################  static variable ###############################
grepProcess="[${processPath[@]:0:1}]${processPath[@]:1}"
killCount=0
retrylimit=3
action=$1
currentUser=$(whoami)

#######################  function definition  ###############################
function delayIndicator {
# $1: message
# $2: number of second
i=0
let delaySec=$2*10
printf "$1"
while [ $i -lt $delaySec ]
do
printf "."
let i=$i+1
sleep 0.1
done
echo "."
}

function usage {
	echo -e "\e[38;5;196m USAGE :\e[38;5;46m processMan.sh start/stop/restart/status \e[0m"
}

function stopProcess {
checkProcessThread
if [ $processCount -gt 0 ]; then
	killProcesses
	stopCount=1
	delayIndicator "Stopping Process" 3
	stopProcess
else
	if [ -z "$stopCount" ]; then
                printf "%-100s [${green}ALREADY STOPPED${normal}] \n" "The process in ${blue} $processPath ${normal}:"
		if [ -z "$isRestart"  ]; then
		exit 3
		fi
	else
                                                                                                                         
                printf "%-100s [${green}OK${normal}] \n" "Stop process in ${blue} $processPath ${normal}:"
                if [ -z "$isRestart"  ]; then
                exit 3
                fi
	fi
fi
}

function startProcess {
checkProcessThread
if [ $processCount -gt 1 ]; then
        killProcesses
	startProcess        
else
	if [ $processCount -eq 1 ]; then
		if [ -z "$startCount" ]; then
		printf "%-100s [${green}ALREADY STARTD${normal}] \n" "The process in ${blue} $processPath ${normal}:"
		exit 2
		else
                printf "%-100s [${green}OK${normal}] \n" "Start process in ${blue} $processPath ${normal}:"
		exit 0
		fi
	else
		if [ -z "$startCount" ]; then
			/bin/sh $startProcessCMD
			startCount=1
			delayIndicator "Starting Process" 3
			startProcess	
		else
	                printf "%-100s [${red}FAILED${normal}] \n" "Start process in ${blue} $processPath ${normal}:"
			exit 1
		fi	
	fi
fi
}

function checkProcessThread {
processPIDs=`/bin/ps aux | grep $grepProcess | grep -v processMan.sh  | awk '{print $2}'`
processCount=`/bin/ps aux | grep $grepProcess | grep -v processMan.sh | awk '{print $2}' | wc -l`
}

function killProcesses {
for pid in $processPIDs
do
	if [ $killCount -gt 1 ]; then
		/bin/kill -9 $pid
	else
		/bin/kill -SIGTERM $pid
	fi
done
sleep 3

checkProcessThread

if [ $processCount -gt 0 ]; then
	let killCount=$killCount+1
	sleep 7
	echo "Retry to KILL process for $killCount time"
	if [ $killCount -eq $retrylimit ]; then
        printf  "%-100s [${red}FAILED${normal}] \n" "KILL process in ${blue} $processPath ${normal}:"
        printf "Check it Manually"
	exit 1
	fi
	killProcesses
fi

}

function processStatus {
echo "Checking Process......"
checkProcessThread
if [ $processCount -eq 0 ]; then
        printf "%-100s [${red}STOPPED${normal}] \n" "Status of Process in ${blue} $processPath ${normal}:"
	exit 3
else
	if [ $processCount -eq 1 ]; then	
        printf "%-100s [${green}STARTED${normal}] \n"  "Status of Process in ${blue} $processPath ${normal}:"
	exit 2
	else
        printf  "%-100s [${red}CRITICAL${normal}] \n" "There are $processCount processes of ${blue} $processPath ${normal} still running, try to stop then start:"
	exit 1
	fi
	
fi

}

#################################   MAIN   #################################
# check if run.sh exist or not
if [ ! -e $startProcessCMD ]; then
echo "Run.sh file doesn't exist, pls check and add as following :
 1/ run.sh must be placed in the processPath                                      
 2/ run.sh must be run daemon and out put (standard in/out) to /dev/null         
 3/ run.sh must has absolute path (processPath)                                   
 4/ exit : 0 - ok, 1 -error , status: 2 - started , 3 - stopped                   
"
exit 4
fi
#### check if current user is running user or not
if [ $currentUser != "$runningUser"  ]; then

	echo -e "\e[38;5;196m This process doesn't running with \e[30;48;5;82m $currentUser \e[0m\e[38;5;196m user.\e[0m  Try with \e[38;5;46m sudo -u $runningUser CMD  \e[0m"
	exit 1
else
	if [[ -z "$action" ]]; then
		usage
		exit 1
	else
	cd $processPath
		case $action in
		start)
			startProcess;;
		stop)
			stopProcess;;
		restart)	
			isRestart=1
			stopProcess
			startProcess;;
		status)
			processStatus;;
		*)
			usage;;
		esac
	fi
fi
exit 0
