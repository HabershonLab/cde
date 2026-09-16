This page describes the allowed input parameters, and a description of what they do. Please note the following:

- Note that input-file keywords are case-sensitive - everything should be lower-case!
- In the input file, lines beginning with '#' are comments.
- Blank lines are ignored.
- Keywords can appear in any order.

<!-- ## Input file examples

Select your desired `calctype` below to view its specific required fields and configuration schema.

=== "🚀 AWS S3 Integration"

    ```yaml
    integration_type: "aws_s3"
    configuration:
      bucket_name: "<string>"
      region: "<string>"
      role_arn: "<string>"
    ```

=== "☁️ Google Cloud Storage"

    ```yaml
    integration_type: "gcs"
    configuration:
      project_id: "<string>"
      bucket_name: "<string>"
      credentials_json: "<string>"
    ``` -->


## General input parameters

These parameters are used to control input, number of images, and other general aspects of the calculation.

| <div style="width: 120px;">Keyword</div>  | Type | Required | Description |
| :--- | :--- | :---: | :--- |
| `calctype` | `string` | :white_check_mark: Yes | Calculation type:<br>• `optpath` - Minimum energy path optimization.<br>• `pathfind` - Double-ended reaction-path finding.<br> |
| `startfile` | `string` | :white_check_mark: Yes | Start-point / reactant `xyz` coordinate file used to initialize reaction-paths and pathfinding. |
| `endfile` | `string` | :white_check_mark: Yes | End-point `xyz` coordinate file. |
| `pathfile` | `string` | :x: No | Initial path file in `xyz` format <br>- used when `startfrompath = .TRUE.` |
| `ranseed` | `integer` | :white_check_mark: Yes | Random number seed (positive integer). |
| `startfrompath` | `logical` | :white_check_mark: Yes | Indicates whether to start from end-point files only (`.FALSE.`) or from a full path (`.TRUE.`). |

## Path optimization control

The following parameters are used to control the calculation when performing a path-optimization simulation (`calctype optpath`), for example using climbing-image nudged elastic band.


| <div style="width: 120px;">Keyword</div> | Type | Required | Description |
| :--- | :--- | :---: | :---|
| `pathinit` | `string` | :x: No |  If `startfrompath = .FALSE.`, specifies the initial interpolation method:<br>- `linear` is linear Cartesian interpolation.<br> - `idpp` is image-dependent pair potential. |
| `nimage` | `integer` | :x: No | Number of nudged elastic band images. |
| `pathoptmethod` | `string` | :x: No  | Path-optimization method - currently `cineb` only. |
| `nebmethod` | `string` | :white_check_mark: Yes  | (CI)NEB optimization method. Options are:<br>- `fire` for FIRE algorithm.<br>- `quickmin` for QuickMin algorithm,<br>- `steepest` for steepest-descent method (generally slow). |
| `nebiter` | `integer` | :x: No | Number of (CI)NEB optimization iterations. |
| `cithresh` | `float` | :x: No | RMS force threshold (in atomic units) at which climbing-image is activated. |
| `nebspring` | `float` | :x: No | (CI)NEB spring constant in atomic units (`Eh/bohr²`). |
| `nebstep` | `float` | :x: No  | Step size for steepest descent or QuickMin (in atomic units). |
| `neboutfreq` | `integer` | :x: No  | Output frequency during (CI)NEB optimization. |
| `optendsbefore` | `logical` | :x: No | Flag indicating whether to optimize reaction end-points before NEB refinement. |
| `optendsduring` | `logical` | :x: No | Flag indicating whether to optimize end points simultaneously with path optimization. |
| `nebrestrend` | `logical` | :x: No | Flag indicating whether to apply the graph-restraining potential during NEB optimization (also used in GDS). |
| `vsthresh` | `logical` | :x: No | RMS force threshold (atomic units) at which variable spring strength is switched on. |
| `reconnect` | `logical` | :x: No | For images 2 through N−1, linearly interpolates the coordinates of beads 1 and N after minimization (if `optendsbefore` is `.TRUE.`). |
| `idppguess` |`logical` | :x: No | Performs NEB starting from an Image-Dependent Pair Potential (IDPP) guess (generally better idea). |
| `projforcetype` | `integer` | :x: No | Selects the type of NEB projected force:<br>- `1` is original formulation,<br>- `2` is from Henkelman *et al.* (2000),<br> - `3` is Kolsbjerg *et al.* (2016). |
| `stripinactive` | `logical` | :x: No | Controls whether "inactive" molecules are removed from the initial NEB path before refinement. |
| `nebconv` | `float` | :x: No | NEB RMF force convergence threshold (in atomic units). |
| `nebmaxconv` | `float`  | :x: No | Maximum-force convergence threshold (in atomic units) for NEB optimization. |


