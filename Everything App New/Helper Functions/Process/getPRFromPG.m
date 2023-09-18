function [allPR] = getPRFromPG(pg, allPR)

%% PURPOSE: GIVEN ONE OR MORE PROCESSING GROUPS, RETURN AN UNORDERED LIST OF ALL THE PROCESSING FUNCTIONS IN THOSE GROUPS.
% Inputs:
%   pg: List of processing groups
%   allPR: List of processing functions (2nd input optional)

% Outputs:
%   pr: List of processing functions
global conn;

% Column 1: PR ID
% Column 2: Corresponding PG ID
if exist('allPR','var')~=1
    allPR = cell(0,2);
end

if isempty(pg)
    allPR = {};
    return;
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
    t = fetch(conn, sqlquery);
    t = table2MyStruct(t);
    if isempty(fieldnames(t))
        t.PR_ID = {};
    end
    if ~iscell(t.PR_ID)
        t.PR_ID = {t.PR_ID};
    end
    listPR = t.PR_ID;
    listPR = [listPR, repmat(pg(i),length(listPR),1)]; % Specifies the group that the PR's are in.
    allPR = [allPR; listPR];  

    % Get the processing groups in this group.
    sqlquery = ['SELECT Child_PG_ID FROM PG_PG WHERE Parent_PG_ID = ''' pg{i} ''';'];
    t = fetch(conn, sqlquery);
    t = table2MyStruct(t);
    if isempty(fieldnames(t))
        t.Child_PG_ID = {};
    end
    if ~iscell(t.Child_PG_ID)    
        t.Child_PG_ID = {t.Child_PG_ID};
    end
    listPG = t.Child_PG_ID;  
    for j = 1:length(listPG)
        prsRec = getPRFromPG(listPG{j}, allPR);
        append = [prsRec, repmat(pg{i},length(prsRec), 1)];
        allPR = [allPR; append];
    end
end