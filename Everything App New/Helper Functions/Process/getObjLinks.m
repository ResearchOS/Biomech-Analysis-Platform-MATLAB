function [G] = getObjLinks(remTypes)

%% PURPOSE: RETURN A GRAPH WHERE EACH NODE IS AN OBJECT TYPE, AND THE EDGES ARE JUST THE CONNECTIONS BETWEEN THEM.

global conn;

if nargin==0
    remTypes = {};
end

types = getTypes();
alwaysRemTypes = {'PJ','AN','ST','LG'};
types(ismember(types,alwaysRemTypes)) = [];
types(ismember(types,remTypes)) = [];

tablenames = sqlfind(conn, '');
tablenames = tablenames.Table(contains(tablenames.Table,types));

array = {};
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

    sqlquery = ['SELECT ' col1 ', ' col2 ' FROM ' tablename];
    t = fetch(conn, sqlquery);
    t = table2MyStruct(t);
    if isempty(t.(col1))
        t.(col1) = {};
        t.(col2) = {};
    end

    % Flip column order for VR & PR connections because they're in opposite order from other tables' columns.
    if ismember(tablename,{'VR_PR','PR_VR'})
        array = [array; t.(col1), t.(col2)];
    else
        array = [array; t.(col2), t.(col1)];
    end

end

G = digraph(array(:,1),array(:,2));