function update-all {
    workdir=$(pwd)
    for repo in $(find $DEMO_HOME -type d -name ".git"); do
	cd $(dirname $repo)
	pwd
	git pull
    done
    cd $workdir
}

function info-update-all () {
    echo "update-all : pulls the latest versions of the tools and libs"
}

function help-update-all () {
    info-update-all
    echo " 

Usage: update-all

Works anywhere within the shell.
"   
}

function clean-all {
    if [ ! $(dirname $(pwd)) == $DEMO_HOME/models/sysc ]; then
	echo "The working directory is not a ForSyDe project. Abandoning command!"
	return
    fi
    find . -maxdepth 1 -mindepth 1 -not \( -name 'src' -or -name 'files' -or -name 'Makefile' \)  -exec rm -rf "{}" \;
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
