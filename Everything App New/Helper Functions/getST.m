function [st]=getST(uuid)

%% PURPOSE: GET THE SPECIFY TRIALS FOR THE SPECIFIED UUID FROM THE LINKAGE MATRIX.
% UUID is in the right column

[type, abstractID, instanceID] = deText(uuid);

st = {};
if ~ismember(type,{'LG','PR'})
    return; % Only logsheets and process functions have specify trials.
end

isInstance = true;
if isempty(instanceID)
    isInstance = false;
end

tablename = getTableName(type, isInstance);

sqlquery = ['SELECT SpecifyTrials FROM ' tablename ' WHERE UUID = ''' uuid ''';'];
st = fetchQuery(sqlquery);
st = st.SpecifyTrials;

if isempty(st) || isequal(st,'NULL')
    st={};
end