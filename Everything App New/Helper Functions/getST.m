function [st]=getST(uuid)

%% PURPOSE: GET THE SPECIFY TRIALS FOR THE SPECIFIED UUID

[type] = deText(uuid);

st = {};
if ~ismember(type,{'LG','PR'})
    return; % Only logsheets and process functions have specify trials.
end

if isequal(type,'LG')
    tablename = getTableName(type, isInstance(uuid));

    sqlquery = ['SELECT SpecifyTrials FROM ' tablename ' WHERE UUID = ''' uuid ''';'];
    st = fetchQuery(sqlquery);
    st = st.SpecifyTrials;

    if isempty(st) || isequal(st,'NULL')
        st={};
    end
    return;
end

%% PR only.
Current_Analysis = getCurrent('Current_Analysis');
sqlquery = ['SELECT ST_ID FROM PR_ST_AN WHERE PR_ID = ''' uuid ''' AND AN_ID = ''' Current_Analysis ''';'];
t = fetchQuery(sqlquery);

st = t.ST_ID;