## Constraint controls

These inputs controls the constrained atoms and degrees-of-freedom in GDS calculations and geometry-optimization calculations.

!!! Tip
	None of the following are required input parameters.

* **`dofconstraints`**

The `dofconstraints` input comprises two lines, as in the following example:

     dofconstraints 6
     1 2 3 5 6 9

This input gives the number of fixed DoFs (in this case, 6), with the second line in the input file listing the integer-values of the fixed DoFS. Here, counting starts at 1 for the *x*-coordinate of atom 1. The *z*-coordinate of atom 2 has the integer value of 6, and so on.

!!! Warning
	Once defined, the constrained DoFs will remain fixed throughout any NEB calculation; these DoFs are simply not optimized.

* **`atomconstraints`**

The `atomconstraints` input has the same format as `dofconstraints`, but the integers now refer to the number of fixed atoms, and the indices of the fixed atoms. In the following, 1 atom is fixed - atom number 13:

     atomconstraints 1
     13

* **`alignedatoms`** (experimental)

The `alignedatoms` input allows one to define three atoms which will be used to position and orient any input molecular structure in space. This can be very useful when performing NEB calculations as it helps remove overall translations and orientations of the molecules in the optimized string. Note that the NEB routines will automatically select 3 atoms to position and orient if you don't input anything as *alignedatoms*. In the following example, atoms 1, 2 and 3 are chosen to define the relative position and orientation.

     alignedatoms
     1 2 3

!!! Warning
	The `alignedatoms` are not fixed during optimization; they are just used during initial path approximation.


## PES controls

These input parameters control potential energy evaluations during GDS and NEB calculations.


| <div style="width: 135px;">Keyword</div> | Type | Required | Description |
| :--- | :--- | :---: | :---|
| `pesfull` | `logical` | :white_check_mark: Yes | If `.TRUE.`, we perform PES evaluations and geometry optimizations for the full system (that is, all atoms) each time. If `.FALSE.`, we separately calculate the energy for each independent molecule in the structure. |
| `pestype` | `string` | :white_check_mark: Yes | Defines single-point PES evaluation code to use. options are:<br>- `orca` for the ORCA code,<br>- `dftb` for DFTB,<br> - `lammps` for LAMMPS,<br>- `null` for no PES evaluation (GRP optimization only). |
| `pesfile` | `string` | :x: No | Defines the filename containing the header information to be used for PES single-point calculation. |
| `pesopttype` | `string` | :x: No | Defines the geometry optimization PES code to be used. Options are:<br>- `orca` for ORCA,<br>- `dftb` for DFT,<br>- `uff` for universal force-field implemented in `OpenBabel`,<br>- `null` for no optimization. |
| `pesoptfile` | `string` | :x: No |Defines the filename containing the header for geometry-optimization calculation. |
| `pesexecutable` | `string` | :x: No | Defines the executable to use to for single-point PES evaluation (full path or alias). |
| `pesoptexecutable` | `string` | :x: No | Defines the executable to use to for geometry optimization (full path or alias). |

!!! Warning
	For NEB calculations, `pesfull` must be set to `.TRUE.` because uniquely identifying independent molecules along a reaction path becomes tricky.


