## Setting up CDE ## {#setup}

## Organization of CDE code

The main CDE directory (referred to hereafter as `~/cde`) contains the following relevant subdirectories:

| Directory | Description |
|-----------|-------------|
| `./src` | Contains the main source files. |
| `./docs` | Contains the documentation (generated using `Doxygen` and `mkdocs`). |
| `./bin` | Directory where the `cde.x` executable is stored. |
| `./Tutorials` | Directory containing the CDE tutorials. |
| `./utils` | Directory containing a few potentially useful plotting and analysis scripts, mostly written in Python and using Matplotlib. |


## Compiling CDE

CDE is generally written in pretty standard Fortran90 throughout - it should be relatively easy to compile, and does not require any fancy libraries beyond `LAPACK`.

To compile CDE, just do the following:

1. Go to the `~/cde` directory.
- Edit the `Makefile` so that your Fortran compiler and LAPACK libraries are picked up. You can also edit the `Makefile` (if you want) to change the executable name and the location of the compiled executable (the default is `~/cde/bin/cde.x`).
- Type `make clean` in your terminal
- Type `make`
- After compilation, you should now have an executable labelled `cde.x` in the specified location (probably `~/cde/bin/`).
- At this point, it's a good idea (although not essential) to make sure that either `~/cde/bin/` is in your environment's `PATH` variable, or you add an alias to run `cde.x`. 

!!! warning
    From now on, the rest of the documentation will assume that typing `cde.x` will run the compiled CDE executable.

## Running CDE

To run the code, you'll need some input files. First, you should go and read the sections about the input files that CDE requires. 

Once your input files are ready, you simply type into your terminal:

        cde.x input

where `input` is the name of your input file.

!!! tip
    See the section on [annotated input files](annotated-input.md) for complete input description. 

## Adding an alias 

To make things easier, you can add an alias to your environment's configuration file in your home directory. To do so (assuming a linux/unix system using `BASH` shell, as an example):

- `cd` to your home directory;
- Type `vi .bashrc`
- Add the following line to you `.bashrc`:

	`alias cde='YYY/cde.x'`

    Here `YYY` is the full directory path to the `cde.x` executable.

- Save the `.bashrc` file, then type

	`source .bashrc`

- If successful, you should then be able to simply type

    `cde.x input` 
 
    to run the CDE code.

