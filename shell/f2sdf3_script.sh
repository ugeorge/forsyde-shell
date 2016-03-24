function f2sdf3 () {
    if [  ! -f .project ]; then
	echo "The working directory is not a ForSyDe project. Abandoning command!"
	return
    fi
    projname=$(basename $(pwd) | sed 's|-|_|g')
    mkdir -p sdf3
    cp $F2SDF3_HOME/DTD/forsyde.dtd ir
    saxonb-xslt -s:$1 -xsl:$F2SDF3_HOME/f2sdf3.xsl -o:sdf3/log -dtd:off -ext:on debug=yes application-name=$projname types=$(cd ir; pwd)/types.xml inputFolder=$(cd ir; pwd)/ outputFolder=sdf3 2>sdf3/log
}

function info-f2sdf3 () {
    echo "f2sdf3 : converts generated ForSyDe-XML IR into SDF3 format"
}

function help-f2sdf3 () {
    info-f2sdf3
    echo "

Usage: f2sdf3 <in_xml> [app_name]

in_xml        Top level input file
app_name      Application name. Default: the current project name

This command needs to be invoked in the root folder of a project!
"   
}
