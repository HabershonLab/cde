# Makefile for CDE

.SUFFIXES:
EXE = ./bin/cde.x
EXE_DIR = $(dir ${EXE})
FC ?= 'gfortran'
COMPILE_STATIC ?= TRUE

ifeq "$(FC)" "gfortran"
MODCMD = -J
FFLAGS = -O3
LIBS = -lopenblas
else ifeq "$(FC)" "ifort"
MODCMD = -module
FFLAGS = -O3 -i8 -I"${MKLROOT}/include"
LIBS =  -Wl,--start-group ${MKLROOT}/lib/intel64/libmkl_intel_ilp64.a ${MKLROOT}/lib/intel64/libmkl_intel_thread.a ${MKLROOT}/lib/intel64/libmkl_core.a -Wl,--end-group -liomp5 -lpthread -lm
endif

ifeq "$(COMPILE_STATIC)" "TRUE"
FFLAGS := $(FFLAGS) -static
endif

MF = Makefile
SRC = \
	src/constants.f90 \
	src/globaldata.f90 \
	src/functions.f90 \
	src/io.f90 \
	src/structure.f90 \
	src/pes.f90 \
	src/rpath.f90 \
	src/pathopt.f90 \
	src/pathfinder.f90 \
	src/main.f90
OBJ = $(SRC:%.f90=%.o)

all: ${EXE}
${EXE}: src/main.o src/pathfinder.o src/pathopt.o src/rpath.o src/pes.o src/structure.o src/io.o src/functions.o src/globaldata.o src/constants.o
src/main.o: src/globaldata.o src/constants.o src/rpath.o src/io.o src/pathopt.o src/pes.o src/pathfinder.o
src/pathfinder.o: src/constants.o src/globaldata.o src/pes.o src/structure.o src/rpath.o src/io.o
src/pathopt.o: src/constants.o src/globaldata.o src/pes.o src/structure.o src/rpath.o
src/rpath.o: src/constants.o src/globaldata.o src/structure.o src/pes.o src/functions.o
src/pes.o: src/constants.o src/globaldata.o src/structure.o
src/structure.o: src/constants.o src/globaldata.o src/functions.o
src/io.o: src/constants.o src/globaldata.o src/functions.o
src/functions.o: src/constants.o
src/globaldata.o: src/constants.o
src/constants.o: 

${EXE}: ${OBJ}
	mkdir -p $(EXE_DIR)
	$(FC) $(FFLAGS) -o $@ $^ $(LIBS)

%.o: %.f90
	$(FC) $(FFLAGS) -c $< -o $@ $(MODCMD) src

tar:
	tar cvf $(EXE).tar $(MF) $(SRC)

.PHONY: clean
clean:
	rm src/*.o src/*.mod
