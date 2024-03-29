## Tutorial 1: CINEB {#Tutorial1}

This section gives example input files and instructions for a typical CINEB calculation run through CDE.

In this case, we are going to run a CINEB optimization of a reaction path representing dissociation of molecular hydrogen (H2) from formaldehyde (H2CO). We will using the semi-empirical PM3 method *via* the *ab initio* code *ORCA*, to calculate potential energies and forces.

**The actual files to run this example can be found in the *~/cde/Tutorials/Tutorial_1 directory.**

In this directory, you will find several input files:

    input
    path.xyz
    orca.head
    orca.min

All of these input filenames are arbitrary; we could have called them alice, bob, clive and ralph and the program would still read them in correctly. Note that the extensions have no effect for input files read in by CDE, but they can be used to remind you what the different input files are.

Let's have a look at each input file individually:

### input

The *input* file looks like this:

    # This input file demonstrates a CINEB refinement.
    # We use the quickmin method here, and orca
    # for PES calculations.

    nimage 10 
    calctype optpath 
    startfile start.xyz
    endfile end.xyz
    pathfile path.xyz
    ranseed  5
    startfrompath .true.
    idppguess .true.

    # path optimization
    pathoptmethod cineb
    nebmethod quickmin 
    nebiter 250
    vsthresh 5d-2
    cithresh 1d-2
    nebspring 0.05
    nebconv 5d-3
    nebstep  10.0 
    neboutfreq 1
    stripinactive .FALSE.
    optendsbefore .false.
    optendsduring .false.
    nebrestrend .FALSE.
    reconnect .false.

    # constraints
    dofconstraints 0
    atomconstraints 0 

    # PES input
    pesfull .true.
    pestype  orca 
    pesfile   orca.head
    pesopttype  orca 
    pesoptfile orca.min
    pesexecutable orca 
    pesoptexecutable orca 

The input file in this case only contains those options which are relevant to the CINEB simulation; other input directives have been removed and will be ignored internally in CDE.

The first input block (beginning with the comment line "# control parameters") identifies the following input parameters:
- **nimage**: Number of images (in total) in the reaction-path which is going to be optimized. In this case, we have 8; note that the number of images indicated here must be the same as in the input pathfile if *startfrompath = .TRUE.* (see below).

- **calctype**: Here, we're using *optpath* to indicate that we want to do a path optimization calculation.

- **pathfile**: In nudged elastic band path refinement calculations, we often have a good initial guess of the reaction path we'd like to refine. The *pathfile* variable defines the input file where our initial reaction-path guess is stored. In this case, we're saying that our initial reaction-path is in *path.xyz*; this is an *xyz* format file (with coordinates given in Angstroms) which MUST contain the same number of snapshots as the number *nimage* defined above.

- **startfile**: This is an xyz file containing the reactant structure for our target system.

- **endfile**: This is an xyz file containing the product structure for out target system. **Note that the *startfile* and *endfile* MUST have the same number of atoms in the same order!**

**IMPORTANT: While we show how to provide the end-points of a reaction with *startfile* and *endfile*, we are not actually using them in this calculation. If these options are present in the input file but *startfrompath = .TRUE.* then they will be ignored.**

- **ranseed**: This is an integer random number seed, used to generate random initial velocities drawn from the Boltzmann distribution for *quickmin* (see above)

- **startfrompath**: Here, by inputting *.TRUE.*, we're indicating that CDE should start from the provided *pathfile*. If it were *.FALSE.*, CDE would start by generating its own initial path by linear interpolation between *startfile* and *endfile*.

- **idppguess**: Whether or not to pre-optimise the reaction path (either linearly interpolated from a *startfile* and an *endfile*, or provided as a *pathfile*) with the IDPP method. In cases where any reaction path optimisation has already occurred, this should be disabled.

The second input block (beginning with "# path optimization") defines parameters which control the NEB path refinement calculation:

- **pathoptmethod**: We're setting this to *cineb*, to indicate that we'd like to run a CINEB calculation.

- **nebmethod**: This defines the optimization method we're using to find the minimum-energy path. Options are *quickmin*, which uses a velocity Verlet-based method, or *steepest* for a simple steepest-descent method. The *quickmin* method is preferred - it's usually much faster to converge.

- **nebiter**: This defines the mamximum number of CINEB iterations to perform before stopping. Note that if the calculation reaches a force convergence value lower than *nebconv* (see below), it stops anyway. If this number is reached without converging, a message will be displayed and the current reaction path will still be output, but should be passed back in as a new reaction path. Consider increasing this value if CINEB does not converge.

