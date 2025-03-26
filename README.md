# TMSL
This project is based on https://code.google.com/archive/p/turing-machine-language/ The manual for it is [here](https://www.cs.columbia.edu/~sedwards/classes/2008/w4115-fall/reports/TMSL.pdf), and also copied in the repository as [TMSL.pdf](TMSL.pdf).

# Compiler
The TMSL compiler can be compiled like this:
```
cd compiler
make
```

# Machine Simulator
You can find examples of the input file format in `machine/test`.

## Building the Machine
There are two ways to build the machine:

### Using PowerShell:
```
cd machine
./build.ps1
```

### Using Make:
```
cd machine
make
```

## Usage
Usage of the machine executable looks like this:
```
machine <machine file> <input tape file> <output tape file>
```

For example (using PowerShell syntax):
```
cd machine
./machine test/reverse.tm test/input.tape test/output.tape
```

The simulator assumes that the start state is called "s0", but other than that, the state names can be any alphanumeric strings.

# `run` script
For running the compiler to compile a TMSL file to a TM file, and then simulating it with a tape, you can use the run script. For example:
```
$ ./run.sh test/not.tml test/not.tml.input output.txt
Input tape:
0 0 1 0 0 1 0
Output tape:
1 1 0 1 1 0 1 
Done - have a nice day. Thank you for using the run script(tm).
```
