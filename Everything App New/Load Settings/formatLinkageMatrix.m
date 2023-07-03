function [newJSON] = formatLinkageMatrix(json,writeRead)

%% PURPOSE: REFORMAT THE JSON STRUCT FOR THE LINKAGE MATRIX FOR WRITING/SAVING
% Everything is in a field called "Links"

% In MATLAB: N x 3 cell array (Analysis, ForwardLink, BackwardLink)
% In JSON: An N x 1 array of 3 x 1

%% NOTE: AS THIS MATRIX COULD GET QUITE BIG, UTILIZE MATLAB'S COPY ON WRITE BEHAVIOR BY NOT MODIFYING OR DELETING ITEMS FROM JSON

if isequal(upper(writeRead),'WRITE')    
    newJSON.Links = cell(size(json.Links,1),1);
    
    for i = 1:length(newJSON.Links)

        % Initialize with N x 1 cell array.
        newJSON.Links{i} = json.Links(i,:);

    end
   
end

% Read the JSON from file.
if isequal(upper(writeRead),'READ')
    m = length(json.Links);
    n = length(json.Links{1});
    newJSON.Links = cell(m,n);
    
    for i=1:size(newJSON.Links,1)

        for j=1:length(json.Links{i})
            newJSON.Links{i,j} = json.Links{i}{j};
        end

    end

end