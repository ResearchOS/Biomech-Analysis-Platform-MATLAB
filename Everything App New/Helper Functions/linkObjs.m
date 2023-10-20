function [success, msg]=linkObjs(leftObjs, rightObjs, nameInCode)

%% PURPOSE: LINK TWO OBJECTS TOGETHER. INPUTS ARE:
% 1. THE UUID'S TO LINK TOGETHER, OR
% 2. THE EDGETABLE (MAY ALSO INCLUDE OTHER COLUMNS)
% IF LINKING VR AND PR, THEN THE ORDER MATTERS TO DETERMINE IF INPUT OR
% OUTPUT VARIABLE.
% IF LINKING ANY OTHER OBJECTS, ORDER OF LEFT OBJECT AND RIGHT OBJECT DOES NOT MATTER.

global conn globalG;

success = true; % Initialize that this is not a duplicate entry.
msg = '';

%% With one input, this is a table or digraph, and it should be converted to struct
if nargin==1
    tmpTable = leftObjs; clear leftObjs;
    if isa(tmpTable,'digraph')
        tmpTable = tmpTable.Edges;
    end

    assert(isa(tmpTable,'table'));
    try
        testG = digraph(tmpTable); % Make sure it's in the proper format to become a digraph, will throw an error if not.
        clear testG;
    catch
        success = false;
        msg = 'Table not in the proper format for a digraph edgetable';
        return;
    end
    if ~isfield(tmpTable,'NameInCode')
        tmpTable.NameInCode = repmat({'NULL'}, size(tmpTable,1),1);
    end
    if ~isfield(tmpTable,'Subvariable')
        tmpTable.Subvariable = repmat({'NULL'}, size(tmpTable,1),1);
    end
    emptyNameInCodeIdx = cellfun(@isempty, tmpTable.NameInCode);
    emptySubvarIdx = cellfun(@isempty, tmpTable.Subvariable);
    tmpTable.NameInCode(emptyNameInCodeIdx) = repmat({'NULL'},sum(emptyNameInCodeIdx),1);
    tmpTable.Subvariable(emptySubvarIdx) = repmat({'NULL'}, sum(emptySubvarIdx),1);
    edgeStruct = table2MyStruct(tmpTable,'struct');
    assert(all(isUUID(tmpTable.EndNodes(:,1))));
    assert(all(isUUID(tmpTable.EndNodes(:,2))));   
    EndNodes = tmpTable.EndNodes;
elseif nargin==2
    % With 2 inputs, this is the UUID's of the objects, and it should be
    % converted to a table and then a struct.    
    if isempty(leftObjs) || isempty(rightObjs)
        return;
    end  

    if isstruct(leftObjs)
        leftObjs = {leftObjs.UUID};
    end

    if isstruct(rightObjs)
        rightObjs = {rightObjs.UUID};
    end

    if ~iscell(leftObjs)
        leftObjs = {leftObjs};
    end
    if ~iscell(rightObjs)
        rightObjs = {rightObjs};
    end
    
    % Ensure that there are two lists of equal length.
    if length(leftObjs)==1
        leftObjs = repmat(leftObjs,length(rightObjs),1);
    end
    
    if length(rightObjs)==1
        rightObjs = repmat(rightObjs,length(leftObjs),1);
    end
    
    assert(length(leftObjs)==length(rightObjs));
    assert(all(isUUID(leftObjs)));
    assert(all(isUUID(rightObjs)));
    EndNodes(:,1) = leftObjs;
    EndNodes(:,2) = rightObjs;
    edgeStruct = table2MyStruct(table(EndNodes),'struct');
    clear leftObjs rightObjs;
end
    
%% Ensure that the struct has all of the column names.
rightObjs = EndNodes(:,2);
leftObjs = EndNodes(:,1);

numLinks = size(EndNodes,1);

allColNames = {'EndNodes','NameInCode','Subvariable','HeaderName'};
missingColNames = allColNames(~ismember(allColNames,fieldnames(edgeStruct)));
for i=1:length(missingColNames)
    for j=1:length(edgeStruct)
        edgeStruct(j).(missingColNames{i}) = {'NULL'};
    end
end


%% Everything from here down deals with the edgeTable representation of the linkages.

%% Get the table and column names
tablenamesAll = sqlfind(conn,'');
tablenames = cellstr(tablenamesAll.Table);

%% Ensure that all columns are in the proper order. 
% Table name order is [source, target], column order may not agree but
% that doesn't matter.
allTypes = getTypes();
for i=1:numLinks

    %% Identify the table for this object pair.
    [sourceType] = deText(leftObjs{i});
    [targetType] = deText(rightObjs{i});
    otherTypes = allTypes(~ismember(allTypes,{sourceType,targetType}));
    tableIdx = contains(tablenames, sourceType) & contains(tablenames, targetType) & ~contains(tablenames,otherTypes);
    if sum(tableIdx)>1
        if isequal(sourceType,'PR')
            tablename = 'PR_VR';
        elseif isequal(targetType,'PR')
            tablename = 'VR_PR';
        end
        tableIdx = ismember(tablenames,tablename);
    end
    assert(sum(tableIdx)==1);

    tablename = tablenames{tableIdx};    
    tableCols = strsplit(tablename,'_');

    % Switch the left and right objects if necessary.
    if ~isequal(tablename,[sourceType '_' targetType])
        edgeStruct(i).EndNodes(1,:) = edgeStruct(i).EndNodes([2 1]);
    end

    sourceType = deText(edgeStruct(i).EndNodes{1});
    targetType = deText(edgeStruct(i).EndNodes{2});
    assert(contains(tableCols{1},sourceType) && contains(tableCols{2}, targetType)); % Check that things are being put in the proper column.

end

%% Link the objects
for i=1:numLinks

    sourceObj = edgeStruct(i).EndNodes{1}; % Opposite because that's how the tables are.
    targetObj = edgeStruct(i).EndNodes{2};
    sourceType = deText(sourceObj);
    targetType = deText(targetObj);
    tablename = getTableName(sourceType, targetType);

    switch tablename
        case 'VR_PR'
            extraColNames = {'HeaderName'};
        case 'PR_VR'
            extraColNames = {'Subvariable','HeaderName'};
        case 'LG_VR'
            extraColNames = {'NameInCode', 'Subvariable'};
        otherwise
            extraColNames = {'NameInCode','Subvariable','HeaderName'};
    end

    sqlStruct = rmfield(edgeStruct, extraColNames); % The data to be inserted to SQL.
    
    sqlquery = struct2SQL(tablename, sqlStruct(i), 'INSERT');    

    try
        tmpG = globalG;
        edgeTable = struct2table(edgeStruct(i),'AsArray',true);
        % Check that we are never adding any new nodes here, just make new edges.        
        assert(all(ismember(edgeTable.EndNodes(:,1),globalG.Nodes.Name)));
        assert(all(ismember(edgeTable.EndNodes(:,2),globalG.Nodes.Name)));
        tmpG = addedge(tmpG, edgeTable);

        % Check that this new edge does not result in a cyclic graph.
        if ~isdag(tmpG)
            success = false;
            msg = ['Cannot link ' sourceObj ' and ' targetObj ' because it forms a cyclic graph'];
            return;
        else % If there are no cycles, add the link to the SQL database and update the globalG.
            execute(conn, sqlquery);            
            globalG = tmpG;            
        end
    catch e
        if ~contains(e.message,'UNIQUE constraint failed')
            error(e);
        end
        msg = ['Cannot add duplicate entries to ' tablename];
        success = false;
        return;
    end
end