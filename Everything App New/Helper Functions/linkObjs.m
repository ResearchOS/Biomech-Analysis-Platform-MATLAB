function [isDupl]=linkObjs(leftObjs, rightObjs, date)

%% PURPOSE: LINK TWO OBJECTS TOGETHER. INPUTS ARE THE STRUCTS THEMSELVES, OR THEIR UUID'S.
% LINKAGE INFORMATION IS STORED IN ITS OWN FILE, UNDER "LINKAGES" IN THE
% COMMON PATH.

allTypes = {'PJ','AN','PG','PR','VR','LG','ST'};

global conn;

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

tablenames = sqlfind(conn,'');
tablenames = cellstr(tablenames.Table);

[type1] = deText(leftObjs{1});
[type2] = deText(rightObjs{1});
otherTypes = allTypes(~ismember(allTypes,{type1,type2}));
tableIdx = contains(tablenames, type1) & contains(tablenames, type2) & ~contains(tablenames,otherTypes);
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
isDupl = false; % Initialize that this is not a duplicate entry.
for i=1:length(leftObjs)
    sqlquery = ['INSERT INTO ' tablename ' (' col1 ', ' col2 ') VALUES ',...
        '(''' leftObjs{i} ''', ''' rightObjs{i} ''');'];
    type1 = deText(leftObjs{i});
    type2 = deText(rightObjs{i});
    assert(contains(col1,type1) && contains(col2, type2)); % Check that things are being put in the proper column.

    undoquery = ['DELETE FROM ' tablename ' WHERE ' col1 ' = ''' leftObjs{i} ''' AND ' col2 ' = ''' rightObjs{i} ''';'];
    try
        execute(conn, sqlquery);
        % CHECK TO MAKE SURE THIS DOES NOT RESULT IN A CYCLIC DIGRAPH
        anUUID = getCurrent('Current_Analysis');
        list = getUnorderedList(anUUID);
        links = loadLinks(list);
        G = linkageToDigraph(links);
        if ~isdag(G)
            isDupl = true;
            execute(conn, undoquery);
            disp(['Cannot link ' leftObjs{i} ' and ' rightObjs{i} ' because it forms a cyclic graph in the current analysis']);
            return;
        end
    catch e
        if ~contains(e.message,'UNIQUE constraint failed')
            error(e);
        end
        disp(['Cannot add duplicate entries to ' tablename]);
        isDupl = true;
        return;
    end
end