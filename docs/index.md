# CDE — Chemical Discovery Engine

CDE (Chemical Discovery Engine) is a collection of Fortran90 routines for chemical reaction-path analysis and automated reaction discovery.

!!! warning "Experimental software"
    CDE is an experimental code that is used to develop and investigate new simulation methods in the field of automated reaction discovery. It is your responsibility to check and verify any results obtained using CDE.

## What can CDE do?

CDE supports several types of chemical-reaction calculations:

- **Double-ended mechanism searching** <br>
Given input reactant and product structures, CDE can generate intermediate structures for diverse reaction paths connecting these end-points.

- **Single-ended mechanism generation** <br>
Starting from a reactant structure, CDE can generate an arbitrarily long string of subsequent reactions; this process can be repeated to build up a reaction network of related chemical products

- **Generation of initial approximate minimum-energy paths (MEPs)** <br> 
CDE includes standard image-dependent pair-potential (IDPP) and linear interpolation schemes for generating initial MEPs.

- **Nudged elastic band (NEB) calculations** <br>
CDE includes drivers to perform NEB and climbing-image NEB (CI-NEB) calculations using optimization methods such as QuickMin.

/// tip 
CDE is also an integral part of the [Kinetica.jl](https://kinetica-jl.github.io/Kinetica.jl/stable/) package that integrates mechanism searching with symbolic kinetic modelling based on ML-predicted activation barriers.
///


## External programs

CDE interfaces with several external programs for energy and force calculations:

- ORCA
- Psi4
- LAMMPS
- DFTB+
- Molpro

## Documentation

<div class="grid cards" markdown>

- :material-rocket-launch: **Getting Started**

    Install CDE and run your first calculation.

    [:octicons-arrow-right-24: Getting started](getting-started.md)

- :material-book-open-variant: **User Guide**

    Input files, PES definitions, path optimisation and configuration.

    [:octicons-arrow-right-24: User guide](user-guide/index.md)

- :material-school: **Tutorials**

    Complete worked examples of CDE calculations.

    [:octicons-arrow-right-24: Tutorials](tutorials/index.md)

- :material-code-braces: **API Reference**

    Documentation generated from the CDE Fortran source.

    [:octicons-arrow-right-24: API reference](api/index.md)

</div>
