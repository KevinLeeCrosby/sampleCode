/******************************************************/
/*                                                    */
/*                    File SPLIT.C                    */
/*                                                    */
/*      THIS IS MY MAIN CALLING PROGRAM FOR NODE      */
/*            SPLITTING (SUBNODE CREATION)            */
/*                                                    */
/******************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <iostream.h>
#include <math.h>
#include "matrix.h"
#include "gvar.h"
#include "gfunct.h"
#include "objective.h"

#define min(a, b) (((a) < (b)) ? (a) : (b));

void main(int argc, char **argv) {

  const char usage[80] = "Usage:  split -i [...] -o [...]";

  int i, j, k, l, m, n, subset, match;
  int I=0, O=0, in, out;

  for(i = 1; i < argc; i++)
    if(**(argv+i) == '-')
      switch(argv[i][1])
        {
        case 'i':
	  if (I) {
	    cout << "You have already specified the original nodes!" << endl;
	    exit(1);
	  }
	  I = i;
          break;
        case 'o':
	  if (O) {
	    cout << "You have already specified the subnodes!" << endl;
	    exit(1);
	  }
	  O = i;
          break;
        default:
	  cerr << usage << endl;
	  exit(1);
        }

  if (!I) {
    cout << "You have failed to specify the original nodes!" << endl;
    exit(1);
  }
  else if (!O) {
    cout << "You have failed to specify the subnodes!" << endl;
    exit(1);
  }

  if (I < O) {
    in = O - I - 1;
    out = argc - O - 1;
  }
  else {
    in = argc - I - 1;
    out = I - O - 1;
  }

  double MSE[out];
  char input_node[in][10], output_node[out][10];
  char input_final_file[in][20], output_initial_file[out][20];
  char input_entities_file[in][20], output_entities_file[out][20];

  /* format input and output filenames */
  cout << endl << "Original nodes:  ";
  for(i = 0; i < in; i++) {
    strcpy(input_node[i], argv[i + I + 1]);
    cout << input_node[i] << " ";
    strcpy(input_final_file[i], input_node[i]);
    strcat(input_final_file[i], "_final.dat");
    strcpy(input_entities_file[i], input_node[i]);
    strcat(input_entities_file[i], "_entities.dat");
  }
  cout << endl << "Subnodes:  ";
  for(i = 0; i < out; i++) {
    MSE[i]=1.0e30;
    strcpy(output_node[i], argv[i + O + 1]);
    cout << output_node[i] << " ";
    strcpy(output_initial_file[i], output_node[i]);
    strcat(output_initial_file[i], "_initial.dat");
    strcpy(output_entities_file[i], output_node[i]);
    strcat(output_entities_file[i], "_entities.dat");
  }
  cout << endl << endl;

  char resolve_file[]="resolve.dat";
  char vertices_file[]="vertices.dat";
  char variances_file[]="variances.dat";
  char camera_parms_file[]="camera_parms.dat";
  matrix temp_resolve(resolve_file);    /* get l for resolution constraint */
  matrix temp_vertices(vertices_file);  /* get vertices for entities */
  temp_vertices = temp_vertices.T();
  C6.read(variances_file);              /* get variances for 6 dof */
  camera_parms.read(camera_parms_file); /* get rx, ry, f, respectively */

  FILE *entities;
  char entity[15];
  char input_entity_set[in][10][15], output_entity_set[out][10][15];
  int input_entity_count[in], output_entity_count[out];
  
  for(i = 0; i < in; i++) {
    j=0;
    entities=fopen(input_entities_file[i], "r");
    while(fscanf(entities, " %s ", entity)!=EOF)
      strcpy(input_entity_set[i][j++], entity);
    input_entity_count[i]=j;
    fclose(entities); 
  }

  for(i = 0; i < out; i++) {
    j=0;
    entities=fopen(output_entities_file[i], "r");
    while(fscanf(entities, " %s ", entity)!=EOF)
      strcpy(output_entity_set[i][j++], entity);
    output_entity_count[i]=j;
    fclose(entities); 
  }

  for(i = 0; i < in; i++) {
    cout << "Original node " << input_node[i] << " has entities ";
    for(j = 0; j < input_entity_count[i]; j++)
      cout << input_entity_set[i][j] << " ";
    cout << endl;
  }

  for(i = 0; i < out; i++) {
    cout << "Subnode " << output_node[i] << " has entities ";
    for(j = 0; j < output_entity_count[i]; j++)
      cout << output_entity_set[i][j] << " ";
    cout << endl;
  }
  cout << endl;

  matrix setting;
  double rx = camera_parms(1), ry = camera_parms(2), f = camera_parms(3);
  double objective;

  char t_entities_file[]="entities.dat";
  FILE *t_entities=fopen(t_entities_file, "r");
  int t_entity_count=-1;
  char t_entity[10][15];
  while(fscanf(t_entities, " %s ", t_entity[++t_entity_count])!=EOF);

  /* determine what output entity sets are subsets of input entity sets */
  for(i = 0; i < out; i++) {
    
    strcpy(node, output_node[i]);
    entity_count=output_entity_count[i];

    /* determine resolve matrix for current entity set */
    resolve = temp_resolve;   /* reset to original */
    vertices = temp_vertices; /* reset to original */
    for(n = 0, k = 0; n < t_entity_count; n++) {
      match = 0;
      for(j = 0; j < output_entity_count[i] && !match; j++)
	match = !strcmp(output_entity_set[i][j], t_entity[n]);
      if(!match){/* if no t_entity matches any output_entities remove column */
	resolve = resolve.cremove(n - k + 1);
	vertices = vertices.cremove(2*(n - k) + 2);
	vertices = vertices.cremove(2*(n - k) + 1);
	k++;
      }
    }

    length = resolve; /* just make these same size as resolve */

    /* begin comparing current output entity set with each input entity set */
    for(m = 0; m < in; m++) {
      match = 1;
      for(j = 0; j < output_entity_count[i] && match; j++) {
	match = 0;
	for(n = 0; n < input_entity_count[m] && !match; n++)
	  match = !strcmp(output_entity_set[i][j],input_entity_set[m][n]);
      }
      if (match) {
	cout << "Subnode " << output_node[i];
	cout << " is subset of original node " << input_node[m] << endl;

	/* determine setting for current entity set */
	setting.read(input_final_file[m]);
	for(k = 1; k <= 6; k++)
	  x[k] = setting(k);

	/* find smallest objective for current entity set and save */
	objective = function(rx, ry, f);
	if(MSE[i] > objective) {
	  MSE[i] = objective;
	  setting.write(output_initial_file[i]);
	}
	printf(" with MSE = %.7g\n", objective);
      }
    }
    cout << "Copy the visibility regions of these original nodes for this subnode."<<endl<<endl;
  }
}






