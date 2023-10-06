function [listPR_PG_AN, listInclContainer] = getUnorderedList(containerUUID)

%% PURPOSE: RETURN AN UNORDERED LIST OF PROCESSING FUNCTIONS AND THEIR CONTAINERS IN THE SPECIFIED CONTAINER

[type] = deText(containerUUID);

% Get the groups in this container
if isequal(type,'AN')
    sqlquery = ['SELECT PG_ID FROM PG_AN WHERE AN_ID = ''' containerUUID ''';'];
else
    sqlquery = ['SELECT Child_PG_ID FROM PG_PG WHERE Parent_PG_ID = ''' containerUUID ''';'];
end
listPG = fetchQuery(sqlquery);
fldName = fieldnames(listPG);
listPG = listPG.(fldName{1});

% Get the processing functions in this container.
if isequal(type,'AN')
    sqlquery = ['SELECT PR_ID FROM PR_AN WHERE AN_ID = ''' containerUUID ''';'];
else
    sqlquery = ['SELECT PR_ID FROM PR_PG WHERE PG_ID = ''' containerUUID ''';'];
end
listPR = fetchQuery(sqlquery);
listPR = listPR.PR_ID;
if isempty(listPR) && isempty(listPG)    
    listPR_PG_AN = {};
    return;
end

listInclContainer = [listPR; listPG]; % The top level groups & functions in the analysis.
listInclContainer(:,2) = {containerUUID}; % Include the container UUID.
listPR_PG_AN = getPRFromPG(listInclContainer(:,1), listInclContainer); % Get all processing functions in the groups.

% Get the logsheets in this container
if isequal(type,'AN')
    sqlquery = ['SELECT LG_ID FROM LG_AN WHERE AN_ID = ''' containerUUID ''';'];
    t = fetchQuery(sqlquery);
    if isempty(t.LG_ID)
        return;
    end
    if ~iscell(t.LG_ID)
        t.LG_ID = {t.LG_ID};
    end

    % Append the LG & AN to the unordered list.
    listPR_PG_AN = [listPR_PG_AN; [t.LG_ID, repmat({containerUUID}, length(t.LG_ID), 1)]];
end