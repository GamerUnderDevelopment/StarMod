#!/bin/bash

aMods=($( cat modlist.txt | cut -d' ' -f 1,2))
iMods=${#aMods[@]}
strReturn='null'$1

for (( i=0; i<$iMods; i++ ))
do
   if [ $1 = ${aMods[$i]} ]
   then
      strReturn=${aMods[((i+1))]}" " 
   fi
done

echo $strReturn