### PES templates {#Templates}

## General comments

A key piece of information which `cde` requires in order to perform energy evaluations or geometry optimization is a PES *template file*.

- The input parameters `pesfile` and `pesoptfile` are header files which are used to direct external codes in which calculation to perform when they are called by `cde`. These header files must have the same format as input files required by the `pesexecutable` and `pesoptexecutable`.

- However, in the `pesfile` and `pesoptfile` template files, there must be a line with `XXX` as follows:


		XXX

- The `XXX` indicator tells `cde` where it should insert the atomic coordinates of the configuration at which the energy evaluation is requested. After inserting the coordinates, `cde` writes the input file then runs the relevant external executable to evaluate the energy. Once the energy evaluation (or geometry optimization) is complete, `cde` reads in the results.

- The file `pes.f90` can be consulted to see how this write/run/read process works for each external code.

- An example header file for a PES evaluation by `ORCA` using PM3 semi-empirical method might be as follows:

        ! PM3
        * xyz 0 1
        XXX
        *


- An example header file for PES evaluation by `DFTB+` might be as follows:

        Geometry = GenFormat {
        XXX
        }
        Driver = {}
         Hamiltonian = DFTB {
         SCC = Yes
         SCCTolerance = 1e-3
         Mixer = Broyden{}
         Eigensolver = RelativelyRobust {}
        MaxAngularMomentum {
        C = "p"
        O = "p"
        H = "s"
        }
        SlaterKosterFiles = Type2FileNames {
        Prefix = "/Users/scott/code/cde/src/SKfiles/"
        Separator = "-"
        Suffix = ".skf"
        }
        }
        Analysis = {
        CalculateForces = Yes
        }



!!! Warning
    Note in the above examples that the only part of the file which is written by `cde` is in replacing the `XXX` with the coordinates at which the energy evaluation is being performed. All other aspects, such as the calculation type (e.g. DFT, Hartree-Fock, semi-empirical, DFTB+), basis sets, accuracy controls, and so on, are controlled by editing the `pesfile` and `pesoptfile` **BEFORE** the calculation starts.

## Template file examples

This section gives several examples of template files for PES evaluation or geometry evaluation.

!!! Tip
    Note that a single PES template file is used for all energy evaluations in `cde`. There is no option to change the PES evaluation-type "on the fly".

### ORCA examples

- Example header file for a PES evaluation by ORCA using PM3 semi-empirical method:

        ! PM3
        * xyz 0 1
        XXX
        *


- Example header file for a PES evaluation by ORCA using DFT (B3LYP):

        ! DFT B3LYP aug-cc-pvtz
        * xyz 0 1
        XXX
        *


- Example header file for geometry optimization using PM3:


        ! PM3 OPT
        * xyz 0 1
        XXX
        *


### DFTB+ example

 In the case of DFTB+, note that the input file must correctly specify the location of any Slater-Koster files required. 

- Example header file for PES evaluation by DFTB+:


         Geometry = GenFormat {
        XXX
        }
        Driver = {}
         Hamiltonian = DFTB {
         SCC = Yes
         SCCTolerance = 1e-3
         Mixer = Broyden{}
         Eigensolver = RelativelyRobust {}
        MaxAngularMomentum {
         C = "p"
        O = "p"
        H = "s"
         }
        SlaterKosterFiles = Type2FileNames {
        Prefix = "./SKfiles/"
         Separator = "-"
         Suffix = ".skf"
         }
        }
        Analysis = {
        CalculateForces = Yes
         }

- DFTB+ geometry optimization example (with constraints):

        Geometry = GenFormat {
        XXX
        }
        Driver = ConjugateGradient{
        MaxForceComponent = 1d-5
        MaxSteps = 1000
        Constraints = {
        1 1.0 0.0 0.0
        1 0.0 1.0 0.0
        1 0.0 0.0 1.0
        2 0.0 1.0 0.0
        2 0.0 0.0 1.0
        3 0.0 0.0 1.0
        }
        }
        Hamiltonian = DFTB {
        SCC = Yes
        SCCTolerance = 1e-3
        Mixer = Broyden{}
        Eigensolver = RelativelyRobust {}
        MaxAngularMomentum {
        C = "p"
        O = "p"
        H = "s"
        }
        SlaterKosterFiles = Type2FileNames {
        Prefix = "./SKfiles/"
        Separator = "-"
        Suffix = ".skf"
        }
        }
        Analysis = {
        CalculateForces = Yes
        }



### Psi-4 example

- Hartree-Fock example using `psi-4`.


        ################
        # INPUT SETUP #
        ################

        molecule x {
        0 1
        XXX
        }

        set {
            basis def2-SVP
            fail_on_maxiter false
        }

        ################
        # OUTPUT SETUP #
        ################

        energy = energy('scf')
        grad = np.array(gradient('scf'))        

        e = open('e.out','w')
        e.write(str(energy))
        e.close()

        f = open('f.out','w')
        for i in grad:
            for j in i:
                f.write(str(j)+'\n')
        f.close

!!! Warning
    Note that the `python` sections are required in the output section above to ensure that energies and forces can be correctly read back into `cde`.


### LAMMPS/ReaxFF example

- The following is an example of a LAMMPS input file (e.g. `lmp.head`) for running a ReaxFF calculation.

        #dimension      3
        units          real
        boundary       f f f
        atom_style     charge
        atom_modify    map array sort 0 0.0

        # XXX replaced by mass labels and atom creation

        XXX

        pair_style     reax/c lmp_control
        # Force file to be used, types added automatically
        pair_coeff     * * CHOPtNiX.ff
        fix            1 all qeq/reax 1 0.0 10.0 1.0e-8 reax/c  # new addition

        neighbor       1.0 bin
        neigh_modify   every 1 delay 0 check no

        compute        reax all pair reax/c

        dump           1 all custom 1 temp.force fx fy fz
        dump_modify    1 format float "%14.8f"

        thermo         0
        thermo_style   custom pe

        run            0

-  The following is an example of a geometry optimization calculation performed using ReaxFF through LAMMPS.

        # Intialization
        dimension      3
        units          real
        boundary       f f f
        atom_style     charge
        atom_modify    map array sort 0 0.0

        # XXX replaced by mass labels and atom creation
        XXX

        pair_style     reax/c lmp_control
        # Force file to be used, atom types are added automatically for reax/c
        pair_coeff     * * CHOPtNiX.ff
        fix            1 all qeq/reax 1 0.0 10.0 1.0e-8 reax/c

        neighbor       2.5 bin
        neigh_modify   every 1 delay 0 check no

        compute        reax all pair reax/c

        thermo         1
        thermo_style   custom pe

        min_style quickmin # new addition
        minimize 1.00e-10 1.00e-8 50000 50000

        timestep 1

        # output forces
        dump           2 all custom 1 temp.force fx fy fz
        dump_modify    2 format float "%14.8f"


- Both of the files above also require two additional files to be present in the run directory. The first of these, `lmp_control` is an additional LAMMPS control file, which usually looks like the following:


        nbrhood_cutoff          5.0  ! near neighbors cutoff for bond calculations in A
        hbond_cutoff            6.0  ! cutoff distance for hydrogen bond interactions
        bond_graph_cutoff       0.3  ! bond strength cutoff for bond graphs
        thb_cutoff              0.001 ! cutoff value for three body interactions
        atom_forces 1


- The second additional file required is the ReaxFF parameter file. In this case, it is referred to as `CHOPtNiX.ff`, but this could be changed depending on the system under investigation and the parameters available. An example of these `*.ff` files can be found in `Tutorial 2`. 
