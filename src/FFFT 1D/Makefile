FC = gfortran
FFLAGS  = -g -Wall -Wno-tabs -O3
EXEC = ftransport

.DEFAULT_GOAL = all
.PHONY = clean

SRCS  =  $(wildcard ∗.f90)
OBJS = $(SRCS:.f90=.o)

all : ftransport.f90
	$(FC) $(FFLAGS) -o $(EXEC) ftransport.f90


clean : 
	rm *.out *.o *.mod $(EXEC)
