#!/bin/bash

homedir=$(pwd)
scriptpath=$(cd shell; pwd)
shfile=$scriptpath/forsyde-shell.sh
libdir=$homedir/libs
tooldir=$homedir/tools
projdir=$homedir/workspace
cmdstring=" Commands provided by this shell (type help-<command> for manual):"

repo_fsysc='https://github.com/ugeorge/ForSyDe-SystemC.git -b type-introspecion --single-branch'
repo_f2dot='https://github.com/forsyde/f2dot.git'
repo_fm2m='https://github.com/ugeorge/forsyde-m2m.git'
repo_fsysc_apps='https://github.com/forsyde/forsyde-systemc-demonstrators.git'

installed_general=false
installed_fsysc=false
installed_f2dot=false
installed_fm2m=false
installed_valgrind=false


source shell/debian_setup_utils.sh


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

    install_dependencies $dep_general

    touch forsyde-shell
    echo '#!/bin/bash
gnome-terminal -e "bash --rcfile shell/forsyde-shell.sh"' > forsyde-shell
    chmod +x forsyde-shell

    installed_general=true

}

function install-forsyde-systemc {
    syscpath=$(bash $scriptpath/setup-forsyde-systemc.sh $shfile | tail -n 1)
    echo "$syscpath"

    echo "Installing dependencies..."
    install_dependencies $dep_sysc

    echo "Acquiring ForSyDe-SystemC libraries..."
    clone_repo $repo_fsysc $libdir/ForSyDe-SystemC
    fsspath=$(cd $libdir/ForSyDe-SystemC; pwd)

    read -p "What is your machine architecture [linux64]" arch
    if [ $arch ]; then arch_string=$arch; fi

    echo "Creating  shell environment variables for SystemC-ForSyDe..."
    add-var "SYSC_ARCH" $arch_string
    add-var "SYSTEMC_HOME" "$syscpath"
    add-var "LD_LIBRARY_PATH" "$syscpath/lib-$arch"
    add-var "SC_FORSYDE" "$fsspath/src"
    add-var "FORSYDE_MAKEDEFS" "$scriptpath/Makefile.defs"
    add-intro " * ForSyDe-SystemC" " Libraries included:"
    installed_fsysc=true   

}

function install-apps () {
    echo "Installing applications from $1 ..."
    mkdir -p $projdir
    appdir=$projdir/$2
    clone_repo $1 $appdir

    for app in $(find $projdir -type f -name '.project' -printf '%P\n'); do
	appname=$(dirname $app)
	add-intro " * $appname" " Applications:"
    done
    add-intro "export WORKSPACE=${projdir}" "#vars begin";
}

function install-f2dot {
    echo "Installing dependencies..."
    install_dependencies $dep_f2dot
    f2dotpath=$tooldir/f2dot
    clone_repo $repo_f2dot $f2dotpath

    echo "Creating  shell environment variables for f2dot..."
    add-var "F2DOT" "$(cd $f2dotpath; pwd)/f2dot"
    add-intro ' * f2dot           script : $F2DOT' " Tools included:"
    installed_f2dot=true
}

function install-forsyde-m2m {
    echo "Installing dependencies for f2sdf3..."
    install_dependencies $dep_fm2m
    fm2mpath=$tooldir/forsyde-m2m
    clone_repo $repo_fm2m $fm2mpath


    echo "Creating  shell environment variables for f2sdf3... "
    add-var "F2SDF3_HOME" "$(cd $fm2mpath; pwd)"
    add-intro ' * f2sdf3          prefix : $F2SDF3_HOME' " Tools included:"
    installed_fm2m=true
}

function install-f2et {
    echo "Installing valgrind..."
    install_dependencies $dep_valgrind

    echo "Creating  shell environment variables for valgrind functions... "
    installed_valgrind=true
}


function wrap-up () {
    echo "Wrapping it all up..."

    if [ "$installed_fm2m" = true ]; then
	add-script "$scriptpath/fm2m_script.sh"
	add-intro " * $(source $scriptpath/fm2m_script.sh; info-f2sdf3)" "$cmdstring"
    fi

    if [ "$installed_f2dot" = true ]; then
	add-script "$scriptpath/f2dot_script.sh"
	add-intro " * $(source $scriptpath/f2dot_script.sh; info-plot)" "$cmdstring"
    fi

    if [ "$installed_valgrind" = true ]; then    
	add-script "$scriptpath/valgrind_script.sh"
	add-intro " * $(source $scriptpath/valgrind_script.sh; info-execute-model)" "$cmdstring"
    fi

    if [ "$installed_fsysc" = true ]; then
	add-script "$scriptpath/sysc_script.sh"
	add-intro "$(source $scriptpath/sysc_script.sh; _print-general);" "$cmdstring";
    fi

    if [ "$installed_general" = true ]; then
	add-script "$scriptpath/general.sh"
	add-intro "$(source $scriptpath/general.sh; _print-general);" "$cmdstring";
    fi

    sed -i 's/: \$/: \\\$/g' $shfile
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
    * ) install-apps $repo_fsysc_apps demo;;
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
