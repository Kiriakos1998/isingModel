#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <stdbool.h>
int nValues[15]={100,150,200,250,350,500,650,800,900,1000,1200,1400,1600,1800,2000};
// here you can put any values you want for k
// warning do not change the length of the array
int kValues[5]={10,20,45,80,100};
__device__
static void calculate(int *readingArray, int* writingArray, double *weights, int n ,int current,int xAxes, int yAxes){
		double Sum = 0;
		if(current < n*n)
		{
	// loop through all the points that affect
	for(int p=-2;p<3;p++){
	for(int q=-2;q<3;q++){
	Sum += weights[(p+2)*5+(q+2)] * readingArray[((p + yAxes + n) % n) * n + ( q + xAxes + n) % n];
	// index properly in order to include the wrap points
	// add the weight to Sum
	}
	}

	// check to decide which value the current spin should take
			if(Sum > 0.00001)// set to 0.000001 in order to take into account
			// floating points
				writingArray[current] = 1;
			else if(Sum < -0.00001)
				writingArray[current] = -1;
			else // if it is zero then let the value remain the same
				writingArray[current] = readingArray[current];
		}
}
// cuda function to parallelize the spin calculation
__global__ void spinCalculation(int n, double * gpuWeights,int *gpuG,int *gpuGTemp,int i,int block,int looper) {
 // variable to hold the sum of the weights

	int current = blockIdx.x * block * block + threadIdx.x; // calculation of the current index



	int xAxes;
	int yAxes;


for(int q=0;q<looper;q++)
{
	// switch the i%2 which is the current number of iretarion
	// so periodically we will be writing to gpuGTemp and then to gpuG
switch (i%2) {
	case 0:
xAxes=(current*looper+q)%n;
yAxes=(current*looper+q)/n;
	 calculate(gpuG,gpuGTemp,gpuWeights,n,current*looper+q,xAxes,yAxes);
	break;
// here everything is the same with the difference that is reading from the gpuGTemp array
// and write to the gpuG
case 1:
xAxes=(current*looper+q)%n;
yAxes=(current*looper+q)/n;
calculate(gpuGTemp,gpuG,gpuWeights,n,current*looper+q,xAxes,yAxes);
break;
}
}
}
void ising (int *G, double *w, int k, int n,int grid ,int block)
{
int looper= n*n/(grid*grid*block*block) + 1;
double *weights;
 cudaMalloc(&weights,sizeof(double)*25);

cudaMemcpy(weights,w,25*sizeof(double),cudaMemcpyHostToDevice);

int *tempG=(int *) malloc(sizeof(int)*n*n);

memcpy(tempG,G,n*n*sizeof(int));
  int *gpuTempG;
	cudaMalloc(&gpuTempG,n*n*sizeof(int));
  int *gpuG;
	cudaMalloc(&gpuG,n*n*sizeof(int));
  cudaMemcpy(gpuTempG,tempG,n*n*sizeof(int),cudaMemcpyHostToDevice);
  cudaMemcpy(gpuG,G,n*n*sizeof(int),cudaMemcpyHostToDevice);

for(int i=0;i<k;i++){
	spinCalculation<<<grid*grid,block*block>>>(n,weights,gpuG,gpuTempG,i,block,looper);
  cudaDeviceSynchronize();
}
if(k%2==1){
cudaMemcpy(G,gpuTempG,n*n*sizeof(int),cudaMemcpyDeviceToHost);
}
else{
	cudaMemcpy(G,gpuG,n*n*sizeof(int),cudaMemcpyDeviceToHost);
}


cudaFree(gpuG);
cudaFree(gpuTempG);
free(tempG);
}
void initializeG(int n, int *G){
  for (int i=0;i<n*n;i++){
    if((random()%2)==0)
    G[i]=1;
    else
    G[i]=-1;
}
  }
int main(){
int block=50;
int grid=50;
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

int *G=(int*)malloc(sizeof(int)*n*n); // allocate memory for G
for(int j=0;j<5;j++){


k=kValues[j]; // set k value
initializeG(n,G);// initialize G
start=clock(); // start counting
ising(G,weights,k,n,grid,block);// call ising
end=clock();// stop counting
file=fopen("V2.csv","a"); // open csv file
fprintf(file, "%d ,%d, %lf\n",n,k, ((double)(end-start))/CLOCKS_PER_SEC);
// write the data
printf("%lf\n",((double)(end-start))/CLOCKS_PER_SEC);// print data
fclose(file);// close file
}
free(G);// free G
}
	return 0;
}
