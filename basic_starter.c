/*********
File        FileName.c
Author      EPW <estebanpw@uma.es>
Description What do I do?
PARAMETERS       
			-query <file>	Query file
			-db <file>	Database file
			-out <file> Output file
			-k <Integer>	K-mer size	DEFAULT=32
			-verbose	Print information to stdout
**********/


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define MAX(x, y) (((x) > (y)) ? (x) : (y))

void terror(const char * msg){
	fprintf(stderr, "ERR** :->: %s\n", msg);
	exit(-1);
}

int main(int argc, char ** av){
    
	// Configuration variables
	
	FILE * query, * db, * out;
	int ksize = -1;
	int verbose = 0;
	
	int pNum = 0;
	while(pNum < argc){
		if(strcmp(av[pNum], "-verbose") == 0) verbose = 1;
		if(strcmp(av[pNum], "-query") == 0){
			query = fopen64(av[pNum+1], "rt");
			if(query==NULL) terror("Could not open query file");
		}
		if(strcmp(av[pNum], "-db") == 0){
			db = fopen64(av[pNum+1], "rt");
			if(db==NULL) terror("Could not open database file");
		}
		if(strcmp(av[pNum], "-out") == 0){
			out = fopen64(av[pNum+1], "wt");
			if(out==NULL) terror("Could not open output file");
		}
		if(strcmp(av[pNum], "-ksize") == 0){
			ksize = atoi(av[pNum+1]);
			if(ksize < 1) terror("Ksize must be positive");
		}
		pNum++;
	}
	
	// Exit if not all needed parameters were included
	
	if(query==NULL || db==NULL || out==NULL || ksize==-1) terror("A query, database, outputfile and ksize value is required");
	
	// Finished configuration variables step
	
	// Close files, free memory
	
	fclose(query);
	fclose(db);
	fclose(out);
	
	return 0;
}









