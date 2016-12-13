#!/bin/bash

# Global vars
configFile=~/wgetter.conf
logFile=~/wgetter.log
downloadFile=~/wgetter.in
downloadDir=~/Downloads
delayTime=10
currentLine=""

# Functions
readConfig() {
   if [[ -e $configFile ]]; then
      source $configFile
   fi
}
writeConfig() {
   rm $configFile
   echo "logFile=$logFile" >> $configFile
   echo "downloadFile=$downloadFile" >> $configFile
   echo "downloadDir=$downloadDir" >> $configFile
   echo "delayTime=$delayTime" >> $configFile
}
printStatus() {
   nextLine=$(tail -n -2 $logFile | head -n 1)
   if [[ $currentLine == $nextLine ]]; then
      echo "Warning: No progress made"
   else
      echo $nextLine
      currentLine=$nextLine
   fi
}
main() {
   readConfig
   while true; do
      if ps | grep -q "\bwget\b"; then
         echo "Warning: wget is currently running"
      else
         if [[ ! -e $downloadFile ]]; then
            touch $downloadFile
         fi
         url=$(head -n 1 $downloadFile)
         if [[ $url == "" ]]; then
            echo "Finished"
            break
         fi
         echo "Starting: $url"
         wget --tries=0 -c -o $logFile -P $downloadDir/ $url &
      fi
      printStatus
      sleep $delayTime
   done
}

# Program
trap "writeConfig" SIGHUP SIGINT SIGTERM
main
