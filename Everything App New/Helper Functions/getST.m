function [st]=getST(uuid)

%% PURPOSE: GET THE SPECIFY TRIALS FOR THE SPECIFIED UUID FROM THE LINKAGE MATRIX.
% UUID is in the right column

[type] = deText(uuid);

st = {};
if ~ismember(type,{'LG','PR'})
    return; % Only logsheets and process functions have specify trials.
end

slash = filesep;
linksFolder = [getCommonPath() slash 'Linkages'];
linksFilePath = [linksFolder slash 'Linkages.json'];

links = loadJSON(linksFilePath);

idx = ismember(links(:,2),uuid);
if ~any(idx)
    return;
end

currRows = links(idx,:); % The rows that have the current UUID in the right column.

stIdx = contains(currRows(:,1),'ST'); % Find all of the specify trials

st = currRows(stIdx,1); % The current UUID's specify trials.