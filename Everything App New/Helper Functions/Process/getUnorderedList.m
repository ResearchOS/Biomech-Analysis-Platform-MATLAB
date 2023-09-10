function [listPR_PG_AN, listInclContainer] = getUnorderedList(containerUUID)

%% PURPOSE: RETURN AN UNORDERED LIST OF PROCESSING FUNCTIONS AND THEIR CONTAINERS IN THE SPECIFIED CONTAINER

global conn;

[type] = deText(containerUUID);

% Get the groups in this container
if isequal(type,'AN')
    sqlquery = ['SELECT PG_ID FROM AN_PG WHERE AN_ID = ''' containerUUID ''';'];
else
    sqlquery = ['SELECT Child_PG_ID FROM PG_PG WHERE Parent_PG_ID = ''' containerUUID ''';'];
end
listPG = fetch(conn, sqlquery);
listPG = table2MyStruct(listPG);
fldName = fieldnames(listPG);
if isempty(fldName)
    listPG = {};
else
    listPG = listPG.(fldName{1});
end

% Get the processing functions in this container.
if isequal(type,'AN')
    sqlquery = ['SELECT PR_ID FROM AN_PR WHERE AN_ID = ''' containerUUID ''';'];
else
    sqlquery = ['SELECT PR_ID FROM PG_PR WHERE PG_ID = ''' containerUUID ''';'];
end
listPR = fetch(conn, sqlquery);
listPR = table2MyStruct(listPR);
if isempty(fieldnames(listPR))
    listPR = {};
else
    listPR = listPR.PR_ID;
end
if isempty(listPR) && isempty(listPG)    
    listPR_PG_AN = {};
    return;
end

listInclContainer = [listPR; listPG]; % The top level groups & functions in the analysis.
listInclContainer(:,2) = {containerUUID}; % Include the container UUID.
listPR_PG_AN = getPRFromPG(listInclContainer(:,1), listInclContainer); % Get all processing functions in the groups.

% Get the logsheets in this container
if isequal(type,'AN')
    sqlquery = ['SELECT LG_ID FROM AN_LG WHERE AN_ID = ''' containerUUID ''';'];
    t = fetch(conn, sqlquery);
    t = table2MyStruct(t);
    if isempty(fieldnames(t))
        return;
    end
    if isempty(t.LG_ID)
        return;
    end
    if ~iscell(t.LG_ID)
        t.LG_ID = {t.LG_ID};
    end

    % Append the LG & AN to the unordered list.
    listPR_PG_AN = [listPR_PG_AN; [t.LG_ID, repmat({containerUUID}, length(t.LG_ID), 1)]];
end