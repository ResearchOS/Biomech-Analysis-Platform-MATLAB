function [t] = getAssignedVars(uuid, type)

%% PURPOSE: GET THE INPUT OR OUTPUT VARIABLES ASSIGNED TO THIS FUNCTION.

global conn;

if isequal(type,'Input')
    tablename = 'VR_PR';
elseif isequal(type,'Output')
    tablename = 'PR_VR';
end

sqlquery = ['SELECT VR_ID, NameInCode FROM ' tablename ' WHERE PR_ID = ''' uuid ''';'];
t = fetch(conn, sqlquery);
t = table2MyStruct(t);

if isempty(fieldnames(t))
    t.VR_ID = {''};
    t.NameInCode = {''};
    return;
end

if isnumeric(t.VR_ID)
    t.VR_ID = {''};
    t.NameInCode = {''};
end

if ~iscell(t.VR_ID)
    t.VR_ID = {t.VR_ID};
    t.NameInCode = {t.NameInCode};
end