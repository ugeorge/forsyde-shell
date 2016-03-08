#!/bin/bash

function add-var {
    if ! grep -q "$1" $shfile ; then
	sed -i "s|#vars end|export $1=$2\n#vars end|g" $shfile
    fi
}

function add-script {
    if ! grep -q "$1" $shfile ; then
	sed -i "s|#scripts end|source $1\n#scripts end|g" $shfile
    fi
}

function add-intro {
    echo "$1" | while read line; do
	if ! grep -q "$line" $shfile ; then
	    sed -i "s|$2|$2\n$line|g" $shfile
	fi
    done 
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
