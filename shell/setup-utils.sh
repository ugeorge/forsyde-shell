#!/bin/bash

function add-var {
    if ! grep -q "$1" $scriptpath/forsyde-shell.sh ; then
	sed -i "s|#vars end|export $1=$2\n#vars end|g" $scriptpath/forsyde-shell.sh
    fi
}

function add-script {
    if ! grep -q "$1" $scriptpath/forsyde-shell.sh ; then
	sed -i "s|#scripts end|source $1\n#scripts end|g" $scriptpath/forsyde-shell.sh
    fi
}

function add-intro {
    pattern="$2"
    text=$(echo "$1" | tr '\n' "\\n")
    echo "$text"
    if ! grep -q "$1" $scriptpath/forsyde-shell.sh ; then
	sed -i "s/$2/$2\n${text}/g" $scriptpath/forsyde-shell.sh
    fi
}

function check_url(){
	echo "    Sniffing url $1"
	if [[ ! `wget -S --spider $1 2>&1 | egrep 'HTTP.* 200 OK|File .* exists'` ]]; then 
		echo "    WARNING: Broken link '$1'"
		return 1
	fi
	return 0
}

function download_url(){
	echo "    Downloading file '$1' from $2 "
	wget --progress=bar:force $2 -P . 2>&1 
	if [ ! -f $1 ]; then 
		echo "    WARNING: Failed to download file '$1' from $2"
	fi	
	return 0
}

