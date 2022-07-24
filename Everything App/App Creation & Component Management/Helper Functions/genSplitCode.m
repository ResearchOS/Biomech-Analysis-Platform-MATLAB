function [splitCode]=genSplitCode(iters)

%% PURPOSE: GENERATE A CODE FOR THE SPECIFIED SPLIT
% Inputs:
% iters: The number of times to run the rng. Equal to the number of splits + 1 (double)

% Outputs:
% splitCode: The three character code corresponding to a specific split

key={'0','1','2','3','4','5','6','7','8','9',...
    'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z',...
    'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'};

rng default;

for i=1:iters
    nums=randi(length(key),3);
end

nums=nums(1,1:3);

splitCodeUnchecked='111'; % Initialize
for i=1:length(nums)
    splitCodeUnchecked(1,i)=key{nums(i)};
end

splitCode=splitCodeUnchecked;

% Check the split code against the list of existing split codes for this
% project