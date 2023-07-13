function [out] = formatLinkageMatrix(dataIn,writeRead)

%% PURPOSE: REFORMAT THE JSON STRUCT FOR THE LINKAGE MATRIX FOR WRITING/SAVING
% Everything is in a matrix.

% In MATLAB: N x 2 cell array (ForwardLink, BackwardLink)
% In JSON: An N x 1 array of 2 x 1 arrays

%% NOTE: AS THIS MATRIX COULD GET QUITE BIG, UTILIZE MATLAB'S COPY ON WRITE BEHAVIOR BY NOT MODIFYING OR DELETING ITEMS FROM JSON

% Read the JSON from file.
if isequal(upper(writeRead),'READ')
    out = cell(length(dataIn),2);

    for i=1:size(out,1)
        out(i,:) = dataIn{i}';
    end

    return;
end

%% Write N x 2 cell array in JSON format, so that each row of dataIn is on one row of the JSON file.
if isequal(upper(writeRead),'WRITE')

    out = ['[' newline];
    indent = '  ';
    for i=1:size(dataIn,1)
        if i<size(dataIn,1)
            endLine = '"],';
        else
            endLine = '"]';
        end
        out = [out indent '["' dataIn{i,1} '", "' dataIn{i,2} endLine newline];
    end
    out = [out ']'];

end

