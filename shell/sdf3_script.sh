function sdf3print () {
    if [ ! $(dirname $(pwd)) == $DEMO_HOME/models/sysc ]; then
	echo "The working directory is not a ForSyDe project. Abandoning command!"
	return
    fi
    projname=$(basename $(pwd))
    mkdir -p plots
    outfile=plots/sdf3.dot
    if [ ! -z "$2" ]; then outfile=$2; fi
    $SDF3_BIN/sdf3print-sdf --graph $1 --format dot --output $outfile
    sed -i 's/label="[^"]*",//' plots/sdf3.dot
} 

function info-sdf3print () {
    echo "sdf3print : plots SDF3 graphs"
}

function help-sdf3print () {
    echo "Overrides command: "
    $SDF3_BIN/sdf3print-sdf -h
    info-sdf3print
    echo "

The shell command overrides the output directort to 'plots', and the format
to pretty printed dot.

Command usage: sdf3print <in_xml>

One can use the original (un-overriden) command as \$SDF3_BIN/sdf3print-sdf

This command needs to be invoked in the root folder of a project!
"   
}
