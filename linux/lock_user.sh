#!/bin/bash

# Locks and expires users that are not listed in the SAFE array. Generally doesn't include service accounts or
# accounts that do not have a /home/ directory.
# Alternative to deleting in case an important user needs to be kept, we can simply reactivate it.

declare -a SAFE

SAFE=("root" "blackteam")

for user_dir in /home/*/
do

  user=$(basename "$user_dir")

  if [[ ! "${SAFE[@]} " =~ " $user " ]]
  then
    sudo usermod -L -e 1 $user
  fi

done
