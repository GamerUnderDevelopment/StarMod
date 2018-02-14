#!/bin/bash

SBMM=~/Library/Application\ Support/sbmm/

function modSearch {
	local aMods=($( cat "${SBMM}"db/modlist.txt | cut -d' ' -f 1,2))
	local iMods=${#aMods[@]}
	local strReturn=$1

	for (( i=0; i<$iMods; i++ ))
	do
		if [ $1 = ${aMods[$i]} ]
		then
			strReturn=${aMods[((i+1))]}" "
		fi
	done

	echo "${strReturn}"
}

function modScan {
	local aSubbedMods=( $(ls "${SBMM}"sb_workshop/) )
	local iChoice=1
	local tmpURL
	local strName
	local steamID
	local steamURL="http://steamcommunity.com/sharedfiles/filedetails/?id="

	for (( i=1; i<${#aSubbedMods[@]}; i++ ))
	do
		strName=$( modSearch "${aSubbedMods[i]}" )
	 	if [[ $strName =~ ^[[:digit:]] ]]
			then
			steamID="${aSubbedMods[$i]}"
			tmpURL="${steamURL}${steamID}"
			strName=$( curl -s $tmpURL | grep -e "<title>" )
			strName="${strName/<title>Steam Workshop :: /}"
			strName="${strName/<\/title>/}"
			strName="${strName//&quot;/\"}"
			strName="${strName// /_}"
			echo $steamID $strName >> "${SBMM}"db/modlist.txt
		fi
	done

	sleep 10
}

modScan
