function __pull {
    for repo in $(find $1 -type d -name ".git"); do
	cd $(dirname $repo)
	pwd
	git pull
    done
}


function pull  {
    workdir=$(pwd)
    case $1 in
	-p* ) __pull $DEMO_HOME/$projdir ;;
	-l* ) __pull $DEMO_HOME/$libdir ;;
	-t* ) __pull $DEMO_HOME/$tooldir ;;
	* )   __pull $DEMO_HOME ;;
    esac
    cd $workdir
}

function info-pull () {
    echo "pull : pulls the latest versions of the included repositories"
}

function help-pull () {
    info-update-all
    echo " 

Usage: pull [option]

option        what to update
  -a --all         everything (default)
  -p --projects    only projects
  -l --libraries   only libraries
  -t --tools       only tools
"   
}

function clean-all {
    if [ ! -f .project ]; then
	echo "The working directory is not a ForSyDe project. Abandoning command!"
	return
    fi
    find . -maxdepth 1 -mindepth 1 -not \( -name 'src' -or -name 'files' -or -name 'Makefile' -or -name '.project' \)  -exec rm -rf "{}" \;
}

function info-clean-all () {
    echo "clean-all : cleans all generated files in a project"
}

function help-clean-all () {
    info-clean-all
    echo " 

Usage: clean-all

Needs to be called from a project root folder!
"   
}

function _print-general () {
    echo " * $(info-update-all)"
    echo " * $(info-clean-all)"
}
