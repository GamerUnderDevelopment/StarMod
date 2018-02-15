#!/bin/bash
# Mod Scanner
# Version 0.1
# May Be Deprecated

HOMEDIR=~/Library/Application\ Support/starmod/

function scan {
	local aSubbedMods=( $(ls "${HOMEDIR}"sb_workshop/) )
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
			echo $steamID $strName >> "${HOMEDIR}"db/modlist.txt
		fi
	done

	sleep 10
}