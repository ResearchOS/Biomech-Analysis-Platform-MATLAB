function [t] = getAssignedVars(uuid, type)

%% PURPOSE: GET THE INPUT OR OUTPUT VARIABLES ASSIGNED TO THIS FUNCTION.

if isequal(type,'Input')
    tablename = 'VR_PR';
elseif isequal(type,'Output')
    tablename = 'PR_VR';
end

sqlquery = ['SELECT VR_ID, NameInCode FROM ' tablename ' WHERE PR_ID = ''' uuid ''';'];
t = fetchQuery(sqlquery);