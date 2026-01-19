#!/bin/bash
checkBootFile=$1

#first argument takes a file that contains complete service name(include ".service" to avoid grep grabbing similar entries)
#and expected boot status.
#service and boot status seperated by whitespace while entires and seperated by newline
#boot status can be: enabled, disabled, static, alias, transient, generated, indirect, masked, enabled-runtime

serviceList=$(systemctl list-unit-files | awk -F' ' '{print $1,$2}')

while read -r line; do
  name=$(echo "$line" | awk -F' ' '{print $1}')
  expectedBootStatus=$(echo "$line" | awk -F' ' '{print $2}' | sed 's/ //g')

  service=$(echo "$serviceList" | grep "$name")
  serviceName=$(echo "$service" | awk -F' ' '{print $1}')
  actualBootStatus=$(echo "$service" | awk -F' ' '{print $2}' | sed 's/ //g')
  
  statusDiff=$(diff <(echo "$actualBootStatus") <(echo "$expectedBootStatus")) #for some reason i couldnt get string comparison to work
  [[ -n "$statusDiff"  ]] && echo "Boot statuses do not match: $serviceName has boot status: $actualBootStatus. Should be $expectedBootStatus"
done < $checkBootFile
