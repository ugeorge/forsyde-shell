#!/bin/bash


function get_variable() {
    var=`grep "$1" $2`
    echo ${var#*=}
}

function jumpto {
    label=$1
    cmd=$(sed -n "/$label:/{:a;n;p;ba};" $0 | grep -v ':$')
    eval "$cmd"
    exit
}

syscpath=$(get_variable "SYSTEMC_HOME" $1)
if [ ! -d "$syscpath" ]; then 
    jumpto SEARCH
else
    read -p "SystemC previously installed in [$syscpath]. Is it correct? [Y] " yn
    case $yn in
	[Nn]* ) jumpto SEARCH ;;
	*     ) jumpto TEST;;
    esac
fi

SEARCH:
echo "Attempting to locate SystemC in the default paths..."
syscpath=$(find /usr/local /opt ~ -type f -name "systemc.h"  2>/dev/null -print | head -n 1)
if [ -f "$syscpath" ]; then 
    syscpath=$(dirname $(dirname $syscpath)) 
    jumpto TEST
else
    echo "Could not find SystemC in the default paths."
    jumpto MANUAL
fi

MANUAL:
read -p "Please provide a valid path for SystemC: " syscpath
jumpto TEST

TEST:
if [ -f $syscpath/include/systemc.h ]; then
    read -p "Found SystemC in [$syscpath]. Is it correct? [Y] " yn
    if [[ $yn == [Nn]* ]]; then jumpto MANUAL; fi
else
    echo "I cannot find $syscpath/include/systemc.h. Path is invalid."
    jumpto MANUAL 
fi

echo $syscpath
