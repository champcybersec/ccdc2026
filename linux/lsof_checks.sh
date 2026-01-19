#!/bin/bash
touch ~/lsof_check.txt
echo $(date); sudo lsof -i -r5 >> ~/lsof_check.txt &
jobs