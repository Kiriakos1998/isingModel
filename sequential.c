#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
void ising( int *G, double *w, int k, int n){

	// Array we will be reading from when iretator is odd
	int *helping= malloc(n*n*sizeof(int));

	//variable to hold the sum of the weights
	double sum = 0;

	// Variables to hold final indices when examining each moment
	int xAxes, yAxes;
	memcpy(helping, G, n*n*sizeof(int));//copy g to helping
	// loop through the number of times we need to calculate the state of the model
	for(int i = 0; i < k; i++){
		// loop through every value of G (j yAxes, p xAxes)
		for(int j = 0; j < n; j++){
			for(int p = 0; p < n; p++){

				// set sum again to 0
				sum= 0;

				// loop through the points  (l yAxes, m xAxes)
				for(int l = 0; l < 5; l++){
					for(int m = 0; m < 5; m++){

				// skip the point itself
						if((l == 2) && (m == 2))
							continue;

						// calculate yAxes so that includes the wrap points
						// and xAxes so threre are no underflows
						yAxes= ((l-2) + j + n) % n;
						xAxes = ((m-2) + p + n) % n;

		//switch i%2 so read from G  when i%2 is even to calculate sum
		// and helping  if i%2 is odd
switch (i%2) {
	case 0:
			sum += w[l * 5 + m] * G[yAxes * n + xAxes];
			break;
			case 1:
					sum += w[l * 5 + m] * helping[yAxes * n + xAxes];
					break;
}


					}

				}

				// calculate future value according to sum sum
				// If positive, set to 1. If negative, to -1. If 0, leave untouched
				// switch i%2 so when i even write write to helping and read from G
				// if i%2 odd then read from helping and write to G
switch (i%2) {
	case 0:
	if(sum> 0.0001)// check if sum is too small positive
{
	helping[j * n + p] = 1;
}
	else if(sum < -0.0001) //check if sum is too small negative
{
			helping[j * n + p] = -1;

}
	else
	{
			helping[j * n + p] = G[j * n + p];
		}
		break;
	case 1:
			if(sum > 0.0001)
			{
					G[j * n + p] = 1;
}
			else if(sum < -0.0001)
{
G[j * n + p] = -1;
}
		else
		{
			G[j * n + p] = helping[j * n + p];
		}
break;
}


			}
		}
	}
	// if k is odd then the values we need will be in helping
	// so coppy helping to G
	if(k%2==1){
		memcpy(G,helping,n*n*sizeof(int));
	}
free(helping); // free helping
}
void takeBinData(int *array, FILE *file,int n){
// check if the file pointer is null
if (file==NULL)
{
printf("error opening file");
exit(1);
}
// read the data and pass them to the array
fread(array,sizeof(int),n*n,file);
fclose(file); // close the file that opened
}
void checkCorrectness(int *G, int *expectedState,int n,int k){
bool noMistake=true; // as long as this value is true no mistake has been found
// according to the confing files
	for(int i=0;i<n*n;i++) // loop through every point and check it with the confing
	//file data
	{
		if(expectedState[i]!=G[i])
			{
				printf("wrong in index %d\n",G[i] );
	noMistake=false; // threy are not the same set the noMistake variable to false
	}
	}
	// if noMistake is true then all good else print where we have wrong spin
	if (noMistake) {
	printf("ising for k=%d is correct\n",k );
	}
	else{
		printf("ising for k=%d is wrong\n",k );
	}
}
int main(){
int n=517;
int *initialG= malloc(sizeof(int)*n*n);// pointer to the initialG data
int *G=malloc(sizeof(int)*n*n); // allocate memory
int *expectedState=malloc(sizeof(int)*n*n);//pointer for the expected data
FILE *file; // pointer to file for the data for k=1,4,11 and n 517
file= fopen("conf-init.bin","rb"); //open bin file
takeBinData(initialG,file,n); // take the data
memcpy(G,initialG,sizeof(int)*n*n);// coppy initialG to G
double weights[] = {0.004, 0.016, 0.026, 0.016, 0.004,
			0.016, 0.071, 0.117, 0.071, 0.016,
		0.026, 0.117, 0, 0.117, 0.026,
		0.016, 0.071, 0.117, 0.071, 0.016,
		0.004, 0.016, 0.026, 0.016, 0.004}; // declare array with weights
ising(G,weights,1,n); // call ising for k1
file=fopen("conf-1.bin","rb"); // open file to data for k=1
takeBinData(expectedState,file,n); // take data
checkCorrectness(G,expectedState,n,1); // check if G is correct
memcpy(G,initialG,sizeof(int)*n*n); // coppy againt intialG to G
ising(G,weights,4,n); // call ising for k=4
file =fopen("conf-4.bin","rb"); // open bin file for k=4
takeBinData(expectedState,file,n); // take data
checkCorrectness(G,expectedState,n,4);//check if G is correct
memcpy(G,initialG,sizeof(int)*n*n); // coppy initialG to G
ising(G,weights,11,n); // call ising for k=11
file =fopen("conf-11.bin","rb"); // open file for k=11
takeBinData(expectedState,file,n);// take data
checkCorrectness(G,expectedState,n,11); // check if G is correct
free(initialG); // free initialG
free(G); // free G
free(expectedState); // free expectedState
	return 0;
}