## Graph-driven sampling controls

The following control the varisou (single-ended and double-ended) GDS calculations.

| <div style="width: 135px;">Keyword</div> | Type | Required | Description |
| :--- | :--- | :---: | :---|
| `movefile` | `string` | :x: No | Identifies the filename of the move-file used to define allowed graph moves.|
| `gdsspring` |`float`|:x: No | Inter-bead spring constant for GRP (defaul: 0.025 `Eh/Bohr**2`). |
| `gdsrestspring` | `float` | :x: No | Spring constant for harmonic graph enforcement terms (default: 0.1 `Eh/Bohr**2`). |
| `nbstrength` | `float` | :x: No | Repulsion strength for non-bonded atoms, where:  $V = nbstrength * exp(-r_{ij}^2 / (2 * nbrange^2))$. |
| `nbrange`| `float` | :x: No | Range parameter for non-bonded atoms (default: 2.0 `Bohr`).|
| `kradius` | `float` | :x: No | Spring constant for non-interacting molecules in GDS simulations (defaul: 0.1 `Eh/Bohr**2`).|
| `ngdsrelax` | `integer`|:x: No| Number of steepest-descent optimization steps to minimize graph restraint potential (default: 2000).|
| `gdsdtrelax` |`float` | :x: No | Step-size for GDS relaxation (default: 0.05 `Bohr`). |
| `gdsoutfreq` | `integer` | :x: No | Information output frequency during GDS simulation. |
| `nebrestrend` | `logical` | :x: No | Flag indicating weather to apply to it duing the optimization of molecules during GDS, if `optaftermove` is `.TRUE.` (also used in CINEB). |
| `optaftermove` | `logical` | :x: No | Optimizes every molecule involved in the path formation - if the resulting optimised molecule does not conform to the graph,  the proposed path is rejected. If `nebrestrend .TRUE.`, the graph constraining potential are also included during the optimization, and then switched off  during a second, in the hope to find a minima in agreement with the graphs (would recommend to set `nebrestrend .TRUE.` for this).|

In addition to the keywords above, GDS calculations can also be controlled by the following complex optional inputs:

* **`valencerange`** 

This input defines the allowed valence ranges of each element, as in the following example:

	valencerange{
	C 1 4
	O 1 2
	H 0 1
	Pt 0 3 fz
	}

Here, carbon atoms can only be bonded to between 1 and 4 other atoms, oxygen can be bonded to 1-to-2 other atoms, and so on. These constraints are applied when generating new reaction species in GDS simulations.

The `fz` keyword applies only to frozen atoms, either by being defined in the `fixedbonds{}` input (see below), or by the `atomcontraints` keyword. In the example given above, only `Pt-X` bonds (`X` = any atom) which can be formed or broken during the GDS calculation are counted into the 'valence'. If a cluster of Pt atoms are not moving during a GDS calculation, and they are bonded to each other (to varying degrees), the above keyword will allow for up to 3 more bonds, not counting the Pt-Pt bonds, to be formed on the Pt atoms.

* **`reactiveatomtypes`**

This keyword defines which *elements* are allowed to react during GDS runs, as follows:

	reactiveatomtypes{
	C
	O
	H
	}

!!! Warning
	If no reactive atoms are defined explicitly, `cde` assumes that nothing can react!


* **`reactiveatoms`**

This keyword defines which atom numbers (indices) are allowed to react. These can be given as an inclusive range (`range XX YY`), or by individual atom-index number (`id XX`), as in the following example:

	reactiveatoms{
	range 1 4
	id 7
	}

!!! Warning
	Atom indices start at 1!


* **`reactivevalence`**

This keyword defines the valence range that one element can have while bonded to another element, as follows:

	reactivevalence{
	Fe Fe 6 8
        H C 0 1
        H O 0 1
	}

In the above, `Fe` must be bonded between 6 to 8 other `Fe` atoms to be an acceptable molecule. Similarly, the second line indicates that hydrogen can only be bonded up to 1 carbon atom.