- **vsthresh**: This is the force threshold at which the variable spring adjustment for NEB (see references for details) is activated. In this case, once the current reaction-path forces are less than 0.05 Eh/a0, variable springs are activated.

- **cithresh**: This is the force threshold at which the climbing-image variant of NEB (see references for details) is activated. In this case, once the current reaction-path forces are less than 0.01 Eh/a0, climbing-image is activated.

- **nebspring**: CINEB spring parameter (in atomic units, Eh/a0**2).

- **nebconv**: Target force convergence threshold for CINEB calculation.

- **nebstep**: Step-length parameter for optimization. In the case of *quickmin*, this is an effective velocity Verlet time-step taken at each CINEB iteration (in atomic units, so a value of ~41 au corresponds to about a 1 fs time-step). In the case of steepest-descent (*nebmethod steepest*), the *nebstep* parameter indicates the fraction of the current force used to update the atomic coordinates at each step.

- **neboutfreq**: Frequency with which the NEB calculation will output the current reaction path and energy profile. The energy profiles are input to the file ending with *.nebprofile* and the paths are output to *input_YYYY.xyz*, where *YYYY* is the current NEB iteration. Alternatively, if this is set to 1 (i.e. outputting every iteration) then this is centralised in a single trajectory file called *full_neb_path.xyz*.

- **stripinactive**: If set to *.TRUE.*, then any molecules which are simply acting as "spectators" to the reaction (e.g. they are far away from the reaction sites and do not participate) are "stripped" (removed) from the reaction path BEFORE the NEB calculation. This option can make calculations a bit faster!

- **optendsbefore**: If set to *.TRUE.*, then CDE first performs a geometry optimization of the two end-point structures *before* procedding with CINEB.

- **optendsduring**: If set to *.TRUE.*, the two end-points are optimized under the action of the PES *during* the NEB optimization. Here, the end-points only feel the force due to the PES, and do not feel the NEB springs.

- **nebrestrend**: If *optendsduring = .TRUE.*, this options indicates whether or not to additionally include the graph-restraining potential into the forces felt by the two end-points during NEB optimization. This option can prevent the end-point molecules changing the connectivity during NEB optimization. Note that this option is only important if *optendsduring = .TRUE.*.

- **reconnect**: If set to *.TRUE.*, re-interpolate the reaction path after performing optimisation of the two end-point structures. Only relevant id *optendsbefore = .TRUE.*.

- **alignedatoms**: As described in the *annotated input file description* (@ref Annotated), the *alignedatoms* directive tells CDE which triple of atoms should serve as coordinates to align and orient the NEB string in space, to avoid overall translation and rotation of the system during NEB refinement.

The next input block (starting with "# constraints") indicate any constraints we'd like to impose on each image in the reaction-path during NEB optimization.

- **atomconstraints**: In this example, we've indicated that there are no atom constraints (beyond the *alignedatoms* directive noted above).

- **dofconstraints**: Again, in this case, we don't have any DOF constraints other than those noted above.


The final block (starting with "# PES input") defines options to enable potential energy evaluations and geometry optimization during the NEB calculation. These input parameters are discussed elsewhere, such as in *Annotated input file description* (@ref Annotated).

### start.xyz and end.xyz

Here, the file *start.xyz* and *end.xyz* files contain the reactant and product structures for the initial reaction-path. These are xyz files, as described in *I/O formats* (@ref formats).


### orca.head

In the current calculation, we're going to use the *ab initio* code *ORCA* to perform potential energy and force evaluations.

Again, note that we could have called this file anything we wanted to - it doesn't have to be called *orca.head*. However, we must make sure that this is the same filename as defined in the *pesfil* variable in the input file above.

The *orca.head* file looks like this.

	! PM3 ENGRAD
	* xyz 0 1
	XXX
	*

Note that this file is exactly the same format as a usual *ORCA* input file:

- The first line tells *ORCA* to run an *energy and gradient* evaluation using the *PM3* semi-empirical method.

- The second line begins the geometry specification; here, we're indicating that the geometry will be specified as *xyz* Cartesian coordinates (in Angstroms), the total charge on the system is *0*, and the total spin multiplicity is *1* (i.e. closed-shell species).

- In a normal *ORCA* file, we would then input the geometry on the following lines. For example, an *ORCA* input file would look like this:

    ! PM3 ENGRAD
    * xyz 0 1
    C 0.1500  0.2166 0.007
    O 1.56  1.679  5.7098
    *

