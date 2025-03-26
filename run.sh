#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ "$1" == "" ] || [ "$2" == "" ] || [ "$3" == "" ]; then
    echo "Usage: ./run.sh code.tmsl input.tape output.tape"
    exit 1
fi

"$SCRIPT_DIR/compiler/compiler.exe" "$1" code.tm
"$SCRIPT_DIR/machine/machine.exe" code.tm "$2" "$3"

echo "Input tape:"
cat "$2"
echo ""
echo "Output tape:"
cat "$3"
echo ""
echo "Done - have a nice day. Thank you for using the run script(tm)."