* **`fixedbonds`**

This keyword defines fixed bonds, which are not allowed to change during a chemical reaction (although they can vibrate, translate, etc.):

	fixedbonds{
	C O
	3 4
	}

In the above example, **all** C-O bond orders are fixed at whatever they are in the starting structure. So, if a C-O bond is present in the starting structure, it cannot change during the GDS simulation. Similarly, the bond between atoms *3* and *4* is also fixed at the starting structure value.

* **`essentialmoveatoms`**

Defines a list of atoms of which AT LEAST ONE OF THEM MUST be included in any possible graph moves. The formatting options are the same as the `reactiveatoms` block described above, for example:

	essentialmoveatoms{
	range 1 2
	}

In the above example, the atoms in the range 1-2 must be included amogst the moves chosen.

* **`essentialatoms`** 

Defines atoms of which AT LEAST ONE OF THEM MUST be included in molecules that are involved in the reactions. The formatting options are the same as the `reactiveatoms` block described above, for example:

	essentialatoms{
	id 5
	id 7
	}

In the above example, the atoms 5 and 7 must be in any of the molecules that are involved in the reaction (from chemical species image 1 changing to nimage)

!!! Warning
	In the latest version of CDE, the implementation of `essentialatoms` and `essentialmoveatoms` needs debugging....

* **`allowedbonds`** 

Allows definition of bond-number constraints in the structures generated by graph moves. The format is as given in the following example:

	allowedbonds{
	O O 1
	}

Here, the constraint indicates that an oxygen atom cannot be bonded to more than 1 other oxygen atom.


* **`forbidgraphs`** 

This is a logical flag which indicates whether or not to use the forbidden graph pattern file. If `.TRUE.`, then a GDS simulation will not allow any graph-patterns to form which are input into the `forbidfile` defined below. By adding entries to the `forbidfile`, users can force GDS to stop generating user-defined bonding patterns.

* **`forbidfile forbid.in`** 

Identifies the file (here, `forbid.in`) which contains the library of forbidden bonding patterns which are used if `forbidgraphs = .TRUE.`.

## Path-finding controls

The following parameters control the double-ended reaction-path finding algorithm.

| <div style="width: 135px;">Keyword</div> | Type | Required | Description |
| :--- | :--- | :---: | :---|
| `nrxn` | `integer` | :x: No | Total number of elementary steps allowed in mechanism. |
| `nmcrxn` | `integer` |:x: No | Maximum number of Monte Carlo moves to attempt during simulated annealing optimization. |
| `nmechmove` | `integer` | :x: No | Maximum number of mechanism updates in each MC step. |
| `mcrxntemp` | `integer` | :x: No | Initial temperature (in K) for simulated annealing optimization (decreases linearly during run). |
| `graphfunctype` | `integer` | :x: No | Determines the optimization function used for the path-finding calculation. This should be an integer, as follows:<br> (1) Standard element-wise comparison,<br> (2) Eigenvalue comparison,<br> (3) Histogram comparison,<br> (4) Eigenvalue comparison for single molecule.<br> **You should preferably use either (2) or (4)!** |

!!! Warning
	In addition to the keywords above, the following keywords cna be defined to influence charge constraints. Note that these options have not yet been thoroughly tested.

| <div style="width: 135px;">Keyword</div> | Type | Required | Description |
| :--- | :--- | :---: | :---|
 |`minmolcharge` | `integer` | :x: No | Minimum allowed molecular charge (if electron transfer moves are allowed in the movefile).|
| `maxmolcharge` | `integer` | :x: No | As above, but maximum value. |
| `nchargemol` | `integer` | :x: No | Maximum number of molecules which can be charged. |
| `maxstepcharge` |`integer` |:x: No | Maximum number of reation steps which can involve charge changes.
| `maxtotalcharge` | `integer` |:x: No | Maximum total charge in a given reaction step.|
 
