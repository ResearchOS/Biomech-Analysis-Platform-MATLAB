function [list]=getUniqueMembers(array)

%% PURPOSE: MODIFIED VERSION OF UNIQUE TO HANDLE A CELL ARRAY WITH ELEMENTS THAT ARE CELL ARRAYS
% Inputs:
% array: The data to iterate through (cell array of cell arrays)

% Outputs:
% list: The unique elements in the input array (cell array of chars)

list={};

for i=1:length(array)
    currCell=array{i};
    
    list=[list; currCell];

end

list=unique(list);