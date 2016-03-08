#!/bin/bash

PS1="\[\e[32;2m\]\w\[\e[0m\]\n[ForSyDe-Demos]$ "

if [ "$FORSYDE_BASH_RUN" != "" ]
then
	return 0 # is already runníng
fi
FORSYDE_BASH_RUN=1

#vars begin
export DEMO_HOME=/home/ugeorge/Work/2_code_proj/forsyde/forsyde-shell
export SYSC_ARCH=linux64
export SYSTEMC_HOME=/opt/systemc-2.3.1
export LD_LIBRARY_PATH=/opt/systemc-2.3.1/lib-linux64
export SC_FORSYDE=/home/ugeorge/Work/2_code_proj/forsyde/forsyde-shell/libs/ForSyDe-SystemC/src
export FORSYDE_MAKEDEFS=/home/ugeorge/Work/2_code_proj/forsyde/forsyde-shell/shell/Makefile.defs
export F2DOT=/home/ugeorge/Work/2_code_proj/forsyde/forsyde-shell/tools/f2dot/f2dot
export F2SDF3_HOME=/home/ugeorge/Work/2_code_proj/forsyde/forsyde-shell/tools/f2sdf3
#vars end

#scripts begin
source /home/ugeorge/Work/2_code_proj/forsyde/forsyde-shell/shell/general.sh
source /home/ugeorge/Work/2_code_proj/forsyde/forsyde-shell/shell/generate-makefile.sh
source /home/ugeorge/Work/2_code_proj/forsyde/forsyde-shell/shell/f2dot_script.sh
source /home/ugeorge/Work/2_code_proj/forsyde/forsyde-shell/shell/f2sdf3_script.sh
source /home/ugeorge/Work/2_code_proj/forsyde/forsyde-shell/shell/valgrind_script.sh
#scripts end

echo "########################################################################

               =  ForSyDe Demonstrators Project =

 Applications:
* demo/sysc/mp3decoder
* demo/sysc/jpeg-encoder
* demo/sysc/vad

 Libraries included:
* ForSyDe-SystemC

 Tools included:
* f2sdf3          prefix : \$F2SDF3_HOME
* f2dot           script : \$F2DOT

 To list all commands provided by the shell type 'list-commands'.

########################################################################
"

cd projects

export LS_OPTIONS='--color=auto'
eval "`dircolors`"
alias ls='ls $LS_OPTIONS'

function list-commands () {
    echo " Commands provided by this shell (type help-<command> for manual):
* execute-model : runs a ForSyDe model and extracts and plot performance
* f2sdf3 : converts generated ForSyDe-XML IR into SDF3 format
* f2dot : plots generated ForSyDe-XML IR
* generate-makefile : generates a simple Makefile in the current directory;
* make : GNU make for compiling ForSyDe-SystemC projects (no help)
* make clean : cleans the results of a compialtion (no help)
* clean-all : cleans all generated files in a project;
* update-all : pulls the latest versions of the tools and libs
"
}
