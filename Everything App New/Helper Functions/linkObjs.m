function [success, msg]=linkObjs(leftObjs, rightObjs, date)

%% PURPOSE: LINK TWO OBJECTS TOGETHER. INPUTS ARE THE UUID'S TO LINK TOGETHER.
% IF LINKING VR AND PR, THEN THE ORDER MATTERS TO DETERMINE IF INPUT OR
% OUTPUT VARIABLE.
% IF LINKING ANY OTHER OBJECTS, ORDER DOES NOT MATTER.

global conn globalG;

success = true; % Initialize that this is not a duplicate entry.
msg = '';

%% Ensure leftObjs & rightObjs are in the proper format.
if isempty(leftObjs) || isempty(rightObjs)
    return;
end

allTypes = getTypes();

if ischar(leftObjs)
    leftObjs = {leftObjs};    
end

if ischar(rightObjs)
    rightObjs = {rightObjs};
end

if isstruct(leftObjs)
    % When do I need to update the left object as being out of date?
    leftObjs = {leftObjs.UUID};
end

if isstruct(rightObjs)
    % When do I need to update the right object as being out of date?
    rightObjs = {rightObjs.UUID};
end

if length(leftObjs)>1 && length(rightObjs)>1
    error('Either the left or right element must be scalar');
end

% Ensure that there are two lists of equal length.
if length(leftObjs)==1
    leftObjs = repmat(leftObjs,length(rightObjs),1);
end

if length(rightObjs)==1
    rightObjs = repmat(rightObjs,length(leftObjs),1);
end

assert(length(leftObjs)==length(rightObjs));

%% Get the table and column names
tablenames = sqlfind(conn,'');
tablenames = cellstr(tablenames.Table);

[type1] = deText(leftObjs{1});
[type2] = deText(rightObjs{1});
otherTypes = allTypes(~ismember(allTypes,{type1,type2}));
tableIdx = contains(tablenames, type1) & contains(tablenames, type2) & ~contains(tablenames,otherTypes);
if sum(tableIdx)>1
    if isequal(type1,'PR')
        tablename = 'PR_VR';
    elseif isequal(type2,'PR')
        tablename = 'VR_PR';
    end
    tableIdx = ismember(tablenames,tablename);
end
assert(sum(tableIdx)==1);

tablename = tablenames{tableIdx};
tableInfo = sqlfind(conn,tablename);

col1 = char(tableInfo.Columns{1}(1));
col2 = char(tableInfo.Columns{1}(2));
type1 = deText(leftObjs{1});
type2 = deText(rightObjs{1});
% Switch the left and right objects if necessary.
if contains(col1,type2)
    tmpL = leftObjs;
    tmpR = rightObjs;
    leftObjs = tmpR;
    rightObjs = tmpL;
end

%% Link the objects
for i=1:length(leftObjs)
    sqlquery = ['INSERT INTO ' tablename ' (' col1 ', ' col2 ') VALUES ',...
        '(''' leftObjs{i} ''', ''' rightObjs{i} ''');'];
    type1 = deText(leftObjs{i});
    type2 = deText(rightObjs{i});
    assert(contains(col1,type1) && contains(col2, type2)); % Check that things are being put in the proper column.
    
    try
        tmpG = globalG;
        % Edge Table
        NameInCode = {''};
        Subvariable = {''};
        EndNodes = [rightObjs(i) leftObjs(i)]; 
        if all(ismember({type1, type2},{'PR','VR'}))                      
            EndNodes = [leftObjs(i) rightObjs(i)]; 
        end
        % Check that we are never adding any new nodes here, just make new edges.
        assert(all(ismember(EndNodes(:,1),globalG.Nodes.Name)));
        assert(all(ismember(EndNodes(:,2),globalG.Nodes.Name)));
        edgeTable = table(EndNodes, NameInCode, Subvariable);
        tmpG = addedge(tmpG, edgeTable);
        
        % Check that this new edge does not result in a cyclic graph.
        if ~isdag(tmpG)
            success = false;            
            msg = ['Cannot link ' leftObjs{i} ' and ' rightObjs{i} ' because it forms a cyclic graph'];
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