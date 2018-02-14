#!/bin/bash
# Starbound Mod Manager
# Version 1.0

#Global Variables
COLS=$( tput cols )
STEAMFILE=$( find ~ -name "Starbound.app" 2> /dev/null )
BOTTOM_ROW=$( tput lines )
SBMM=~/Library/Application\ Support/sbmm/

# Variable Checking Function
function vc {
   local varKey=$1
   local varValue=$2
   echo "   "$varKey: $varValue
}

# Test New Display Output
function displayOutput {
	# 	Declare/Define Variables
	local aMsgs=("$@")					# Variable Contains All Message Strings
	local line_count=${#aMsgs[@]}		# Counts The Number Of Message Strings By Line
	local insert_row=2					# Set the start point of text insertion
	local message_len=14					# Variable to store the longest message
	local insert_col=0					# Variable to store the column for display message insertion
	local lineBreaks=0					# Variable to store the number of line breaks after the message
	local tmpStr=""						# Variable to store the message string minus pre/post tags
												# Pre-tags:
												# BOLD_ = Bold Text
												# REV_ = Reversed Text
												# YELLOW_ = Yellow Text
												# PROMPT_ = Set 2 rows from the bottom

	# Get widest message length
	for message in "${aMsgs[@]}"
	do
		if [ ${#message} -gt $message_len ]
		 then
		 	message_len=${#message}
		fi
	done

	insert_col=$(( ($COLS / 2) - ($message_len / 2) ))

	for message in "${aMsgs[@]}"
	do
		# Get Line Breaks
		lineBreaks=$(( ${message#*_LINES} ))
 		tmpStr="_LINES"$lineBreaks
		message="${message/$tmpStr/}"

 		# Check for Bold
    	if [ "${message#*BOLD_}" != "${message}" ]
    	then
 			message="${message/BOLD_/}"
 			tput bold
 		fi

 		# Check for Reverse
 		if [ "${message#*REV_}" != "${message}" ]
 		then
 			message="${message/REV_/}"
 			tput setaf 3
 			tput rev
 		fi

		# Check for Yellow
 		if [ "${message#*YELLOW_}" != "${message}" ]
		then
			message="${message/YELLOW_/}"
			tput setaf 3
 		fi

		# Check for PROMPT
    	if [ "${message#*PROMPT_}" != "${message}" ]
    	then
 			message=${message/PROMPT_/}
 			insert_row=$(( $BOTTOM_ROW - 4 ))
 		else
	 		insert_row=$(( insert_row + lineBreaks ))
 		fi
 		tput cup $insert_row $insert_col
		printf "${message}"
		tput sgr0
	done
}

# FIRST LAUNCH - Preflight
function preflight {
	if [ ! -e ~/sb_configs ]
		then
		displaySetup
	fi
}

# function modSearch {
# 	local aMods=($( cat modlist.txt | cut -d' ' -f 1,2))
# 	local iMods=${#aMods[@]}
# 	local strReturn=$1

# 	for (( i=0; i<$iMods; i++ ))
# 	do
# 		if [ $1 = ${aMods[$i]} ]
# 		then
# 			strReturn=${aMods[((i+1))]}" "
# 		fi
# 	done

# 	echo "${strReturn}"
# }

# function modScan {
# 	local aModDisplay=("$@")
# 	local aSubbedMods=( $(ls ~/sb_workshop/) )
# 	local iChoice=1
# 	local strName
# 	local aModList=()

# 	for (( i=1; i<${#aSubbedMods[@]}; i++ ))
# 		do
# 		strName=$( modSearch "${aSubbedMods[i]}" )
# 		aModList+=($strName)
# 		strName=${strName//_/ }

# 		if [ $i -lt 10 ]
# 			then
# 			aModDisplay+=("PROMPT_0${i}: ${strName}_LINES1")
# 		else
# 			aModDisplay+=("PROMPT_${i}: ${strName}_LINES1")
# 		fi
# 	done

# 	aModDisplay+=("PROMPT_Please select a mod to add to this modPack: _LINES3")

# 	tput clear

# 	displayOutput "${aModDisplay[@]}"

# 	read modSelect

# 	modSelect=$(( $modSelect - 1 ))

# 	local selection="${aModList[$modSelect]}"
# 	if [[ $selection =~ ^[[:digit:]] ]]
# 		then
# 		open "http://steamcommunity.com/sharedfiles/filedetails/?id=${selection}"

# 		tput clear
# 		local aPrompt=()
# 		aPrompt+=("BOLD_Please enter a name for this mod below:_LINES1")
# 		aPrompt+=("PROMPT_This mod is: _LINES3")
# 		displayOutput "${aPrompt[@]}"
# 		read modName

# 		local saveName="${modName// /_}"
# 		echo $selection $saveName >> modlist.txt
# 	else
# 		selection="${selection} [*]"
# 	fi

# 	modScan "$@"
# }

# function setupMod {
# 	message=()
# 	message+=("BOLD_REV_ Starbound Mod Manager _LINES1")
# 	message+=("BOLD_We will now provide a list of mods available to be added to your mod pack_LINES1")
# 	message+=("If the mod is know to SBMM it will be listed by name otherwise it will be listed by SteamID_LINES2")

# 	modScan "${message[@]}"
# }

# # Setup A Mod Pack
# function setupPack {
# 	message=()
# 	message+=("BOLD_REV_ Starbound Mod Manager _LINES1")
# 	message+=("BOLD_In order to setup a mod pack for you we will need you to name it:_LINES1")
# 	message+=("PROMPT_Name: _LINES3")

# 	tput clear
# 	displayOutput "${message[@]}"

# 	read packName
# 	packName="${packName// /_}"

# 	echo $packName >> modpacks.txt

# 	setupMod
# }

# Main Menu Display
function mainMenu {
	message=()
	message+=("BOLD_REV_ Starbound Mod Manager _LINES1")
	message+=("Please select from the options below:_LINES2")
	message+=("BOLD_YELLOW_   1. Play Starbound_LINES1")
	message+=("BOLD_YELLOW_   2. Manage ModPacks_LINES1")
	message+=("BOLD_YELLOW_   3. Uninstall SBMM_LINES1")
	message+=("BOLD_YELLOW_   4. Exit SBMM_LINES1")
	message+=("PROMPT_Please enter your selection number [1 - 4]: _LINES0")

	tput clear

	displayOutput "${message[@]}"

	read menuChoice

	case $menuChoice in
		1) echo "Play Starbound"
			;;
		2) setupPack
			;;
		3) displaySetup
			;;
		4) exit 0
			;;
		*) echo "Not a Correct Selection"
			mainMenu
			;;
	esac
}

# Symlink File Setup
function fileSetup {
	STEAMFILE=${STEAMFILE/\/osx\/Starbound.app/}
 	local steamMods=${STEAMFILE/Starbound/Starbound\/mods\/}
 	local steamConfig=${STEAMFILE/Starbound/Starbound\/osx\/}
 	local steamApps=${STEAMFILE/\/common\/Starbound/}
 	local steamWorkshop=${steamApps/SteamApps/SteamApps\/workshop\/content\/211820\/}

 	rm -rf ~/Library/Application\ Support/sbmm

	mkdir "${SBMM}"
	mkdir "${SBMM}"db

	if [ ! -e "${steamWorkshop}" ]
		then
		mkdir -p "${steamWorkshop}"
	fi

	ln -s "${steamMods}" "${SBMM}"sb_mods
	ln -s "${steamConfig}" "${SBMM}"sb_configs
	ln -s "${steamWorkshop}" "${SBMM}"sb_workshop
	touch "${SBMM}"db/modlist.txt
	touch "${SBMM}"db/modpacks.txt

	# ./modScan.sh &
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

   displayOutput "${message[@]}"
   fileSetup

	pid=$!

	i=1

	while [ -n "$( ps -p ${pid} | grep ${pid} )" ]
	do
			message=()
   		case $i in
   			1) message+=("BOLD_YELLOW_ [ .     ] _LINES14")
   				;;
   			2)	message+=("BOLD_YELLOW_ [ ..    ] _LINES14")
   				;;
   			3)	message+=("BOLD_YELLOW_ [ ...   ] _LINES14")
   				;;
   			4) message+=("BOLD_YELLOW_ [ ....  ] _LINES14")
					;;
				5) message+=("BOLD_YELLOW_ [ ..... ] _LINES14")
					;;
   		esac

		((i++))
		if [ $i -eq 6 ]
			then
			i=1
		fi
		sleep 1
 		displayOutput "${message[@]}"
	done

	cp modlist.txt ~/sbmm/modlist.txt
	rm modlist.txt
}

preflight
mainMenu
# #modScan