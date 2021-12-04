size1=100000;
size2=200;

n=rand(size1,size2); % Create a 10,000 x 1 matrix of random numbers
s=sparse(size1,size2); % Create a sparse 10,000 x 1 matrix
stepSize=size1/100; % Step size 1% of size

for i=1:100
    % Get the size of the full struct
    fullStruct=whos('n');
    fullSize(i)=fullStruct.bytes;
    
    % Put zeros into the full struct
    n((i-1)*stepSize+1:stepSize*i,:)=0;
    
    % Get the size of the sparse struct
    sparseStruct=whos('s');
    sparseSize(i)=sparseStruct.bytes;
    
    % Put numbers into the sparse struct
    s((i-1)*stepSize+1:stepSize*i,:)=rand(stepSize,size(n,2));
    
end

Q=figure;
subplot(2,1,1);
plot(1:100,fullSize);
title('Full')

subplot(2,1,2);
plot(1:100,sparseSize);
title('Sparse');
yline(fullSize(1));