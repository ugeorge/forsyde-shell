function install-sdf3 {
    sdf3path=$libdir/sdf3
    sdf3bins=$tooldir/sdf3
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
	unzip $dfile -d $libdir
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

read -p "Would you like to install the SDF3 tool chain? [y]" yn
case $yn in
    [Nn]* ) ;;
    * ) install-sdf3;;
esac
