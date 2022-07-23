function [structPaths]=getStructPaths(struct,partialPath,structPaths)

%% PURPOSE: GET ALL OF THE STRUCTURE PATHS FROM A SCALAR STRUCT RECURSIVELY. DOES NOT HANDLE NON-SCALAR STRUCTS.
% Inputs:
% struct: The structure to get the paths from (struct)
% partialPath: The partial path for the current descent into the struct (char)
% structPaths: The paths from the previous iteration of getStructPaths (cell array of chars)

% Outputs:
% structPaths: The structure paths (cell array of chars)

if ~isstruct(struct)
    structPaths=inputname(1);
    return;
end

if ~exist('partialPath','var')
    partialPath=inputname(1);
end

if ~exist('structPaths','var')
    structPaths={};
end

% fldNames=fieldnames(struct); % Get the structure field names
structSize=size(squeeze(struct));

% numElems=numel(struct); % Number of structure elements
% struct=reshape(struct,[numElems 1]); % Reshape the matrix to a vector

structIdx=ones(size(structSize)); % Initialize the indices used in the struct

if all(structSize==1)
    isScalar=1; % Defines whether this struct is a scalar.
else
    isScalar=0;
end

if isScalar==1
    assert(length(structSize)==2); % Test the assertion that all scalar structs will be 1x1 size.
end

fieldNames=fieldnames(struct);

for fldNum=1:length(fieldNames)

    fieldName=fieldNames{fldNum};
    structNew=struct.(fieldName);    

    if isstruct(structNew) % Is a structure, do recursion

        partialPath=[partialPath '.' fieldName];
        structPaths=getStructPaths(structNew,partialPath,structPaths);

    else % Not a structure, no recursion
        
        partialPath=[partialPath '.' fieldName];
        structPaths=[structPaths; partialPath];       

    end

    % Remove the most recent struct field to prep for the next iteration        
    dotIdx=strfind(partialPath,'.');

    if ~isempty(dotIdx)
        partialPath=partialPath(1:dotIdx(end)-1);
    end

end



% for dimNum=1:length(structSize) % Iterate through all dimensions of structSize
% 
%     if structSize(dimNum)==1 || (isScalar==1 && dimNum==1)
%         continue; % If dimension is 1, ignore it.
%     end
% 
%     for dimIdx=1:length(structSize(dimNum)) % Iterate over every idx of that dimension               
% 
%         if isstruct(struct(structIdx))
% 
%             fieldNames=fieldnames(struct(structIdx));
%             for fldNum=1:length(fieldNames)
% 
%                 fieldName=fieldNames{fldNum}; % Field name within the current idx 
%                 partialPath=[partialPath '('];
%                 for i=1:length(structIdx)
%                     if i<length(structIdx)
%                         partialPath=[partialPath num2str(structIdx(i)) ','];
%                     else
%                         partialPath=[partialPath num2str(structIdx(i))];
%                     end
%                 end
%                 partialPath=[partialPath ')'];
%                 struct=struct(structIdx).(fieldName);
%                 structPaths=getStructPaths(struct,partialPath,structPaths);
% 
%             end
% 
%         else
% 
%             structPaths=[structPaths; partialPath];
%             return;
% 
%         end
% 
%         structIdx(dimNum)=structIdx(dimNum)+1; % Increment the idx for this dimension at the end of the iteration
% 
%     end
% 
% end