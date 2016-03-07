function f2dot () {
    if [ ! $(dirname $(pwd)) == $DEMO_HOME/models/sysc ]; then
	echo "The working directory is not a ForSyDe project. Abandoning command!"
	return
    fi
    projname=$(basename $(pwd))
    mkdir -p plots
    if [ ! -f files/f2dot.conf ]; then mkdir -p files; cd files; python $F2DOT -g> /dev/null; cd ..; fi 
    python $F2DOT "$@" -c files/f2dot.conf -o plots
}

function info-f2dot () {
    echo "f2dot : plots generated ForSyDe-XML IR"
}

function help-f2dot () {
    python $F2DOT -h
    info-f2dot
    echo "

Usage: f2dot [f2dot_args] <in_xml>

in_xml        Top level input file
f2dot_args    Arguments to f2dot, as printed above. Overrides the 
              output to 'plots'

This command needs to be invoked in the root folder of a project!
"   
}

function _print-f2dot () {
    echo " * $(info-f2dot)"
}
