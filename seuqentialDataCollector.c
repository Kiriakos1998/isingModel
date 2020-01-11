#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <time.h>
// here you can put any values you want for n
// warning do not change the length of the array
int nValues[15]={100,150,200,250,350,500,650,800,900,1000,1200,1400,1600,1800,2000};
// here you can put any values you want for k
// warning do not change the length of the array
int kValues[5]={10,20,45,80,100};
// ising model
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
// function to initialize G
void initializeG(int n, int *G){
  for (int i=0;i<n*n;i++){
    if((random()%2)==0)
    G[i]=1;
    else
    G[i]=-1;
}
  }


int main(){
FILE *file; // pointer to a file
clock_t end,start; // variables to count time
int n,k; // n and k
  double weights[] = {0.004, 0.016, 0.026, 0.016, 0.004,
  			0.016, 0.071, 0.117, 0.071, 0.016,
  		0.026, 0.117, 0, 0.117, 0.026,
  		0.016, 0.071, 0.117, 0.071, 0.016,
  		0.004, 0.016, 0.026, 0.016, 0.004}; // array with weights
// loop through every n and k value
for(int i=0;i<15;i++){
n=nValues[i]; // set n value
int *G=malloc(sizeof(int)*n*n); // allocate memory for G
for(int j=0;j<5;j++){


k=kValues[j]; // set k value
initializeG(n,G);// initialize G
start=clock(); // start counting
ising(G,weights,k,n);// call ising
end=clock();// stop counting
file=fopen("sequential.csv","a"); // open csv file
fprintf(file, "%d ,%d, %lf\n",n,k, ((double)(end-start))/CLOCKS_PER_SEC);
// write the data
printf("%lf\n",((double)(end-start))/CLOCKS_PER_SEC);// print data
fclose(file);// close file
}
free(G);// free G
}
	return 0;
}
