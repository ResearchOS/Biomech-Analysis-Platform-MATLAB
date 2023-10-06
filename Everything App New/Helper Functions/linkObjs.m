function [success, msg]=linkObjs(leftObjs, rightObjs, date)

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
    tmpStruct = table2MyStruct(tmpTable,'struct');
    assert(all(isUUID(tmpTable.EndNodes(:,1))));
    assert(all(isUUID(tmpTable.EndNodes(:,2))));    
elseif nargin==2
    % With 2 inputs, this is the UUID's of the objects, and it should be
    % converted to a table and then a struct.    
    if isempty(leftObjs) || isempty(rightObjs)
        return;
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
    tmpStruct = table2MyStruct(table(EndNodes),'struct');
    clear leftObjs rightObjs;
end
    

%% Ensure that the struct has all of the column names.
allColNames = {'EndNodes','NameInCode','Subvariable'};
missingColNames = allColNames(~ismember(allColNames,fieldnames(tmpStruct)));
for i=1:length(missingColNames)
    for j=1:length(tmpStruct)
        tmpStruct(j).(missingColNames{i}) = {'NULL'};
    end
end


%% Everything from here down deals with the edgeTable representation of the linkages.
endNodes = [tmpStruct.EndNodes];
rightObjs = endNodes(:,2);
leftObjs = endNodes(:,1);

numLinks = size(endNodes,1);

%% Get the table and column names
tablenamesAll = sqlfind(conn,'');
tablenames = cellstr(tablenamesAll.Table);

%% Ensure that all columns are in the proper order. 
% For all tables except PR_VR and VR_PR, column order is [target, source]
% For PR_VR and VR_PR, column order is [source, target]
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
    tableInfo = tablenamesAll(tableIdx,:);

    col1 = char(tableInfo.Columns{1}(1));
    col2 = char(tableInfo.Columns{1}(2));
    % Switch the left and right objects if necessary.
    if ismember(tablename,{'VR_PR','PR_VR'})
        if contains(col1,targetType)
            tmpStruct(i).EndNodes(1,:) = tmpStruct(i).EndNodes([2 1]);
        end
    else
        if contains(col1,sourceType)    
            tmpStruct(i).EndNodes(1,:) = tmpStruct(i).EndNodes([2 1]);
        end
    end

    sourceType = deText(tmpStruct(i).EndNodes{1});
    targetType = deText(tmpStruct(i).EndNodes{2});
    assert(contains(col1,targetType) && contains(col2, sourceType)); % Check that things are being put in the proper column.

end

%% Link the objects
for i=1:numLinks
    sqlquery = struct2SQL(tablename, tmpStruct(i), 'INSERT');
    leftObj = tmpStruct(i).EndNodes{1}; % Opposite because that's how the tables are.
    rightObj = tmpStruct(i).EndNodes{2};

    try
        tmpG = globalG;
        edgeTable = struct2table(tmpStruct(i));
        % Check that we are never adding any new nodes here, just make new edges.
        assert(all(ismember(edgeTable.EndNodes(:,1),globalG.Nodes.Name)));
        assert(all(ismember(edgeTable.EndNodes(:,2),globalG.Nodes.Name)));
        tmpG = addedge(tmpG, edgeTable);

        % Check that this new edge does not result in a cyclic graph.
        if ~isdag(tmpG)
            success = false;
            msg = ['Cannot link ' leftObj ' and ' rightObj ' because it forms a cyclic graph'];
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