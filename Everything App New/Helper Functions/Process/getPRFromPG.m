function [allPR] = getPRFromPG(pg, allPR)

%% PURPOSE: GIVEN ONE OR MORE PROCESSING GROUPS, RETURN AN UNORDERED LIST OF ALL THE PROCESSING FUNCTIONS IN THOSE GROUPS.
% Inputs:
%   pg: List of processing groups
%   prevAllPR: List of processing functions

% Outputs:
%   pr: List of processing functions
global conn;

% Column 1: PR ID
% Column 2: Corresponding PG ID
if exist('allPR','var')~=1
    allPR = cell(0,2);
end

if ~iscell(pg)
    pg = {pg};
end

for i=1:length(pg)    

    if contains(pg{i},'PR')
        continue;
    end
    
    % Get the processing functions in this group.
    sqlquery = ['SELECT PR_ID FROM PG_PR WHERE PG_ID = ''' pg{i} ''';'];
    listPR = fetch(conn, sqlquery);
    listPR = table2MyStruct(listPR);
    listPR = listPR.PR_ID;
    if isempty(listPR)
        listPR = {};
    end
    listPR = [listPR, repmat(pg(i),length(listPR),1)]; % Specifies the group that the PR's are in.
    allPR = [allPR; listPR];  

    % Get the processing groups in this group.
    sqlquery = ['SELECT Child_PG_ID FROM PG_PG WHERE Parent_PG_ID = ''' pg{i} ''';'];
    listPG = fetch(conn, sqlquery);
    listPG = table2MyStruct(listPG);
    listPG = listPG.Child_PG_ID;
    if isempty(listPG)
        listPG = {};
    end    
    for j = 1:length(listPG)
        prsRec = getPRFromPG(listPG{j}, allPR);
        append = [prsRec, repmat(pg{i},length(prsRec), 1)];
        allPR = [allPR; append];
    end
end