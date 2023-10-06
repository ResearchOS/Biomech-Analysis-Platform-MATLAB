function [G] = getAllObjLinks(remTypes, inclExcl)

%% PURPOSE: RETURN A GRAPH WHERE EACH NODE IS AN OBJECT TYPE, AND THE EDGES ARE JUST THE CONNECTIONS BETWEEN THEM.

global conn globalG;

if nargin==0
    remTypes = {};
end

if nargin<2
    inclExcl = 'excl'; % By default, specify the types to exclude.
end

types = getTypes();

tablenames = sqlfind(conn, '');
tablenames = tablenames.Table;
tablenames(~contains(cellstr(tablenames),types)) = []; % Only the 'types' tables.
tablenames(contains(tablenames,remTypes)) = []; % Only the desired types

%% Get all of the nodes
allTypes = getTypes();
allTypes(contains(allTypes,remTypes)) = [];
Name = {};
OutOfDate = [];
for i=1:length(allTypes)

    type = allTypes{i}; 
    isInstance = true;
    if isequal(type,'ST')
        isInstance = false;
    end
    tablename = getTableName(type, isInstance);
    sqlquery = ['SELECT UUID, OutOfDate FROM ' tablename];
    t = fetchQuery(sqlquery);
    Name = [Name; t.UUID];
    OutOfDate = [OutOfDate; t.OutOfDate];

end

%% Get all of the edges
EndNodes = cell(0,2);
NameInCode = {};
Subvariable = {};
for i=1:length(tablenames)

    tablename = tablenames{i};
    currTypes = strsplit(tablename,'_');
    type1 = currTypes{1};
    type2 = currTypes{2};

    if isequal(type1,type2)
        type1 = ['Parent_' type1];
        type2 = ['Child_' type2];
    end

    col1 = [type1 '_ID'];
    col2 = [type2 '_ID'];

    sqlquery = ['SELECT * FROM ' tablename];
    t = fetchQuery(sqlquery);
    if isempty(t.(col1))
        continue;
    end

    if ~iscell(t.(col1))
        t.(col1) = {t.(col1)};
        t.(col2) = {t.(col2)};
        allCols = fieldnames(t);
        allCols(ismember(allCols,{col1,col2})) = [];
        for j=1:length(allCols)
            t.(allCols{j}) = {t.(allCols{j})};
        end
    end

    EndNodes = [EndNodes; t.(col1), t.(col2)];

    % NameInCode & Subvariable will only be for VR & PR connections. All
    % other object types, this column will just be empty.
    if isfield(t,'NameInCode')
        NameInCode = [NameInCode; t.NameInCode];
    else
        NameInCode = [NameInCode; repmat({''},length(t.(col1)),1)];
    end
    if isfield(t,'Subvariable')
        Subvariable = [Subvariable; t.Subvariable];
    else
        Subvariable = [Subvariable; repmat({''},length(t.(col1)),1)];
    end

end

%% Construct the digraph
nodeTable = table(Name, OutOfDate);
edgeTable = table(EndNodes, NameInCode, Subvariable);

globalG = digraph(edgeTable, nodeTable);
G = globalG;