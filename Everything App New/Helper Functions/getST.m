function [st]=getST(uuid)

%% PURPOSE: GET THE SPECIFY TRIALS FOR THE SPECIFIED UUID FROM THE LINKAGE MATRIX.
% UUID is in the right column
global conn;

st = {};
disp('ST not implemented yet!');
return;

[type] = deText(uuid);

st = {};
if ~ismember(type,{'LG','PR'})
    return; % Only logsheets and process functions have specify trials.
end

tablename = 'table';
sqlquery = ['SELECT ST_ID FROM ' tablename ' WHERE OBJ_ID = ''' uuid ''';'];
st = fetch(conn, sqlquery);
st = table2MyStruct(st);