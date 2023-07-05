## Tutorial 6: Molecular breakdown path-finding {#breakdown}

This section gives example input files and instructions for a typical single-ended breakdown reaction calculation run through CDE.

This calculation will perform a sequential breakdown of a starting molecular structure, using the given graph moves in moves.in. This allows for optimisations to be applied to each step in the breakdown reaction, such that a consistent mechanism can always be maintained while also producing optimised products.

As opposed to the netgrow routine, the breakdown routine is capable of ensuring that proposed graph moves are not invalidated by structure optimisations. It is also capable of utlising move probabilities, e.g. to ensure that bond-making events are more likely than bond-breaking events. The breakdown routine is also capable of producing more than one reaction in a single run, as well as outputting individual xyz files for each intermediate in each reaction mechanism.

**Important: Note that the target reactant graph is calculated directly from the input reactant structure, so make sure that the bond lengths in your reactants are correct so that the calculated connectivity matrices are also correct!**

The allowed moves (i.e. chemical reactions) which are used in the search for a breakdown mechanism are provided in the move file.

In this example, we will use xTB to perform our electronic structure calculations.

**The actual files to run this example can be found in the *~/cde/Tutorials/Tutorial_6/* directory.**

In this directory, you will find several input files:

	input
	start.xyz
	moves.in
    xtb.head

Let's have a look at each input file individually:

### input

The *input* file for this GDS run looks like this:

    # Breakdown calculation on polyethylene.
    calctype breakdown
    minmolcharge 0      
    maxmolcharge 0 
    nchargemol 0
    maxstepcharge 0
    maxtotalcharge 0
    pesfull .false.
    startfile start.xyz

    stripinactive .true.
    optaftermove .true.
    ignoreinvalidgraphopts .false.

    dofconstraints 0
    atomconstraints 0

    pestype xtb
    pesfile xtb.head
    pesopttype xtb 
    pesoptfile xtb.head
    pesexecutable xtb --iterations 1000 --grad
    pesoptexecutable xtb --iterations 1000 --etemp 1000 --opt normal --grad

    movefile moves.in
    gdsthresh 0.5 
    gdsspring 0.05
    gdsrestspring 0.05
    nbstrength 0.04
    nbrange 2.5
    kradius 0.05
    ngdsrelax 10000
    gdsdtrelax 0.1
    gdsoutfreq 10

    valencerange{
    C 2 4
    H 1 1
    }

    reactiveatomtypes{  
    C 
    H 
    }

    reactiveatoms{  
    all
    }

    reactivevalence{
    }

    fixedbonds{
    }

    allowedbonds{
    } 

    nrxn 20
    nmcrxn 1
    graphfunctype 4

The input file in this case only contains options which are relevant to the breakdown simulation; other input directives have been removed and will be ignored internally in CDE.

The parameter input blocks in the input file have already been covered in other tutorials for GDS and for CINEB (see, for example, @ref Annotated). In the case of a breakdown calculation, the following are the new parameters which have an impact on the algorithm:

- **calctype**: Note that the *calctype* parameter must be set to *breakdown*.

- **ignoreinvalidgraphopt**: When *.TRUE.*, this allows for optimisations that break a graph to still be accepted as valid. This will likely result in a discontinuous reaction path, as reactants from each reaction step have the chance to change their bonding, becoming entirely different molecules. This should be left as *.FALSE.* unless you are generating reactions with no need for a consistent single-ended reaction path.

Some parameters which are present in other *calctype*s also gain slightly different meanings, and should be taken into account:

- **stripinactive**: This still removes spectator molecules, but deserves a special mention since it is usually useful to keep active in these simulations. Breakdown simulations usually lead to many separated molecules in the overall system, and usually only a handful of these will be reacting each step. Removing spectator molecules can therefore provide a massive boost in performance, either by reducing the number of calculator calls when *pesfull .FALSE.* or reducing the complexity of the calculator calls for the reactant system and product system when *pesfull .TRUE.*. This will however negate intermolecular interactions between the active and spectator molecules in each step, so if these are important to you then this should be *.FALSE.*.

    In cases where this behaviour is desired, it can be useful to also adjust the *kradius* parameter. Reducing this parameter lets separate molecules end up closer together when optimised under the GRP, which can be desirable if e.g. you are running TS-finding calculations on reactant-product pairs from these calculations, as computational effort is not wasted resolving the translation of one molecule to another. This can also lead to more graphs being invalidated when *optaftermove .TRUE.* though, so *ignoreinvalidgraphopt .TRUE.* may be necessary.

- **optaftermove**: When *.TRUE.*, this parameter requests a geometry optimisation of the products after a graph move has been made. If *stripinactive .TRUE.* then this will also trigger an optimisation of the reactants of each reaction step, as they may behave differently in isolation when compared to being in a full system of spectator molecules. These optimisations have the potential to break the graph for a reaction step, as they operate outside of the GRP and so aren't beholden to maintaining the graph. In some cases, this can lead to many attempts at graph moves failing due to expensive PES calls invalidating graphs.

- **nrxn**: This is the total number of reactions used in the reaction mechanisms being searched and generated. Unlike in netgrow, null reactions are not possible in this routine.

- **nmcrxn**: This is the total number of full mechanisms (each with nrxn steps) to generate.

### start.xyz

The *start.xyz* file is a standard XYZ format file (Cartesian coordinates in Angstroms).

In a netgrow simulation, *start.xyz* contains the coordinates of the **reactant** structure.

### moves.in

The moves.in file describes the allowed chemical reaction classes which are allowed to take place; these allowed moves are applied to configurations during a netgrow calculation in order to generate new reaction end-points.

The format of the move-file is discussed in @ref moves.

### xtb.head

The xtb.head file is interntionally blank as xtb does not require a configuration file. Instead, it is set up to automatically run calculations on an xyz file which CDE generates (xtbin.xyz), and any calculation-dependent arguments can be passed directly to the pesexecutable and pesoptexecutable input arguments. However, it must be present as a dummy file since CDE expects such a file to exist for each calculation.

### Running the calculation

With these input files, we are now able to run the breakdown calculation. To do so, go into the *~/cde/Tutorials/Tutorial_6/* directory and type:

	cde.x input

As in the other tutorials, the above assumes that you have already made sure that CDE can be run by simply typing *cde.x*. See the [setup section] (@ref setup) for more details.

As the calculation runs, you will find lots of output files generated in the run directory.

### Optimizing structures

If one sets the input parameter

        optaftermove .true.

then this means that each of the intemediate structures will be optimized before moving onto the next intermediate, using the *pesopttype* and defined in the input file. In addition, the energy of each intermediate, as calculated according to *pestype*, will also be output to the comment line of each intermediate's xyz output file.
