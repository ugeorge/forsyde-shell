# ForSyDe Shell

The current project provides a set of scripts to set up the ForSyDe ecosystem for the demonstrator applications and create a shell environment with the necessary commands.

### Dependencies

For the ForSyDe-SystemC projects you need to install [SystemC](http://www.accellera.org/downloads/standards/systemc) manually on your workstation. 

### Installation

Currently the installation script works only on Debian distributions of Linux. For the time being you can study `setup.sh` to install manually all dependencies on other OSs.

To install the dependencies and create the shell simply run from the current folder:

    ./setup.sh

and follow the instructions.

In case you need to update your installation options you can run `setup.sh` again and it will just update the shell, without modifying the existing options.

If you need to reset the shell (without reinstalling the tools) type

    ./setup.sh -r

If you want to completely uninstall the tools, libraries and the shell, type

    ./setup.sh -u

### Running the shell

Open the newly created shell by running

    ./forsyde-shell
    
which starts in the working directory `models`. The welcome screen contains enough information for getting started. All in-built commands come with usage manuals which can be printed by calling `help-<command>` inside the shell.
x
