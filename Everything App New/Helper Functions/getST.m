function [st]=getST(uuid)

%% PURPOSE: GET THE SPECIFY TRIALS FOR THE SPECIFIED UUID FROM THE LINKAGE MATRIX.
% UUID is in the right column
global conn;

% st = {};
% disp('ST not implemented yet!');
% return;

[type] = deText(uuid);

st = {};
if ~ismember(type,{'LG','PR'})
    return; % Only logsheets and process functions have specify trials.
end

if isequal(type,'LG')
    disp('ST still not done for logsheets!');
    return;
end

tablename = 'Process_Instances';
sqlquery = ['SELECT SpecifyTrials FROM ' tablename ' WHERE UUID = ''' uuid ''';'];
st = fetch(conn, sqlquery);
st = table2MyStruct(st);

if isempty(fieldnames(st))
    st = {};
    return;
end

st = st.SpecifyTrials;

if isempty(st)
    st={};
end