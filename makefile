#makefile for project 
#Author: Vincent von Appen

.Phony : clear test all submit runtest

##################
#Variables
##################

#EXE= ALL BIN/* EXECUTABLE FILES  
#OBJ= ALL OBJ/* OUTPUT FILES THAT SHOULD BE LINKED
#OBJD=ALL OBJD/* OUTPUT FILES THAT SHOULD BE LINKED WITH DEBUG INFO

#EXE= bin/graderx bin/graderd
#OBJ=obj/grader.o obj/studentClass.o obj/scoreClass.o obj/Marks.o obj/Category.o
#OBJD=objd/grader.o objd/studentClass.o objd/scoreClass.o  objd/Marks.o objd/Category.o

Compiler=g++
BaseFlags=-Wall -Wextra 
DebugFlags=-g
CC=${Compiler} ${BaseFlags}
WARNINGS= -Wall -Wextra

##################

all: ${EXE}

#bin/graderx: ${OBJ}
#	@echo "Building $@"
#	${CC} ${WARNINGS} ${OBJ} -o $@

#bin/graderd: ${OBJD}
#	@echo "Building $@"
#	${CC} -g ${WARNINGS} ${OBJD} -o $@

#Clean all objects, object
clean:
	@echo "Cleaning"
	rm -f ${OBJ} ${OBJD} ${EXE} 

#run the testing script
runtest: bin/graderx
	./test/tester.sh

#submit all files in the repository to the remote 
submit:
	@echo "Everything will be pushed" ; \
	echo "Input the commit message and press [enter]" ; \
	read message ; \
	git add . ; \
	git commit -m "$${message}" ; \
	git push origin ; \
	git log -1	

#obj ******************************************************

obj/grader.o: src/grader.cpp hdr/studentClass.hpp  hdr/scoreClass.hpp hdr/Category.hpp hdr/types.hpp hdr/Marks.hpp hdr/grader.hpp
	@echo "Building $@"
	${CC} ${WARNINGS} -c $< -o $@

#objd ******************************************************
#Generate source-level debug information

objd/grader.o: src/grader.cpp hdr/studentClass.hpp  hdr/scoreClass.hpp hdr/Category.hpp hdr/types.hpp hdr/Marks.hpp hdr/grader.hpp
	@echo "Building $@"
	${CC} -g ${WARNINGS} -c $< -o $@





