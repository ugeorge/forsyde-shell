#!/bin/bash

homedir=$(pwd)
scriptpath=$(cd shell; pwd)
cmdstring=" Commands provided by this shell (type help-<command> for manual):"

source shell/setup-utils.sh

function init-shell () {
    if [[ $1 == *"-r"* ]]; then
	rm shell/forsyde-shell.sh
	rm forsyde-shell
    fi

    if [[ $1 == *"-u"* ]]; then
	read -p "Are you sure you want to completely remove the shell along with the installed tools and libraries? [N]" yn
	case $yn in
	    [Yy]* )     
		rm shell/forsyde-shell.sh
		rm -rf libs
		rm -rf tools
		rm forsyde-shell ;;
	    * ) ;;
	esac
	exit 0
    fi

    echo "Setting up the shell environment..."
    cp -n shell/forsyde-shell.template shell/forsyde-shell.sh
    add-var "DEMO_HOME" "$(pwd)"

    if ! $(dpkg -l build-essential &> /dev/null); then sudo apt-get install -y build-essential; fi
    if ! $(dpkg -l git &> /dev/null); then sudo apt-get install -y git; fi

    add-script "$scriptpath/general.sh"
    add-intro "$(source $scriptpath/general.sh; _print-general)" "$cmdstring"

    touch forsyde-shell
    echo '#!/bin/bash
gnome-terminal -e "bash --rcfile shell/forsyde-shell.sh"' > forsyde-shell
    chmod +x forsyde-shell
}

function install-apps () {
    echo "Installing applications from $1 ..."
    mkdir -p projects
    git clone $1 projects/$2
    for app in $(find $2 -maxdepth 2 -mindepth 2 -type d -printf '%P\n'); do
	add-intro " * $app" " Applications:"
    done
}

function install-forsyde-systemc {
    echo "Attempting to locate SystemC in the default paths..."
    syscpath=$(find /usr/local /opt ~ -type f -name "systemc.h"  2>/dev/null -print | head -n 1)
    if [ -f "$syscpath" ]; then 
	syscpath=$(dirname $(dirname $syscpath))
	read -p "Found SystemC. Please provide another path if not correct: [$syscpath] " path
	if [ ! -z "$path" ]; then 
	    while true; do syscpath=$path
		if [ -f $syscpath/include/systemc.h ]; then break; else
		    echo "I cannot find $syscpath/include/systemc.h. Path is invalid."
		fi
	    done
	fi
    else
	read -p "SystemC not found. Please provide a valid path: " path
	while true; do syscpath=$path
	    if [ -f $syscpath/include/systemc.h ]; then break; else
		echo "I cannot find $syscpath/include/systemc.h. Path is invalid."
	    fi
	done
    fi

    echo "Installing dependencies..."
    if ! $(dpkg -l libboost-dev &> /dev/null); then sudo apt-get install -y libboost-dev; fi

    echo "Acquiring ForSyDe-SystemC libraries..."
    if [ ! -d libs/ForSyDe-SystemC ]; then
	mkdir -p libs
	cd libs 
	git clone https://github.com/forsyde/ForSyDe-SystemC.git
	cd ..
    else
	cd libs/ForSyDe-SystemC
	git pull
	cd ../..
    fi
    fsspath=$(cd libs/ForSyDe-SystemC; pwd)


    echo "Creating 'Makefile.defs'..."
    arch="linux64"
    read -p "What is your machine architecture [linux64]" tarch
    if [ $tarch ]; then arch=$tarch; fi


    echo "Creating  shell environment variables for SystemC-ForSyDe..."
    add-var "SYSC_ARCH" $arch
    add-var "SYSTEMC_HOME" "$syscpath"
    add-var "LD_LIBRARY_PATH" "$syscpath/lib-$arch"
    add-var "SC_FORSYDE" "$fsspath/src"
    add-var "FORSYDE_MAKEDEFS" "$scriptpath/Makefile.defs"
    add-intro " * ForSyDe-SystemC" " Libraries included:"

    add-script "$scriptpath/generate-makefile.sh"
    add-intro " * make clean : cleans the results of a compialtion (no help)" "$cmdstring"
    add-intro " * make : GNU make for compiling ForSyDe-SystemC projects (no help)" "$cmdstring"
    add-intro " * $(source $scriptpath/generate-makefile.sh; info-generate-makefile)" "$cmdstring"
}

function install-f2dot {
    echo "Installing dependencies..."
    if ! $(dpkg -l python &> /dev/null); then sudo apt-get install -y python; fi
    if ! $(dpkg -l python-pygraphviz &> /dev/null); then 
	sudo apt-get install -y python-pygraphviz; fi
    if ! $(dpkg -l xdot &> /dev/null); then sudo apt-get install -y xdot; fi

    f2dotpath=tools/f2dot
    if [ ! -d $f2dotpath ]; then
	mkdir -p tools
	cd tools 
	git clone https://github.com/forsyde/f2dot.git
	cd ..
    else
	cd $f2dotpath
	git pull
	cd ../..
    fi

    echo "Creating  shell environment variables for f2dot..."
    add-var "F2DOT" "$(cd $f2dotpath; pwd)/f2dot"
    add-script "$scriptpath/f2dot_script.sh"
    add-intro ' * f2dot           prefix : \\$F2DOT' " Tools included:"
    add-intro " * $(source $scriptpath/f2dot_script.sh; info-f2dot)" "$cmdstring"
}

