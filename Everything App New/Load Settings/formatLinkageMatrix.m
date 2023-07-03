function [newJSON] = formatLinkageMatrix(json,writeRead)

%% PURPOSE: REFORMAT THE JSON STRUCT FOR THE LINKAGE MATRIX FOR WRITING/SAVING
% Everything is in a field called "RunList"

% In MATLAB: N x 3 cell array (Analysis, ForwardLink, BackwardLink)
% In JSON: An N x 1 array of 3 x 1

%% NOTE: AS THIS MATRIX COULD GET QUITE BIG, UTILIZE MATLAB'S COPY ON WRITE BEHAVIOR BY NOT MODIFYING OR DELETING ITEMS FROM JSON

if isequal(upper(writeRead),'WRITE')    
    newJSON.RunList = cell(size(json.RunList,1),1);
    
    for i = 1:length(newJSON.RunList)

        % Initialize with N x 1 cell array.
        newJSON.RunList{i} = json.RunList(i,:);

    end
   
end

% Read the JSON from file.
if isequal(upper(writeRead),'READ')
    newJSON.RunList = cell(length(json.RunList),length(json.RunList{1}));
    
    for i=1:size(newJSON.RunList,1)

        for j=1:length(json.RunList{i})
            newJSON.RunList{i,j} = json.RunList{i}{j};
        end

    end

end