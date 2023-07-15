function [G] = linkageToDigraph()

%% PURPOSE: CONVERT THE LINKAGE MATRIX TO A DIGRAPH (FUNCTIONS ONLY) SO THAT I CAN CHECK DEPENDENCIES.

slash = filesep;

linksFolder = [getCommonPath() slash 'Linkages'];
linksFile = [linksFolder slash 'Linkages.json'];

links = loadJSON(linksFile);

% Remove everything except for functions and variables.
varIdx = contains(links(:,1),'VR') | contains(links(:,2),'VR');
links = links(varIdx,:);

% Get all of the names of all functions.
% fcnIdx{1} = contains(links(:,1),'PR');
% fcnIdx{2} = contains(links(:,2),'PR');
% fcnNames = [links(fcnIdx{1},1); links(fcnIdx{2},2)];

% Get all of the names of all variables
varIdx{1} = contains(links(:,1),'VR');
varIdx{2} = contains(links(:,2),'VR');
varNames = [links(varIdx{1},1); links(varIdx{2},2)];

% Convert to vector of source and target nodes.
count = 0;
s = []; t = [];
for i=1:length(varNames)

    varName = varNames{i};

    firstColIdx = ismember(links(:,1),varName); % Var is input
    secondColIdx = ismember(links(:,2),varName); % Var is output

    if ~any(firstColIdx) || ~any(secondColIdx)
        continue;
    end

    count = count+1;
    s = [s; links(secondColIdx,1)];
    t = [t; links(firstColIdx,2)];

end

% Convert to digraph
G = digraph(s,t);