function install-f2sdf3 {
    echo "Installing dependencies for f2sdf3..."
    if ! $(dpkg -l libsaxonb-java &> /dev/null); then sudo apt-get install -y libsaxonb-java; fi

    f2sdf3path=tools/f2sdf3
    if [ ! -d $f2sdf3path ]; then
	echo "$f2sdf3path"
	mkdir -p tools
	cd tools 
	git clone https://github.com/forsyde/f2sdf3.git
	cd ..
    else
	cd $f2sdf3path
	git pull
	cd ../..
    fi

    echo "Creating  shell environment variables for f2sdf3... "
    add-var "F2SDF3_HOME" "$(cd $f2sdf3path; pwd)"
    add-script "$scriptpath/f2sdf3_script.sh"
    add-intro ' * f2sdf3          prefix : \\$F2SDF3_HOME' " Tools included:"
    add-intro " * $(source $scriptpath/f2sdf3_script.sh; info-f2sdf3)" "$cmdstring"
}

function install-f2et {
    echo "Installing valgrind..."
    if ! $(dpkg -l valgrind &> /dev/null); then sudo apt-get install -y valgrind kcachegrind graphviz; fi
    if ! $(dpkg -l xml-twig-tools &> /dev/null); then sudo apt-get install -y xml-twig-tools; fi

    echo "Creating  shell environment variables for valgrind functions... "
    add-script "$scriptpath/valgrind_script.sh"
    add-intro " * $(source $scriptpath/valgrind_script.sh; info-execute-model)" "$cmdstring"
}

function install-sdf3 {
    sdf3path=libs/sdf3
    sdf3bins=tools/sdf3
    durl="http://www.es.ele.tue.nl/sdf3/download/files/releases/sdf3-140724.zip"
    dfile="sdf3-140724.zip"

    if [ ! -d $sdf3path ]; then 
        check_url  $durl; if [[ $? -eq 1 ]]; then return 1; fi
	download_url $dfile $durl; if [[ $? -eq 1 ]]; then return 1; fi
    fi

    echo "Installing dependencies for f2sdf3..."
    if ! $(dpkg -l libxml2-dev &> /dev/null); then sudo apt-get install -y libxml2-dev; fi
    if ! $(dpkg -l libboost-dev &> /dev/null); then sudo apt-get install -y libboost-dev; fi

    if [ ! -d $sdf3path/build/release/Linux ]; then
	mkdir -p $sdf3path
	unzip $dfile -d libs
	rm $dfile
	cd $sdf3path
	make

	mkdir -p include/sdf3
	find . -depth -name '*.h'  | cpio -pmdv include/sdf3
	cd $homedir

	mkdir -p $sdf3bins
	mv $sdf3path/build/release/Linux/bin/* $sdf3bins
    fi

    echo "Creating  shell environment variables for sdf3..."
    add-intro " * sdf3" " Libraries included:"
    add-intro ' * sdf3 tools      prefix : \\$SDF3_BIN' " Tools included:"
    add-intro " * $(source $scriptpath/sdf3_script.sh; info-sdf3print)" "$cmdstring"
    add-intro "export SDF3_BIN=$(cd $sdf3bins; pwd)" "#vars begin"
    add-var "SDF3_INCLUDE" "$(cd $sdf3path/include; pwd)"
    add-var "SDF3_LIB" "$(cd $sdf3path/build/release/Linux/lib; pwd)"
    add-script "$scriptpath/sdf3_script.sh"
}

####### MAIN ##########


init-shell $@

read -p "Would you like to set up ForSyDe-SystemC? [y]" yn
case $yn in
    [Nn]* ) ;;
    * ) install-forsyde-systemc;;
esac

read -p "Would you like to install the public demonstrator apps for ForSyDe? [y]" yn
case $yn in
    [Nn]* ) ;;
    * ) install-apps git@gitr.sys.kth.se:ingo/forsyde-demonstrators.git demo;;
esac


read -p "Would you like to set up f2dot for plotting ForSyDe IR? [y]" yn
case $yn in
    [Nn]* ) ;;
    * ) install-f2dot;;
esac

read -p "Would you like to set up f2sdf3 for converting ForSyDe IR into SDF3 format? [y]" yn
case $yn in
    [Nn]* ) ;;
    * ) install-f2sdf3;;
esac

read -p "Would you like to install valgrind for run-time analysis of ForSyDe-SystemC models? [y]" yn
case $yn in
    [Nn]* ) ;;
    * ) install-f2et;;
esac

read -p "Would you like to install the SDF3 tool chain? [y]" yn
case $yn in
    [Nn]* ) ;;
    * ) install-sdf3;;
esac
