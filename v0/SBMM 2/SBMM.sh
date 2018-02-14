#!/bin/bash
# Starbound Mod Manager
# Version 1.0

#Global Variables
cols=$( tput cols )
rows=$( tput lines )
middle_row=$(( $rows / 2 ))
bottom_row=$rows
steamFile=$( find ~ -name "Starbound.app" )

# Variable Checking Function
function vc {
   local varKey=$1
   local varValue=$2
   echo "   "$varKey: $varValue
}

# Preflight to Check for Symlinks
function preflight {
	if [ ! -e ~/sb_configs ]
		then
		displaySetup
	fi
}

# Test New Display Output
function displayOutput {
# 	Declare/Define Variables	
	local aMsgs=("$@")
	local line_count=${#aMsgs[@]}
	local insert_row=2
	local message_len=0
	local half_message_len=0
	local insert_col=0
	local curPosition=0
	local lineBreaks=0
	local tmpStr=""

#	Get widest message length	
	for message in "${aMsgs[@]}"
	do
		if [ ${#message} -gt $message_len ]
		 then
		 	message_len=${#message}
		fi
	done

	half_message_len=$(( message_len / 2 ))
	insert_col=$(( ($cols / 2) - $half_message_len ))
	
	for message in "${aMsgs[@]}"
	do
		# Get Line Breaks
		lineBreaks=$(( ${message#*_LINES} ))
 		tmpStr="_LINES"$lineBreaks
		message="${message/$tmpStr/}"
 		insert_row=$(( insert_row + lineBreaks ))
 		tput cup $insert_row $insert_col

# 		Check for Bold
    	if [ "${message#*BOLD_}" != "${message}" ]
    	then
 			message=${message/BOLD_/}
 			tput bold
 		fi
 
# 		Check for Reverse
 		if [ "${message#*REV_}" != "${message}" ]
 		then
 			message="${message/REV_/}"
 			tput setaf 3
 			tput rev
 		fi

#		Check for Prompts
 		if [ "${message#*PROMPT_}" != "${message}" ]
 			then
 				message="${message/PROMPT_/}"
 				tput setaf 3
 				tput bold
 				printf "${message}"
 		else
 			echo "${message}"
 		fi
 		tput sgr0
	done
}

function modSearch {
	local aMods=($( cat modlist.txt | cut -d' ' -f 1,2))
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
	local aModDisplay=("$@")
	local aSubbedMods=( $(ls ~/sb_workshop/) )
	local iChoice=1
	local strName
	local aModList=()

	for (( i=1; i<${#aSubbedMods[@]}; i++ ))
		do
		strName=$( modSearch "${aSubbedMods[i]}" )
		aModList+=($strName)
		strName=${strName//_/ }
		
		if [ $i -lt 10 ]
			then
			aModDisplay+=("PROMPT_0${i}: ${strName}_LINES1")
		else
			aModDisplay+=("PROMPT_${i}: ${strName}_LINES1")
		fi
	done

	aModDisplay+=("PROMPT_Please select a mod to add to this modPack: _LINES3")
	
	tput clear
	
	displayOutput "${aModDisplay[@]}"
	
	read modSelect
	
	modSelect=$(( $modSelect - 1 ))
	
	local selection="${aModList[$modSelect]}"
	if [[ $selection =~ ^[[:digit:]] ]]
		then
		open "http://steamcommunity.com/sharedfiles/filedetails/?id=${selection}"
		
		tput clear
		local aPrompt=()
		aPrompt+=("BOLD_Please enter a name for this mod below:_LINES1")
		aPrompt+=("PROMPT_This mod is: _LINES3")
		displayOutput "${aPrompt[@]}"
		read modName
		
		local saveName="${modName// /_}"
		echo $selection $saveName >> modlist.txt
	else
		selection="${selection} [*]"
	fi

	modScan "$@"
}

function setupMod {
	message=()
	message+=("BOLD_REV_ Starbound Mod Manager _LINES1")
	message+=("BOLD_We will now provide a list of mods available to be added to your mod pack_LINES1")
	message+=("If the mod is know to SBMM it will be listed by name otherwise it will be listed by SteamID_LINES2")

	modScan "${message[@]}"
}

# Setup A Mod Pack
function setupPack {
	message=()
	message+=("BOLD_REV_ Starbound Mod Manager _LINES1")
	message+=("BOLD_In order to setup a mod pack for you we will need you to name it:_LINES1")
	message+=("PROMPT_Name: _LINES3")

	tput clear
	displayOutput "${message[@]}"
	
	read packName
	packName="${packName// /_}"
	
	echo $packName >> modpacks.txt
	
	setupMod
}

# Main Menu Display
function mainMenu {
	message=()
	message+=("BOLD_REV_ Starbound Mod Manager _LINES1")
	message+=("Please select from the options below:_LINES2")
	message+=("PROMPT_   1. Play Starbound_LINES1")
	message+=("PROMPT_   2. Setup a ModPack_LINES1")
	message+=("PROMPT_   3. Check Mods Available_LINES1")
	message+=("PROMPT_   4. Re-Install SBMM_LINES1")
	message+=("PROMPT_   5. Exit SBMM_LINES1")
	message+=("PROMPT_Please enter your selection number [1 - 5]: _LINES3")

	tput clear
	
	displayOutput "${message[@]}"
	
	read menuChoice

	case $menuChoice in
		1) echo "Play Starbound"
			;;
		2) setupPack
			;;
		3) echo "Check Mods"
			;;
		4) displaySetup
			;;
		5) exit 0
			;;
		*) echo "Not a Correct Selection"	
	esac
}

# Symlink File Setup
function fileSetup {
	steamFile=${steamFile/\/osx\/Starbound.app/}
 	local steamMods=${steamFile/Starbound/Starbound\/mods\/}
 	local steamConfig=${steamFile/Starbound/Starbound\/osx\/}
 	local steamApps=${steamFile/\/common\/Starbound/}
 	local steamWorkshop=${steamApps/SteamApps/SteamApps\/workshop\/content\/211820\/}

	ln -s "${steamMods}" ~/sb_mods
	ln -s "${steamConfig}" ~/sb_configs
	ln -s "${steamWorkshop}" ~/sb_workshop

	./modScan.sh &
}

# Function to Display Setup Message
function displaySetup {
	message=()
   message+=("BOLD_REV_ Welcome to the Starbound Mod Manager _LINES2")
   message+=("We've detected this is your first time running SBMM!_LINES2")
   message+=("BOLD_     Symlinks that will be created:_LINES2")
   message+=("     ~/sb_configs/_LINES1")
   message+=("     ~/sb_mods/_LINES1")
   message+=("     ~/sb_workshop/_LINES1")
   message+=("BOLD_ One moment please while we setup necessary files _LINES3")

	tput clear

	rm -f ~/sb_mods
	rm -f ~/sb_configs
	rm -f ~/sb_workshop
	origMessages=("${message[@]}")
   displayOutput "${message[@]}"
   fileSetup
   
	pid=$!
	
	i=1
	
	while [ -n "$( ps -p ${pid} | grep ${pid} )" ]
	do
			message=()
   		case $i in
   			1) message+=("PROMPT_ [.  ] _LINES14")
   				;;
   			2)	message+=("PROMPT_ [.. ] _LINES14")
   				;;
   			3)	message+=("PROMPT_ [...] _LINES14")
   				;;	
   		esac
	
		((i++))
		if [ $i -eq 4 ]
			then
			i=1
		fi
		sleep 1
 		displayOutput "${message[@]}"
	done
}

preflight
mainMenu
#modScan