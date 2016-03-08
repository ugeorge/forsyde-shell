function f2sdf3 () {
    if [  ! -f .project ]; then
	echo "The working directory is not a ForSyDe project. Abandoning command!"
	return
    fi
    projname=$(basename $(pwd) | sed 's|-|_|g')
    mkdir -p sdf3
    cp $F2SDF3_HOME/DTD/forsyde.dtd ir
    saxonb-xslt -s:$1 -xsl:$F2SDF3_HOME/converter.xsl -o:sdf3/converter.log -dtd:off -ext:on application-name=$projname inputFolder=$(cd ir; pwd)/ outputFolder=sdf3
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
