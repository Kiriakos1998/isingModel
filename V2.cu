#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <stdbool.h>
static int grid_array[5]={5,9,16,23,30};
static int block_array[5]={2,3,5,10,12};
static FILE *pointerToFile;
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
void takeBinData(int *array, FILE *file,int n){

if (file==NULL)
{
printf("error opening file");
exit(1);
}
fread(array,sizeof(int),n*n,file);
fclose(file);
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

void checkCorrectness(int *G, int *expectedState,int n,int k){
bool noMistake=true;
int counter=0;
	for(int i=0;i<n*n;i++)
	{
		if(expectedState[i]!=G[i])
			{
				//printf("wrong in index %d\n",i );
counter++;
	noMistake=false;

	}
	}
	if (noMistake) {
	printf("ising for k=%d is correct\n",k );
	}
	else{
		printf("ising for k=%d is wrong\n",k );

	}
printf("%d\n",counter );
}

int main(){
int n=517;
int grid,block;
for(int i=0;i<5;i++){
	for(int j=0;j<5;j++)
{
grid=grid_array[i];
block=block_array[j];
int *initialG=(int *) malloc(sizeof(int)*n*n);
int *G=(int *)malloc(sizeof(int)*n*n);
int *expectedState=(int *)malloc(sizeof(int)*n*n);
FILE *file;
file= fopen("conf-init.bin","rb");
takeBinData(initialG,file,n);
memcpy(G,initialG,sizeof(int)*n*n);
double weights[] = {0.004, 0.016, 0.026, 0.016, 0.004,
			0.016, 0.071, 0.117, 0.071, 0.016,
		0.026, 0.117, 0, 0.117, 0.026,
		0.016, 0.071, 0.117, 0.071, 0.016,
		0.004, 0.016, 0.026, 0.016, 0.004};
clock_t start,end;
start=clock();
ising(G,weights,1,n,grid,block);
end=clock();
printf("%lf\n",((double)(end-start))/CLOCKS_PER_SEC);
file=fopen("conf-1.bin","rb");
takeBinData(expectedState,file,n);
checkCorrectness(G,expectedState,n,1);
memcpy(G,initialG,sizeof(int)*n*n);
start=clock();
ising(G,weights,4,n,grid,block);
end=clock();
printf("%lf\n",((double)(end-start))/CLOCKS_PER_SEC );
file =fopen("conf-4.bin","rb");
takeBinData(expectedState,file,n);
checkCorrectness(G,expectedState,n,4);
memcpy(G,initialG,sizeof(int)*n*n);
start=clock();
ising(G,weights,11,n,grid,block);
end=clock();
printf("%lf\n",((double)(end-start))/CLOCKS_PER_SEC );
file =fopen("conf-11.bin","rb");
takeBinData(expectedState,file,n);
checkCorrectness(G,expectedState,n,11);
}
}

	return 0;
}
