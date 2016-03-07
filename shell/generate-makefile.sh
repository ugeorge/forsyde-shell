function generate-makefile () {
touch Makefile
echo "
EXTRACFLAGS = -Wno-unknown-pragmas
EXTRA_LIBS =

MODULE = run
SRCS = \$(wildcard src/*.cpp)

include \$(FORSYDE_MAKEDEFS)

CFLAGS += -DFORSYDE_INTROSPECTION

" > Makefile
}

function info-generate-makefile () {
    echo "generate-makefile : generates a simple Makefile in the current directory"
}

function help-generate-makefile () {
    info-generate-makefile
    echo "Usage: generate-makefile"
}
