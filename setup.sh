#!/bin/bash

homedir=$(pwd)
scriptpath=$(cd shell; pwd)
shfile=$scriptpath/forsyde-shell.sh
libdir=$homedir/libs
tooldir=$homedir/tools
projdir=$homedir/projects
cmdstring=" Commands provided by this shell (type help-<command> for manual):"

source shell/setup-utils.sh

function init-shell () {
    if [[ $1 == *"-r"* ]]; then
	rm $shfile
	rm forsyde-shell
    fi

    if [[ $1 == *"-u"* ]]; then
	read -p "Are you sure you want to completely remove the shell along with the installed tools and libraries? [N]" yn
	case $yn in
	    [Yy]* )     
		rm $shfile
		rm -rf $libdir
		rm -rf $tooldir
		rm -rf $projdir
		rm forsyde-shell ;;
	    * ) ;;
	esac
	exit 0
    fi

    echo "Setting up the shell environment..."
    cp -n shell/forsyde-shell.template $shfile
    add-var "DEMO_HOME" "$(pwd)"

    if ! $(dpkg -l build-essential &> /dev/null); then sudo apt-get install -y build-essential; fi
    if ! $(dpkg -l git &> /dev/null); then sudo apt-get install -y git; fi

    add-script "$scriptpath/general.sh"
    add-intro "$(source $scriptpath/general.sh; _print-general);" "$cmdstring";


    touch forsyde-shell
    echo '#!/bin/bash
gnome-terminal -e "bash --rcfile shell/forsyde-shell.sh"' > forsyde-shell
    chmod +x forsyde-shell
}

function wrap-up () {
    sed -i 's/: \$/: \\\$/g' $shfile
}

function install-forsyde-systemc {
    syscpath=$(bash $scriptpath/setup-forsyde-systemc.sh $shfile | tail -n 1)
    echo "$syscpath"

    echo "Installing dependencies..."
    if ! $(dpkg -l libboost-dev &> /dev/null); then sudo apt-get install -y libboost-dev; fi

    echo "Acquiring ForSyDe-SystemC libraries..."
    if [ ! -d $libdir/ForSyDe-SystemC ]; then
	mkdir -p $libdir
	cd $libdir 
	git clone https://github.com/forsyde/ForSyDe-SystemC.git
	cd ..
    else
	cd $libdir/ForSyDe-SystemC
	git pull
	cd ../..
    fi
    fsspath=$(cd $libdir/ForSyDe-SystemC; pwd)

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
    add-intro " * $(source $scriptpath/generate-makefile.sh; info-generate-makefile);" "$cmdstring";
}

function install-apps () {
    echo "Installing applications from $1 ..."
    mkdir -p $projdir
    appdir=$projdir/$2
    if [ ! -d $appdir ]; then
	git clone $1 $appdir
    else
	cd $appdir
	git pull
	cd $homedir
    fi
    for app in $(find $projdir -type f -name '.project' -printf '%P\n'); do
	appname=$(dirname $app)
	add-intro " * $appname" " Applications:"
    done
}

function install-f2dot {
    echo "Installing dependencies..."
    if ! $(dpkg -l python &> /dev/null); then sudo apt-get install -y python; fi
    if ! $(dpkg -l python-pygraphviz &> /dev/null); then 
	sudo apt-get install -y python-pygraphviz; fi
    if ! $(dpkg -l xdot &> /dev/null); then sudo apt-get install -y xdot; fi

    f2dotpath=$tooldir/f2dot
    if [ ! -d $f2dotpath ]; then
	mkdir -p tools
	cd $tooldir
	git clone https://github.com/forsyde/f2dot.git
	cd $homedir 
    else
	cd $f2dotpath
	git pull
	cd $homedir
    fi

    echo "Creating  shell environment variables for f2dot..."
    add-var "F2DOT" "$(cd $f2dotpath; pwd)/f2dot"
    add-script "$scriptpath/f2dot_script.sh"
    add-intro ' * f2dot           script : $F2DOT' " Tools included:"
    add-intro " * $(source $scriptpath/f2dot_script.sh; info-plot)" "$cmdstring"
}

function install-forsyde-m2m {
    echo "Installing dependencies for f2sdf3..."
    if ! $(dpkg -l libsaxonb-java &> /dev/null); then sudo apt-get install -y libsaxonb-java; fi

    fm2mpath=$tooldir/forsyde-m2m
    if [ ! -d $fm2mpath ]; then
	echo "$fm2mpath"
	mkdir -p $tooldir
	cd tools 
	git clone https://github.com/ugeorge/forsyde-m2m.git
	cd $homedir
    else
	cd $fm2mpath
	git pull
	cd $homedir
    fi

    echo "Creating  shell environment variables for f2sdf3... "
    add-var "F2SDF3_HOME" "$(cd $fm2mpath; pwd)"
    add-script "$scriptpath/f2sdf3_script.sh"
    add-intro ' * f2sdf3          prefix : $F2SDF3_HOME' " Tools included:"
    add-intro " * $(source $scriptpath/f2sdf3_script.sh; info-f2sdf3)" "$cmdstring"
}

function install-f2et {
    echo "Installing valgrind..."
    if ! $(dpkg -l valgrind &> /dev/null); then sudo apt-get install -y valgrind kcachegrind graphviz; fi
    if ! $(dpkg -l xml-twig-tools &> /dev/null); then sudo apt-get install -y xml-twig-tools; fi
    if ! $(dpkg -l gnuplot &> /dev/null); then sudo apt-get install -y gnuplot; fi


    echo "Creating  shell environment variables for valgrind functions... "
    add-script "$scriptpath/valgrind_script.sh"
    add-intro " * $(source $scriptpath/valgrind_script.sh; info-execute-model)" "$cmdstring"
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
    * ) install-apps https://github.com/forsyde/forsyde-demonstrators.git demo;;
esac


read -p "Would you like to set up f2dot for plotting ForSyDe IR? [y]" yn
case $yn in
    [Nn]* ) ;;
    * ) install-f2dot;;
esac

read -p "Would you like to set up ForSyDe Model-to-Model transformation scripts? [y]" yn
case $yn in
    [Nn]* ) ;;
    * ) install-forsyde-m2m;;
esac

read -p "Would you like to install valgrind for run-time analysis of ForSyDe-SystemC models? [y]" yn
case $yn in
    [Nn]* ) ;;
    * ) install-f2et;;
esac

wrap-up

#read -p "Would you like to install the SDF3 tool chain? [y]" yn
#case $yn in
#    [Nn]* ) ;;
#    * ) source shell/__obsolete.sh; install-sdf3;;
#esac
