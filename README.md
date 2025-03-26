Project copied from https://code.google.com/archive/p/turing-machine-language/ The manual for it is [here](https://www.cs.columbia.edu/~sedwards/classes/2008/w4115-fall/reports/TMSL.pdf), and also copied in the repository as [TMSL.pdf](TMSL.pdf). This is what I found in the wiki, converted to markdown:

# Machine Simulator

The machine simulator appears to be working. You can find examples of the input file format in `machine/test`.

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
