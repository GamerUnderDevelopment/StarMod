#!/bin/bash
# StarMod the Starbound Mod Manager
# Version 0.1

# Global Variables
COLS=$( tput cols )
STEAMFILE=$( find ~ -name "Starbound.app" 2> /dev/null )
BOTTOM_ROW=$( tput lines )
HOMEDIR=~/Library/Application\ Support/starmod/

# Global Functions

# Function to output user prompts in a more pleasing fashion
function displayOutput {
	# 	Declare/Define Variables
	local aMsgs=("$@")					# Variable Contains All Message Strings
	local line_count=${#aMsgs[@]}		# Counts The Number Of Message Strings By Line
	local insert_row=2					# Set the start point of text insertion
	local message_len=0					# Variable to store the longest message
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

function modlistUpdate {
	local aSubbedMods=( $(ls "${HOMEDIR}"sb_workshop/) )
	local aKnownMods=( $(cat "${HOMEDIR}"db/modlist.txt | cut -d' ' -f 1) )
	local steamURL="http://steamcommunity.com/sharedfiles/filedetails/?id="
	local strName

	if [ ${#aSubbedMods[@]} > ${#aKnownMods[@]} ]
		then
		aSubbedMods=(
			$(
		   	for el in "${aSubbedMods[@]}"
		    	do
		    		echo "$el"
		   	done | sort -n
	   	)
	   )

		aKnownMods=(
			$(
		   	for el in "${aKnownMods[@]}"
		    	do
		    		echo "$el"
		   	done | sort -n
	   	)
	   )
		for (( i=0; i<${#aSubbedMods[@]}; i++ ))
		do
			if [ "${aKnownMods[i]}" != "${aSubbedMods[i]}" ]
				then
				strName=$( curl -s "${steamURL}""${aSubbedMods[i]}" | grep -e "<title>" )
				strName="${strName/<title>Steam Workshop :: /}"
				strName="${strName/<\/title>/}"
				strName="${strName//&quot;/\"}"
				strName="${strName// /_}"
				echo ${aSubbedMods[i]} $strName >> "${HOMEDIR}"db/modlist.txt
			fi
		done
	fi
}

# Symlink File Setup
function fileSetup {
	STEAMFILE=${STEAMFILE/\/osx\/Starbound.app/}
 	local steamMods=${STEAMFILE/Starbound/Starbound\/mods\/}
 	local steamConfig=${STEAMFILE/Starbound/Starbound\/osx\/}
 	local steamApps=${STEAMFILE/\/common\/Starbound/}
 	local steamWorkshop=${steamApps/SteamApps/SteamApps\/workshop\/content\/211820\/}

 	rm -rf ~/Library/Application\ Support/sbmm

	mkdir "${HOMEDIR}"
	mkdir "${HOMEDIR}"db

	if [ ! -e "${steamWorkshop}" ]
		then
		mkdir -p "${steamWorkshop}"
	fi

	ln -s "${steamMods}" "${HOMEDIR}"sb_mods
	ln -s "${steamConfig}" "${HOMEDIR}"sb_configs
	ln -s "${steamWorkshop}" "${HOMEDIR}"sb_workshop
	touch "${HOMEDIR}"db/modlist.txt
	touch "${HOMEDIR}"db/modpacks.txt

	modlistUpdate
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
 	modlistUpdate
	# pid=$!

	# i=1

	# while [ -n "$( ps -p ${pid} | grep ${pid} )" ]
	# do
	# 		message=()
 #   		case $i in
 #   			1) message+=("BOLD_YELLOW_ [ .     ] _LINES14")
 #   				;;
 #   			2)	message+=("BOLD_YELLOW_ [ ..    ] _LINES14")
 #   				;;
 #   			3)	message+=("BOLD_YELLOW_ [ ...   ] _LINES14")
 #   				;;
 #   			4) message+=("BOLD_YELLOW_ [ ....  ] _LINES14")
	# 				;;
	# 			5) message+=("BOLD_YELLOW_ [ ..... ] _LINES14")
	# 				;;
 #   		esac

	# 	((i++))
	# 	if [ $i -eq 6 ]
	# 		then
	# 		i=1
	# 	fi
	# 	sleep 1
 # 		displayOutput "${message[@]}"
	# done

	# cp modlist.txt ~/sbmm/modlist.txt
	# rm modlist.txt
}

# Modules

# Preflight - Handles First Launch
function preflight {
	# Determines if this is first launch or not
	# based upon whether or not
	if [ ! -e "$HOMEDIR"sb_configs ]
		then
		displaySetup
	else
		modlistUpdate
	fi
}

preflight