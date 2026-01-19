#!/bin/bash
usage() { echo "Usage: $0 [-G -U -j -s <string> -f <file> -o <file>]" 1>&2; exit 1; }
#G option excludes getty@tty# service from search
#U option excldues user@#### service from search
#s option adds a custom service to the search
#f option requires a file that contains a list of services to search through. entries seperated by newline
#o option redirects output to specified file

#TODO compare current status with expeced status. return not matching services

excludeGetty=0
excudeUsers=0
customService=""
outputFile=""
servicesListFile=""

allServices=$(systemctl list-units --type=service -all)

gettys=$(echo "$allServices" | grep "getty@")
users=$(echo "$allServices" | grep "user@")

while getopts "GUjs:f:o:" arg
do
  case $arg in
    G)
      excludeGetty=1
      ;;
    U)
      excludeUsers=1
      ;;
    j)
      echo "Journalctl not implemented yet"
      ;;
    s)
      customService=$OPTARG
      ;;
    f)
      servicesListFile=$OPTARG
      ;;
    o)
      outputFile=$OPTARG
      :> $outputFile
      ;;
    *)
      usage
      ;;
  esac
done
getServices()
{
  [[ $excludeGetty -eq 0 ]] && echo "$gettys" | awk -F' ' '{print $1,$3,$4}'
  [[ $excludeUsers -eq 0 ]] && echo "$users" | awk -F ' ' '{print$1,$3,$4}'
  [[ -n "$customService" ]] && echo "$allServices" | grep "$customService" | awk -F' ' '{print $1,$3,$4}'
  if [[ -n "$servicesListFile" ]]; then
    while read -r line; do
      echo "$allServices" | grep "$line" | awk -F' ' '{print $1,$3,$4}'
    done < $servicesListFile
  fi
}

servicesSearched=$(getServices)
[[ -n "$outputFile" ]] && echo "$servicesSearched" > $outputFile || echo "$servicesSearched"

