#!/bin/bash

aSubbedMods=( $(ls ~/sb_workshop/) )
iChoice=1
strName

clear
 for (( i=0; i<${#aSubbedMods[@]}; i++ ))
 do
    strName=$( ./modSearch.sh ${aSubbedMods[i]} )

	if [ "${strName#*null}" = "${strName}" ]
   then
   	if [ $iChoice -lt 10 ]
   	then
   		echo 0$iChoice": " ${strName/_/ }
   	else
   		echo $iChoice": " ${strName/_/ }
   	fi
   else
   	strName=${strName/_/ }
   	strName=${strName/null/}

		if [ $iChoice -lt 10 ]
		then
			echo 0$iChoice": " ${strName}
		else
			echo $iChoice": " ${strName}
		fi
    fi
    
    ((iChoice++))
 done