function [] = unlinkObjs(leftObjs, rightObjs)

%% PURPOSE: UNLINK OBJECTS IN THE LINKAGE MATRIX.

global conn globalG;

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
    leftObjs = {leftObjs.UUID};
end

if isstruct(rightObjs)
    rightObjs = {rightObjs.UUID};
end

if length(leftObjs)>1 && length(rightObjs)>1
    error('Either the left or right element must be scalar');
end

if length(leftObjs)>1
    leftObjs(cellfun(@isempty, leftObjs)) = [];
end

if length(rightObjs)>1
    rightObjs(cellfun(@isempty, rightObjs)) = [];
end

% Ensure that there are two lists of equal length.
if length(leftObjs)==1
    leftObjs = repmat(leftObjs,length(rightObjs),1);
end

if length(rightObjs)==1
    rightObjs = repmat(rightObjs,length(leftObjs),1);
end

assert(length(leftObjs)==length(rightObjs));

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
for i=1:length(leftObjs)
    type1 = deText(leftObjs{i});
    type2 = deText(rightObjs{i});
    assert(contains(col1,type1) && contains(col2, type2)); % Check that things are being removed from the proper column.
    sqlquery = ['DELETE FROM ' tablename ' WHERE ' col1 ' = ''' leftObjs{i} ''' AND ' col2 ' = ''' rightObjs{i} ''';'];
    try
        execute(conn, sqlquery);
        tmpG = globalG;
        if ~all(ismember({type1, type2},{'PR','VR'}))
            tmpG = rmedge(tmpG, rightObjs{i}, leftObjs{i});
        else
            tmpG = rmedge(tmpG, leftObjs{i}, rightObjs{i});
        end
        globalG = tmpG;
    catch e
        disp(e.message);
    end
end