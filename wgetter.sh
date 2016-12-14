#!/bin/bash

# Global vars
configFile=~/wgetter.cfg
logFile=~/wgetter.log
downloadFile=~/wgetter.in
downloadDir=~/Downloads
delayTime=10

# System vars
currentLine=""
wgetWarning="Warning: Resuming from previous wget process\n"

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
   elif echo $nextLine | grep -q "\bsaved\b"; then
      echo "Success"
      tail -n +2 $downloadFile > $downloadFile
   elif echo $nextLine | grep -q "\bretrieved\b"; then
      echo "Warning: File already downloaded"
      tail -n +2 $downloadFile > $downloadFile
   else
      echo $nextLine
      currentLine=$nextLine
   fi
}
main() {
   readConfig
   while true; do
      if ps | grep -q "\bwget\b"; then
         echo -ne $wgetWarning
      else
         if [[ ! -e $downloadFile ]]; then
            touch $downloadFile
         fi
         url=$(head -n 1 $downloadFile)
         if [[ $url == "" ]]; then
            echo "Finished with all URLs"
            break
         fi
         echo "Starting: $url"
         wget --tries=0 -c -o $logFile -P $downloadDir/ $url &
      fi
      wgetWarning=""
      printStatus
      sleep $delayTime
   done
}

# Program
trap "writeConfig && exit" SIGHUP SIGINT SIGTERM
main