- However, in an input file for CDE, the coordinate block is simply replaced by the string *XXX*. This indicates that this is the point at which *CDE* should insert coordinates for molecules it would like to run through *ORCA*.

- Finally, there is a "*" symbol on the last line to indicate that this is the end of the *ORCA* input file.


### orca.min

Like the *orca.head* file, the file defined as *pesoptfile* should also be present in the directory.

This file indicates how to run a geometry optimization calculation; note that this calculation is only used if *optendsbefore = .TRUE.*.

As in the case of the files above, the *pesoptfile* can be called anything you'd like!

The format of the *pesoptfile* (here called *orca.min*) is the same as an *ORCA* file for a geometry optimization, but again with the condition that the coordinate input block is replaced by *XXX*. An example is:

	! PM3 OPT 
 	* xyz 0 1
	XXX
	*

Note that everything in the file above is the normal *ORCA* format; the only difference is the *XXX* line required by CDE.

### A note on executables for external programs

Note that our input file above contains two variables defined as:

    pesexecutable orca
    pesoptexecutable orca

The *pesexecutable* and *pesoptexecutable* variables indicate which code to run to calculate energies and forces; in this case, we're using *ORCA*.

Note that, in each case, the input command is run directly. For example, based on the above, CDE will run the following command when an *ORCA* calculation is required:

	orca temp.in

where *temp.in* is the name of a temporary input file which is auto-generated by CDE during NEB calculations.

**If there is no executable called "orca", the CDE calculation will fail!**

**If you see error messages such as "No such file orca..." or similar, you should give the full path to your executable in the input file.**

To make sure everything runs smoothly, there are two options:

(1) You can set up an alias so that, when CDE executes the command *orca* given as *pesexecutable* and *pesoptexecutable*, everything runs as expected. For example, lets say you have *ORCA* installed in *~/programs/stuff/orca/bin/*. If you include an alias in your *.bashrc* (or similar config file if you're on a different system) which reads

	alias orca='~/programs/stuff/orca/bin/orca'

then running the command *orca* will then execute *~/programs/stuff/orca/bin/orca*, which should indeed correspond to an executable binary.

(2) As an alternative, you can also give the full pathname to the desired executable directly in the input file, lik this:

    pesexecutable ~/programs/stuff/orca/bin/orca
    pesoptexecutable ~/programs/stuff/orca/bin/orca



### Running the calculation

With these input files, we are now able to run the CINEB optimization. To do so, go into the *~/cde/examples/cineb/* directory and type:

	cde.x input

The above assumes that you have already made sure that CDE can be run by simply typing *cde.x*. See the [setup section] (@ref setup) for more details.

As the calculation runs, you will find lots of output files generated in the run directory. Many of these files will be useless outputs generated by *ORCA*, typically ocntaining wavefunction and integration grid information.

The interesting output files are as follows:

- **input.nebconv**: This file shows the total norm of the forces, averaged over the images. These values are given for calculations performed with and without the NEB spring terms. This file can be monitored during the calculation to find out how close to convergence the NEB calculation is. This file is written after every NEB iteration.

- **input.nebprofile**: This file contains the energy profile along the reaction-string at the different iterations of the NEB calculation; both absolute energy and relative energy are given. This file is output every **neboutfreq* steps of the NEB optimization.

- **input_nebfinal.xyz**: This is the final CINEB reaction path. Note that this will be output even if the calculation has not fully converged, so take care to ensure that it has before using this in further calculations.

- **full_neb_traj.xyz**: This is the full trajectory of the CINEB optimisation. If *neboutfreq* is greater than 1, this will instead be replaced by files following the patern *input_YYYY.xyz*, where *YYYY* is the iteration of the optimisation that each reaction path represents.

- **input.energy-neb-start**: This contains the energy profile of the reaction string at the start of the calculation.

- **input.energy-neb-end**: This contains the energy profile of the reaction string at the end of the calculation.


In addition to the above output files, the *.log file produced by all CDE calculations will also contain some useful information about the NEB run.

### Next steps

Possible further steps include:

- Performing geometry optimization, followed by frequency calculations, for the reaction-path end-points in order to calculate the free energies using the harmonic oscillator/rigid rotor approximation.

- Finding the transition state for the reaction, using the image nearest to the top of the reaction-barrier obtained by NEB.

- Using all of the above information to calculte the transition-state theory rate constant.
